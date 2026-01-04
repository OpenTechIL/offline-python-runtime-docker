# 🏗️ Architecture

This document describes the architectural design and technical decisions behind the Offline Python Runtime Docker project. Covers system components, data flows, security considerations, and future roadmap.

## 🎯 Architecture Overview

### Design Principles
1. **Offline-First**: All functionality works without external network dependencies
2. **Security-Hardened**: Non-root execution, minimal attack surface, SELinux compatible
3. **Enterprise-Ready**: Supports air-gapped deployments, compliance, and monitoring
4. **Developer-Friendly**: Extensible, well-documented, and maintainable codebase
5. **Performance-Optimized**: Efficient resource usage and fast startup times

### High-Level Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                    Enterprise Environment                   │
├─────────────────────────────────────────────────────────────┤
│  Container Orchestration (K8s/Docker Compose)        │
│  ├── Load Balancer / Ingress                           │
│  ├── Monitoring & Logging                                │
│  ├── CI/CD Integration                                   │
│  └── Registry Management                                 │
├─────────────────────────────────────────────────────────────┤
│  Offline Python Runtime Container                        │
│  ├── Application Layer (py-apps/)                       │
│  ├── Python Runtime Environment                           │
│  ├── Database Client Layer                              │
│  └── Security & Compliance Layer                         │
├─────────────────────────────────────────────────────────────┤
│  Data Sources & Sinks                                │
│  ├── Oracle Databases                                   │
│  ├── Enterprise Data Lakes                               │
│  ├── File Systems (NFS, S3-compatible)               │
│  └── Enterprise Services (APIs, Queues)               │
└─────────────────────────────────────────────────────────────┘
```

## 🐳 Container Architecture

### Multi-Layer Container Design
```
┌─────────────────────────────────────────────────────────────┐
│                    Runtime Layer                          │
│  ├── Application Code (user-provided)                   │
│  ├── Application Framework (Flask/FastAPI)            │
│  └── Business Logic                                   │
├─────────────────────────────────────────────────────────────┤
│                    Python Layer                         │
│  ├── Python 3.13 Interpreter                        │
│  ├── Standard Library                                  │
│  ├── User Packages (26 pre-installed)                │
│  └── Package Management (pip, user-space)             │
├─────────────────────────────────────────────────────────────┤
│                   Client Layer                         │
│  ├── Oracle Instant Client 19.29                      │
│  ├── Database Drivers (SQLAlchemy, PyMongo)           │
│  ├── Data Formats (Parquet, Excel, CSV)             │
│  └── Enterprise Libraries (dlt, DuckDB)             │
├─────────────────────────────────────────────────────────────┤
│                   System Layer                         │
│  ├── Debian Trixie Base                                │
│  ├── Oracle Client Dependencies (libaio, etc.)         │
│  ├── Security Hardening                               │
│  └── Performance Optimization                         │
└─────────────────────────────────────────────────────────────┘
```

### Container Filesystem Structure
```
/home/appuser/                    # Application home directory (non-root)
├── py-apps/                   # Application layer
│   ├── main.py                 # Container entry point
│   └── tests/                  # Validation tests
│       ├── test_imports.py       # Package validation
│       └── test_thick_oracle.py  # Oracle client validation
├── .local/                      # User package installation
│   ├── bin/                    # Local executables
│   ├── lib/python3.13/site-packages/  # Installed packages
│   └── share/                 # Shared data
├── data/                       # Application data (mounted)
├── logs/                       # Application logs (mounted)
├── config/                     # Configuration files (mounted)
└── temp/                       # Temporary files
```

## 🗄️ Database Integration Architecture

### Oracle Database Connectivity
```python
# Oracle Client Architecture
class OracleClientManager:
    """Enterprise Oracle database manager"""
    
    def __init__(self):
        self.connection_pool = None
        self.setup_thick_mode()
    
    def setup_thick_mode(self):
        """Setup Oracle thick mode for optimal performance"""
        oracle_path = os.environ["ORACLE_INSTANTCLIENT_PATH"]
        
        # Initialize thick mode client
        oracledb.init_oracle_client(lib_dir=oracle_path)
        
        # Configure connection pool for enterprise use
        self.connection_pool = oracledb.create_pool(
            user=os.environ["ORACLE_USER"],
            password=os.environ["ORACLE_PASSWORD"],
            dsn=os.environ["ORACLE_DSN"],
            min=2,                    # Minimum connections
            max=10,                   # Maximum connections
            increment=2,               # Connection increment
            getmode=oracledb.POOL_GETMODE_NOWAIT,
            sessions=oracledb.POOL_SAMETYPE,
            homogeneous=False
        )
