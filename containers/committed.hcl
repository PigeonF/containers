# SPDX-FileCopyrightText: 2024 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD

group "default" {
  targets = ["committed"]
}

variable "IMAGE" {
  default = "pigeonf/containers/committed"
}

variable "COMMITTED_VERSION" {
  default = "v1.1.2" # renovate: datasource=github-releases depName=crate-ci/committed
}

# Split into its own target, so that the docker metadata action can override the tags.
#
# This is added as a convenience for building the container locally (the actual version definition
# is in `.github/workflows/committed.yaml`).
target "_committed-version" {
  tags = [
    "${IMAGE}:${COMMITTED_VERSION}"
  ]
}

target "committed" {
  inherits = ["_common", "_committed-version", "_docker-metadata-action"]
  context = "https://github.com/crate-ci/committed.git#${COMMITTED_VERSION}"
  # NOTE(PigeonF): As of v1.0.20, `committed` releases only x86_64 prebuilt binaries for linux (see
  # <https://github.com/crate-ci/committed/releases/tag/v1.0.20>), so we follow the same pattern here.
  platforms = [
    "linux/amd64"
  ]
}
