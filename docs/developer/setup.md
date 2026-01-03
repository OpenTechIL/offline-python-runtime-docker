# 🛠️ Development Setup

This guide helps you set up a development environment for contributing to Offline Python Runtime Docker project. Covers local development, testing, and contribution workflow.

## 🎯 Prerequisites

### System Requirements
- **Docker 20.10+** or **Podman 3.0+**
- **Git 2.25+** for version control
- **Python 3.8+** (optional, for local testing)
- **Make** (recommended for build automation)
- **Node.js 16+** (optional, for documentation)

### Development Tools
```bash
# Install development dependencies (Ubuntu/Debian)
sudo apt-get update
sudo apt-get install -y git make curl

# Install Python development tools
pip3 install --user pre-commit black flake8 mypy

# Install development container tools (optional)
curl -fsSL https://get.docker.com | sh
# or
curl -fsSL https://podman.io/get-podman.sh | sh
```

## 🚀 Quick Development Setup

### Step 1: Clone Repository
```bash
# Clone the repository
git clone https://github.com/opentechil/offline-python-runtime-docker.git
cd offline-python-runtime-docker

# Switch to development branch
git checkout develop
git pull origin develop
```

### Step 2: Setup Development Environment
```bash
# Create development configuration
cat > .env.development << 'EOF'
# Development environment
APP_ENV=development
DEBUG=true
LOG_LEVEL=DEBUG
PYTHONWARNINGS=default

# Development paths
PYTHONPATH=/home/appuser/py-apps:/home/appuser/dev-apps
DEV_MODE=true
EOF

# Create development directories
mkdir -p dev-apps/{tests,examples,scripts}
mkdir -p dev-data/{input,output,temp}
mkdir -p dev-logs
```

### Step 3: Build Development Container
```bash
# Build development image with optimizations
podman build . -t offline-python-runtime:dev

# Verify build
podman run -it offline-python-runtime:dev python -c "
import pandas as pd
import oracledb
print('✅ Development container built successfully')
print(f'🐍 Pandas {pd.__version__}')
print(f'🗄️ Oracle {oracledb.__version__}')
"
```

## 🔧 Development Workflow

### Local Development with Volume Mounts
```bash
# Development with live code mounting
podman run -it \
           --name dev-python-runtime \
           --rm \
           -v $(pwd)/py-apps:/home/appuser/py-apps:Z \
           -v $(pwd)/dev-apps:/home/appuser/dev-apps:Z \
           -v $(pwd)/dev-data:/home/appuser/dev-data:Z \
           -v $(pwd)/dev-logs:/home/appuser/dev-logs:Z \
           --env-file .env.development \
           -p 8000:8000 \
           -p 5000:5000 \
           offline-python-runtime:dev \
           bash

# Inside container - start development shell
cd /home/appuser/py-apps
python -m pytest tests/ -v --tb=short
```

### Development with Hot Reload
```bash
# Create development script
cat > dev-run.sh << 'EOF'
#!/bin/bash
# Development runner with hot reload

CONTAINER_NAME="dev-python-runtime"
PROJECT_ROOT=$(pwd)

# Stop existing container if running
podman stop $CONTAINER_NAME 2>/dev/null || true
podman rm $CONTAINER_NAME 2>/dev/null || true

# Start development container
podman run -it -d \
           --name $CONTAINER_NAME \
           -v $PROJECT_ROOT/py-apps:/home/appuser/py-apps:Z \
           -v $PROJECT_ROOT/dev-apps:/home/appuser/dev-apps:Z \
           -v $PROJECT_ROOT/dev-data:/home/appuser/dev-data:Z \
           --env-file $PROJECT_ROOT/.env.development \
           -p 8000:8000 \
           -p 5678:5678 \
           offline-python-runtime:dev \
           bash -c "cd /home/appuser/py-apps && python -m debugpy --listen 0.0.0.0:5678 --wait-for-client main.py"

echo "🚀 Development container started"
echo "🔗 Debug server: localhost:5678"
echo "🌐 Web app: http://localhost:8000"
echo "📋 Container name: $CONTAINER_NAME"
EOF

chmod +x dev-run.sh
./dev-run.sh
```