```

### Multi-Database Support
```python
# Abstract Database Interface
class DatabaseManager:
    """Multi-database management interface"""
    
    def __init__(self):
        self.connections = {}
        self.setup_connections()
    
    def setup_connections(self):
        """Setup connections to different databases"""
        # Oracle Database
        self.connections['oracle'] = self.setup_oracle()
        
        # MongoDB (NoSQL)
        self.connections['mongodb'] = self.setup_mongodb()
        
        # SQL databases via SQLAlchemy
        self.connections['sqlserver'] = self.setup_sqlserver()
        self.connections['postgresql'] = self.setup_postgresql()
    
    def execute_query(self, database_type, query, params=None):
        """Unified query execution interface"""
        conn = self.connections.get(database_type)
        if conn:
            return conn.execute(query, params or {})
        else:
            raise ValueError(f"Unsupported database: {database_type}")
```

## 📊 Data Processing Architecture

### ETL Pipeline Design
```python
# Enterprise ETL Architecture
class ETLPipeline:
    """Enterprise-grade ETL pipeline"""
    
    def __init__(self):
        self.extractors = {}
        self.transformers = {}
        self.loaders = {}
        self.setup_pipeline_components()
    
    def setup_pipeline_components(self):
        """Setup extract, transform, and load components"""
        # Extractors for different data sources
        self.extractors = {
            'oracle': OracleExtractor(),
            'mongodb': MongoExtractor(),
            'file': FileExtractor(),
            'api': APIExtractor()
        }
        
        # Transformers for data processing
        self.transformers = {
            'validation': ValidationTransformer(),
            'cleansing': DataCleansingTransformer(),
            'enrichment': DataEnrichmentTransformer(),
            'aggregation': AggregationTransformer()
        }
        
        # Loaders for different targets
        self.loaders = {
            'oracle': OracleLoader(),
            'mongodb': MongoLoader(),
            'file': FileLoader(),
            'api': APILoader()
        }
    
    def execute_pipeline(self, config):
        """Execute complete ETL pipeline"""
        # Extract phase
        raw_data = self.extract_data(config['extractors'])
        
        # Transform phase
        transformed_data = self.transform_data(raw_data, config['transformers'])
        
        # Load phase
        self.load_data(transformed_data, config['loaders'])
        
        return self.generate_report(raw_data, transformed_data)
```

### High-Performance Analytics with DuckDB
```python
# DuckDB Integration Architecture
class AnalyticsEngine:
    """High-performance analytics engine with DuckDB"""
    
    def __init__(self):
        self.duckdb_conn = duckdb.connect(':memory:')
        self.data_sources = {}
    
    def register_data_source(self, name, dataframe):
        """Register DataFrame for SQL analysis"""
        self.data_sources[name] = dataframe
        self.duckdb_conn.register(name, dataframe)
    
    def execute_analytics(self, query):
        """Execute complex analytics query"""
        result = self.duckdb_conn.execute(query).fetchdf()
        return result
    
    def optimized_aggregation(self, data_source, group_by, aggregations):
        """Optimized aggregation with DuckDB"""
        query = f"""
        SELECT 
            {group_by},
            {', '.join(aggregations)}
        FROM {data_source}
        GROUP BY {group_by}
        """
        return self.execute_analytics(query)
