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
      digest = "sha256:94c4d598b5987d76c38408657aae7118b101662595bf5eefe478e093a0bed2f6"
      suffixes = ["", "bookworm"]
      platforms = ["linux/amd64", "linux/arm64"]
      rustflags = "-C target-feature=-crt-static"
    }
    windows = {
      # renovate:
      name = "mcr.microsoft.com/windows/nanoserver"
      tag = "ltsc2025"
      digest = "sha256:4bfc3ec32a8b9bb5e7a182440c517b0706267d88fda77b54acddf819920400ad"
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
        digest = "sha256:5601811fde88bb9e8a577bfe804af82bccb712e1cd07ff94663bded5e628cf75"
      },
      {
        # renovate: datasource=docker depName=docker.io/moby/buildkit
        tag = "buildx-stable-1-rootless"
        digest = "sha256:d2d84019c976ee62863bb5eb0c98c796a324cfbecb220d692119184382def15e"
      },
      {
        # renovate: datasource=docker depName=docker.io/moby/buildkit
        tag = "v0.26.3"
        digest = "sha256:5601811fde88bb9e8a577bfe804af82bccb712e1cd07ff94663bded5e628cf75"
      },
      {
        # renovate: datasource=docker depName=docker.io/moby/buildkit
        tag = "v0.26.3-rootless"
        digest = "sha256:d2d84019c976ee62863bb5eb0c98c796a324cfbecb220d692119184382def15e"
      },
      {
        # renovate: datasource=docker depName=docker.io/moby/buildkit
        tag = "latest"
        digest = "sha256:5601811fde88bb9e8a577bfe804af82bccb712e1cd07ff94663bded5e628cf75"
      },
      {
        # renovate: datasource=docker depName=docker.io/moby/buildkit
        tag = "rootless"
        digest = "sha256:d2d84019c976ee62863bb5eb0c98c796a324cfbecb220d692119184382def15e"
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
