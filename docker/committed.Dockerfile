# syntax=docker/dockerfile:1

# SPDX-FileCopyrightText: 2026 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD

FROM mcr.microsoft.com/windows/nanoserver:ltsc2025 AS base-windows
FROM docker.io/library/debian:bookworm-slim AS base-linux

FROM --platform=$BUILDPLATFORM docker.io/library/busybox:latest AS packages
WORKDIR /packages/
# renovate: datasource=github-releases packageName=crate-ci/committed
ARG COMMITTED_VERSION=v1.1.11
# renovate: datasource=github-release-attachments packageName=crate-ci/committed digestVersion=v1.1.11
ARG COMMITTED_CHECKSUM_LINUX_AMD64=1e5c20049eeaa4633e6798283913f92dc90a97f2b5c6dfc28e8c4b7e77a67157
# renovate: datasource=github-release-attachments packageName=crate-ci/committed digestVersion=v1.1.11
ARG COMMITTED_CHECKSUM_LINUX_ARM64=96d6334ab2dccc0e90b67ebdcaa2af856f29eadef48161926e21a0e35f1ae80d
# renovate: datasource=github-release-attachments packageName=crate-ci/committed digestVersion=v1.1.11
ARG COMMITTED_CHECKSUM_WINDOWS_AMD64=af4f5a65320471751ed1dfbb5502f15f4857cea797b077c6049acb2b995d293b
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
