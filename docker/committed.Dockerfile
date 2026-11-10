# syntax=docker/dockerfile:1

# SPDX-FileCopyrightText: 2026 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD

FROM mcr.microsoft.com/windows/nanoserver:ltsc2025 AS base-windows
FROM docker.io/library/debian:trixie-slim AS base-linux

FROM --platform=$BUILDPLATFORM docker.io/library/busybox:latest AS packages
WORKDIR /packages/
# renovate: datasource=github-releases packageName=crate-ci/committed
ARG COMMITTED_VERSION=v1.1.12
# renovate: datasource=github-release-attachments packageName=crate-ci/committed digestVersion=v1.1.12
ARG COMMITTED_CHECKSUM_LINUX_AMD64=9a860b0a557bc842df663ce923213ff36f077ae2783f8db3123738823279387f
# renovate: datasource=github-release-attachments packageName=crate-ci/committed digestVersion=v1.1.12
ARG COMMITTED_CHECKSUM_LINUX_ARM64=2077f9fa0157f3e0bfa7273327aa26c793d05b16620e046e499a982dd6fd2e7c
# renovate: datasource=github-release-attachments packageName=crate-ci/committed digestVersion=v1.1.12
ARG COMMITTED_CHECKSUM_WINDOWS_AMD64=9d8608d3622037f19c784bc907903d840c52c1d5e1e4f16daef8653d8a8894b6
ADD \
  --unpack=true \
  --checksum=sha256:${COMMITTED_CHECKSUM_LINUX_AMD64} \
  https://github.com/crate-ci/committed/releases/download/v${COMMITTED_VERSION#v}/committed-v${COMMITTED_VERSION#v}-x86_64-unknown-linux-musl.tar.gz \
  committed-linux/amd64/
ADD \
  --unpack=true \
  --checksum=sha256:${COMMITTED_CHECKSUM_LINUX_ARM64} \
  https://github.com/crate-ci/committed/releases/download/v${COMMITTED_VERSION#v}/committed-v${COMMITTED_VERSION#v}-aarch64-unknown-linux-musl.tar.gz \
  committed-linux/arm64/
ADD \
  --checksum=sha256:${COMMITTED_CHECKSUM_WINDOWS_AMD64} \
  https://github.com/crate-ci/committed/releases/download/v${COMMITTED_VERSION#v}/committed-v${COMMITTED_VERSION#v}-x86_64-pc-windows-msvc.zip \
  committed-windows/amd64/committed.zip
RUN cd committed-windows/amd64 && unzip committed.zip && rm committed.zip

FROM base-windows AS committed-windows
ARG TARGETPLATFORM
COPY --link --from=packages ["/packages/committed-${TARGETPLATFORM}/", "Program Files/committed"]
ENV PATH="c:\\Program Files\\committed;c:\\Windows\\System32;c:\\Windows"

FROM base-linux AS committed-linux
ARG TARGETPLATFORM
COPY --link --from=packages /packages/committed-${TARGETPLATFORM}/committed /usr/local/bin/

FROM committed-${TARGETOS} AS committed
