# 🔧 Troubleshooting

This guide helps you diagnose and resolve common issues with Offline Python Runtime Docker container. Includes solutions for build problems, runtime errors, and enterprise deployment issues.

## 🚨 Quick Diagnosis

### Container Health Check
```bash
# Check container status
podman ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}\t{{.Image}}"

# Check container logs
podman logs python-runtime-container --tail=50

# Inspect container configuration
podman inspect python-runtime-container | jq '.[0].State'

# Resource usage check
podman stats --no-stream python-runtime-container
```

### Package Validation
```bash
# Verify all packages are installed
podman run -it offline-python-runtime:latest python -c "
import importlib
import sys

# List of critical packages to verify
packages = [
    'pandas', 'numpy', 'oracledb', 'pytest', 'requests',
    'urllib3', 'pydantic', 'httpx', 'openpyxl',
    'duckdb', 'dlt', 'pymongo', 'pyarrow',
    'scikit-learn', 'matplotlib', 'sqlalchemy',
    'pyodbc', 'mssql-python', 'pyreadstat',
    'tabulate', 'ipykernel'
]

missing = []
for pkg in packages:
    try:
        importlib.import_module(pkg)
        print(f'✅ {pkg}')
    except ImportError as e:
        print(f'❌ {pkg}: {e}')
        missing.append(pkg)

if missing:
    print(f'\n❌ Missing packages: {missing}')
    sys.exit(1)
else:
    print('\n✅ All packages verified successfully')
"
```

## 🏗️ Build Issues

### Issue: "No space left on device" during build
**Symptoms:**
```
failed to register layer: Error processing tar file(exit status 1): write no space left on device
```

**Solutions:**
```bash
# Solution 1: Use temporary directory with more space
mkdir -p ~/podman-tmp
export TMPDIR=~/podman-tmp
podman build . -t offline-python-runtime:latest

# Solution 2: Clean up disk space
podman system prune -a
podman image prune -a
podman volume prune

# Solution 3: Use different storage driver
podman build --storage-driver vfs . -t offline-python-runtime:latest
```

### Issue: Oracle client download failure
**Symptoms:**
```
curl: (35) OpenSSL SSL_connect: SSL_ERROR_SYSCALL
error during build process
```

**Solutions:**
```bash
# Solution 1: Use offline installation
# Download Oracle client manually and place in build context
mkdir -p oracle-client
curl -o oracle-client/instantclient-basic.zip \
     https://download.oracle.com/otn_software/linux/instantclient/1929000/instantclient-basic-linux.x64-19.29.0.0.0dbru.zip

# Modify Dockerfile to use local file
# RUN cp oracle-client/instantclient-basic.zip . && unzip -o instantclient-basic.zip

# Solution 2: Skip SSL verification (development only)
podman build --build-arg CURL_OPTS="--insecure" . -t offline-python-runtime:latest
```

### Issue: Permission denied during build
**Symptoms:**
```
permission denied while trying to connect to the Docker daemon socket
```

**Solutions:**
```bash
# Solution 1: Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Solution 2: Use sudo
sudo podman build . -t offline-python-runtime:latest

# Solution 3: Rootless Podman setup
podman system reset -f
podman machine init
```

## 🔌 Runtime Issues

### Issue: Volume mounting permission errors
**Symptoms:**
```
permission denied while trying to open ./app/main.py: Permission denied
chown: changing ownership of '/home/appuser/app': Operation not permitted
```

**Solutions:**
```bash
# Solution 1: Fix file ownership
sudo chown -R 1000:1000 ./your-app-directory
sudo chmod -R 755 ./your-app-directory

# Solution 2: Use SELinux context
podman run -v ./source:/home/appuser/source:Z \
           --security-opt label=disable \
           offline-python-runtime:latest

# Solution 3: Change user ID in container
podman run --user $(id -u):$(id -g) \
           -v ./source:/home/appuser/source:Z \
           offline-python-runtime:latest
```

### Issue: Oracle client initialization failure
**Symptoms:**
```
DPI-1047: Cannot locate Oracle Net library
libclntsh.so.19.1: cannot open shared object file: No such file or directory
```

