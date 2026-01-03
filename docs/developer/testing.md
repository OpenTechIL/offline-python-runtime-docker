# 🧪 Testing

This guide covers testing strategies and best practices for Offline Python Runtime Docker project.

## 🎯 Testing Strategy

### Test Categories
- **Unit Tests**: Individual function and method testing
- **Integration Tests**: Component interaction testing  
- **Container Tests**: Container build and runtime validation
- **Oracle Tests**: Database connectivity and functionality
- **Performance Tests**: Resource usage and optimization validation

## 📝 Running Tests

### Basic Test Execution
```bash
# Run all tests
podman run -v $(pwd)/py-apps:/home/appuser/py-apps:Z \
           offline-python-runtime:dev \
           python -m pytest /home/appuser/py-apps/tests/ -v

# Run specific test
podman run -v $(pwd)/py-apps:/home/appuser/py-apps:Z \
           offline-python-runtime:dev \
           python -m pytest /home/appuser/py-apps/tests/test_imports.py -v

# Run with coverage
podman run -v $(pwd)/py-apps:/home/appuser/py-apps:Z \
           offline-python-runtime:dev \
           python -m pytest /home/appuser/py-apps/tests/ --cov=py-apps
```

### Oracle Client Testing
```bash
# Test Oracle thick mode
podman run -it offline-python-runtime:dev \
           python /home/appuser/py-apps/tests/test_thick_oracle.py

# Test with environment variables
podman run -e ORACLE_USER=test \
           -e ORACLE_PASSWORD=test \
           -e ORACLE_DSN=host:1521/service \
           -it offline-python-runtime:dev \
           python /home/appuser/py-apps/tests/test_thick_oracle.py
```

## 📊 Test Coverage

### Coverage Report
```python
# Run coverage in container
podman run -v $(pwd)/py-apps:/home/appuser/py-apps:Z \
           offline-python-runtime:dev \
           python -c "
import pytest
import coverage

# Run coverage
pytest.main([
    '/home/appuser/py-apps/tests/',
    '--cov=py-apps',
    '--cov-report=term-missing',
    '--cov-report=html:/home/appuser/coverage',
    '--cov-fail-under=80'
])
"
```

## 🚨 Common Test Issues

### Oracle Client Fails
```bash
# Check Oracle environment
podman run -it offline-python-runtime:dev bash -c "
echo \$ORACLE_INSTANTCLIENT_PATH
echo \$ORACLE_HOME
echo \$LD_LIBRARY_PATH
ls -la \$ORACLE_INSTANTCLIENT_PATH/
"
```

### Permission Denied
```bash
# Fix test permissions
sudo chown -R 1000:1000 py-apps/
chmod -R 755 py-apps/
```

## 📞 Getting Help

- **📖 Documentation**: [Development Setup](setup.md) for environment
- **🔧 Configuration**: [Configuration Guide](../user/configuration.md) for setup
- **🐛 Issues**: Report bugs at [GitHub Issues](https://github.com/opentechil/offline-python-runtime-docker/issues)

---

**🧪 Comprehensive testing ensures reliable enterprise deployments!**