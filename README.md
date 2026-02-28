<!--
SPDX-FileCopyrightText: 2024 Jonas Fierlings <fnoegip@gmail.com>

SPDX-License-Identifier: CC-BY-4.0
-->

# containers

This repository provides [container image](https://opencontainers.org/) builds of repositories that do not provide their own, or slightly adjusted upstream images.
The primary purpose is for use in [GitLab CI/CD](https://docs.gitlab.com/ee/ci/docker/using_docker_images.html), as well as for installation in other container images[^container-images-install].

[^container-images-install]: The easiest way to install an application in a container image without a package manager, is to copy the binary from a separate container image that already contains the binary.

## Actively maintained Containers

| Upstream Repository         | Container Image                                            | Architecture                                                               |
| --------------------------- | ---------------------------------------------------------- | -------------------------------------------------------------------------- |
| [crate-ci/typos]            | [`ghcr.io/pigeonf/containers/typos:1.43.4`][typos]         | `amd64`, `arm64` [^rust-target]                                            |
| [crate-ci/committed]        | [`ghcr.io/pigeonf/containers/committed:1.1.10`][committed] | `amd64`, `arm64` [^rust-target]                                            |

[crate-ci/typos]: https://github.com/crate-ci/typos
[typos]: https://github.com/PigeonF/containers/pkgs/container/containers%2Ftypos
[crate-ci/committed]: https://github.com/crate-ci/committed
[committed]: https://github.com/PigeonF/containers/pkgs/container/containers%2Fcommitted

[^rust-target]: The images are also built for `windows/arm64`, but are available under a separate tag (`<version>-ltsc`).
  See the package registry for details.

## Building

To build a container you have to call `docker bake` with the name of the container.
For example, to build the `typos` container

```console
docker buildx bake typos
```

## License

_This project is [REUSE] compliant_.

[REUSE]: https://reuse.software/spec/

Different parts of the work fall under different licenses[^license-summary]

[^license-summary]: The summary is for you to get a rough overview, not to give a comprehensive listing.

- Source code is dual licensed under `0BSD`.
- Documentation is licensed under `CC-BY-4.0`.
- Configuration files are licensed under `0BSD`.

Refer the files themselves for the licensing information of individual files.
Copies of the license text are available in the [`LICENSES/`](./LICENSES/) folder.
