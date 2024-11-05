# SPDX-FileCopyrightText: 2024 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: Unlicense

target "_docker-metadata-action" {}

target "_common" {
  args = {
    BUILDKIT_MULTI_PLATFORM = true
  }
}
