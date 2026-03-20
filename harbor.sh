#!/bin/sh

set -e

ROOTFS_DIR=/home/container
ARCH=$(uname -m)
PROOT_VERSION="5.3.0"

if [ "$ARCH" = "x86_64" ]; then
  DEB_ARCH="amd64"
  PROOT_URL="https://github.com/proot-me/proot/releases/download/v${PROOT_VERSION}/proot-v${PROOT_VERSION}-x86_64-static"
elif [ "$ARCH" = "aarch64" ]; then
  DEB_ARCH="arm64"
  PROOT_URL="https://github.com/proot-me/proot/releases/download/v${PROOT_VERSION}/proot-v${PROOT_VERSION}-aarch64-static"
else
  echo "Unsupported architecture: $ARCH"
  exit 1
fi

ROOTFS_URL="https://github.com/debuerreotype/docker-debian-artifacts/raw/dist-bookworm/${DEB_ARCH}/rootfs.tar.gz"

mkdir -p "$ROOTFS_DIR"

if [ ! -f "$ROOTFS_DIR/.installed" ]; then

  echo "[*] Downloading rootfs..."
  curl -L --fail -o /tmp/rootfs.tar.gz "$ROOTFS_URL"

  echo "[*] Extracting rootfs..."
  tar -xzf /tmp/rootfs.tar.gz -C "$ROOTFS_DIR"

  echo "[*] Downloading proot..."
  mkdir -p "$ROOTFS_DIR/usr/local/bin"
  curl -L --fail -o "$ROOTFS_DIR/usr/local/bin/proot" "$PROOT_URL"

  chmod +x "$ROOTFS_DIR/usr/local/bin/proot"

  mkdir -p "$ROOTFS_DIR/etc"
  printf "nameserver 1.1.1.1\nnameserver 1.0.0.1\n" > "$ROOTFS_DIR/etc/resolv.conf"

  touch "$ROOTFS_DIR/.installed"

  rm -f /tmp/rootfs.tar.gz
fi

exec "$ROOTFS_DIR/usr/local/bin/proot" \
--rootfs="$ROOTFS_DIR" \
--link2symlink \
--kill-on-exit \
--root-id \
--cwd=/root \
--bind=/proc \
--bind=/dev \
--bind=/sys \
--bind=/tmp \
/bin/bash
