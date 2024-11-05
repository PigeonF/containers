# SPDX-FileCopyrightText: 2024 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: Unlicense

group "default" {
  targets = ["committed"]
}

variable "COMMITTED_VERSION" {
  default = "v1.1.1" # renovate: datasource=github-releases depName=crate-ci/committed
}

target "_committed-version" {
  tags = [
    "pigeonf/containers/committed:${COMMITTED_VERSION}"
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
