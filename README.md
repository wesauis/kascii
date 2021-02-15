# kascii

x86_64 kernel from wasm to c

This was made by following a video series by
[CodePulse](https://www.youtube.com/channel/UCUVahoidFA7F3Asfvamrm7w), the
playlist can be found
[here](https://www.youtube.com/watch?v=FkrpUaGThTQ&list=PLZQftyCk7_SeZRitx5MjBKzTtvk0pHMtp)

## Prerequisites

> remember to have this tools in your path

[Docker](https://www.docker.com/) for the build-environment

[QEMU](https://www.qemu.org/) for emulating our operating system

## Setup Build Environment

```sh
# buildenv: folder with the dockerfile
# kascii-env: container name

docker build buildenv --tag kascii-env
```

## Entering on the Build Environment

```sh
# Linux or MacOS: 
docker run --rm -it -v "$pwd":/root/env kascii-env

# Windows (CMD): 
docker run --rm -it -v "%cd%":/root/env kascii-env

# Windows (PowerShell): 
docker run --rm -it -v "${pwd}:/root/env" kascii-env

# --rm: remove container on exit
# -i: interactive mode
# -t: allocate a pseudo-TTY
# -v "<current_folder>:/root/env": mounts the current folter into the volume /root/env on the container
# kascii-env: container name used on setup
```
