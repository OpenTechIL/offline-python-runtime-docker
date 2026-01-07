# Offline Python Runtime Docker

[![Build Status](https://github.com/opentechil/offline-python-runtime-docker/workflows/Build%20and%20Push%20Multi-Folder%20to%20GHCR/badge.svg)](https://github.com/opentechil/offline-python-runtime-docker/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![Podman](https://img.shields.io/badge/podman-supported-green.svg)](https://podman.io/)
[![GHCR](https://img.shields.io/badge/ghcr-latest-blue)](https://github.com/OpenTechIL/offline-python-runtime-docker/pkgs/container/offline-python-runtime-docker)
[![Python Version](https://img.shields.io/badge/python-3.13-blue.svg)](https://www.python.org/downloads/)
[![GitHub stars](https://img.shields.io/github/stars/OpenTechIL/offline-python-runtime-docker?style=social)](https://github.com/OpenTechIL/offline-python-runtime-docker/stargazers)

A comprehensive, containerized Python runtime environment designed specifically for **enterprise offline and air-gapped deployments**. Features an innovative **wheelhouse architecture** for optimized package management and reliable offline operations.

## 🚀 Quick Start

### Prerequisites
- Docker 20.10+ or Podman 3.0+
- 2GB+ free disk space

```bash
# Build and run immediately
git clone https://github.com/opentechil/offline-python-runtime-docker.git
cd offline-python-runtime-docker

# Development build (faster rebuilds)
podman build . -t offline-python-runtime:dev

# Production build
podman build . -t offline-python-runtime:latest

# Verify installation with wheelhouse
podman run -it offline-python-runtime:latest python -c "import oracledb, pandas; print('✅ Wheelhouse-enabled Python runtime ready!')"
```

## 🏢 Key Features

- **🔒 Air-Gapped Ready**: Complete offline deployment with pre-cached wheel files
- **🗄️ Oracle Database**: Full Instant Client 19.29 with thick mode support  
- **📊 Data Science Stack**: pandas, numpy, scikit-learn, matplotlib pre-installed
- **🛡️ Security Hardened**: Non-root user, SELinux compatible, minimal attack surface
- **📦 Wheelhouse Architecture**: Three-tier package management for optimal offline deployment
- **🚀 Enterprise Ready**: Multi-database support, ETL tools, compliance features
- **⚡ Optimized Size**: Reduced container footprint through efficient dependency management

## 🏗️ Wheelhouse Architecture

Our innovative wheelhouse system provides reliable package management for offline environments through three installation tiers:

### 📋 Package Management Tiers

| Tier | File | Purpose | Installation Target |
|------|------|---------|-------------------|
| **Global** | `requirements-global.txt` | Essential system packages | Base Python environment |
| **Wheelhouse** | `requirements-wheelhouse.txt` | Pre-download wheels for offline use | `/lib/python_wheelhouse` |
| **Local** | `requirements.txt` | Application-specific packages | User `appuser` environment |

### 🔄 Installation Process

1. **Global Packages**: Essential tools like `pytest`, `cryptography` installed system-wide
2. **Wheelhouse Population**: Download wheel files to `/lib/python_wheelhouse` for offline access  
3. **Local Installation**: Application packages installed from wheelhouse to user environment
4. **Global pip Config**: Automatic wheelhouse usage via `/etc/pip.conf`

### 💡 Benefits

- **Reliable Offline Operations**: No network dependencies during runtime
- **Reduced Image Size**: Optimized dependency layering
- **Isolated Environments**: Clean separation between system and user packages
- **Fast Development**: Rebuilds leverage cached wheelhouse

## 📚 Documentation

| 📖 Guide | 📄 Link |
|---------|--------|
| **Getting Started** | [📖 docs/user/getting-started.md](docs/user/getting-started.md) |
| **Enterprise Deployment** | [📖 docs/user/enterprise-deployment.md](docs/user/enterprise-deployment.md) |
| **Development Guide** | [📖 docs/developer/setup.md](docs/developer/setup.md) |
| **Architecture** | [📖 docs/developer/architecture.md](docs/developer/architecture.md) |

For comprehensive guides, examples, and troubleshooting, visit our [documentation portal](docs/README.md).

## 💻 Quick Examples

### Data Science Workflow
```bash
# Run data analysis with volume mounting
mkdir -p ./my-analysis && echo 'import pandas as pd; print(f"Pandas {pd.__version__} ready!")' > ./my-analysis/test.py

podman run -v ./my-analysis:/home/appuser/my-analysis:Z \
           -it offline-python-runtime:latest \
           python ./my-analysis/test.py
```

### Oracle Database Connection
```bash
# Test Oracle client (no credentials required for test)
podman run -it offline-python-runtime:latest \
           python /home/appuser/py-apps/tests/test_thick_oracle.py
```

### Wheelhouse Usage Examples
```bash
# Install packages from wheelhouse in container
podman run -it offline-python-runtime:latest \
           pip install requests numpy --no-index --find-links=/lib/python_wheelhouse

# Custom application with additional packages
podman run -it offline-python-runtime:latest \
           bash -c "pip install --user httpx && python -c 'import httpx; print(\"✅ Package installed from wheelhouse!\")'"
```

### Development with Volume Mounts
```bash
# Mount local code and leverage wheelhouse for dependencies
podman run -v ./my-app:/home/appuser/my-app:Z \
           -it offline-python-runtime:dev \
           bash -c "cd my-app && pip install --user -r requirements.txt && python app.py"
```

## 📦 Enterprise Deployment

```bash
# Export for air-gapped deployment
podman pull ghcr.io/opentechil/offline-python-runtime-docker:latest
podman save -o offline-python-runtime-docker.tar ghcr.io/opentechil/offline-python-runtime-docker:latest

# Deploy in offline environment (wheelhouse included)
podman load -i offline-python-runtime-docker.tar
podman run -v ./app:/home/appuser/app:Z offline-python-runtime-docker:latest

# Verify wheelhouse functionality
podman run offline-python-runtime-docker:latest \
           python -c "import sys; print(f'Wheelhouse at {sys.path} ready!')"
```

### 🏭 Enterprise Features

- **Pre-cached Dependencies**: All packages available offline via wheelhouse
- **Zero Network Required**: Complete air-gapped operation guaranteed
- **Compliance Ready**: Auditable dependency versions locked in wheelhouse
- **Fast Deployment**: Single container image with all runtime dependencies
- **Enterprise Registry Support**: Compatible with private container registries

## 📈 Changelog

See [CHANGELOG.md](CHANGELOG.md) for detailed version history and feature updates.

## 🤝 Contributing

We welcome contributions! See [📖 docs/developer/contributing.md](docs/developer/contributing.md) for detailed guidelines.

### Quick Contributing Setup
```bash
# Fork and clone your repository
git clone https://github.com/your-username/offline-python-runtime-docker.git
cd offline-python-runtime-docker

# Development build with your changes
podman build . -t offline-python-runtime:dev
podman run -it offline-python-runtime:dev python ./py-apps/tests/
```

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

---

**🚀 Ready for enterprise offline deployment?** 

📖 **Check our [complete documentation](docs/README.md)** for detailed guides, examples, and enterprise integration patterns.

**⭐ Star this repository** if you find it useful for your enterprise Python deployments!

**🔄 New in v1.1.0**: Check out our innovative [wheelhouse architecture](#-wheelhouse-architecture) for enhanced offline operations!