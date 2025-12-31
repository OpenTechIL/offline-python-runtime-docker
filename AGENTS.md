# Agentic Coding Guidelines for Offline Python Dockers Runtime

This document outlines the guidelines for agentic coding within the `offline-python-runtime-docker` repository. Agents operating in this codebase should adhere to these conventions to ensure consistency, maintainability, and alignment with project standards.

## 1. Build, Lint, and Test Commands

### 1.1 Build Commands
The project uses `podman` for building Docker images.
-   **Build the main Docker image:**
    ```bash
    podman build . -t offline-python-runtime-docker:dev-latest-local
    ```

### 1.2 Test Commands
The project uses `pytest` for running tests. All Python code, including tests, is designed to run within the Docker container.

-   **Run all tests within Docker:**
    ```bash
    podman run -v ./py-apps:/home/appuser/py-apps:Z -it localhost/offline-python-runtime-docker:dev /usr/bin/python3 -m pytest /home/appuser/py-apps/tests/
    ```
-   **Run a single test file within Docker:**
    ```bash
    podman run -v ./py-apps:/home/appuser/py-apps:Z -it localhost/offline-python-runtime-docker:dev /usr/bin/python3 -m pytest /home/appuser/py-apps/tests/<test_file_name>.py
    ```
    (e.g., `podman run -v ./py-apps:/home/appuser/py-apps:Z -it localhost/offline-python-runtime-docker:dev /usr/bin/python3 -m pytest /home/appuser/py-apps/tests/test_imports.py`)
-   **Run a specific test within a file in Docker:**
    ```bash
    podman run -v ./py-apps:/home/appuser/py-apps:Z -it localhost/offline-python-runtime-docker:dev /usr/bin/python3 -m pytest /home/appuser/py-apps/tests/<test_file_name>.py::<test_function_name>
    ```
    (e.g., `podman run -v ./py-apps:/home/appuser/py-apps:Z -it localhost/offline-python-runtime-docker:dev /usr/bin/python3 -m pytest /home/appuser/py-apps/tests/test_imports.py::test_basic_import`)

### 1.3 Linting and Formatting
Currently, there is no explicit linting or formatting tool configured for this project (e.g., `flake8`, `black`, `ruff`). Agents should:
-   Adhere to [PEP 8](https://www.python.org/dev/peps/pep-0008/) for code style.
-   Follow the existing formatting observed in `py-apps/` files.
-   If new linting/formatting tools are introduced in the future, adapt to them.

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

## 3. Git Workflow
-   Development should primarily occur on the `develop` branch.
-   New features or significant changes should be implemented in dedicated feature branches, branched off from `develop`.
-   Follow a git-flow-like convention for branching and merging.

## 4. Cursor/Copilot Rules

No explicit `.cursor/rules/` or `.github/copilot-instructions.md` files were found in this repository. Agents should default to the general guidelines provided in this `AGENTS.md` and their inherent best practices.