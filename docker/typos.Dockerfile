# syntax=docker/dockerfile:1

# SPDX-FileCopyrightText: 2026 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD

FROM mcr.microsoft.com/windows/nanoserver:ltsc2025 AS base-windows
FROM docker.io/library/debian:bookworm-slim AS base-linux

FROM --platform=$BUILDPLATFORM docker.io/library/busybox:latest AS packages
WORKDIR /packages/
# renovate: datasource=github-releases packageName=crate-ci/typos
ARG TYPOS_VERSION=v1.45.0
# renovate: datasource=github-release-attachments packageName=crate-ci/typos digestVersion=v1.45.0
ARG TYPOS_CHECKSUM_LINUX_AMD64=fa10c3c77c61bdf03f2f6f8245eb6fb89d92115450272a4eabe326b3967ac375
# renovate: datasource=github-release-attachments packageName=crate-ci/typos digestVersion=v1.45.0
ARG TYPOS_CHECKSUM_LINUX_ARM64=dde3b5c5bd5d0ab6ff76a1465658dc6485e7d420cf8eccfdfbdea37809bed793
# renovate: datasource=github-release-attachments packageName=crate-ci/typos digestVersion=v1.45.0
ARG TYPOS_CHECKSUM_WINDOWS_AMD64=dc89f5f175ee1a389e1f5cc5173353d9db3751e2cddedf34339d8ec45cd38aa0
ADD \
  --unpack=true \
  --checksum=sha256:${TYPOS_CHECKSUM_LINUX_AMD64} \
  https://github.com/crate-ci/typos/releases/download/v${TYPOS_VERSION#v}/typos-v${TYPOS_VERSION#v}-x86_64-unknown-linux-musl.tar.gz \
  typos-linux/amd64/
ADD \
  --unpack=true \
  --checksum=sha256:${TYPOS_CHECKSUM_LINUX_ARM64} \
  https://github.com/crate-ci/typos/releases/download/v${TYPOS_VERSION#v}/typos-v${TYPOS_VERSION#v}-aarch64-unknown-linux-musl.tar.gz \
  typos-linux/arm64/
ADD \
  --checksum=sha256:${TYPOS_CHECKSUM_WINDOWS_AMD64} \
  https://github.com/crate-ci/typos/releases/download/v${TYPOS_VERSION#v}/typos-v${TYPOS_VERSION#v}-x86_64-pc-windows-msvc.zip \
  typos-windows/amd64/typos.zip
RUN cd typos-windows/amd64 && unzip typos.zip && rm typos.zip

FROM base-windows AS typos-windows
ARG TARGETPLATFORM
COPY --link --from=packages ["/packages/typos-${TARGETPLATFORM}/", "Program Files/typos"]
ENV PATH="c:\\Program Files\\typos;c:\\Windows\\System32;c:\\Windows"

FROM base-linux AS typos-linux
ARG TARGETPLATFORM
COPY --link --from=packages /packages/typos-${TARGETPLATFORM}/typos /usr/local/bin/

FROM typos-${TARGETOS} AS typos
