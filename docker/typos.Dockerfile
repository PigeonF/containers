# syntax=docker/dockerfile:1

# SPDX-FileCopyrightText: 2026 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD

FROM mcr.microsoft.com/windows/nanoserver:ltsc2025 AS base-windows
FROM docker.io/library/debian:trixie-slim AS base-linux

FROM --platform=$BUILDPLATFORM docker.io/library/busybox:latest AS packages
WORKDIR /packages/
# renovate: datasource=github-releases packageName=crate-ci/typos
ARG TYPOS_VERSION=v1.49.1
# renovate: datasource=github-release-attachments packageName=crate-ci/typos digestVersion=v1.49.1
ARG TYPOS_CHECKSUM_LINUX_AMD64=467c88326d29b225263a64efcc47729bfea2b5b9b5e787de0002b8ddb9f2efc9
# renovate: datasource=github-release-attachments packageName=crate-ci/typos digestVersion=v1.49.1
ARG TYPOS_CHECKSUM_LINUX_ARM64=631f19b0e4df118c97497e2a8505b97af33bd7f3bba027d65750fbefb4a087f9
# renovate: datasource=github-release-attachments packageName=crate-ci/typos digestVersion=v1.49.1
ARG TYPOS_CHECKSUM_WINDOWS_AMD64=a2ce9a02125d0ab4a9490f45bba7f0296ebe1bebb6ae508e8277521a5cf29e35
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
