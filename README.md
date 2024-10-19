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
