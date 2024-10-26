<!--
SPDX-FileCopyrightText: 2024 Jonas Fierlings <fnoegip@gmail.com>

SPDX-License-Identifier: CC-BY-4.0
-->

# Project Architecture

Two central parts of the repository are the [bake file] and the [docker CI workflow].
The former defines which containers to build (and how),
whereas the latter is used for publishing the containers to [the projects container registry].

[bake file]: ../docker-bake.hcl
[docker CI workflow]: ../.github/workflows/docker.yaml
[the project container registry]: https://github.com/PigeonF?tab=packages&repo_name=containers

- [**The `.github/` folder**][.github] contains the project's CI/CD configuration.

[.github]:  ../.github/

- [**The `docker-bake.hcl` file**][bake file] describes how to build the containers for the
  repository.

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