## 🧪 Testing

### Running Tests
```bash
# Run all tests
podman run -it \
           -v $(pwd)/py-apps:/home/appuser/py-apps:Z \
           offline-python-runtime:dev \
           python -m pytest /home/appuser/py-apps/tests/ -v

# Run specific test file
podman run -it \
           -v $(pwd)/py-apps:/home/appuser/py-apps:Z \
           offline-python-runtime:dev \
           python -m pytest /home/appuser/py-apps/tests/test_imports.py -v

# Run with coverage
podman run -it \
           -v $(pwd)/py-apps:/home/appuser/py-apps:Z \
           offline-python-runtime:dev \
           python -m pytest /home/appuser/py-apps/tests/ --cov=/home/appuser/py-apps --cov-report=term-missing
```

### Creating New Tests
```bash
# Create test file structure
mkdir -p py-apps/tests/{unit,integration,performance}

# Example unit test
cat > py-apps/tests/unit/test_new_feature.py << 'EOF'
import pytest
import pandas as pd
import numpy as np

class TestNewFeature:
    """Test suite for new functionality"""
    
    def setup_method(self):
        """Setup for each test method"""
        self.test_data = pd.DataFrame({
            'id': range(10),
            'value': np.random.randn(10)
        })
    
    def test_data_processing(self):
        """Test data processing functionality"""
        assert len(self.test_data) == 10
        assert 'value' in self.test_data.columns
        assert self.test_data['value'].dtype == 'float64'
    
    def test_calculations(self):
        """Test calculation accuracy"""
        result = self.test_data['value'].mean()
        assert isinstance(result, (int, float))
        assert not np.isnan(result)
    
    def teardown_method(self):
        """Cleanup after each test method"""
        del self.test_data

if __name__ == "__main__":
    pytest.main([__file__])
EOF

# Run the new test
podman run -it \
           -v $(pwd)/py-apps:/home/appuser/py-apps:Z \
           offline-python-runtime:dev \
           python -m pytest /home/appuser/py-apps/tests/unit/test_new_feature.py -v
```

### Integration Tests
```bash
# Create integration test
cat > py-apps/tests/integration/test_database_integration.py << 'EOF'
import pytest
import os
import oracledb

class TestDatabaseIntegration:
    """Integration tests for database functionality"""
    
    @pytest.fixture
    def oracle_client(self):
        """Setup Oracle client for testing"""
        try:
            oracle_path = os.environ.get('ORACLE_INSTANTCLIENT_PATH')
            if oracle_path:
                oracledb.init_oracle_client(lib_dir=oracle_path)
            yield oracledb
        except Exception as e:
            pytest.skip(f"Oracle client not available: {e}")
    
    def test_oracle_client_initialization(self, oracle_client):
        """Test Oracle client initialization"""
        assert hasattr(oracle_client, 'connect')
        assert hasattr(oracle_client, 'init_oracle_client')
        assert oracle_client.__version__ is not None
    
    def test_connection_parameters(self, oracle_client):
        """Test connection parameter validation"""
        # Test with missing parameters
        with pytest.raises(Exception):
            oracle_client.connect()
        
        # Test with invalid parameters
        with pytest.raises(Exception):
            oracle_client.connect(user='invalid', password='invalid', dsn='invalid')
    
    def test_thick_mode_support(self, oracle_client):
        """Test thick mode functionality"""
        oracle_path = os.environ.get('ORACLE_INSTANTCLIENT_PATH')
        if oracle_path:
            # Test thick mode initialization
            try:
                oracle_client.init_oracle_client(lib_dir=oracle_path)
                assert True  # If we reach here, thick mode works
            except Exception as e:
                pytest.fail(f"Thick mode failed: {e}")
        else:
            pytest.skip("Oracle instant client path not configured")
EOF
```

