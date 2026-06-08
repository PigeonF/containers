# syntax=docker/dockerfile:1

# SPDX-FileCopyrightText: 2026 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD

FROM mcr.microsoft.com/windows/nanoserver:ltsc2025 AS base-windows
FROM docker.io/library/debian:bookworm-slim AS base-linux

FROM --platform=$BUILDPLATFORM docker.io/library/busybox:latest AS packages
WORKDIR /packages/
# renovate: datasource=github-releases packageName=crate-ci/typos
ARG TYPOS_VERSION=v1.47.2
# renovate: datasource=github-release-attachments packageName=crate-ci/typos digestVersion=v1.47.2
ARG TYPOS_CHECKSUM_LINUX_AMD64=7aef58932fc123b4cf4b40d86468e89a3297d80169051d7cfd13a235e05fc426
# renovate: datasource=github-release-attachments packageName=crate-ci/typos digestVersion=v1.47.2
ARG TYPOS_CHECKSUM_LINUX_ARM64=596d5c6b9ecf34307f68bea649178c5b45a4398fe3a1fcef9598e85aa2ccb742
# renovate: datasource=github-release-attachments packageName=crate-ci/typos digestVersion=v1.47.2
ARG TYPOS_CHECKSUM_WINDOWS_AMD64=f4a12400c48cc08e7f5435b64d0ecb08c54091b97c3ccabf6cea178d0969ca1f
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
