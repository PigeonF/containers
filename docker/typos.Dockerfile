# syntax=docker/dockerfile:1

# SPDX-FileCopyrightText: 2026 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD

FROM mcr.microsoft.com/windows/nanoserver:ltsc2025 AS base-windows
FROM docker.io/library/debian:bookworm-slim AS base-linux

FROM --platform=$BUILDPLATFORM docker.io/library/busybox:latest AS packages
WORKDIR /packages/
# renovate: datasource=github-releases packageName=crate-ci/typos
ARG TYPOS_VERSION=v1.48.0
# renovate: datasource=github-release-attachments packageName=crate-ci/typos digestVersion=v1.48.0
ARG TYPOS_CHECKSUM_LINUX_AMD64=72a930c9a94fc3914aa56835c5b859c892a797d40c1c42638b98d93f16ff519c
# renovate: datasource=github-release-attachments packageName=crate-ci/typos digestVersion=v1.48.0
ARG TYPOS_CHECKSUM_LINUX_ARM64=2960ae07bc1ffe19e4895e4359394dd349c9c31de78aac3a124b6e4aeb206698
# renovate: datasource=github-release-attachments packageName=crate-ci/typos digestVersion=v1.48.0
ARG TYPOS_CHECKSUM_WINDOWS_AMD64=ce018a2352da7c1b23bd2684019ee279d2080dc063087020e80c1247d11b0743
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
