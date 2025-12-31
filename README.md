# Offline Python Dockers Runtime
for offline air gapped enviorment 

## For Open Source Community

We welcome contributions from the open-source community to enhance Offline Python Dockers.

### Getting Started

To get started with OfflinePythonDockers, clone the repository and follow these steps:

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/offline-python-runtime-docker.git
    cd offline-python-runtime-docker
    ```
2.  **Build Docker images:**
    ```bash
    podman build . -t offline-python-runtime-docker:dev-latest-local
    
3. **Run python**
    TL;DR:
    ```bash
        podman run -v ./your-python-dir:/home/appuser/your-python-dir:Z \
        -it localhost:offline-python-runtime-docker:dev \
        python ./your-python-dir/file.py
    ```

    Full example:
    ```bash
    # Create folder to share with docker
    mkdir -p ./your-python-dir

    # Write a code
    echo 'print ("Hello world!")' > ./your-python-dir/file.py
    
    # Run it
    podman run \
        -v ./your-python-dir:/home/appuser/your-python-dir:Z \
        -it localhost/offline-python-runtime-docker:dev \
        python ./your-python-dir/file.py

    #output> Hello world!
    ```

### Contributing

We encourage contributions! Please read our `CONTRIBUTING.md` (to be created) for guidelines on:
*   Reporting bugs
*   Suggesting enhancements
*   Submitting pull requests
*   Code style and conventions

### License
This project is licensed under the MIT License. See the `LICENSE` file for details.
