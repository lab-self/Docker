#!/usr/bin/env bash
set -e

if [[ "$EUID" -ne 0 ]]; then
  echo "Please run as root or with sudo"
  exit 1
fi

echo "=== Updating system ==="
apt update -y
apt install -y ca-certificates curl gnupg lsb-release

echo "=== Adding Docker GPG key ==="
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

UBUNTU_CODENAME=$(lsb_release -cs)

echo "=== Adding Docker repository ==="
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $UBUNTU_CODENAME stable" \
> /etc/apt/sources.list.d/docker.list

echo "=== Installing Docker ==="
apt update -y
apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

echo "=== Enabling Docker ==="
systemctl enable --now docker

docker --version
docker compose version

if [[ -n "$SUDO_USER" ]]; then
  usermod -aG docker "$SUDO_USER"
  echo "User $SUDO_USER added to docker group (logout required)"
fi

echo "=== Docker installation completed successfully ==="