**Solutions:**
```bash
# Solution 1: Check Oracle client installation
podman run -it offline-python-runtime:latest bash -c "
echo '📦 Oracle client files:'
ls -la \$ORACLE_INSTANTCLIENT_PATH/
echo '🔗 LD_LIBRARY_PATH:'
echo \$LD_LIBRARY_PATH
echo '🧪 Testing library loading:'
ldd \$ORACLE_INSTANTCLIENT_PATH/libclntsh.so.19.1
"

# Solution 2: Reinitialize Oracle client
podman run -it offline-python-runtime:latest python -c "
import os
import sys
sys.path.insert(0, os.environ.get('ORACLE_INSTANTCLIENT_PATH', ''))
import oracledb

try:
    oracle_instantclient_path = os.environ['ORACLE_INSTANTCLIENT_PATH']
    oracledb.init_oracle_client(lib_dir=oracle_instantclient_path)
    print('✅ Oracle client initialized successfully')
except Exception as e:
    print(f'❌ Oracle client initialization failed: {e}')
    print('🔧 Checking environment:')
    print(f'  ORACLE_INSTANTCLIENT_PATH: {os.environ.get(\"ORACLE_INSTANTCLIENT_PATH\", \"Not set\")}')
    print(f'  LD_LIBRARY_PATH: {os.environ.get(\"LD_LIBRARY_PATH\", \"Not set\")}')
"

# Solution 3: Use thin mode (fallback)
podman run -it offline-python-runtime:latest python -c "
import oracledb
print('✅ Using Oracle thin mode (no client initialization required)')
"
```

### Issue: Out of memory errors
**Symptoms:**
```
MemoryError: Unable to allocate array
Killed
```

**Solutions:**
```bash
# Solution 1: Increase memory limits
podman run --memory=4g \
           --memory-swap=4g \
           --shm-size=256m \
           offline-python-runtime:latest

# Solution 2: Optimize memory usage in Python
podman run -it offline-python-runtime:latest python -c "
import pandas as pd
import numpy as np

# Generate data with optimized data types
data = pd.DataFrame({
    'id': range(1_000_000),
    'value': np.random.uniform(0, 100, 1_000_000).astype('float32'),  # Use float32 instead of float64
    'category': pd.Categorical(np.random.choice(['A', 'B', 'C'], 1_000_000))  # Use categorical
})

print(f'📊 Data shape: {data.shape}')
print(f'💾 Memory usage: {data.memory_usage(deep=True).sum() / 1024 / 1024:.2f} MB')

# Process in chunks
chunk_size = 100_000
for i in range(0, len(data), chunk_size):
    chunk = data[i:i+chunk_size]
    # Process chunk
    result = chunk['value'].mean()
    print(f'Chunk {i//chunk_size + 1}: mean = {result:.2f}')
"

# Solution 3: Use memory-mapped files
podman run -it offline-python-runtime:latest python -c "
import pandas as pd
import numpy as np

# Create memory-mapped array
mm_array = np.memmap('/tmp/large_array.dat', dtype='float32', mode='w+', shape=(10_000_000,))
mm_array[:] = np.random.random(10_000_000)

print(f'📊 Memory-mapped array shape: {mm_array.shape}')
print(f'💾 Array size: {mm_array.nbytes / 1024 / 1024:.2f} MB')
"
```

## 🌐 Network Issues

### Issue: Container cannot connect to external services
**Symptoms:**
```
urllib3.exceptions.MaxRetryError: HTTPConnectionPool(host='api.example.com', port=443)
ConnectionError: [Errno 11] Resource temporarily unavailable
```

**Solutions:**
```bash
# Solution 1: Use host network
podman run --network host \
           offline-python-runtime:latest

# Solution 2: Configure DNS
podman run --dns=8.8.8.8 --dns=8.8.4.4 \
           offline-python-runtime:latest

# Solution 3: Disable proxy
podman run --env HTTP_PROXY= --env HTTPS_PROXY= \
           offline-python-runtime:latest
```

### Issue: Port binding conflicts
**Symptoms:**
```
Error starting userland proxy: listen tcp4 0.0.0.0:8000: bind: address already in use
```

**Solutions:**
```bash
# Solution 1: Find and stop conflicting process
podman ps | grep :8000
podman stop <container-id>

# Solution 2: Use different port
podman run -p 8001:8000 \
           offline-python-runtime:latest

# Solution 3: Check port usage
netstat -tulpn | grep :8000
ss -tulpn | grep :8000
```

## 🗄️ Database Connection Issues

### Issue: Oracle database connection timeout
**Symptoms:**
```
ORA-12170: TNS:Connect timeout occurred
ORA-12541: TNS:no listener
```

