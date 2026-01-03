# 📦 Pre-installed Packages

This document lists all Python packages pre-installed in Offline Python Runtime Docker container, organized by category with version information and use cases.

## 🗂️ Package Categories

### 📊 Data Science & Analytics
| Package | Version | Description | Use Cases |
|----------|----------|-------------|------------|
| **pandas** | Latest | Data manipulation and analysis | Data cleaning, transformation, analysis |
| **numpy** | Latest | Numerical computing | Scientific computing, array operations |
| **scikit-learn** | Latest | Machine learning library | Predictive modeling, data mining |
| **matplotlib** | Latest | Data visualization | Charts, plots, graphs |
| **scipy** | Latest | Scientific computing | Optimization, signal processing |

### 🗄️ Database Connectivity
| Package | Version | Description | Use Cases |
|----------|----------|-------------|------------|
| **oracledb** | Latest | Oracle database driver | Oracle database connectivity |
| **sqlalchemy** | Latest | SQL toolkit and ORM | Multiple SQL database support |
| **pymongo** | Latest | MongoDB driver | NoSQL database operations |
| **pyodbc** | Latest | ODBC database driver | Generic database connectivity |
| **mssql-python** | Latest | Microsoft SQL Server driver | SQL Server connectivity |

### 📈 Data Processing & ETL
| Package | Version | Description | Use Cases |
|----------|----------|-------------|------------|
| **duckdb** | Latest | In-process analytical database | High-performance analytics |
| **dlt** | Latest | Data loading tool | ETL pipeline orchestration |
| **pyarrow** | Latest | Columnar data format | Efficient data interchange |
| **openpyxl** | Latest | Excel file handling | Excel file read/write operations |
| **tabulate** | Latest | Table formatting | Data presentation, CLI output |
| **pyreadstat** | Latest | Statistical data files | SAS, SPSS file formats |

### 🌐 Web & Networking
| Package | Version | Description | Use Cases |
|----------|----------|-------------|------------|
| **requests** | Latest | HTTP library | API calls, web requests |
| **httpx** | Latest | Async HTTP client | Modern async HTTP operations |
| **urllib3** | Latest | URL handling library | HTTP connection pooling |

### 🔐 Security & Validation
| Package | Version | Description | Use Cases |
|----------|----------|-------------|------------|
| **cryptography** | Latest | Cryptographic recipes | Data encryption, security |
| **pydantic** | Latest | Data validation | Input validation, settings |

### 🛠️ Development & Testing
| Package | Version | Description | Use Cases |
|----------|----------|-------------|------------|
| **pytest** | Latest | Testing framework | Unit testing, integration tests |
| **ipykernel** | Latest | Jupyter kernel | Notebook development, debugging |

### ⚙️ Configuration & Environment
| Package | Version | Description | Use Cases |
|----------|----------|-------------|------------|
| **python-dotenv** | Latest | Environment variable management | Configuration management |

## 📋 Complete Package List

```python
# Get package information in container
podman run -it offline-python-runtime:latest python -c "
import pkg_resources
import sys

print('🐍 Python Version:', sys.version)
print('\n📦 Installed Packages:')

packages = [d for d in pkg_resources.working_set]
packages.sort(key=lambda x: x.project_name.lower())

for pkg in packages:
    version = pkg.version if hasattr(pkg, 'version') else 'Unknown'
    print(f'  {pkg.project_name:<25} {version}')

print(f'\n📊 Total packages: {len(packages)}')
"
```

## 🔍 Package Usage Examples

### Data Science Workflow
```python
# Data science with pre-installed packages
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier

# Generate sample data
data = pd.DataFrame({
    'feature_1': np.random.randn(1000),
    'feature_2': np.random.randn(1000),
    'target': np.random.choice([0, 1], 1000)
})

# Machine learning workflow
X = data[['feature_1', 'feature_2']]
y = data['target']

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

model = RandomForestClassifier(n_estimators=100, random_state=42)
model.fit(X_train, y_train)

# Visualization
plt.figure(figsize=(10, 6))
plt.scatter(X_test['feature_1'], X_test['feature_2'], c=y_test, alpha=0.6)
plt.title('Classification Results')
plt.xlabel('Feature 1')
plt.ylabel('Feature 2')
plt.colorbar()
plt.show()
```

