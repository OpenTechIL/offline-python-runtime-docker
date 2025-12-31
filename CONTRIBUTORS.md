# Project Contributors

This file lists the individuals who have contributed to the OpenTech (R.A.) docker project.

## How to contribute
*   Reporting bugs
*   Suggesting Enhancements
*   Submitting pull requests
*   Code style and conventions

## Develop / fix
use git flow method
0. create `feature` branch or `bugfix` (see git flow)
1. Do some changes
2. commit and push

### Git Flow

This project utilizes `git-flow` for its branching model, which helps organize development and release cycles. Please adhere to the following `git-flow` conventions:

*   **`develop` Branch:** This is the main development branch where all new features are integrated. `feature` branches are always merged into `develop`.
*   **`feature` Branches:** Use `git flow feature start <feature-name>` for new features. These branches should be based off `develop` and merged back into `develop`.
*   **`release` Branch:** This branch contains the official release history. Use `git flow release start <version>` when preparing a new release. These branches are based off `develop` and are merged into `release` (for official releases) and `develop` (to ensure feature parity).
*   **`hotfix` Branches:** Use `git flow hotfix start <hotfix-name>` for urgent bug fixes on `release`. These branches are based off `release` and merged into both `release` and `develop`.
*   **`bugfix` Branches:** Use `git flow bugfix start <bugfix-name>` for new bugfixes. These branches should be based off `develop` and merged back into `develop`.

## How to push image (for authorized)

after developing you sould build
```bash
# Build
podman build . -t offline-python-runtime-docker:dev-latest-local

# Create ghcr tag
podman tag localhost/offline-python-runtime-docker:dev-latest-local \
    ghcr.io/opentechil/offline-python-runtime-docker:v-SOME-VER

# push
podman push ghcr.io/opentechil/offline-python-runtime-docker:v-SOME-VER
```
## How to add yourself

If you've contributed to this project, please add your name and (optionally) your GitHub username or other contact information to this list.

Example:

*   Your Name (@your-github-username)

## Current Contributors
*   Yehuda Korotkin (@alefbt)

