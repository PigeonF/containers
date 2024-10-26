<!--
SPDX-FileCopyrightText: 2024 Jonas Fierlings <fnoegip@gmail.com>

SPDX-License-Identifier: CC-BY-4.0
-->

# Development Guide

Before working on the project,
please ensure that your editor is configured to follow the [EditorConfig] [configuration of the project].

[EditorConfig]: https://editorconfig.org
[configuration of the project]: ../.editorconfig

To work on the project,
you will need to install [docker].
Other container engines are currently not supported,
as I am not aware of other [bake] implementations.

[docker]: https://www.docker.com/
[bake]: https://docs.docker.com/build/bake/

## Building

You can build all containers by running `docker buildx bake`,
or you can pass a specific container to build.

```console
docker buildx bake
docker buildx bake typos
```

To make use of the containers,
load them into the docker daemon,
or push them to a registry.

```console
docker buildx bake typos --load
docker buildx bake typos --set "typos.tags=registry.com/typos:latest" --push
```