### Database Integration
```python
# Multi-database example
import pandas as pd
from sqlalchemy import create_engine
import pymongo
import oracledb

# Oracle connection
def connect_oracle():
    oracle_engine = create_engine('oracle://user:password@host:1521/service')
    df = pd.read_sql('SELECT * FROM table_name', oracle_engine)
    return df

# MongoDB connection
def connect_mongodb():
    client = pymongo.MongoClient('mongodb://localhost:27017/')
    db = client['database_name']
    collection = db['collection_name']
    data = list(collection.find({}))
    return pd.DataFrame(data)

# Universal data processor
class DataProcessor:
    def __init__(self):
        self.oracle_conn = None
        self.mongodb_conn = None
    
    def process_all_sources(self):
        oracle_data = self.get_oracle_data()
        mongo_data = self.get_mongodb_data()
        
        # Combine and process
        combined_data = pd.concat([oracle_data, mongo_data], ignore_index=True)
        return combined_data
```

### ETL Pipeline
```python
# Enterprise ETL with dlt and DuckDB
import dlt
import duckdb
import pandas as pd

@dlt.source
def oracle_source():
    """Dlt source for Oracle data"""
    # Connect to Oracle and extract data
    query = "SELECT * FROM source_table WHERE updated_date > '{start_date}'"
    # Implementation would connect to Oracle
    return [{"data": "sample_row_1"}, {"data": "sample_row_2"}]

@dlt.resource
def processed_data():
    """Transform data with DuckDB"""
    # Get raw data from source
    raw_data = oracle_source()
    
    # Process with DuckDB
    conn = duckdb.connect(':memory:')
    df = pd.DataFrame(raw_data)
    conn.register('raw_data', df)
    
    # Transform
    result = conn.execute("""
        SELECT 
            data,
            LENGTH(data) as data_length,
            'processed' as status
        FROM raw_data
    """).fetchdf()
    
    return result.to_dict('records')

@dlt.destination
def local_file_system(data):
    """Load to local file system"""
    df = pd.DataFrame(data)
    df.to_csv('/home/appuser/output/processed_data.csv', index=False)
    return len(df)

# ETL Pipeline
pipeline = dlt.pipeline(
    pipeline_name="oracle_etl",
    destination=local_file_system
)

# Run pipeline
pipeline.run(oracle_source() | processed_data())
```

## 🔧 Package Management

### Check Package Updates
```python
# Check for available updates
import subprocess
import json

def check_updates():
    """Check for package updates"""
    packages = ['pandas', 'numpy', 'oracledb', 'scikit-learn']
    
    for package in packages:
        try:
            result = subprocess.run(
                ['pip', 'index', 'versions', package],
                capture_output=True, text=True
            )
            if result.returncode == 0:
                versions = result.stdout.strip().split('\n')
                if len(versions) > 1:
                    latest = versions[-1]
                    print(f"🔄 {package}: Update available - {latest}")
                else:
                    print(f"✅ {package}: Up to date")
        except Exception as e:
            print(f"❌ {package}: Error checking updates - {e}")
```

### Install Additional Packages
```bash
# Install packages in running container
podman exec -it python-runtime-container pip install --user <package-name>

# Install from requirements file
podman exec -it python-runtime-container pip install --user -r requirements.txt

# Install with specific version
podman exec -it python-runtime-container pip install --user <package>==<version>

# Install development packages
podman exec -it python-runtime-container pip install --user jupyter scipy seaborn
```

### Virtual Environments in Container
```python
# Create virtual environment in container
import subprocess
import os

def create_virtual_env(env_name):
    """Create Python virtual environment"""
    venv_path = f"/home/appuser/venvs/{env_name}"
    os.makedirs(os.path.dirname(venv_path), exist_ok=True)
    
    subprocess.run(['python', '-m', 'venv', venv_path])
    print(f"✅ Virtual environment created: {venv_path}")
    
    # Activate script
    activate_cmd = f"source {venv_path}/bin/activate"
    print(f"🔄 Activate with: {activate_cmd}")

# Usage
create_virtual_env("project_env")
```

## 📊 Performance Benchmarks

### Package Import Performance
```python
# Benchmark package imports
import time
import importlib

def benchmark_imports():
    """Benchmark package import times"""
    packages = [
        'pandas', 'numpy', 'matplotlib', 'sklearn',
        'oracledb', 'sqlalchemy', 'pymongo', 'duckdb'
    ]
    
    import_times = {}
    
    for package in packages:
        start_time = time.time()
        try:
            importlib.import_module(package)
            end_time = time.time()
            import_times[package] = end_time - start_time
        except ImportError:
            import_times[package] = None
    
    # Sort by import time
    sorted_times = sorted(import_times.items(), key=lambda x: x[1] or float('inf'))
    
    print("📊 Package Import Performance:")
    for package, import_time in sorted_times:
        if import_time:
            print(f"  {package:<15} {import_time:.3f}s")
        else:
            print(f"  {package:<15} ❌ Failed")
    
    return import_times

# Run benchmark
benchmark_imports()
```

