# syntax=docker/dockerfile:1
#
# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
#
# Dockerfile for cross compilation, as well as runnable images for windows and glibc.

# Which project to build
ARG PROJECT
# Which crate in the project to compile
ARG CRATE

# =================================================================================================
# Abbreviations for third party images
# =================================================================================================

FROM --platform=$BUILDPLATFORM docker.io/library/rust:1@sha256:6a6dda669f020fa1fcb0903e37a049484fbf4b4699c8cb89db26ca030f475259 AS rust
FROM --platform=$BUILDPLATFORM docker.io/tonistiigi/xx:latest@sha256:923441d7c25f1e2eb5789f82d987693c47b8ed987c4ab3b075d6ed2b5d6779a3 AS xx
FROM --platform=$BUILDPLATFORM ghcr.io/rust-cross/cargo-xwin:0.18.4@sha256:9333c8f4c5090653985edc14beda8565ae7512db512e55b9f8b94accc81451d2 AS cargo-xwin

# =================================================================================================
# Builder stages
# =================================================================================================

FROM rust AS builder-base
# renovate: renovate: datasource=github-releases depName=rust-secure-code/cargo-auditable
ARG CARGO_AUDITABLE_VERSION=v0.6.6
# Install cargo auditable (can switch to `apt install` once debian trixie becomes stable)
RUN curl --proto '=https' --tlsv1.2 -LsSf https://github.com/rust-secure-code/cargo-auditable/releases/download/${CARGO_AUDITABLE_VERSION}/cargo-auditable-installer.sh | sh
ARG TARGETARCH
ENV CARGO_TARGETARCH=${TARGETARCH}
ENV CARGO_TARGETARCH=${CARGO_TARGETARCH/amd64/x86_64}
ENV CARGO_TARGETARCH=${CARGO_TARGETARCH/arm64/aarch64}
ARG TARGETOS
ENV CARGO_TARGETOS=${TARGETOS}
ENV CARGO_TARGETOS=${CARGO_TARGETOS/darwin/apple-darwin}
ENV CARGO_TARGETOS=${CARGO_TARGETOS/linux/unknown-linux-gnu}
ENV CARGO_TARGETOS=${CARGO_TARGETOS/windows/pc-windows-msvc}
ENV CARGO_BUILD_TARGET=${CARGO_TARGETARCH}-${CARGO_TARGETOS}
RUN rustup target add "${CARGO_BUILD_TARGET}"
ARG RUSTFLAGS=""
ENV RUSTFLAGS=${RUSTFLAGS}
ENV CARGO_INCREMENTAL=0
ARG PROJECT
ADD --keep-git-dir --link ${PROJECT} /app
WORKDIR /app
RUN \
  --mount=type=cache,id=${PROJECT}-git-db,sharing=locked,target=/usr/local/cargo/git/db/ \
  --mount=type=cache,id=${PROJECT}-cargo-registry,sharing=locked,target=/usr/local/cargo/registry/ \
  cargo fetch
RUN \
  --mount=type=cache,id=${PROJECT}-git-db,sharing=locked,target=/usr/local/cargo/git/db/ \
  --mount=type=cache,id=${PROJECT}-cargo-registry,sharing=locked,target=/usr/local/cargo/registry/ \
  cargo fetch --target "${CARGO_BUILD_TARGET}"

FROM builder-base AS builder-unix
RUN \
  --mount=type=cache,sharing=locked,target=/var/cache/apt \
  --mount=type=cache,sharing=locked,target=/var/lib/apt \
  <<EOF
  set -o errexit -o nounset

  apt-get update
  apt-get --no-install-recommends install --yes clang lld
EOF
COPY --from=xx / /
ARG TARGETPLATFORM
RUN \
  --mount=type=cache,sharing=locked,target=/var/cache/apt \
  --mount=type=cache,sharing=locked,target=/var/lib/apt \
  <<EOF
  set -o errexit -o nounset

  xx-apt-get install -y xx-c-essentials libz-dev
EOF
ARG PROJECT
ARG CRATE
RUN \
  --mount=type=cache,id=${PROJECT}-${CRATE}-${CARGO_BUILD_TARGET},target=/app/target/ \
  --mount=type=cache,id=${PROJECT}-git-db,sharing=private,target=/usr/local/cargo/git/db/ \
  --mount=type=cache,id=${PROJECT}-cargo-registry,sharing=private,target=/usr/local/cargo/registry/ \
  <<EOF
  set -o errexit -o nounset

  xx-cargo auditable build --release --target "${CARGO_BUILD_TARGET}" --package "${CRATE}"

  find "target/${CARGO_BUILD_TARGET}/release" -maxdepth 1 -type f -executable -exec install -D -m 755 -t "/out/${CARGO_BUILD_TARGET}" {} \;
EOF

FROM builder-base AS builder-msvc
RUN \
  --mount=type=cache,sharing=locked,target=/var/cache/apt \
  --mount=type=cache,sharing=locked,target=/var/lib/apt \
  <<EOF
  set -o errexit -o nounset

  apt-get update
  apt-get --no-install-recommends install --yes llvm-16 clang-tools-16
EOF
ENV PATH=/usr/local/cargo/bin:/usr/lib/llvm-16/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
COPY --from=cargo-xwin /usr/local/cargo/bin/cargo-xwin /usr/local/cargo/bin/
ARG PROJECT
ARG CRATE
RUN \
  --mount=type=cache,sharing=locked,target=/root/.cache/cargo-xwin/xwin/ \
  --mount=type=cache,id=${PROJECT}-${CRATE}-${CARGO_BUILD_TARGET},target=/app/target/ \
  --mount=type=cache,id=${PROJECT}-git-db,sharing=private,target=/usr/local/cargo/git/db/ \
  --mount=type=cache,id=${PROJECT}-cargo-registry,sharing=private,target=/usr/local/cargo/registry/ \
  <<EOF
  set -o errexit -o nounset

  cargo auditable xwin build --release --target "${CARGO_BUILD_TARGET}" --package "${CRATE}"

  find "target/${CARGO_BUILD_TARGET}/release" -maxdepth 1 -type f -executable -exec install -D -m 755 -t "/out/${CARGO_BUILD_TARGET}" {} \;
EOF

# =================================================================================================
# Artifacts
# =================================================================================================

FROM builder-unix AS artifacts-linux
FROM builder-msvc AS artifacts-windows

FROM artifacts-${TARGETOS} AS artifacts-targetos

FROM scratch AS artifacts
COPY --from=artifacts-targetos /out/ /

# =================================================================================================
# Container Images
# =================================================================================================

FROM mcr.microsoft.com/windows/nanoserver:ltsc2025 AS windows
ARG CRATE
COPY --from=artifacts ["/*-pc-windows-msvc/", "Program Files/${CRATE}/"]
ENV PATH="c:\\Program Files\\${CRATE};c:\\Windows\\System32;c:\\Windows"

FROM docker.io/library/debian:stable-slim AS linux
COPY --from=artifacts --chown=0:0 --chmod=755 /*-unknown-linux-gnu/* /usr/local/bin/

FROM ${TARGETOS}
