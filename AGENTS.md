# Agentic Coding Guidelines for Offline Python Dockers Runtime

This document outlines the guidelines for agentic coding within the `offline-python-runtime-docker` repository. This is a **Docker project** that provides a complete Python runtime environment for enterprise offline/air-gapped deployments. Agents operating in this codebase should adhere to these conventions to ensure consistency, maintainability, and alignment with enterprise standards.

## 1. Container Build, Deployment, and Testing Commands

### 1.1 Build Commands
The project uses `podman` for building Docker images (compatible with `docker`).

-   **Build the main Docker image:**
    ```bash
    podman build . -t offline-python-runtime-docker:dev-latest-local
    ```

-   **Build with custom tag for enterprise deployment:**
    ```bash
    podman build . -t offline-python-runtime-docker:v1.0.0-enterprise
    ```

### 1.2 Container Testing Commands
Tests are integrated into the Docker build process and validate container runtime readiness.

-   **Build-time testing (automated):** Tests run during `podman build` via `RUN pytest -v py-apps/tests/`
-   **Runtime testing (manual):**
    ```bash
    # Test container startup and package imports
    podman run -it localhost/offline-python-runtime-docker:dev python -c "import oracledb, pytest; print('✅ Container validation passed')"
    
    # Test Oracle client connectivity
    podman run -it localhost/offline-python-runtime-docker:dev python /home/appuser/py-apps/tests/test_thick_oracle.py
    ```

-   **Development testing with volume mounts:**
    ```bash
    # Run tests with local code changes
    podman run -v ./py-apps:/home/appuser/py-apps:Z \
               -it localhost/offline-python-runtime-docker:dev \
               /usr/bin/python3 -m pytest /home/appuser/py-apps/tests/
    ```

### 1.3 Enterprise Offline Deployment Commands

-   **Export container for air-gapped transfer:**
    ```bash
    podman save -o offline-python-runtime-docker.tar ghcr.io/opentechil/offline-python-runtime-docker:latest
    ```

-   **Load container in offline environment:**
    ```bash
    podman load -i offline-python-runtime-docker.tar
    ```

-   **Enterprise registry operations:**
    ```bash
    # Tag for enterprise registry
    podman tag localhost/offline-python-runtime-docker:dev-latest-local \
        enterprise-registry.company.com/offline-python-runtime:enterprise-latest
    
    # Push to enterprise registry
    podman push enterprise-registry.company.com/offline-python-runtime:enterprise-latest
    ```

### 1.4 Linting and Formatting
Currently, there is no explicit linting or formatting tool configured for this project. Agents should:
-   Follow the existing pragmatic patterns observed in `py-apps/` files
-   Prioritize container compatibility over strict PEP 8 compliance
-   Focus on runtime reliability in offline environments

## 2. Code Style Guidelines

### 2.1 Imports
-   Imports should be organized according to PEP 8:
    1.  Standard library imports.
    2.  Third-party imports.
    3.  Local application/library-specific imports.
-   Each group should be separated by a blank line.
-   Absolute imports are preferred over relative imports where feasible for clarity.

### 2.2 Formatting
-   **Indentation:** Use 4 spaces for indentation.
-   **Line Length:** Aim for a maximum of 79 characters per line, as per PEP 8.
-   **Blank Lines:**
    -   Surround top-level function and class definitions with two blank lines.
    -   Method definitions inside a class should be surrounded by one blank line.
    -   Use blank lines sparingly to improve readability within functions.

### 2.3 Types (Type Hinting)
-   While existing code may not extensively use type hints, agents are strongly encouraged to use [PEP 484](https://www.python.org/dev/peps/pep-0008/) style type hints for new code and when modifying existing functions.
-   This improves code clarity, maintainability, and enables static analysis.

### 2.4 Naming Conventions
-   **Modules:** lowercase_with_underscores (e.g., `my_module.py`).
-   **Packages:** lowercase_with_underscores (e.g., `my_package/`).
-   **Classes:** CapWords (e.g., `MyClass`).
-   **Functions/Methods:** lowercase_with_underscores (e.g., `my_function`, `my_method`).
-   **Variables:** lowercase_with_underscores (e.g., `my_variable`).
-   **Constants:** ALL_CAPS_WITH_UNDERSCORES (e.g., `MY_CONSTANT`).
-   **Private Members:** Prefix with a single underscore (e.g., `_private_method`).

### 2.5 Error Handling
-   Use Python's exception handling mechanisms (`try`, `except`, `finally`, `else`).
-   Be specific with exception types rather than catching a broad `Exception`.
-   Provide meaningful error messages.
-   Log errors appropriately, if a logging framework is present. Otherwise, print to stderr.

### 2.6 Documentation
-   Use [PEP 257](https://www.python.org/dev/peps/pep-0257/) docstring conventions for modules, classes, and functions.
-   Provide clear, concise, and comprehensive docstrings explaining the purpose, arguments, and return values.

## 3. Enterprise Development Patterns

### 3.1 Oracle Client Integration
-   **Environment Variables Required**: `ORACLE_INSTANTCLIENT_PATH`, `ORACLE_HOME`, `LD_LIBRARY_PATH`
-   **Thick Mode Initialization**: `oracledb.init_oracle_client(lib_dir=oracle_instantclient_path)`
-   **Testing Pattern**: Always validate Oracle client connectivity in container runtime
-   **Error Handling**: Use `sys.exit(1)` for Oracle client initialization failures

### 3.2 Container Volume Mounting
-   **Development Pattern**: Mount code to `/home/appuser/your-dir:Z` for SELinux compatibility
-   **User Context**: All operations run as non-root `appuser` user
-   **Working Directory**: `/home/appuser` is the container working directory
-   **Python Path**: User packages installed in `/home/appuser/.local/bin`

### 3.3 Offline Dependency Management
-   **Single Source of Truth**: `requirements.txt` contains all Python dependencies
-   **No Runtime Downloads**: Container must be fully self-contained for offline use
-   **System Dependencies**: Oracle client libraries pre-installed in container
-   **Package Installation**: Use `pip install --user -r requirements.txt` in Dockerfile

## 4. Git Workflow
-   Development should primarily occur on the `develop` branch.
-   New features or significant changes should be implemented in dedicated feature branches, branched off from `develop`.
-   Follow git-flow conventions (see CONTRIBUTORS.md for detailed branching model):
    -   `git flow feature start <name>` for new features
    -   `git flow release start <version>` for releases
    -   `git flow hotfix start <name>` for urgent fixes
    -   `git flow bugfix start <name>` for bug fixes

## 5. Cursor/Copilot Rules

No explicit `.cursor/rules/` or `.github/copilot-instructions.md` files were found in this repository. Agents should default to the general guidelines provided in this `AGENTS.md` and their inherent best practices.