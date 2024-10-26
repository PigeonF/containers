<!--
SPDX-FileCopyrightText: 2024 Jonas Fierlings <fnoegip@gmail.com>

SPDX-License-Identifier: CC-BY-4.0
-->

# Project Design

The purpose of the repository is to provide easy access to tools that can be used in [GitLab CI/CD].
The easiest way to do so is to provide a [docker image] that contains the desired tool(s).
As some projects do not provide ready container images,
this project provides them instead.

[GitLab CI/CD]: https://docs.gitlab.com/ee/ci/
[docker image]: https://docs.gitlab.com/ee/ci/docker/using_docker_images.html

To ease maintenance of the repository,
the container are images built from upstream [Dockerfile] definitions where possible.
This is possible by using the upstream repositories as the [docker build context].

[Dockerfile]: https://docs.docker.com/reference/dockerfile/
[docker build context]: https://docs.docker.com/build/concepts/context/#remote-context

The repository is for my personal use,
but I am open to suggestion and extending the list of available container images,
as well as the list of architectures for which the container images are built.