**Solutions:**
```bash
# Solution 1: Test network connectivity
podman run -it offline-python-runtime:latest bash -c "
# Test basic connectivity
nc -zv your-oracle-host 1521

# Test with telnet if available
telnet your-oracle-host 1521

# Ping test
ping -c 4 your-oracle-host
"

# Solution 2: Verify connection parameters
podman run -it offline-python-runtime:latest python -c "
import os
import oracledb

print('🔧 Oracle Connection Parameters:')
print(f'  User: {os.environ.get(\"ORACLE_USER\", \"Not set\")}')
print(f'  DSN: {os.environ.get(\"ORACLE_DSN\", \"Not set\")}')
print(f'  Path: {os.environ.get(\"ORACLE_INSTANTCLIENT_PATH\", \"Not set\")}')

# Test connection string parsing
try:
    dsn = os.environ.get('ORACLE_DSN')
    if dsn:
        parts = dsn.split(':')
        if len(parts) >= 2:
            print(f'  Host: {parts[0]}')
            print(f'  Port: {parts[1]}')
            if len(parts) > 2:
                service_parts = parts[2].split('/')
                print(f'  Service: {service_parts[0] if len(service_parts) > 0 else \"Not specified\"}')
except Exception as e:
    print(f'❌ Error parsing DSN: {e}')
"

# Solution 3: Test with different connection methods
podman run -it offline-python-runtime:latest python -c "
import os
import oracledb

# Initialize client
oracle_path = os.environ.get('ORACLE_INSTANTCLIENT_PATH')
if oracle_path:
    oracledb.init_oracle_client(lib_dir=oracle_path)

# Test different connection formats
connection_formats = [
    # Easy Connect format
    f\"{os.environ.get('ORACLE_USER')}/{os.environ.get('ORACLE_PASSWORD')}@{os.environ.get('ORACLE_DSN')}\",
    
    # Parameters format
    {
        'user': os.environ.get('ORACLE_USER'),
        'password': os.environ.get('ORACLE_PASSWORD'),
        'dsn': os.environ.get('ORACLE_DSN')
    }
]

for i, conn_params in enumerate(connection_formats, 1):
    try:
        if isinstance(conn_params, dict):
            conn = oracledb.connect(**conn_params)
        else:
            conn = oracledb.connect(conn_params)
        print(f'✅ Connection method {i} successful')
        conn.close()
        break
    except Exception as e:
        print(f'❌ Connection method {i} failed: {e}')
"
```

## 📁 File System Issues

### Issue: File not found in volume mount
**Symptoms:**
```
FileNotFoundError: [Errno 2] No such file or directory: './app/config.json'
```

**Solutions:**
```bash
# Solution 1: Verify volume mounting
podman run -v ./app:/home/appuser/app:Z \
           -it offline-python-runtime:latest \
           ls -la /home/appuser/app

# Solution 2: Check file permissions
podman run -v ./app:/home/appuser/app:Z \
           -it offline-python-runtime:latest \
           bash -c "
ls -la /home/appuser/app/
find /home/appuser/app -type f -exec echo {} \; -exec cat {} \;
"

# Solution 3: Use absolute paths
podman run -v $(pwd)/app:/home/appuser/app:Z \
           -it offline-python-runtime:latest \
           python /home/appuser/app/main.py
```

### Issue: SELinux permission denied
**Symptoms:**
```
PermissionError: [Errno 13] Permission denied: '/home/appuser/data/output.csv'
```

**Solutions:**
```bash
# Solution 1: Use proper SELinux context
podman run -v ./data:/home/appuser/data:Z \
           offline-python-runtime:latest

# Solution 2: Restore SELinux context
sudo restorecon -R ./data
sudo chcon -R svirt_sandbox_file_t ./data

# Solution 3: Disable SELinux for development
podman run --security-opt label=disable \
           -v ./data:/home/appuser/data \
           offline-python-runtime:latest
```

## 🐛 Performance Issues

### Issue: Slow container startup
**Symptoms:**
```
Container takes 30+ seconds to start
High CPU usage during initialization
```

**Solutions:**
```bash
# Solution 1: Optimize startup scripts
podman run -it offline-python-runtime:latest python -c "
import time
import pandas as pd
import numpy as np

start_time = time.time()

# Lazy loading - import only when needed
def get_pandas():
    import pandas as pd
    return pd

def get_numpy():
    import numpy as np
    return np

# Use lazy loading
print('🚀 Using lazy loading...')
pd = get_pandas()
np = get_numpy()

# Quick test
data = pd.DataFrame({'x': [1, 2, 3]})
print(f'✅ Startup time: {time.time() - start_time:.2f} seconds')
"

# Solution 2: Use resource limits effectively
podman run --memory=2g --cpus=2 \
           --entrypoint /bin/bash \
           offline-python-runtime:latest -c "
echo '📊 Resource limits set'
free -h
cat /sys/fs/cgroup/memory/memory.limit_in_bytes
"

# Solution 3: Pre-warm container image
podman run -it offline-python-runtime:latest python -c "
# Pre-import heavy packages during build
import pandas as pd
import numpy as np
import sklearn
import matplotlib.pyplot as plt

print('🔥 Pre-warming complete')
print(f'🐍 Pandas {pd.__version__}')
print(f'🔢 NumPy {np.__version__}')
"
```

