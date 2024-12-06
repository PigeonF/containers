# SPDX-FileCopyrightText: 2024 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD

target "_docker-metadata-action" {}

target "_common" {
  output = ["type=image,rewrite-timestamp=true,oci-mediatypes=true"]
  args = {
    BUILDKIT_MULTI_PLATFORM = true
  }
}
