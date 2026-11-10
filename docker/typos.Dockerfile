# syntax=docker/dockerfile:1

# SPDX-FileCopyrightText: 2026 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD

FROM mcr.microsoft.com/windows/nanoserver:ltsc2025 AS base-windows
FROM docker.io/library/debian:trixie-slim AS base-linux

FROM --platform=$BUILDPLATFORM docker.io/library/busybox:latest AS packages
WORKDIR /packages/
# renovate: datasource=github-releases packageName=crate-ci/typos
ARG TYPOS_VERSION=v1.52.1
# renovate: datasource=github-release-attachments packageName=crate-ci/typos digestVersion=v1.52.1
ARG TYPOS_CHECKSUM_LINUX_AMD64=c034dbec8797cfa0c4548b3726c1eebbafcf703b8a17f15a961b037788eebcdd
# renovate: datasource=github-release-attachments packageName=crate-ci/typos digestVersion=v1.52.1
ARG TYPOS_CHECKSUM_LINUX_ARM64=3c82c3e97aafdd686fbb3f8c7b82bca3a870d21a0bcadd41babd37e84cc2f2df
# renovate: datasource=github-release-attachments packageName=crate-ci/typos digestVersion=v1.52.1
ARG TYPOS_CHECKSUM_WINDOWS_AMD64=adb3ac98b0ca8964a23b984c786c2116a25b3665e070f2a4f8156e2d6d4df2e3
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
