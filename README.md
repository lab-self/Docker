# Docker & Docker Compose Installation Script (Ubuntu)

This repository provides a **secure, automated installation script** for installing **Docker Engine** and **Docker Compose v2** on Ubuntu servers.

The script follows **official Docker best practices**, uses **APT keyrings**, and automatically detects the Ubuntu version.

---

## Supported Ubuntu Versions

The script works on:

- Ubuntu 20.04 (focal)
- Ubuntu 22.04 (jammy)
- Ubuntu 24.04 (noble)

> Other Debian-based distributions are not officially supported.

---

## What This Script Installs

- Docker Engine (`docker-ce`)
- Docker CLI (`docker-ce-cli`)
- Containerd (`containerd.io`)
- Docker Compose v2 plugin (`docker compose`)
- Enables and starts Docker service
- Adds the invoking user to the `docker` group

---

## Prerequisites

- Fresh or existing Ubuntu server
- Root access or sudo privileges
- Internet connectivity

---
## Quick Install (One Command)

Run the following command on your Ubuntu server:

```shell
curl -fsSL https://raw.githubusercontent.com/lab-self/Docker/main/install-docker-ubuntu.sh | sudo bash

---

## Validate Docker Installation

After the installation completes, log out and log back in (or open a new shell), then run the following checks.

## Check Docker Engine

```shell
docker --version

---

## Check Docker Compose Version
```shell
docker compose version

---

## Verify Docker Service Status
```shell
systemctl status docker

---

## Run a Test Container
```shell
docker run hello-world

---

### List Running Containers
```shell
docker ps