```

## 🔐 Security Architecture

### Multi-Layer Security
```
┌─────────────────────────────────────────────────────────────┐
│                   Security Layers                        │
├─────────────────────────────────────────────────────────────┤
│  Application Security                                  │
│  ├── Input Validation                                  │
│  ├── SQL Injection Prevention                          │
│  ├── Authentication & Authorization                    │
│  └── Secure Configuration Management                   │
├─────────────────────────────────────────────────────────────┤
│  Container Security                                   │
│  ├── Non-root User (UID/GID 1000)                  │
│  ├── Read-only Filesystem (where possible)             │
│  ├── Capability Dropping                              │
│  ├── SELinux Context Support                          │
│  └── Minimal Attack Surface                           │
├─────────────────────────────────────────────────────────────┤
│  Network Security                                    │
│  ├── Air-gapped Deployment Support                    │
│  ├── Private Registry Integration                     │
│  ├── Network Policy Enforcement                       │
│  └── Secure Communication Protocols                  │
├─────────────────────────────────────────────────────────────┤
│  Data Security                                      │
│  ├── Encryption at Rest                              │
│  ├── Encryption in Transit                          │
│  ├── Data Masking & Anonymization                  │
│  └── Audit Logging                                 │
└─────────────────────────────────────────────────────────────┘
```

### Security Implementation
```python
# Security Manager
class SecurityManager:
    """Enterprise security management"""
    
    def __init__(self):
        self.security_context = self.setup_security_context()
        self.audit_logger = self.setup_audit_logging()
    
    def setup_security_context(self):
        """Setup container security context"""
        return {
            'user_id': 1000,              # Non-root user
            'group_id': 1000,             # Non-root group
            'capabilities': [],             # Drop all capabilities
            'selinux_context': 'container_runtime_t',
            'read_only_fs': True,          # Read-only filesystem
            'no_new_privileges': True      # No privilege escalation
        }
    
    def validate_input(self, user_input, input_type):
        """Validate user inputs against injection attacks"""
        validators = {
            'sql': self.validate_sql_input,
            'file_path': self.validate_file_path,
            'command': self.validate_command
        }
        
        validator = validators.get(input_type)
        if validator:
            return validator(user_input)
        else:
            raise ValueError(f"Unknown input type: {input_type}")
    
    def audit_action(self, action, user, resource, result):
        """Log all sensitive actions for audit"""
        audit_record = {
            'timestamp': datetime.utcnow().isoformat(),
            'action': action,
            'user': user,
            'resource': resource,
            'result': result,
            'container_id': os.environ.get('HOSTNAME', 'unknown')
        }
        self.audit_logger.info(audit_record)
```

## 🚀 Performance Architecture

### Resource Optimization
```python
# Performance Manager
class PerformanceManager:
    """Container performance optimization"""
    
    def __init__(self):
        self.memory_pool = MemoryPool()
        self.thread_pool = ThreadPool(max_workers=4)
        self.cache_manager = CacheManager()
    
    def optimize_memory_usage(self):
        """Optimize memory usage for containerized environment"""
        # Use memory-efficient data types
        dtype_optimizations = {
            'int64': 'int32',
            'float64': 'float32',
            'object': 'category'  # For low-cardinality strings
        }
        
        return dtype_optimizations
    
    def batch_processing(self, data, batch_size=10000):
        """Process data in batches to limit memory usage"""
        for i in range(0, len(data), batch_size):
            batch = data[i:i+batch_size]
            yield batch
    
    def connection_pooling(self, connection_string):
        """Implement connection pooling for database operations"""
        return {
            'min_connections': 2,
            'max_connections': min(10, os.cpu_count()),
            'connection_timeout': 30,
            'idle_timeout': 300,
            'max_lifetime': 3600
        }
