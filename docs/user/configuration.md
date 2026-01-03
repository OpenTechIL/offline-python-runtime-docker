# ⚙️ Configuration

This guide covers all configuration options for the Offline Python Runtime Docker container, including environment variables, volume mounting, and deployment settings.

## 🌍 Environment Variables

### Oracle Client Configuration
```bash
# Required for Oracle database connectivity
ORACLE_INSTANTCLIENT_PATH=/opt/oracle/instantclient_19_29
ORACLE_HOME=/opt/oracle/instantclient_19_29
LD_LIBRARY_PATH=/opt/oracle/instantclient_19_29:$LD_LIBRARY_PATH

# Optional Oracle connection settings
ORACLE_USER=your_database_user
ORACLE_PASSWORD=your_database_password
ORACLE_DSN=your_host:1521/your_service_name
```

### Python Configuration
```bash
# Python executable path
PATH=/home/appuser/.local/bin:$PATH

# Python module search path
PYTHONPATH=/home/appuser/py-apps

# Python encoding
PYTHONIOENCODING=utf-8

# Python warnings (set to 'ignore' to suppress warnings)
PYTHONWARNINGS=default
```

### Application Configuration
```bash
# Application environment
APP_ENV=development|production|staging

# Debug mode
DEBUG=true|false

# Logging level
LOG_LEVEL=DEBUG|INFO|WARNING|ERROR

# Timezone
TZ=UTC

# Locale
LC_ALL=en_US.UTF-8
```

### Security Configuration
```bash
# Non-root user settings (already configured in container)
USER_ID=1000
GROUP_ID=1000

# File permissions
UMASK=0022

# Security context (SELinux)
SE_USER=system_u
SE_ROLE=system_r
SE_TYPE=container_t
SE_LEVEL=s0:c123,c456
```

## 📁 Volume Mounting Best Practices

### Development Setup
```bash
# Development with source code mounting
podman run -v ./source:/home/appuser/source:Z \
           -v ./data:/home/appuser/data:Z \
           -v ./logs:/home/appuser/logs:Z \
           -it offline-python-runtime:latest \
           python ./source/app.py

# Development with configuration files
podman run -v ./config:/home/appuser/config:Z,ro \
           -v ./source:/home/appuser/source:Z \
           --env-file ./config/.env \
           -it offline-python-runtime:latest \
           python ./source/app.py

# Development with data directory
podman run -v ./datasets:/home/appuser/datasets:Z \
           -v ./notebooks:/home/appuser/notebooks:Z \
           -p 8888:8888 \
           -it offline-python-runtime:latest \
           jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root
```

### Production Setup
```bash
# Production with read-only source
podman run -v ./app:/home/appuser/app:Z,ro \
           -v ./data:/home/appuser/data:Z \
           -v ./logs:/home/appuser/logs:Z \
           -v ./config:/home/appuser/config:Z,ro \
           --env-file ./production.env \
           -d offline-python-runtime:latest \
           python ./app/main.py

# Production with persistent storage
podman run -v app-source:/home/appuser/app:Z,ro \
           -v app-data:/home/appuser/data:Z \
           -v app-logs:/home/appuser/logs:Z \
           -v app-config:/home/appuser/config:Z,ro \
           --env-file ./production.env \
           -d offline-python-runtime:latest \
           python ./app/main.py

# Production with resource limits
podman run -v ./app:/home/appuser/app:Z,ro \
           -v ./data:/home/appuser/data:Z \
           --memory=4g \
           --cpus=2 \
           --memory-swap=4g \
           --ulimit nofile=65536:65536 \
           -d offline-python-runtime:latest \
           python ./app/main.py
```

### Enterprise Setup
```bash
# Enterprise with multiple data volumes
podman run -v ./source-code:/home/appuser/source:Z,ro \
           -v ./enterprise-data:/home/appuser/data:Z \
           -v ./configs:/home/appuser/config:Z,ro \
           -v ./certs:/home/appuser/certs:Z,ro \
           -v ./logs:/home/appuser/logs:Z \
           --env-file ./enterprise.env \
           -d offline-python-runtime:latest \
           python ./source/enterprise-app.py

# Enterprise with backup and restore
podman run -v ./backups:/home/appuser/backups:Z \
           -v ./restore-data:/home/appuser/restore-data:Z,ro \
           -v ./app:/home/appuser/app:Z,ro \
           --env-file ./backup.env \
           -d offline-python-runtime:latest \
           python ./app/backup-restore.py
```

## 🔧 Container Runtime Options

