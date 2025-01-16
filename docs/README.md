<!--
SPDX-FileCopyrightText: 2024 Jonas Fierlings <fnoegip@gmail.com>

SPDX-License-Identifier: CC-BY-4.0
-->

# Project Documentation

- [Read notes about how to hack on the project](./developing.md)
- [Read the maintainer guide](./maintenance.md)

## Project Goals

The purpose of the repository is to provide easy access to tools that can be used in [GitLab CI/CD].
The easiest way to do so is to provide a [docker image](https://docs.gitlab.com/ee/ci/docker/using_docker_images.html) that contains the desired tool(s).
As some projects do not provide ready container images, or provides container images that need additional modifications to work with [GitLab CI/CD], this project provides them instead.

[GitLab CI/CD]: https://docs.gitlab.com/ee/ci/

## Repository Layout

Two central parts of the repository are the [bake file](../docker-bake.hcl) and the [docker CI workflow](../.github/workflows/docker.yaml).
The former defines which containers to build (and how), whereas the latter is used for publishing the containers to [the project's container registry][container registry].

[container registry]: https://github.com/PigeonF?tab=packages&repo_name=containers

- [**The `.github/` folder**](../.github/) contains the project's CI/CD configuration.

  The CI/CD configuration builds the containers during merge requests and merges to the `main` branch.
  When a changed container configuration is merged into `main`, the CI/CD configuration will automatically build and push the new container image to the [container registry].

- [**The `docker-bake.hcl` file**](../docker-bake.hcl) contains definitions on how to build the containers using `docker buildx bake`.

- [**The `docker/` folder**](../docker/) contains dockerfiles that are shared between multiple containers.

  - [**The `rust.Dockerfile`**](../docker/rust.Dockerfile) is used to build glibc and msvc binaries from a rust project.

- [**The `docs/` folder**](../docs/) contains project documentation.

- [**The `LICENSES/` folder**](../LICENSES/) contains a copy of the project's licenses.

The remaining files (such as [`.editorconfig`](../.editorconfig), or [`renovate.json5`](../renovate.json5)) configuration files[^configuration-files], and are not overly important for the project itself.

[^configuration-files]: If you feel like one of these files should be mentioned in this document, feel free to [open an issue](https://github.com/PigeonF/containers/issues), or [add them in a pull request](https://github.com/PigeonF/containers/pulls).