## 🎨 Code Quality

### Pre-commit Hooks
```bash
# Install pre-commit hooks
pip3 install --user pre-commit

# Create pre-commit configuration
cat > .pre-commit-config.yaml << 'EOF'
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
      - id: check-merge-conflict
  
  - repo: https://github.com/psf/black
    rev: 22.10.0
    hooks:
      - id: black
        language_version: python3
        
  - repo: https://github.com/pycqa/flake8
    rev: 5.0.4
    hooks:
      - id: flake8
        args: [--max-line-length=88, --extend-ignore=E203,W503]
        
  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v0.991
    hooks:
      - id: mypy
        additional_dependencies: [types-all]
EOF

# Install hooks
pre-commit install

# Run hooks on all files
pre-commit run --all-files
```

### Code Formatting
```bash
# Format Python code with Black
podman run -it \
           -v $(pwd)/py-apps:/home/appuser/py-apps:Z \
           -v $(pwd)/dev-apps:/home/appuser/dev-apps:Z \
           offline-python-runtime:dev \
           python -m black /home/appuser/py-apps/ --line-length 88

# Check formatting without making changes
podman run -it \
           -v $(pwd)/py-apps:/home/appuser/py-apps:Z \
           offline-python-runtime:dev \
           python -m black /home/appuser/py-apps/ --check --line-length 88
```

### Linting
```bash
# Run flake8 linting
podman run -it \
           -v $(pwd)/py-apps:/home/appuser/py-apps:Z \
           offline-python-runtime:dev \
           python -m flake8 /home/appuser/py-apps/ --max-line-length=88 --extend-ignore=E203,W503

# Type checking with mypy
podman run -it \
           -v $(pwd)/py-apps:/home/appuser/py-apps:Z \
           offline-python-runtime:dev \
           python -m mypy /home/appuser/py-apps/ --ignore-missing-imports
```

## 🔍 Debugging

### Remote Debugging Setup
```bash
# Create debug-enabled development script
cat > debug-app.py << 'EOF'
import debugpy
import time
import os
from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/')
def hello():
    return jsonify({'message': 'Hello from debug mode!'})

@app.route('/debug-info')
def debug_info():
    import pandas as pd
    import numpy as np
    return jsonify({
        'pandas_version': pd.__version__,
        'numpy_version': np.__version__,
        'python_version': os.sys.version,
        'working_directory': os.getcwd()
    })

if __name__ == '__main__':
    # Start debug server
    debugpy.listen(('0.0.0.0', 5678))
    print("🔗 Debug server started on port 5678")
    print("⏳ Waiting for debugger connection...")
    
    debugpy.wait_for_client()
    print("🐛 Debugger connected, starting Flask app...")
    
    app.run(host='0.0.0.0', port=8000, debug=True)
EOF

# Run with debugging enabled
podman run -it \
           -v $(pwd)/debug-app.py:/home/appuser/debug-app.py:Z \
           -p 8000:8000 \
           -p 5678:5678 \
           offline-python-runtime:dev \
           python /home/appuser/debug-app.py
```

### Breakpoint Debugging
```bash
# Interactive debugging in container
podman run -it \
           -v $(pwd)/py-apps:/home/appuser/py-apps:Z \
           --entrypoint /bin/bash \
           offline-python-runtime:dev

# Inside container
cd /home/appuser/py-apps
python -c "
import pdb
import pandas as pd

def debug_function():
    data = pd.DataFrame({'x': [1, 2, 3]})
    pdb.set_trace()  # Breakpoint here
    result = data['x'].sum()
    return result

result = debug_function()
print(f'Result: {result}')
"
```

## 🔄 Git Workflow

### Git Flow Setup
```bash
# Initialize git flow (if not already configured)
git flow init

# Start new feature
git flow feature start add-new-feature

# Work on feature
git add .
git commit -m "feat: add new data processing functionality"

# During development
git add .
git commit -m "fix: resolve import issues"

# Finish feature
git flow feature finish add-new-feature
git push origin develop
```