### Memory and CPU Configuration
```bash
# Set memory limits
podman run --memory=2g \
           --memory-swap=2g \
           offline-python-runtime:latest

# Set CPU limits
podman run --cpus=1.5 \
           --cpu-shares=1024 \
           offline-python-runtime:latest

# Combined resource limits
podman run --memory=4g \
           --memory-swap=4g \
           --cpus=2 \
           --cpu-shares=2048 \
           --ulimit nofile=65536:65536 \
           offline-python-runtime:latest
```

### Network Configuration
```bash
# Expose ports
podman run -p 8000:8000 \
           -p 5000:5000 \
           offline-python-runtime:latest

# Host network
podman run --network host \
           offline-python-runtime:latest

# Custom network
podman network create app-network
podman run --network app-network \
           offline-python-runtime:latest

# Network with specific hostname
podman run --network app-network \
           --hostname python-runtime \
           offline-python-runtime:latest
```

### Security Configuration
```bash
# Read-only filesystem with specific writable paths
podman run --read-only \
           --tmpfs /tmp \
           --tmpfs /home/appuser/.cache \
           offline-python-runtime:latest

# No new privileges
podman run --no-new-privileges \
           --user 1000:1000 \
           offline-python-runtime:latest

# Drop capabilities
podman run --cap-drop=ALL \
           --cap-add=SETUID \
           --cap-add=SETGID \
           offline-python-runtime:latest

# SELinux context
podman run --security-opt label=user:container_runtime_t \
           -v ./source:/home/appuser/source:Z \
           offline-python-runtime:latest
```

## 📋 Configuration Files

### Environment Files
Create `.env` files for different environments:

**development.env**
```bash
# Development environment
APP_ENV=development
DEBUG=true
LOG_LEVEL=DEBUG
PYTHONWARNINGS=default

# Database (development)
ORACLE_USER=dev_user
ORACLE_PASSWORD=dev_password
ORACLE_DSN=dev-db:1521/DEV_SERVICE

# Application settings
FLASK_ENV=development
JUPYTER_ENABLE_LAB=yes
```

**production.env**
```bash
# Production environment
APP_ENV=production
DEBUG=false
LOG_LEVEL=INFO
PYTHONWARNINGS=ignore

# Database (production)
ORACLE_USER=prod_user
ORACLE_PASSWORD=${PROD_DB_PASSWORD}
ORACLE_DSN=prod-db:1521/PROD_SERVICE

# Security settings
SSL_VERIFY=true
SESSION_TIMEOUT=3600
```

### Configuration Scripts
**config.sh** - Shell configuration script
```bash
#!/bin/bash
# Container startup configuration script

# Set timezone
export TZ=${TZ:-UTC}

# Configure Python path
export PYTHONPATH="/home/appuser/py-apps:/home/appuser/app:$PYTHONPATH"

# Set memory-efficient Python defaults
export PYTHONHASHSEED=random
export PYTHONUNBUFFERED=1

# Oracle client configuration
if [ -n "$ORACLE_INSTANTCLIENT_PATH" ]; then
    export LD_LIBRARY_PATH="$ORACLE_INSTANTCLIENT_PATH:$LD_LIBRARY_PATH"
    export TNS_ADMIN="$ORACLE_INSTANTCLIENT_PATH"
fi

# Application-specific settings
export APP_NAME="Offline Python Runtime"
export APP_VERSION="1.0.0"

echo "✅ Container environment configured"
echo "🕐 Timezone: $TZ"
echo "🐍 Python path: $PYTHONPATH"
echo "🗄️ Oracle client: $ORACLE_INSTANTCLIENT_PATH"
```

**docker-compose.yml** - Multi-container configuration
```yaml
version: '3.8'

services:
  python-runtime:
    build: .
    container_name: offline-python-runtime
    restart: unless-stopped
    environment:
      - APP_ENV=production
      - LOG_LEVEL=INFO
      - TZ=UTC
    volumes:
      - ./app:/home/appuser/app:Z,ro
      - ./data:/home/appuser/data:Z
      - ./logs:/home/appuser/logs:Z
      - ./config:/home/appuser/config:Z,ro
    ports:
      - "8000:8000"
    networks:
      - app-network
    deploy:
      resources:
        limits:
          memory: 4G
          cpus: '2'
        reservations:
          memory: 2G
          cpus: '1'

  database:
    image: container-registry.oracle.com/database/enterprise:19.3.0.0
    container_name: oracle-database
    environment:
      - ORACLE_SID=ORCLCDB
      - ORACLE_PDB=ORCLPDB1
      - ORACLE_PWD=YourStrongPassword123
    volumes:
      - oracle-data:/opt/oracle/oradata
    networks:
      - app-network

networks:
  app-network:
    driver: bridge

volumes:
  oracle-data:
```

## 🔍 Runtime Validation

