#!/usr/bin/env bash

set -Eeuo pipefail

# ============================================================
# Docker Engine + Docker Compose Plugin Installation
# Supported: Ubuntu 22.04, 24.04, and later supported Ubuntu LTS
# ============================================================

readonly DOCKER_GPG_KEY="/etc/apt/keyrings/docker.asc"
readonly DOCKER_REPO_FILE="/etc/apt/sources.list.d/docker.sources"

log() {
    printf '\n[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

error() {
    printf '\n[ERROR] %s\n' "$*" >&2
    exit 1
}

trap 'error "Installation failed at line $LINENO."' ERR

# ------------------------------------------------------------
# Root validation
# ------------------------------------------------------------

if [[ "$EUID" -ne 0 ]]; then
    error "Run this script as root: sudo bash install-docker-ubuntu.sh"
fi

# ------------------------------------------------------------
# Operating system validation
# ------------------------------------------------------------

if [[ ! -r /etc/os-release ]]; then
    error "Cannot identify the operating system."
fi

# shellcheck source=/etc/os-release
source /etc/os-release

if [[ "${ID:-}" != "ubuntu" ]]; then
    error "This installer supports Ubuntu only."
fi

UBUNTU_CODENAME="${VERSION_CODENAME:-}"

if [[ -z "$UBUNTU_CODENAME" ]]; then
    error "Unable to detect the Ubuntu release codename."
fi

ARCHITECTURE="$(dpkg --print-architecture)"

log "Operating system: ${PRETTY_NAME:-Ubuntu}"
log "Ubuntu codename: $UBUNTU_CODENAME"
log "Architecture: $ARCHITECTURE"

# ------------------------------------------------------------
# Update system and install prerequisites
# ------------------------------------------------------------

export DEBIAN_FRONTEND=noninteractive

log "Updating package indexes..."
apt-get update

log "Installing required packages..."
apt-get install -y ca-certificates curl

# ------------------------------------------------------------
# Configure Docker's official signing key
# ------------------------------------------------------------

log "Configuring Docker's official GPG key..."

install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    -o "$DOCKER_GPG_KEY"

chmod 0644 "$DOCKER_GPG_KEY"

# ------------------------------------------------------------
# Configure Docker's official APT repository
# ------------------------------------------------------------

log "Configuring Docker's official APT repository..."

cat > "$DOCKER_REPO_FILE" <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: ${UBUNTU_CODENAME}
Components: stable
Architectures: ${ARCHITECTURE}
Signed-By: ${DOCKER_GPG_KEY}
EOF

# ------------------------------------------------------------
# Install Docker Engine and plugins
# ------------------------------------------------------------

log "Refreshing package indexes..."
apt-get update

log "Installing Docker Engine, Buildx, and Compose..."

apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# ------------------------------------------------------------
# Enable and start services
# ------------------------------------------------------------

log "Enabling Docker and containerd services..."

systemctl enable --now containerd
systemctl enable --now docker

# ------------------------------------------------------------
# Configure non-root user access
# ------------------------------------------------------------

TARGET_USER="${SUDO_USER:-}"

if [[ -n "$TARGET_USER" && "$TARGET_USER" != "root" ]] && id "$TARGET_USER" &>/dev/null; then
    log "Adding $TARGET_USER to the docker group..."
    usermod -aG docker "$TARGET_USER"
    echo "Docker group access configured for: $TARGET_USER"
    echo "Log out and log back in for group membership to take effect."
else
    log "No non-root invoking user detected; skipping Docker group configuration."
fi

# ------------------------------------------------------------
# Verify installation
# ------------------------------------------------------------

log "Verifying Docker service..."

systemctl is-active --quiet docker || error "Docker service is not running."
systemctl is-active --quiet containerd || error "containerd service is not running."

log "Installed versions:"
docker --version
docker compose version
containerd --version

# ------------------------------------------------------------
# Run Docker smoke test
# ------------------------------------------------------------

log "Running Docker hello-world smoke test..."
docker run --rm hello-world

# ------------------------------------------------------------
# Final status
# ------------------------------------------------------------

echo
echo "============================================================"
echo "          DOCKER INSTALLATION COMPLETED"
echo "============================================================"
echo "Docker Engine : $(docker --version)"
echo "Docker Compose: $(docker compose version)"
echo "Docker service: $(systemctl is-active docker)"
echo "containerd    : $(systemctl is-active containerd)"
if [[ -n "$TARGET_USER" && "$TARGET_USER" != "root" ]]; then
    echo "Configured user: $TARGET_USER"
fi
echo "============================================================"
echo "Installation and verification completed successfully."
echo "============================================================"
