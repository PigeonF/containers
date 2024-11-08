# SPDX-FileCopyrightText: 2024 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: Unlicense

group "default" {
  targets = ["typos"]
}

variable "TYPOS_VERSION" {
  default = "v1.27.3" # renovate: datasource=github-releases depName=crate-ci/typos
}

target "_typos-version" {
  tags = [
    "pigeonf/containers/typos:${TYPOS_VERSION}"
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