```

### Caching Strategy
```python
# Multi-Level Caching
class CacheManager:
    """Enterprise caching strategy"""
    
    def __init__(self):
        self.l1_cache = {}          # Memory cache
        self.l2_cache = CacheLRU(maxsize=1000)  # LRU cache
        self.persistent_cache = self.setup_persistent_cache()
    
    def get(self, key):
        """Get value with multi-level cache lookup"""
        # Level 1: Memory cache
        if key in self.l1_cache:
            return self.l1_cache[key]
        
        # Level 2: LRU cache
        if key in self.l2_cache:
            value = self.l2_cache[key]
            self.l1_cache[key] = value  # Promote to L1
            return value
        
        # Level 3: Persistent cache
        value = self.persistent_cache.get(key)
        if value:
            self.l2_cache[key] = value  # Promote to L2
            return value
        
        return None
    
    def set(self, key, value, ttl=3600):
        """Set value with multi-level cache"""
        self.l1_cache[key] = value
        self.l2_cache[key] = value
        self.persistent_cache.set(key, value, ttl)
```

## 🌐 Deployment Architecture

### Enterprise Deployment Patterns
```
┌─────────────────────────────────────────────────────────────┐
│                Enterprise Cluster                      │
├─────────────────────────────────────────────────────────────┤
│  Load Balancer Layer                                   │
│  ├── External Load Balancer                            │
│  ├── Ingress Controller                                │
│  └── SSL Termination                                 │
├─────────────────────────────────────────────────────────────┤
│  Application Layer                                    │
│  ├── Multiple Container Replicas                       │
│  ├── Auto-scaling                                    │
│  ├── Health Checks                                   │
│  └── Rolling Updates                                │
├─────────────────────────────────────────────────────────────┤
│  Data Layer                                           │
│  ├── Primary Database (Oracle)                        │
│  ├── Cache Layer (Redis/Memcached)                   │
│  ├── File Storage (NFS/Object Storage)              │
│  └── Backup Storage                                 │
├─────────────────────────────────────────────────────────────┤
│  Monitoring & Observability                           │
│  ├── Metrics Collection (Prometheus)                  │
│  ├── Logging (ELK Stack)                           │
│  ├── Tracing (Jaeger)                              │
│  └── Alerting (AlertManager)                       │
└─────────────────────────────────────────────────────────────┘
```

### Kubernetes Deployment Architecture
```yaml
# Deployment Architecture Components
apiVersion: apps/v1
kind: Deployment
metadata:
  name: python-runtime-enterprise
spec:
  # High availability with 3 replicas
  replicas: 3
  
  # Rolling update strategy
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1        # One extra pod during update
      maxUnavailable: 0   # No downtime during update
  
  # Pod template
  template:
    metadata:
      labels:
        app: python-runtime
        version: v1.0.0
      annotations:
        # Monitoring annotations
        prometheus.io/scrape: "true"
        prometheus.io/port: "8000"
        prometheus.io/path: "/metrics"
        
    spec:
      # Security context
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        runAsGroup: 1000
        fsGroup: 1000
        seccompProfile:
          type: RuntimeDefault
      
      # Container definition
      containers:
      - name: python-runtime
        image: registry.company.com/offline-python-runtime:enterprise
        resources:
          # Resource requests and limits
          requests:
            memory: "2Gi"
            cpu: "1000m"
          limits:
            memory: "4Gi"
            cpu: "2000m"
        
        # Health checks
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 5
```

## 📊 Monitoring & Observability

### Metrics Architecture
```python
# Metrics Collection
class MetricsCollector:
    """Enterprise metrics collection"""
    
    def __init__(self):
        self.prometheus_client = PrometheusClient()
        self.metrics = self.setup_metrics()
    
    def setup_metrics(self):
        """Setup application metrics"""
        return {
            'container_info': Gauge(
                'python_runtime_container_info',
                'Container information',
                ['version', 'build_date']
            ),
            'package_imports': Counter(
                'python_runtime_package_imports_total',
                'Total package imports',
                ['package_name']
            ),
            'oracle_connections': Gauge(
                'python_runtime_oracle_connections_active',
                'Active Oracle connections'
            ),
            'processing_duration': Histogram(
                'python_runtime_processing_duration_seconds',
                'Processing duration',
                ['operation_type']
            ),
            'memory_usage': Gauge(
                'python_runtime_memory_usage_bytes',
                'Memory usage in bytes'
            )
        }
    
    def record_metric(self, metric_name, value, labels=None):
        """Record metric with labels"""
        metric = self.metrics.get(metric_name)
        if metric:
            metric.labels(**(labels or {})).set(value)
