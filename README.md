<!--
SPDX-FileCopyrightText: 2024 Jonas Fierlings <fnoegip@gmail.com>

SPDX-License-Identifier: CC-BY-4.0
-->

# containers

This repository provides [container image] builds of repositories that do not provide their own.
The primary purpose is for use in [GitLab CI/CD],
as well as for installation in other container images[^container-images-install].

[container image]: https://opencontainers.org/
[GitLab CI/CD]: https://docs.gitlab.com/ee/ci/docker/using_docker_images.html
[^container-images-install]: &ZeroWidthSpace;
  The easiest way to install an application in a container image without a package manager,
  is to copy the binary from a separate container image that already contains the binary.

## License

_This project is [REUSE] compliant_.

[REUSE]: https://reuse.software/spec/

Different parts of the work fall under different licenses[^license-summary]

[^license-summary]: &ZeroWidthSpace;
The summary is for you to get a rough overview,
not to give a comprehensive listing.

- Source code is dual licensed under `Unlicense`.
- Documentation is licensed under `CC-BY-4.0`.
- Configuration files are licensed under `CC0-1.0`.

Refer the files themselves for the licensing information of individual files.
Copies of the license text are available in the [`LICENSES/`](./LICENSES/) folder.
