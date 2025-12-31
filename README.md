# Offline Python Dockers Runtime

This project provides a runtime environment for Python applications designed for offline, air-gapped environments.


### Getting Started

To get started with OfflinePythonDockers, clone the repository and follow these steps:

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/opentechil/offline-python-runtime-docker.git
    cd offline-python-runtime-docker
    ```
2.  **Build Docker images:**
    ```bash
    podman build . -t offline-python-runtime-docker:dev-latest-local
    
3. **Run python**
    TL;DR:
    ```bash
        podman run -v ./your-python-dir:/home/appuser/your-python-dir:Z \
        -it localhost/offline-python-runtime-docker:dev \
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

We encourage contributions! Please read our [`CONTRIBUTORS.md`](./CONTRIBUTORS.md) for guidelines on:
*   Reporting bugs
*   Suggesting enhancements
*   Submitting pull requests
*   Code style and conventions

### License
This project is licensed under the MIT License. See the `LICENSE` file for details.
