<!--
SPDX-FileCopyrightText: 2024 Jonas Fierlings <fnoegip@gmail.com>

SPDX-License-Identifier: CC-BY-4.0
-->

# containers

This repository provides [container image](https://opencontainers.org/) builds of repositories that do not provide their own, or slightly adjusted upstream images.
The primary purpose is for use in [GitLab CI/CD](https://docs.gitlab.com/ee/ci/docker/using_docker_images.html), as well as for installation in other container images[^container-images-install].

[^container-images-install]: The easiest way to install an application in a container image without a package manager, is to copy the binary from a separate container image that already contains the binary.

## Available Containers

| Upstream Repository         | Container Image                                           | Architecture                                                               |
| --------------------------- | --------------------------------------------------------- | -------------------------------------------------------------------------- |
| [crate-ci/typos]            | [`ghcr.io/pigeonf/containers/typos:1.28.2`][typos]        | `amd64` [^crate-ci-arch]                                                   |
| [crate-ci/committed]        | [`ghcr.io/pigeonf/containers/committed:1.1.2`][committed] | `amd64` [^crate-ci-arch]                                                   |
| [moby/buildkit] [^buildkit] | [`ghcr.io/pigeonf/containers/buildkit`][buildkit]         | `amd64`, `arm/v7`, `arm64`, `s390x`, `ppc64le`, `riscv64` [^buildkit-arch] |

[crate-ci/typos]: https://github.com/crate-ci/typos
[typos]: https://github.com/PigeonF/containers/pkgs/container/containers%2Ftypos
[crate-ci/committed]: https://github.com/crate-ci/committed
[committed]: https://github.com/PigeonF/containers/pkgs/container/containers%2Fcommitted
[moby/buildkit]: https://github.com/moby/buildkit
[buildkit]: https://github.com/PigeonF/containers/pkgs/container/containers%2Fbuildkit

[^buildkit]: This is a copy of the [upstream buildkit container](https://hub.docker.com/r/moby/buildkit).
  The only difference is an added `EXPOSE` instruction so that the buildkit container can be used as a [GitLab CI/CD service](https://docs.gitlab.com/ee/ci/services/).

[^buildkit-arch]: The same architectures as the upstream image.

[^crate-ci-arch]: This corresponds to the same architectures as the upstream prebuilt binaries for linux.
  If you have a need for additional architectures, feel free to [open a pull request](https://github.com/PigeonF/containers/pulls), or [an issue](https://github.com/PigeonF/containers/issues).

## Building

To build a container you have to call `docker bake` with both [`docker-bake.hcl`](./docker-bake.hcl), and the [container hcl file](./containers/).
For example, to build the `typos` container

```console
docker buildx bake -f docker-bake.hcl -f containers/typos.hcl
```

For more detailed instructions, refer to the [developer documentation](./docs/developing.md).

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
