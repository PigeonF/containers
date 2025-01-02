# SPDX-FileCopyrightText: 2024 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD

group "default" {
  targets = ["typos"]
}

variable "IMAGE" {
  default = "pigeonf/containers/typos"
}

variable "TYPOS_VERSION" {
  default = "v1.29.3" # renovate: datasource=github-releases depName=crate-ci/typos
}

# Split into its own target, so that the docker metadata action can override the tags.
#
# This is added as a convenience for building the container locally (the actual version definition
# is in `.github/workflows/typos.yaml`).
target "_typos-version" {
  tags = [
    "${IMAGE}:${TYPOS_VERSION}"
  ]
}

target "typos" {
  inherits = ["_common", "_typos-version", "_docker-metadata-action"]
  context = "https://github.com/crate-ci/typos.git#${TYPOS_VERSION}"
  # NOTE(PigeonF): As of v1.26.1, `typos` releases only x86_64 prebuilt binaries for linux (see
  # <https://github.com/crate-ci/typos/releases/tag/v1.26.0>), so we follow the same pattern here.
  platforms = [
    "linux/amd64"
  ]
}
