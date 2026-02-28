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

variable "_bases" {
  default = {
    linux = {
      # renovate: versioning=debian
      name = "docker.io/library/debian"
      tag = "bookworm-slim"
      digest = "sha256:74d56e3931e0d5a1dd51f8c8a2466d21de84a271cd3b5a733b803aa91abf4421"
      suffixes = ["", "bookworm"]
      platforms = ["linux/amd64", "linux/arm64"]
    }
    windows = {
      # renovate:
      name = "mcr.microsoft.com/windows/nanoserver"
      tag = "ltsc2025"
      digest = "sha256:40a16c02dd07be0ef8077d405238acd5c29f2705136fab609da221e4de849b2a"
      suffixes = ["ltsc", "ltsc2025"]
      platforms = ["windows/amd64"]
    }
  }
}

variable "COMMITTED_VERSION" {
  # renovate: datasource=github-releases depName=crate-ci/committed
  default = "v1.1.11"
}

target "committed" {
  name = "committed-${base}"
  matrix = {
    base = keys(_bases)
  }
  inherits = ["_common"]
  platforms = _bases[base].platforms
  dockerfile = "docker/committed.Dockerfile"
  contexts = {
    _bases[base].name = "docker-image://${_bases[base].name}:${_bases[base].tag}@${_bases[base].digest}"
  }
  args = {
    COMMITTED_VERSION = COMMITTED_VERSION
  }
  annotations = [
    "manifest-descriptor:org.opencontainers.image.base.digest=${_bases[base].digest}",
    "manifest-descriptor:org.opencontainers.image.base.name=${_bases[base].name}:${_bases[base].tag}",
    "manifest-descriptor,manifest:org.opencontainers.image.description=Nitpicking commit history since beabf39",
    "manifest-descriptor,manifest:org.opencontainers.image.licenses=Apache-2.0 OR MIT",
    "manifest-descriptor,manifest:org.opencontainers.image.source=https://github.com/crate-ci/committed.git#${COMMITTED_VERSION}",
    "manifest-descriptor,manifest:org.opencontainers.image.title=committed",
  ]
  target = "committed-${base}"
  tags = combinetags(["${IMAGE_BASE}/committed"], gettags(COMMITTED_VERSION, _bases[base].suffixes))
}

variable "TYPOS_VERSION" {
  # renovate: datasource=github-releases depName=crate-ci/typos
  default = "v1.44.0"
}

target "typos" {
  name = "typos-${base}"
  matrix = {
    base = keys(_bases)
  }
  inherits = ["_common"]
  platforms = _bases[base].platforms
  dockerfile = "docker/typos.Dockerfile"
  contexts = {
    _bases[base].name = "docker-image://${_bases[base].name}:${_bases[base].tag}@${_bases[base].digest}"
  }
  args = {
    TYPOS_VERSION = TYPOS_VERSION
  }
  annotations = [
    "manifest-descriptor:org.opencontainers.image.base.digest=${_bases[base].digest}",
    "manifest-descriptor:org.opencontainers.image.base.name=${_bases[base].name}:${_bases[base].tag}",
    "manifest-descriptor,manifest:org.opencontainers.image.description=Source code spell checker",
    "manifest-descriptor,manifest:org.opencontainers.image.licenses=Apache-2.0 OR MIT",
    "manifest-descriptor,manifest:org.opencontainers.image.source=https://github.com/crate-ci/typos.git#${TYPOS_VERSION}",
    "manifest-descriptor,manifest:org.opencontainers.image.title=typos",
  ]
  target = "typos-${base}"
  tags = combinetags(["${IMAGE_BASE}/typos"], gettags(TYPOS_VERSION, _bases[base].suffixes))
}

group "default" {
  targets = ["committed", "typos"]
}
