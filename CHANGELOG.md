# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-01-07

### 🚀 Added
- **Wheelhouse Architecture**: Implemented multi-level Python package management system for enhanced offline deployment
  - `requirements-global.txt` - Installs packages globally in the base Python environment
  - `requirements-wheelhouse.txt` - Downloads wheel files to `/lib/python_wheelhouse` for offline usage
  - `requirements.txt` - Installs application-specific packages from wheelhouse to user environment
- **Global pip Configuration**: Added `/etc/pip.conf` to automatically use wheelhouse for package installations
- **Optimized Container Size**: Reduced final image size through more efficient dependency management
- **Development Build Support**: Added `podman build . -t offline-python-runtime:dev` command for development builds

### 🏢 Enterprise Features
- **Three-Tier Package Installation**:
  - **Global Scope**: System-wide Python packages
  - **Wheelhouse Scope**: Pre-downloaded packages for offline installation
  - **Local Scope**: User-specific application packages
- **Enhanced Offline Capabilities**: Complete air-gapped deployment with pre-cached wheel files
- **Improved Dependency Isolation**: Better separation between system and user packages

### 🔧 Technical Improvements
- **Build Process Enhancement**: Streamlined Docker build with optimized layer caching
- **Package Management**: Enhanced pip configuration for reliable offline operations
- **User Environment**: Improved appuser setup with dedicated local package installation

### 📦 Package Updates
- Added comprehensive data science stack to wheelhouse (pandas, numpy, scikit-learn, matplotlib)
- Enhanced database connectivity (oracledb, pymongo, pyarrow, sqlalchemy)
- Development tools (pytest, pydebug, ipykernel) properly separated across installation tiers

## [1.0.0] - 2025-12-XX

### 🎉 Initial Release
- **Offline Python Runtime**: Complete containerized Python environment for air-gapped deployments
- **Oracle Database Integration**: Full Oracle Instant Client 19.29 with thick mode support
- **Security Hardening**: Non-root user configuration, SELinux compatibility
- **Data Science Stack**: Pre-installed pandas, numpy, and essential data science libraries
- **Enterprise Ready**: Multi-database support and ETL tools
- **Comprehensive Testing**: Integrated test suite for container validation

### 🏗️ Architecture
- **Base Image**: Python 3.13-slim-trixie
- **Oracle Client**: Instant Client 19.29 with proper library linking
- **Security**: Non-root appuser with minimal attack surface
- **Testing**: Pytest-based validation during container build

---

## Upgrade Instructions

### From 1.0.0 to 1.1.0
The new wheelhouse architecture is backward compatible. No changes required to existing deployments.

### Development Migration
For development builds, use:
```bash
# New development build command
podman build . -t offline-python-runtime:dev

# Production builds remain unchanged
podman build . -t offline-python-runtime:latest
```