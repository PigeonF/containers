# SPDX-FileCopyrightText: 2024 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD

group "default" {
  targets = ["buildkit-service"]
}

variable "IMAGE" {
  default = "pigeonf/containers/buildkit"
}

variable "BUILDKIT_PORT" {
  default = "3375"
}

target "buildkit-service" {
  inherits = ["_common", "_docker-metadata-action"]
  name = "buildkit-${replace(item.tag, ".", "-")}"
  dockerfile-inline = <<EOT
    FROM docker.io/moby/buildkit:${item.tag}@${item.digest}
    EXPOSE ${BUILDKIT_PORT}
    CMD ["--oci-worker-no-process-sandbox", "--addr", "tcp://:${BUILDKIT_PORT}"]
  EOT
  tags = [
    "${lower(IMAGE)}:${item.tag}"
  ]
  matrix = {
    item = [
      {
        # renovate: datasource=docker depName=docker.io/moby/buildkit
        tag = "buildx-stable-1"
        digest = "sha256:58e6d150a3c5a4b92e99ea8df2cbe976ad6d2ae5beab39214e84fada05b059d5"
      },
      {
        # renovate: datasource=docker depName=docker.io/moby/buildkit
        tag = "buildx-stable-1-rootless"
        digest = "sha256:8e70f1e38c50ec5ac8e8fb861c837e9e7b2350ccb90b10e429733f8bda3b7809"
      },
      {
        # renovate: datasource=docker depName=docker.io/moby/buildkit
        tag = "v0.18.1"
        digest = "sha256:58e6d150a3c5a4b92e99ea8df2cbe976ad6d2ae5beab39214e84fada05b059d5"
      },
      {
        # renovate: datasource=docker depName=docker.io/moby/buildkit
        tag = "v0.18.1-rootless"
        digest = "sha256:8e70f1e38c50ec5ac8e8fb861c837e9e7b2350ccb90b10e429733f8bda3b7809"
      },
      {
        # renovate: datasource=docker depName=docker.io/moby/buildkit
        tag = "latest"
        digest = "sha256:58e6d150a3c5a4b92e99ea8df2cbe976ad6d2ae5beab39214e84fada05b059d5"
      },
      {
        # renovate: datasource=docker depName=docker.io/moby/buildkit
        tag = "rootless"
        digest = "sha256:8e70f1e38c50ec5ac8e8fb861c837e9e7b2350ccb90b10e429733f8bda3b7809"
      },
    ]
  }
  platforms = [
    "linux/amd64",
    "linux/arm/v7",
    "linux/arm64",
    "linux/s390x",
    "linux/ppc64le",
    "linux/riscv64",
  ]
}
