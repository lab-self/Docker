# Docker Engine & Docker Compose Installer for Ubuntu

A Bash installer for deploying **Docker Engine**, **Docker CLI**, **containerd**, **Docker Buildx**, and the **Docker Compose V2 plugin** on Ubuntu servers.

The installer configures Docker's official APT repository and signing key, enables the required systemd services, optionally grants the invoking sudo user Docker group access, and runs a Docker smoke test.

## Supported platform

- Ubuntu Server 22.04 LTS and 24.04 LTS.
- Other Ubuntu releases may work when they are supported by Docker's official APT repository.

The installer detects the Ubuntu codename and CPU architecture automatically. It does not support Debian or other non-Ubuntu distributions.

## Components installed

| Component | Package / command |
|---|---|
| Docker Engine | `docker-ce` |
| Docker CLI | `docker-ce-cli` |
| Container runtime | `containerd.io` |
| Docker Buildx | `docker-buildx-plugin` |
| Docker Compose V2 | `docker-compose-plugin` |

## Prerequisites

- Ubuntu server with internet connectivity.
- Root access or a user with `sudo` privileges.
- A supported Ubuntu release and architecture.
- Access to Docker's official package repository.

## Quick installation

Run the installer directly with:

```bash
curl -fsSL https://raw.githubusercontent.com/lab-self/Docker/main/install-docker-ubuntu.sh | sudo bash
```

Alternatively, download and inspect the script before executing it:

```bash
curl -fsSLO https://raw.githubusercontent.com/lab-self/Docker/main/install-docker-ubuntu.sh
less install-docker-ubuntu.sh
chmod +x install-docker-ubuntu.sh
sudo ./install-docker-ubuntu.sh
```

## What the installer does

1. Checks for root privileges and validates that the operating system is Ubuntu.
2. Detects the Ubuntu release codename and system architecture.
3. Updates APT package indexes and installs required prerequisites.
4. Downloads Docker's official GPG signing key into `/etc/apt/keyrings/docker.asc`.
5. Configures the Docker APT repository using a deb822 `.sources` file.
6. Installs Docker Engine, Docker CLI, containerd, Buildx, and the Compose V2 plugin.
7. Enables and starts the `docker` and `containerd` systemd services.
8. Adds the invoking non-root sudo user to the `docker` group, when applicable.
9. Verifies service status and installed versions.
10. Runs `docker run --rm hello-world` as an installation smoke test.

The installer is designed to be safe to re-run: it overwrites its managed Docker repository configuration and reuses the official keyring path.

## Verify the installation

Check installed versions:

```bash
docker --version
docker compose version
docker buildx version
containerd --version
```

Check service status:

```bash
systemctl is-active docker
systemctl is-active containerd
systemctl status docker --no-pager
```

Run a container smoke test:

```bash
sudo docker run --rm hello-world
```

List containers:

```bash
docker ps -a
```

If your user was added to the `docker` group, log out and log back in before running Docker commands without `sudo`. You can check group membership with:

```bash
id
getent group docker
```

## Security considerations

- The installer uses Docker's official APT repository and repository-scoped signing key.
- **Membership in the `docker` group grants root-level privileges on the host.** Add only trusted users. Do not grant this access to ordinary or untrusted accounts.
- Do not expose the Docker daemon over an unauthenticated TCP socket.
- Review Docker's networking and firewall behavior before deploying containers on production hosts.
- Keep Docker Engine and host packages updated with a controlled patching process.

## Troubleshooting

Inspect Docker service logs:

```bash
sudo journalctl -u docker -n 100 --no-pager
```

Inspect containerd logs:

```bash
sudo journalctl -u containerd -n 100 --no-pager
```

Refresh APT indexes and check Docker package availability:

```bash
sudo apt-get update
apt-cache policy docker-ce
```

If the Docker group was just added to your account, start a new login session. Group membership does not update in an existing shell automatically.

## Repository files

- [install-docker-ubuntu.sh](https://github.com/lab-self/Docker/blob/main/install-docker-ubuntu.sh) — Ubuntu Docker installation script.

## Official documentation

- [Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)
- [Docker Engine](https://docs.docker.com/engine/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Docker Buildx](https://docs.docker.com/build/buildx/)

## Author

Maintained by **lab-self**.

GitHub: https://github.com/lab-self
