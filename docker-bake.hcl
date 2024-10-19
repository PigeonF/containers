# SPDX-FileCopyrightText: 2024 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: Unlicense

group "default" {
  targets = ["typos"]
}

target "_docker-metadata-action" {}

variable "TYPOS_VERSION" {
  default = "1.25.0"
}

target "_typos-version" {
  tags = [
    TYPOS_VERSION
  ]
}

target "typos" {
  inherits = ["_typos-version", "_docker-metadata-action"]
  context = "https://github.com/crate-ci/typos.git#v${TYPOS_VERSION}"
}
