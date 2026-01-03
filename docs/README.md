# 📚 Offline Python Runtime Docker Documentation

Welcome to the comprehensive documentation for the Offline Python Runtime Docker project. This containerized Python runtime is designed specifically for enterprise offline and air-gapped deployments.

## 🗂️ Documentation Structure

### 🧑‍💻 For Users

| 📖 Document | 📝 Description |
| ------------- | --------------- |
| [🚀 Getting Started](user/getting-started.md) | Complete setup and installation guide |
| [💻 Usage Examples](user/usage-examples.md) | Code examples and common workflows |
| [🏢 Enterprise Deployment](user/enterprise-deployment.md) | Air-gapped deployment and enterprise setup |
| [⚙️ Configuration](user/configuration.md) | Environment variables and configuration options |
| [🔧 Troubleshooting](user/troubleshooting.md) | Common issues and solutions |

### 👨‍💻 For Developers

| 📖 Document | 📝 Description |
| ------------- | --------------- |
| [🛠️ Development Setup](developer/setup.md) | Development environment and contribution guide |
| [🏗️ Architecture](developer/architecture.md) | System design and technical architecture |
| [🧪 Testing](developer/testing.md) | Test strategy and guidelines |
| [🤝 Contributing](developer/contributing.md) | Contribution guidelines and git flow |

### 📚 Reference

| 📖 Document | 📝 Description |
| ------------- | --------------- |
| [📦 Packages](reference/packages.md) | Complete list of pre-installed packages |
| [🔒 Security](reference/security.md) | Security features and compliance information |
| [🔌 API](reference/api.md) | Internal API documentation |

## 🎯 Quick Navigation

### I'm a new user who wants to...
- **Get started immediately**: [Getting Started](user/getting-started.md)
- **See what I can do with this**: [Usage Examples](user/usage-examples.md)
- **Deploy in my enterprise**: [Enterprise Deployment](user/enterprise-deployment.md)

### I'm a developer who wants to...
- **Contribute to the project**: [Development Setup](developer/setup.md)
- **Understand the architecture**: [Architecture](developer/architecture.md)
- **Write tests**: [Testing](developer/testing.md)

### I need to...
- **Configure the container**: [Configuration](user/configuration.md)
- **Troubleshoot issues**: [Troubleshooting](user/troubleshooting.md)
- **See what's included**: [Packages](reference/packages.md)
- **Understand security**: [Security](reference/security.md)

## 🏗️ Project Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Offline Python Runtime                   │
├─────────────────────────────────────────────────────────────┤
│  Application Layer (py-apps/)                              │
│  ├── main.py              # Entry point                    │
│  └── tests/               # Container validation tests     │
├─────────────────────────────────────────────────────────────┤
│  Python Runtime Environment                                │
│  ├── Python 3.13                                         │
│  ├── pip (user-space packages)                            │
│  └── Pre-installed libraries (26 packages)                │
├─────────────────────────────────────────────────────────────┤
│  Oracle Client Layer                                       │
│  ├── Oracle Instant Client 19.29                          │
│  ├── libaio and system dependencies                       │
│  └── Environment configuration                            │
├─────────────────────────────────────────────────────────────┤
│  Security Layer                                           │
│  ├── Non-root user (appuser)                             │
│  ├── SELinux context support                              │
│  └── Minimal attack surface                               │
└─────────────────────────────────────────────────────────────┘
```

## 🆘 Getting Help

- **📖 Documentation**: Navigate through the structured docs above
- **🐛 Issues**: [Open an issue](https://github.com/opentechil/offline-python-runtime-docker/issues) for bugs or questions
- **💬 Discussions**: [GitHub Discussions](https://github.com/opentechil/offline-python-runtime-docker/discussions) for community support
- **📧 Enterprise**: For enterprise support inquiries, please contact maintainers

---

**🚀 Ready to dive in?** Start with [Getting Started](user/getting-started.md) and you'll have a working enterprise Python runtime in minutes!