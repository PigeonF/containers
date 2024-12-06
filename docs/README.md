<!--
SPDX-FileCopyrightText: 2024 Jonas Fierlings <fnoegip@gmail.com>

SPDX-License-Identifier: CC-BY-4.0
-->

# Project Documentation

- [Read notes about how to hack on the project](./developing.md)
- [Read the maintainer guide](./maintenance.md)

## Project Goals

The purpose of the repository is to provide easy access to tools that can be used in [GitLab CI/CD].
The easiest way to do so is to provide a [docker image] that contains the desired tool(s).
As some projects do not provide ready container images,
or provides container images that need additional modifications to work with [GitLab CI/CD],
this project provides them instead.

[GitLab CI/CD]: https://docs.gitlab.com/ee/ci/
[docker image]: https://docs.gitlab.com/ee/ci/docker/using_docker_images.html

## Project Design

To ease maintenance of the repository,
the container are images built from upstream [Dockerfile] definitions where possible.
This is possible by using the upstream repositories as the [docker build context].

[Dockerfile]: https://docs.docker.com/reference/dockerfile/
[docker build context]: https://docs.docker.com/build/concepts/context/#remote-context

## Repository Layout

Two central parts of the repository are the [bake files][containers] and the [docker CI workflow].
The former defines which containers to build (and how),
whereas the latter is used for publishing the containers to [the project's container registry][container registry].

[containers]: ../containers/
[docker CI workflow]: ../.github/workflows/docker.yaml
[container registry]: https://github.com/PigeonF?tab=packages&repo_name=containers

- [**The `.github/` folder**][.github] contains the project's CI/CD configuration.

  The CI/CD configuration builds the containers during merge requests and merges to the `main` branch.
  When a changed container configuration is merged into `main`,
  the CI/CD configuration will automatically build and push the new container image to the [container registry].

[.github]:  ../.github/

- [**The `docker-bake.hcl` file**][bake file] contains common configuration that is shared between all container definitions.

[bake file]: ../docker-bake.hcl

- [**The `containers/` folder**][containers] contains definitions on how to build the containers using `docker buildx bake`.

  - [**The `buildkit` container**][buildkit] modifies the [official container][buildkit-container] for <https://github.com/moby/buildkit>,
    so that it can be used as a [GitLab CI/CD service][gitlab-service]

  - [**The `committed` container**][committed] builds the <https://github.com/crate-ci/committed> git commit linter.

  - [**The `typos` container**][typos] builds the <https://github.com/crate-ci/typos> spell checker.

[buildkit]: ../containers/buildkit-service.hcl
[buildkit-container]: hub.docker.com/r/moby/buildkit/
[committed]: ../containers/committed.hcl
[typos]: ../containers/typos.hcl
[gitlab-service]: https://docs.gitlab.com/ee/ci/services/

- [**The `docs/` folder**][docs] contains project documentation.

[docs]: ../docs/

- [**The `LICENSES/` folder**][LICENSES] contains a copy of the project's licenses.

[LICENSES]: ../LICENSES/

The remaining files
(such as [`.editorconfig`], or [`renovate.json5`])
are likely for configuring
The remaining files are likely[^likely-files] configuration files,
and are not overly important for the project.

[`.editorconfig`]: ../.editorconfig
[`renovate.json5`]: ../renovate.json5

[^likely-files]: &ZeroWidthSpace;
If you feel like one of these files should be mentioned in this document,
feel free to [open an issue],
or [create a pull request].

[open an issue]: https://github.com/PigeonF/containers/issues
[create a pull request]: https://github.com/PigeonF/containers/pulls
