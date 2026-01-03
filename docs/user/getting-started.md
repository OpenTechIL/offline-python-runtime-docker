# 🚀 Getting Started

This guide will help you get the Offline Python Runtime Docker up and running quickly. This containerized Python runtime is designed for enterprise offline and air-gapped deployments.

## 📋 Prerequisites

### System Requirements
- **Docker 20.10+** or **Podman 3.0+**
- **2GB+ free disk space** for the container image
- **Linux/macOS/Windows** with container runtime support
- **Administrator/sudo access** (for volume mounting in development)

### Optional Requirements
- **SELinux-enabled systems**: Ensure you have permissions for `:Z` volume flags
- **Enterprise registry access**: For private deployments
- **Oracle database access**: If using Oracle connectivity features

## 🏃‍♂️ Quick Start (2 minutes)

### Option 1: Build from Source
```bash
# Clone the repository
git clone https://github.com/opentechil/offline-python-runtime-docker.git
cd offline-python-runtime-docker

# Build the container
podman build . -t offline-python-runtime:latest

# Verify installation
podman run -it offline-python-runtime:latest python -c "import oracledb, pandas; print('✅ Enterprise Python runtime ready!')"
```

### Option 2: Pull Pre-built Image
```bash
# Pull the latest image
podman pull ghcr.io/opentechil/offline-python-runtime-docker:latest

# Verify installation
podman run -it ghcr.io/opentechil/offline-python-runtime-docker:latest python -c "import oracledb, pandas; print('✅ Enterprise Python runtime ready!')"
```

## ✅ Validation

### Test Core Functionality
```bash
# Run built-in validation tests
podman run -it offline-python-runtime:latest python -m pytest /home/appuser/py-apps/tests/ -v

# Verify package imports
podman run -it offline-python-runtime:latest python -c "import pandas, oracledb, sklearn; print('✅ All packages verified')"

# Test Oracle client initialization
podman run -it offline-python-runtime:latest python /home/appuser/py-apps/tests/test_thick_oracle.py
```

### Expected Output
```
✅ Enterprise Python runtime ready!
✅ All packages verified
✅ Oracle client initialized successfully
```

## 💻 Your First Application

### Step 1: Create Application Directory
```bash
mkdir -p ./my-python-app
cd ./my-python-app
```

### Step 2: Create Simple Python Script
```bash
cat > hello.py << 'EOF'
import pandas as pd
import numpy as np
import oracledb

print(f"🐍 Python {pd.__version__} runtime ready!")
print(f"📊 Pandas {pd.__version__} available")
print(f"📦 NumPy {np.__version__} available") 
print(f"🗄️ Oracle client {oracledb.__version__} initialized")
print("✅ Enterprise Python environment fully functional!")
EOF
```

### Step 3: Run Your Application
```bash
# Run with volume mounting
podman run -v ./my-python-app:/home/appuser/my-python-app:Z \
           -it offline-python-runtime:latest \
           python ./my-python-app/hello.py
```

## 📁 Project Structure

After setup, your project should look like:
```
my-project/
├── offline-python-runtime-docker/     # Cloned repository
│   ├── Dockerfile                   # Container definition
│   ├── requirements.txt              # Python dependencies
│   └── py-apps/                   # Application layer
│       ├── main.py                  # Container entry point
│       └── tests/                   # Validation tests
└── my-python-app/                  # Your application code
    └── hello.py                    # Your Python script
```

## 🔧 Development vs Production

### Development Setup
```bash
# Development with live code mounting
podman run -v ./source:/home/appuser/source:Z \
           -it offline-python-runtime:latest \
           python ./source/your-app.py

# Development with debugging
podman run -v ./source:/home/appuser/source:Z \
           -p 8000:8000 \
           -it offline-python-runtime:latest \
           python -m debugpy --listen 0.0.0.0:8000 ./source/your-app.py
```

### Production Setup
```bash
# Production with read-only source
podman run -v ./app:/home/appuser/app:Z,ro \
           -v ./data:/home/appuser/data:Z \
           -d offline-python-runtime:latest \
           python ./app/production-app.py

# Production with environment file
podman run --env-file ./.env \
           -v ./config:/home/appuser/config:Z,ro \
           -d offline-python-runtime:latest \
           python ./app/production-app.py
```

## 🌐 Network Considerations

### Online Development
```bash
# Build with network access (for development dependencies)
podman build --network host . -t offline-python-runtime:dev

# Run with internet access (if needed for development)
podman run --network host \
           -v ./app:/home/appuser/app:Z \
           -it offline-python-runtime:latest
```

### Air-gapped Deployment
For completely offline environments, see [Enterprise Deployment](enterprise-deployment.md).

## 🧪 Common Test Scenarios

### Test Data Science Capabilities
```bash
podman run -it offline-python-runtime:latest python -c "
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# Generate sample data
data = pd.DataFrame({'x': np.random.randn(100), 'y': np.random.randn(100)})
print(f'📊 Generated {len(data)} data points')
print(f'💾 Memory usage: {data.memory_usage().sum() / 1024:.2f} KB')
print('✅ Data science stack ready!')
"
```

### Test Database Connectivity
```bash
# Test Oracle client (no credentials required for initialization test)
podman run -it offline-python-runtime:latest python -c "
import os
import oracledb

# Initialize Oracle client
oracle_instantclient_path = os.environ.get('ORACLE_INSTANTCLIENT_PATH')
if oracle_instantclient_path:
    oracledb.init_oracle_client(lib_dir=oracle_instantclient_path)
    print('✅ Oracle client initialized successfully')
else:
    print('❌ ORACLE_INSTANTCLIENT_PATH not set')
"
```

## ❌ Common Issues

### Build Problems
```bash
# If build fails with "no space left on device"
mkdir -p ~/podman-tmp
export TMPDIR=~/podman-tmp
podman build . -t offline-python-runtime:latest

# If build fails with permission errors
sudo chown -R 1000:1000 ./your-source-directory
```

### Runtime Problems
```bash
# If volume mounting fails on SELinux systems
podman run -v ./source:/home/appuser/source:Z \
           -it offline-python-runtime:latest

# If Python packages not found
podman run -it offline-python-runtime:latest pip list
```

## 🎯 Next Steps

Now that you have a working environment:

1. **Explore Examples**: Check out [Usage Examples](usage-examples.md) for practical implementations
2. **Configure Environment**: See [Configuration](configuration.md) for environment variables and settings
3. **Deploy to Production**: Follow [Enterprise Deployment](enterprise-deployment.md) for production setup
4. **Troubleshoot Issues**: Reference [Troubleshooting](troubleshooting.md) for common problems

## 📞 Need Help?

- **📖 Documentation**: [Complete documentation index](../README.md)
- **🐛 Issues**: [Report a problem](https://github.com/opentechil/offline-python-runtime-docker/issues)
- **💬 Discussions**: [Community support](https://github.com/opentechil/offline-python-runtime-docker/discussions)

---

**🚀 Congratulations!** You now have a fully functional enterprise Python runtime environment ready for development, testing, and deployment.