### Commit Message Standards
```bash
# Use conventional commit messages
git commit -m "feat: add Oracle connection pooling support"
git commit -m "fix: resolve memory leak in data processing"
git commit -m "docs: update getting started guide"
git commit -m "test: add integration tests for database connectivity"
git commit -m "refactor: optimize Dockerfile for faster builds"

# Multi-line commit messages
git commit -m "feat: comprehensive ETL pipeline implementation

- Add DuckDB integration for high-performance analytics
- Implement data validation and error handling
- Add comprehensive logging and monitoring
- Support multiple data sources and formats

This enables enterprise-grade data processing workflows."
```

## 📊 Performance Testing

### Benchmarking Container Performance
```bash
# Create performance benchmark
cat > benchmark.py << 'EOF'
import time
import pandas as pd
import numpy as np
import psutil
import os

def benchmark_data_processing():
    """Benchmark data processing performance"""
    print("🚀 Starting performance benchmark...")
    
    # System information
    memory = psutil.virtual_memory()
    cpu_count = psutil.cpu_count()
    print(f"💾 Available memory: {memory.total / 1024**3:.2f} GB")
    print(f"🔧 CPU cores: {cpu_count}")
    
    # Benchmark 1: Data generation
    start_time = time.time()
    data = pd.DataFrame({
        'id': range(1_000_000),
        'value': np.random.randn(1_000_000),
        'category': np.random.choice(['A', 'B', 'C'], 1_000_000)
    })
    generation_time = time.time() - start_time
    print(f"📊 Data generation: {generation_time:.2f} seconds")
    
    # Benchmark 2: Aggregation
    start_time = time.time()
    result = data.groupby('category')['value'].agg(['mean', 'std', 'count'])
    aggregation_time = time.time() - start_time
    print(f"📈 Aggregation: {aggregation_time:.2f} seconds")
    
    # Benchmark 3: Memory usage
    memory_usage = data.memory_usage(deep=True).sum()
    print(f"💾 Data memory usage: {memory_usage / 1024**2:.2f} MB")
    
    return {
        'generation_time': generation_time,
        'aggregation_time': aggregation_time,
        'memory_usage_mb': memory_usage / 1024**2,
        'system_memory_gb': memory.total / 1024**3,
        'cpu_cores': cpu_count
    }

if __name__ == "__main__":
    results = benchmark_data_processing()
    print("🎯 Benchmark completed!")
    print(f"📊 Results: {results}")
EOF

# Run benchmark
podman run -it \
           -v $(pwd)/benchmark.py:/home/appuser/benchmark.py:Z \
           offline-python-runtime:dev \
           python /home/appuser/benchmark.py
```

## 🔧 Development Tools

### Makefile for Development Automation
```bash
# Create Makefile
cat > Makefile << 'EOF'
.PHONY: build test run dev clean lint format check

# Build development container
build:
	podman build . -t offline-python-runtime:dev

# Run tests
test:
	podman run -it -v $(PWD)/py-apps:/home/appuser/py-apps:Z offline-python-runtime:dev python -m pytest /home/appuser/py-apps/tests/ -v

# Start development environment
dev:
	podman run -it --name dev-python-runtime --rm -v $(PWD)/py-apps:/home/appuser/py-apps:Z -v $(PWD)/dev-apps:/home/appuser/dev-apps:Z --env-file .env.development -p 8000:8000 offline-python-runtime:dev bash

# Code quality checks
lint:
	podman run -it -v $(PWD)/py-apps:/home/appuser/py-apps:Z offline-python-runtime:dev python -m flake8 /home/appuser/py-apps/ --max-line-length=88

format:
	podman run -it -v $(PWD)/py-apps:/home/appuser/py-apps:Z offline-python-runtime:dev python -m black /home/appuser/py-apps/ --line-length 88

check:
	podman run -it -v $(PWD)/py-apps:/home/appuser/py-apps:Z offline-python-runtime:dev python -m mypy /home/appuser/py-apps/ --ignore-missing-imports

# Clean up development artifacts
clean:
	podman stop dev-python-runtime 2>/dev/null || true
	podman rm dev-python-runtime 2>/dev/null || true
	podman rmi offline-python-runtime:dev 2>/dev/null || true

# Full development workflow
dev-workflow: format lint test
	@echo "🎉 Development workflow completed!"

# Build and push to test registry
build-test:
	podman build . -t registry.company.com/offline-python-runtime:test
	podman push registry.company.com/offline-python-runtime:test
EOF

# Use the Makefile
make dev      # Start development
make test     # Run tests
make format   # Format code
make lint     # Run linter
make clean    # Clean up
```