### Memory Usage by Package
```python
# Memory usage analysis
import psutil
import os

def analyze_memory_usage():
    """Analyze memory usage by package"""
    process = psutil.Process()
    
    # Baseline memory
    baseline_memory = process.memory_info().rss
    
    packages_and_imports = [
        ('pandas', 'import pandas as pd'),
        ('numpy', 'import numpy as np'),
        ('scipy', 'import scipy'),
        ('sklearn', 'from sklearn import datasets')
    ]
    
    memory_usage = {}
    
    for package_name, import_statement in packages_and_imports:
        # Import package
        exec(import_statement)
        
        # Measure memory
        current_memory = process.memory_info().rss
        package_memory = current_memory - baseline_memory
        
        memory_usage[package_name] = package_memory
        baseline_memory = current_memory
    
    print("💾 Memory Usage by Package:")
    for package, memory in sorted(memory_usage.items(), key=lambda x: x[1], reverse=True):
        print(f"  {package:<15} {memory / 1024 / 1024:.2f} MB")
    
    return memory_usage
```

## 🚨 Common Issues

### Package Conflicts
```bash
# Check for package conflicts
podman run -it offline-python-runtime:latest python -c "
import pkg_resources
import warnings

conflicts = []
installed = {d.key: d.version for d in pkg_resources.working_set}

for dist in pkg_resources.working_set:
    for req in dist.requires():
        if req.key not in installed:
            conflicts.append(f'{dist.key} requires {req.key} but it is not installed')

if conflicts:
    print('❌ Package conflicts found:')
    for conflict in conflicts:
        print(f'  {conflict}')
else:
    print('✅ No package conflicts detected')
"
```

### Version Compatibility
```bash
# Check Python 3.13 compatibility
podman run -it offline-python-runtime:latest python -c "
import sys
import warnings

print(f'🐍 Python Version: {sys.version}')
print(f'📦 Number of installed packages: {len(__import__(\"pkg_resources\").working_set)}')

# Check for known compatibility issues
known_issues = {
    'pandas': 'Some deprecated features may be removed',
    'scikit-learn': 'API changes in recent versions',
    'oracledb': 'New thin/thick mode options'
}

for package, issue in known_issues.items():
    try:
        __import__(package)
        print(f'⚠️ {package}: {issue}')
    except ImportError:
        print(f'❌ {package}: Not installed')
"
```

## 📚 Package Documentation

### Quick Reference Commands
```bash
# Get package help
podman exec -it python-runtime-container python -c "
import pandas as pd
help(pd.read_csv)

# Get package version
podman exec -it python-runtime-container python -c "
import oracledb
print(f'oracledb version: {oracledb.__version__}')
"

# List package contents
podman exec -it python-runtime-container python -c "
import numpy as np
print('NumPy functions:')
print([attr for attr in dir(np) if not attr.startswith('_')])
"
```

### Common Import Patterns
```python
# Enterprise import patterns
import os
import sys
from pathlib import Path

# Data science imports
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.ensemble import RandomForestClassifier

# Database imports
import oracledb
import pymongo
from sqlalchemy import create_engine

# Data processing imports
import duckdb
import pyarrow
import dlt

# Security and validation
from cryptography.fernet import Fernet
from pydantic import BaseModel

# Web and API imports
import requests
import httpx

# Development and testing
import pytest
from ipykernel import kernelapp as app

# Configuration
from dotenv import load_dotenv
```

## 📞 Getting Help

### Package Support Resources
- **📖 Official Documentation**: [Python Package Index](https://pypi.org/)
- **🐛 Issue Tracking**: [GitHub Issues](https://github.com/opentechil/offline-python-runtime-docker/issues)
- **💬 Community Support**: [GitHub Discussions](https://github.com/opentechil/offline-python-runtime-docker/discussions)
- **📚 Reference**: [API Documentation](api.md)

### Troubleshooting Package Issues
- **Import errors**: Check [Troubleshooting Guide](../user/troubleshooting.md)
- **Version conflicts**: Use virtual environments within container
- **Memory issues**: Monitor with built-in performance tools
- **Oracle connectivity**: Ensure ORACLE_INSTANTCLIENT_PATH is set correctly

---

**📦 All 26 enterprise packages pre-installed and ready for production use!**