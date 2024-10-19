# SPDX-FileCopyrightText: 2024 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: Unlicense

group "default" {
  targets = ["typos"]
}

variable "TYPOS_VERSION" {
  default = "1.25.0"
}

target "typos" {
  context = "https://github.com/crate-ci/typos.git#v${TYPOS_VERSION}"
  tags = [
    TYPOS_VERSION
  ]
}
