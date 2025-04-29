# SPDX-FileCopyrightText: 2024 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD

# Convert the `version` into tags, combined with the `suffixes`.
#
# ## Examples
#
# ```hcl
# > gettags("1.2.3", ["", "alpine"])
# ["1.2.3", "1.2", "1", "latest", "1.2.3-alpine", "1.2-alpine", "1-alpine"]
# > gettags("", ["", "alpine"])
# ["edge", "edge-alpine"]
# > gettags("foo", [])
# ["foo"]
# ```
function "gettags" {
  params = [version, suffixes]
  result = compact(
    flatten([
      for suffix in distinct(coalescelist(suffixes, [""])): [
        for tag in coalescelist(
          compact(
            length(regexall("^v?(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)$", version)) > 0 ?
            concat(semver(split(".", trimprefix(version, "v"))), [suffix == "" ? "latest" : ""]) :
            [version]
          ),
          ["edge"]
        ): join("-", compact([tag, suffix]))
      ]
    ])
  )
}

# Return the tags for the semver `components`.
#
# ## Examples
#
# ```hcl
# > semver(["1", "2", "3"])
# ["1.2.3", "1.2", "1"]
# > semver(["0", "1", "0"])
# ["0.1.0", "0.1"]
# ```
function "semver" {
  params = [components]
  result = compact([
    "${components[0]}.${components[1]}.${components[2]}",
    "${components[0]}.${components[1]}",
    (components[0] > 0 ? components[0] : ""),
  ])
}

# Combine the `images` and `tags`.
function "combinetags" {
  params = [images, tags]
  result = [for tup in setproduct(compact(images), compact(tags)): join(":", tup)]
}

target "_common" {
  output = ["type=image,rewrite-timestamp=true,oci-mediatypes=true"]
  args = {
    BUILDKIT_MULTI_PLATFORM = true
  }
}

variable "IMAGE_BASE" {
  default = "ghcr.io/pigeonf/containers"
}

variable "_base-images" {
  default = {
    linux = {
      # renovate: versioning=debian
      name = "docker.io/library/debian"
      tag = "bookworm-slim"
      digest = "sha256:4b50eb66f977b4062683ff434ef18ac191da862dbe966961bc11990cf5791a8d"
      suffixes = ["", "bookworm"]
      platforms = ["linux/amd64", "linux/arm64"]
      rustflags = "-C target-feature=-crt-static"
    }
    windows = {
      # renovate:
      name = "mcr.microsoft.com/windows/nanoserver"
      tag = "ltsc2025"
      digest = "sha256:79b3923446b9be661f27cdc0ad2af410da24bb6af519b87d2cfc534e1f65b4ca"
      suffixes = ["ltsc", "ltsc2025"]
      platforms = ["windows/amd64"]
      rustflags = "-C target-feature=+crt-static"
    }
  }
}

target "rust" {
  name = "${crates.name}-${base}"
  matrix = {
    crates = [
      {
        name = "committed"
        crate = "committed"
        description = "Nitpicking commit history since beabf39"
        licenses = "Apache-2.0 OR MIT"
        project = "https://github.com/crate-ci/committed.git#${COMMITTED_TAG}"
        tag = COMMITTED_TAG
      },
      {
        name = "typos"
        crate = "typos-cli"
        description = "Source code spell checker"
        licenses = "Apache-2.0 OR MIT"
        project = "https://github.com/crate-ci/typos.git#${TYPOS_TAG}"
        tag = TYPOS_TAG
      },
    ]
    base = keys(_base-images)
  }
  inherits = ["_common"]
  platforms = _base-images[base].platforms
  dockerfile = "docker/rust.Dockerfile"
  contexts = {
    _base-images[base].name = "docker-image://${_base-images[base].name}:${_base-images[base].tag}@${_base-images[base].digest}"
  }
  args = {
    PROJECT = crates.project
    CRATE = crates.crate
    RUSTFLAGS = _base-images[base].rustflags
  }
  annotations = [
    "manifest-descriptor:org.opencontainers.image.base.digest=${_base-images[base].digest}",
    "manifest-descriptor:org.opencontainers.image.base.name=${_base-images[base].name}:${_base-images[base].tag}",
    "manifest-descriptor,manifest:org.opencontainers.image.description=${crates.description}",
    "manifest-descriptor,manifest:org.opencontainers.image.licenses=${crates.licenses}",
    "manifest-descriptor,manifest:org.opencontainers.image.source=${crates.project}",
    "manifest-descriptor,manifest:org.opencontainers.image.title=${crates.name}",
  ]
  target = base
  output = ["type=image,rewrite-timestamp=true,oci-mediatypes=true"]
  tags = combinetags(["${IMAGE_BASE}/${crates.name}"], gettags(crates.tag, _base-images[base].suffixes))
}