### Development Scripts
```bash
# Create development utility script
cat > scripts/dev-helper.sh << 'EOF'
#!/bin/bash
# Development helper script

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

function show_help() {
    echo "🚀 Development Helper Commands:"
    echo "  dev         - Start development container"
    echo "  test        - Run tests"
    echo "  lint        - Run code quality checks"
    echo "  format      - Format code"
    echo "  build       - Build development image"
    echo "  clean       - Clean up containers and images"
    echo "  logs        - Show container logs"
    echo "  help        - Show this help"
}

function start_dev() {
    echo "🚀 Starting development environment..."
    podman run -it --name dev-python-runtime --rm \
               -v "$PROJECT_ROOT/py-apps:/home/appuser/py-apps:Z" \
               -v "$PROJECT_ROOT/dev-apps:/home/appuser/dev-apps:Z" \
               --env-file "$PROJECT_ROOT/.env.development" \
               -p 8000:8000 \
               offline-python-runtime:dev bash
}

function run_tests() {
    echo "🧪 Running tests..."
    podman run -it -v "$PROJECT_ROOT/py-apps:/home/appuser/py-apps:Z" \
               offline-python-runtime:dev \
               python -m pytest /home/appuser/py-apps/tests/ -v
}

function run_lint() {
    echo "🔍 Running linting..."
    podman run -it -v "$PROJECT_ROOT/py-apps:/home/appuser/py-apps:Z" \
               offline-python-runtime:dev \
               python -m flake8 /home/appuser/py-apps/ --max-line-length=88
}

function format_code() {
    echo "🎨 Formatting code..."
    podman run -it -v "$PROJECT_ROOT/py-apps:/home/appuser/py-apps:Z" \
               offline-python-runtime:dev \
               python -m black /home/appuser/py-apps/ --line-length 88
}

case "${1:-help}" in
    dev)
        start_dev
        ;;
    test)
        run_tests
        ;;
    lint)
        run_lint
        ;;
    format)
        format_code
        ;;
    help)
        show_help
        ;;
    *)
        echo "❌ Unknown command: $1"
        show_help
        exit 1
        ;;
esac
EOF

chmod +x scripts/dev-helper.sh

# Use the helper script
./scripts/dev-helper.sh dev      # Start development
./scripts/dev-helper.sh test     # Run tests
./scripts/dev-helper.sh lint     # Run linting
```

## 📞 Getting Help

### Common Development Issues
- **Permission errors**: Ensure proper file ownership for volume mounts
- **Port conflicts**: Use different ports or stop conflicting containers
- **Build failures**: Check base image availability and network connectivity
- **Test failures**: Verify Oracle client configuration and environment setup

### Development Community
- **📖 Documentation**: [Architecture](architecture.md) for system design
- **🧪 Testing**: [Testing Guide](testing.md) for test strategies
- **🤝 Contributing**: [Contributing Guidelines](contributing.md) for contribution process
- **🐛 Issues**: [Development Issues](https://github.com/opentechil/offline-python-runtime-docker/issues) for bug reports

---

**🚀 Ready to contribute?** Start with `make dev` and follow the development workflow!