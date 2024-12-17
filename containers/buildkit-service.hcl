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
        digest = "sha256:86c0ad9d1137c186e9d455912167df20e530bdf7f7c19de802e892bb8ca16552"
      },
      {
        # renovate: datasource=docker depName=docker.io/moby/buildkit
        tag = "buildx-stable-1-rootless"
        digest = "sha256:95da42806e4e3e3d3cb72f84286446ab5aa60e9c69c521e8b4c72d0c283b4593"
      },
      {
        # renovate: datasource=docker depName=docker.io/moby/buildkit
        tag = "v0.18.2"
        digest = "sha256:86c0ad9d1137c186e9d455912167df20e530bdf7f7c19de802e892bb8ca16552"
      },
      {
        # renovate: datasource=docker depName=docker.io/moby/buildkit
        tag = "v0.18.2-rootless"
        digest = "sha256:95da42806e4e3e3d3cb72f84286446ab5aa60e9c69c521e8b4c72d0c283b4593"
      },
      {
        # renovate: datasource=docker depName=docker.io/moby/buildkit
        tag = "latest"
        digest = "sha256:86c0ad9d1137c186e9d455912167df20e530bdf7f7c19de802e892bb8ca16552"
      },
      {
        # renovate: datasource=docker depName=docker.io/moby/buildkit
        tag = "rootless"
        digest = "sha256:95da42806e4e3e3d3cb72f84286446ab5aa60e9c69c521e8b4c72d0c283b4593"
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