variable "COMMITTED_TAG" {
  default = "master"
}

group "committed" {
  targets = [for base in keys(_base-images): "committed-${base}"]
}

variable "TYPOS_TAG" {
  default = "master"
}

group "typos" {
  targets = [for base in keys(_base-images): "typos-${base}"]
}

variable "BUILDKIT_PORT" {
  default = "3375"
}

target "buildkit-service" {
  inherits = ["_common"]
  name = "buildkit-${replace(item.tag, ".", "-")}"
  dockerfile-inline = <<EOT
    FROM docker.io/moby/buildkit:${item.tag}@${item.digest}
    EXPOSE ${BUILDKIT_PORT}
    CMD ["--oci-worker-no-process-sandbox", "--addr", "tcp://:${BUILDKIT_PORT}"]
  EOT
  tags = [
    "${lower(IMAGE_BASE)}/buildkit:${item.tag}"
  ]
  annotations = [
    "manifest-descriptor:org.opencontainers.image.base.digest=${item.digest}",
    "manifest-descriptor:org.opencontainers.image.base.name=docker.io/moby/buildkit:${item.tag}",
    "manifest-descriptor,manifest:org.opencontainers.image.description=concurrent, cache-efficient, and Dockerfile-agnostic builder toolkit",
    "manifest-descriptor,manifest:org.opencontainers.image.licenses=Apache-2.0",
    "manifest-descriptor,manifest:org.opencontainers.image.source=https://github.com/moby/buildkit",
    "manifest-descriptor,manifest:org.opencontainers.image.title=builtkit",
  ]
  matrix = {
    item = [
      {
        # renovate: datasource=docker depName=docker.io/moby/buildkit
        tag = "buildx-stable-1"
        digest = "sha256:c457984bd29f04d6acc90c8d9e717afe3922ae14665f3187e0096976fe37b1c8"
      },
      {
        # renovate: datasource=docker depName=docker.io/moby/buildkit
        tag = "buildx-stable-1-rootless"
        digest = "sha256:cb5bb371545222c430528556acfdf424144b69897f5deaad391bd227187e90df"
      },
      {
        # renovate: datasource=docker depName=docker.io/moby/buildkit
        tag = "v0.21.0"
        digest = "sha256:fc06fa7d79ada15bbcbf8fce2b8f937dc6b7841ce76ba0bf2f071ec29e8f5ff6"
      },
      {
        # renovate: datasource=docker depName=docker.io/moby/buildkit
        tag = "v0.21.0-rootless"
        digest = "sha256:8a20e0009cb3754c91844e1285b619e6023a438c078ee4920fd02c5401f2b847"
      },
      {
        # renovate: datasource=docker depName=docker.io/moby/buildkit
        tag = "latest"
        digest = "sha256:fc06fa7d79ada15bbcbf8fce2b8f937dc6b7841ce76ba0bf2f071ec29e8f5ff6"
      },
      {
        # renovate: datasource=docker depName=docker.io/moby/buildkit
        tag = "rootless"
        digest = "sha256:8a20e0009cb3754c91844e1285b619e6023a438c078ee4920fd02c5401f2b847"
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

group "default" {
  targets = ["buildkit-service", "rust"]
}
