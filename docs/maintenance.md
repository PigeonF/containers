<!--
SPDX-FileCopyrightText: 2024 Jonas Fierlings <fnoegip@gmail.com>

SPDX-License-Identifier: CC-BY-4.0
-->

# Maintainer Guide

This guide is intended for maintainers of the project.

## Releasing a new version

New versions of the containers are released automatically by the [CI/CD configuration](../.github/workflows/) changes are merged into the `main` branch.

## CI/CD Secrets

_The CI/CD configuration currently does not use any secrets_.

## Bots

The repository has bot account members to automate some tasks.

### [renovate bot](https://github.com/apps/renovate)

This bot automatically updates dependencies.
In this case this means updating the container dependencies to their latest released versions.
The bot is configured via the [`renovate.json5`](../renovate.json5) file.