## 🔍 Debugging Tools

### Container Inspection Commands
```bash
# Deep container inspection
podman inspect python-runtime-container | jq '.'

# Check running processes
podman top python-runtime-container

# Resource usage monitoring
podman stats python-runtime-container --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"

# File system changes
podman diff python-runtime-container

# Network connections
podman exec -it python-runtime-container netstat -tulpn
podman exec -it python-runtime-container ss -tulpn
```

### Python Debugging
```bash
# Enable Python debugging
podman run -it offline-python-runtime:latest python -c "
import sys
import os
print('🐍 Python Debug Information:')
print(f'  Version: {sys.version}')
print(f'  Executable: {sys.executable}')
print(f'  Path: {sys.path}')
print(f'  Environment: {dict(os.environ)}')
"

# Memory profiling
podman run -it offline-python-runtime:latest python -c "
import tracemalloc
import pandas as pd

# Start memory tracing
tracemalloc.start()

# Allocate some memory
data = pd.DataFrame({'x': range(1000000)})

# Get memory statistics
current, peak = tracemalloc.get_traced_memory()
print(f'📊 Current memory: {current / 1024 / 1024:.2f} MB')
print(f'🔝 Peak memory: {peak / 1024 / 1024:.2f} MB')

tracemalloc.stop()
"
```

## 📞 Getting Help

### Log Analysis
```bash
# Export logs for analysis
podman logs python-runtime-container > container.log

# Search for errors
grep -i error container.log
grep -i exception container.log

# Timeline analysis
podman logs --since 2023-01-01T00:00:00 --until 2023-01-01T23:59:59 python-runtime-container
```

### Health Monitoring Script
```bash
cat > health-monitor.sh << 'EOF'
#!/bin/bash
# Container health monitoring script

CONTAINER_NAME="python-runtime-container"
LOG_FILE="/tmp/container-health.log"

check_container_health() {
    local container_id=$(podman ps -q -f name=$CONTAINER_NAME)
    
    if [ -z "$container_id" ]; then
        echo "$(date): ❌ Container $CONTAINER_NAME is not running" >> $LOG_FILE
        return 1
    fi
    
    local status=$(podman inspect $container_id | jq -r '.[0].State.Health.Status' 2>/dev/null)
    local exit_code=$(podman inspect $container_id | jq -r '.[0].State.ExitCode')
    
    if [ "$status" = "healthy" ]; then
        echo "$(date): ✅ Container $CONTAINER_NAME is healthy" >> $LOG_FILE
        return 0
    elif [ "$exit_code" -eq 0 ]; then
        echo "$(date): ✅ Container $CONTAINER_NAME running normally" >> $LOG_FILE
        return 0
    else
        echo "$(date): ❌ Container $CONTAINER_NAME has issues (exit code: $exit_code)" >> $LOG_FILE
        return 1
    fi
}

# Run health check
check_container_health

# Auto-restart if failed
if [ $? -ne 0 ]; then
    echo "$(date): 🔄 Restarting container..." >> $LOG_FILE
    podman restart $CONTAINER_NAME
fi
EOF

chmod +x health-monitor.sh
./health-monitor.sh
```

## 🎯 Prevention Tips

### Best Practices
1. **Always test in development first** before deploying to production
2. **Use specific image tags** instead of `latest` for production
3. **Implement health checks** in your applications
4. **Monitor resource usage** and set appropriate limits
5. **Use volume mounts correctly** with proper permissions
6. **Set environment variables** explicitly rather than relying on defaults
7. **Implement logging** in your applications for debugging
8. **Regular updates** of base images and dependencies

### Environment-Specific Checks
```bash
# Development environment checklist
echo "🔧 Development Environment Checklist:"
echo "□ File permissions correct?"
echo "□ SELinux context configured?"
echo "□ Environment variables set?"
echo "□ Ports available?"
echo "□ Dependencies installed?"

# Production environment checklist
echo "🏢 Production Environment Checklist:"
echo "□ Resource limits configured?"
echo "□ Health checks implemented?"
echo "□ Logging configured?"
echo "□ Security hardening applied?"
echo "□ Backup strategy in place?"
echo "□ Monitoring setup?"
```

## 📚 Additional Resources

- **📖 Configuration**: [Configuration Guide](configuration.md)
- **💻 Examples**: [Usage Examples](usage-examples.md)
- **🏢 Deployment**: [Enterprise Deployment](enterprise-deployment.md)
- **👨‍💻 Development**: [Development Setup](../developer/setup.md)

---

**🚨 Still having issues?** Check the [GitHub Issues](https://github.com/opentechil/offline-python-runtime-docker/issues) or create a new one with detailed error information!