### Container Health Check
```bash
# Check container status
podman ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}\t{{.Image}}"

# Inspect container configuration
podman inspect offline-python-runtime-docker | jq '.[0].Config.Env'

# Check resource usage
podman stats --no-stream offline-python-runtime-docker
```

### Environment Validation
```bash
# Validate environment variables
podman run -it offline-python-runtime:latest env | grep -E "(ORACLE|PYTHON|APP_)"

# Validate Python packages
podman run -it offline-python-runtime:latest python -c "
import pandas as pd
import numpy as np
import oracledb
print('✅ Core packages validated')
print(f'🐍 Pandas: {pd.__version__}')
print(f'🔢 NumPy: {np.__version__}')
print(f'🗄️ Oracle: {oracledb.__version__}')
"

# Validate Oracle client
podman run -it offline-python-runtime:latest python -c "
import os
if os.environ.get('ORACLE_INSTANTCLIENT_PATH'):
    import oracledb
    oracledb.init_oracle_client(lib_dir=os.environ['ORACLE_INSTANTCLIENT_PATH'])
    print('✅ Oracle client validated')
else:
    print('⚠️ Oracle client not configured')
"
```

## 🚨 Common Configuration Issues

### Permission Problems
```bash
# Fix file permissions for volume mounts
sudo chown -R 1000:1000 ./app ./data ./logs
sudo chmod -R 755 ./app ./data

# SELinux context issues
podman run -v ./source:/home/appuser/source:Z \
           --security-opt label=disable \
           offline-python-runtime:latest

# Alternative: restore context
sudo restorecon -R ./source
```

### Oracle Client Issues
```bash
# Missing Oracle libraries
podman run -it offline-python-runtime:latest bash -c "
echo '📦 Oracle client files:'
ls -la \$ORACLE_INSTANTCLIENT_PATH/
echo '🔗 LD_LIBRARY_PATH:'
echo \$LD_LIBRARY_PATH
"

# Oracle client initialization failure
podman run -it offline-python-runtime:latest python -c "
import os
import sys
try:
    oracle_path = os.environ.get('ORACLE_INSTANTCLIENT_PATH')
    if oracle_path:
        sys.path.insert(0, oracle_path)
        import oracledb
        oracledb.init_oracle_client(lib_dir=oracle_path)
        print('✅ Oracle client initialized')
    else:
        print('❌ ORACLE_INSTANTCLIENT_PATH not set')
except Exception as e:
    print(f'❌ Oracle client error: {e}')
"
```

### Memory Issues
```bash
# Out of memory errors
podman run --memory=4g \
           --memory-swap=4g \
           --shm-size=256m \
           offline-python-runtime:latest

# Check memory usage in container
podman run -it offline-python-runtime:latest python -c "
import psutil
import os
memory = psutil.virtual_memory()
print(f'📊 Total memory: {memory.total / 1024**3:.2f} GB')
print(f'💾 Available memory: {memory.available / 1024**3:.2f} GB')
print(f'📈 Memory usage: {memory.percent:.1f}%')
"
```

## 📚 Configuration Examples

### Data Science Environment
```bash
# Jupyter Lab setup
podman run -p 8888:8888 \
           -v ./notebooks:/home/appuser/notebooks:Z \
           -v ./datasets:/home/appuser/datasets:Z \
           -e JUPYTER_ENABLE_LAB=yes \
           -e JUPYTER_TOKEN=secure-token-123 \
           -d offline-python-runtime:latest \
           jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --NotebookApp.token='secure-token-123'
```

### Web Application Environment
```bash
# Flask/FastAPI application
podman run -p 8000:8000 \
           -v ./app:/home/appuser/app:Z,ro \
           -v ./static:/home/appuser/static:Z,ro \
           --env-file ./production.env \
           -d offline-python-runtime:latest \
           gunicorn --bind 0.0.0.0:8000 --workers 4 app.main:app
```

### Batch Processing Environment
```bash
# ETL/Cron job container
podman run -v ./scripts:/home/appuser/scripts:Z,ro \
           -v ./data:/home/appuser/data:Z \
           --env-file ./batch.env \
           --memory=2g \
           --cpus=1 \
           --rm offline-python-runtime:latest \
           python ./scripts/batch_processor.py
```

## 📞 Configuration Help

- **📖 Documentation**: [Getting Started](getting-started.md) for setup basics
- **💻 Examples**: [Usage Examples](usage-examples.md) for practical implementations
- **🚨 Troubleshooting**: [Troubleshooting](troubleshooting.md) for common issues
- **🏢 Enterprise**: [Enterprise Deployment](enterprise-deployment.md) for production setup

---

**🎯 Pro Tip**: Always test configuration changes in development before deploying to production environments!