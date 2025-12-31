# Offline Python Dockers Runtime

This project provides a runtime environment for Python applications designed for offline, air-gapped environments.


## Getting Started

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

## How To
### Add python package for offline
1. just edit the `requirements.txt` file and add packages
2. build docker `podman build . -t offline-python-runtime-docker:dev-latest-local`
3. run it

### Export to offline use
- Just use `podman save -o my-offline-py.tar offline-python-runtime-docker:dev-latest-local`
- copy the tar
- then `podman load -i my-offline-py.tar`

## Troubleshooting

### Space on linux 
some times becuse limit `/tmp` folder 

    copying layers and metadata for container "": initializing source
     containers-storage:working-container: storing layer "" to file: on copy: 
     writing to tar filter pipe (closed=false,err=reading tar archive: 
     copying content for "home/appuser/.local/lib/python3.13/site-packages/package/somefile.py":
     write /var/tmp/buildah35812317/layer: no space left on device):
     write /var/tmp/buildah35812317/layer: no space left on device

Solution:
```bash
    mkdir -p ~/podman-tmp
    export TMPDIR=~/podman-tmp
```

## Contributing

We encourage contributions! Please read our [`CONTRIBUTORS.md`](./CONTRIBUTORS.md) for guidelines on:
*   Reporting bugs
*   Suggesting enhancements
*   Submitting pull requests
*   Code style and conventions

## License
This project is licensed under the MIT License. See the `LICENSE` file for details.
