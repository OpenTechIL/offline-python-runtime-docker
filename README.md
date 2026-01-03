# Offline Python Runtime Docker

[![Build Status](https://github.com/opentechil/offline-python-runtime-docker/workflows/Build%20and%20Push%20Multi-Folder%20to%20GHCR/badge.svg)](https://github.com/opentechil/offline-python-runtime-docker/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![Podman](https://img.shields.io/badge/podman-supported-green.svg)](https://podman.io/)
[![GHCR](https://img.shields.io/badge/ghcr-latest-blue)](https://github.com/OpenTechIL/offline-python-runtime-docker/pkgs/container/offline-python-runtime-docker)
[![Python Version](https://img.shields.io/badge/python-3.13-blue.svg)](https://www.python.org/downloads/)
[![GitHub stars](https://img.shields.io/github/stars/OpenTechIL/offline-python-runtime-docker?style=social)](https://github.com/OpenTechIL/offline-python-runtime-docker/stargazers)

A comprehensive, containerized Python runtime environment designed specifically for **enterprise offline and air-gapped deployments**. Pre-configured with data science, database connectivity, and enterprise libraries.

## 🚀 Quick Start

### Prerequisites
- Docker 20.10+ or Podman 3.0+
- 2GB+ free disk space

```bash
# Build and run immediately
git clone https://github.com/opentechil/offline-python-runtime-docker.git
cd offline-python-runtime-docker
podman build . -t offline-python-runtime:latest

# Verify installation
podman run -it offline-python-runtime:latest python -c "import oracledb, pandas; print('✅ Enterprise Python runtime ready!')"
```

## 🏢 Key Features

- **🔒 Air-Gapped Ready**: Complete offline deployment with no external dependencies
- **🗄️ Oracle Database**: Full Instant Client 19.29 with thick mode support  
- **📊 Data Science Stack**: pandas, numpy, scikit-learn, matplotlib pre-installed
- **🛡️ Security Hardened**: Non-root user, SELinux compatible, minimal attack surface
- **📦 Enterprise Ready**: Multi-database support, ETL tools, compliance features

## 📚 Documentation

| 📖 What you need      | 📄 Where to find it                                                        |
| --------------------- | -------------------------------------------------------------------------- |
| **Getting Started**       | [📖 docs/user/getting-started.md](docs/user/getting-started.md)             |
| **Usage Examples**        | [📖 docs/user/usage-examples.md](docs/user/usage-examples.md)               |
| **Enterprise Deployment** | [📖 docs/user/enterprise-deployment.md](docs/user/enterprise-deployment.md) |
| **Configuration**         | [📖 docs/user/configuration.md](docs/user/configuration.md)                 |
| **Troubleshooting**       | [📖 docs/user/troubleshooting.md](docs/user/troubleshooting.md)             |
| **Development Setup**     | [📖 docs/developer/setup.md](docs/developer/setup.md)                       |
| **Architecture**          | [📖 docs/developer/architecture.md](docs/developer/architecture.md)         |

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

## 📦 Enterprise Deployment

```bash
# Export for air-gapped deployment
podman pull ghcr.io/opentechil/offline-python-runtime-docker:latest
podman save -o offline-python-runtime-docker.tar ghcr.io/opentechil/offline-python-runtime-docker:latest

# Deploy in offline environment
podman load -i offline-python-runtime-docker.tar
podman run -v ./app:/home/appuser/app:Z offline-python-runtime-docker:latest
```

## 🤝 Contributing

We welcome contributions! See [📖 docs/developer/contributing.md](docs/developer/contributing.md) for detailed guidelines.

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

---

**🚀 Ready for enterprise deployment?** 

📖 **Check our [complete documentation](docs/README.md)** for detailed guides, examples, and enterprise integration patterns.

**⭐ Star this repository** if you find it useful for your enterprise Python deployments!
