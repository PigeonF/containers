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
as I am not aware of any other [bake] implementations.

[docker]: https://www.docker.com/
[bake]: https://docs.docker.com/build/bake/

Before hacking on the project,
you might want to read the [high level project documentation](./README.md).

## Building

Containers are built using `docker build bake`.
The container definitions are split across multiple files,
so that the [CI/CD configuration] can use fine grained checks to decide whether a container needs a rebuild.

[CI/CD Configuration]: ../.github/workflows/

The top level [`docker-bake.hcl`] contains definitions that are shared across all container definition files.

[`docker-bake.hcl`]: ../docker-bake.hcl

To build,
pass both the [`docker-bake.hcl`] file,
as well as the container definition file to `docker buildx bake`.
For example,
to build the [`typos`] container

[`typos`]: ../containers/typos.hcl

```console
cd /path/to/repository/
docker buildx bake -f docker-bake.hcl -f containers/typos.hcl
```

To make use of the containers,
load them into the docker daemon,
or push them to a registry.

```console
docker buildx bake -f docker-bake.hcl -f containers/typos.hcl --load
IMAGE=registry.com/typos docker buildx bake -f docker-bake.hcl -f containers/typos.hcl --push
```