```

### Logging Architecture
```python
# Structured Logging
class StructuredLogger:
    """Enterprise structured logging"""
    
    def __init__(self):
        self.logger = logging.getLogger('python_runtime')
        self.setup_logger()
    
    def setup_logger(self):
        """Setup structured logging with JSON format"""
        handler = logging.StreamHandler()
        formatter = JsonFormatter()
        handler.setFormatter(formatter)
        self.logger.addHandler(handler)
        self.logger.setLevel(logging.INFO)
    
    def log_structured(self, level, message, **kwargs):
        """Log structured message with additional context"""
        log_record = {
            'timestamp': datetime.utcnow().isoformat(),
            'level': level,
            'message': message,
            'container_id': os.environ.get('HOSTNAME'),
            'app_name': 'offline-python-runtime',
            'version': '1.0.0',
            **kwargs
        }
        
        getattr(self.logger, level.lower())(json.dumps(log_record))
```

## 🔮 Future Architecture Roadmap

### Version 2.0 Features
```
🚀 Enhanced Architecture (Roadmap)
├── 🔧 Core Improvements
│   ├── Multi-Stage Build Optimization
│   ├── Container Image Size Reduction
│   ├── Startup Time Optimization
│   └── Memory Efficiency Improvements
├── 📊 Data Processing Enhancements
│   ├── Streaming Data Support
│   ├── Real-time Analytics
│   ├── Machine Learning Integration
│   └── Advanced ETL Patterns
├── 🗄️ Database Expansions
│   ├── Additional Database Drivers
│   ├── Connection Pool Optimization
│   ├── Database Migration Tools
│   └── Data Lineage Tracking
├── 🔐 Security Enhancements
│   ├── Role-Based Access Control
│   ├── Advanced Encryption Options
│   ├── Compliance Reporting
│   └── Security Scanning Integration
├── 🌐 Deployment Improvements
│   ├── Helm Chart Support
│   ├── Terraform Modules
│   ├── GitOps Integration
│   └── Multi-Cloud Support
└── 📈 Observability Enhancements
    ├── Advanced Metrics
    ├── Distributed Tracing
    ├── Log Aggregation
    └── Performance Profiling
```

### Technology Considerations
- **Base Image**: Consider Alpine Linux for smaller footprint
- **Package Management**: Explore Poetry or pip-tools for dependency management
- **Runtime**: Consider PyPy for performance-critical workloads
- **Security**: Implement AppArmor profiles in addition to SELinux
- **Monitoring**: Add OpenTelemetry support for distributed tracing

## 📞 Architecture Decision Records (ADRs)

### ADR-001: Oracle Thick Mode Decision
**Status**: Accepted  
**Context**: Oracle database connectivity required for enterprise customers  
**Decision**: Use Oracle Instant Client with thick mode support  
**Consequences**: Larger image size but better performance and feature support  

### ADR-002: Non-Root User Decision  
**Status**: Accepted  
**Context**: Security requirements for enterprise deployment  
**Decision**: Run container as non-root user (UID 1000)  
**Consequences**: Enhanced security, but requires volume permission handling  

### ADR-003: Python Version Selection  
**Status**: Accepted  
**Context**: Balance between stability and modern features  
**Decision**: Use Python 3.13 (latest stable)  
**Consequences**: Modern features, good package compatibility  

## 📚 References

- **📖 Configuration**: [Configuration Guide](../user/configuration.md)
- **👨‍💻 Development**: [Development Setup](setup.md)
- **🧪 Testing**: [Testing Guide](testing.md)
- **🏢 Deployment**: [Enterprise Deployment](../user/enterprise-deployment.md)

---

**🏗️ Architecture designed for enterprise scale, security, and maintainability!**