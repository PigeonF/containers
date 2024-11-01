# SPDX-FileCopyrightText: 2024 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: Unlicense

group "default" {
  targets = ["typos"]
}

target "_docker-metadata-action" {}

target "_common" {
  args = {
    BUILDKIT_MULTI_PLATFORM = true
  }
}

# ====
# Versions
# ====

# NOTE(PigeonF): Use separate targets to inherit from, so that the _docker-metadata-action can
# override the tags during CI.
variable "TYPOS_VERSION" {
  default = "v1.27.0" # renovate: datasource=github-releases depName=crate-ci/typos
}

target "_typos-version" {
  tags = [
    "pigeonf/containers/typos:${TYPOS_VERSION}"
  ]
}

variable "COMMITTED_VERSION" {
  default = "v1.1.1" # renovate: datasource=github-releases depName=crate-ci/committed
}

target "_committed-version" {
  tags = [
    "pigeonf/containers/committed:${COMMITTED_VERSION}"
  ]
}

# ====
# Dockerfile targets
# ====

target "typos" {
  inherits = ["_common", "_typos-version", "_docker-metadata-action"]
  context = "https://github.com/crate-ci/typos.git#${TYPOS_VERSION}"
  # NOTE(PigeonF): As of v1.26.1, `typos` releases only x86_64 prebuilt binaries for linux (see
  # <https://github.com/crate-ci/typos/releases/tag/v1.26.0>), so we follow the same pattern here.
  platforms = [
    "linux/amd64"
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
