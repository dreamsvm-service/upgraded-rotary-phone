#!/bin/sh

set -e

ROOTFS_DIR=/home/container
ARCH=$(uname -m)
PROOT_VERSION="5.3.0"

if [ "$ARCH" = "x86_64" ]; then
  DEB_ARCH="x86_64"
  PROOT_URL="https://github.com/proot-me/proot/releases/download/v${PROOT_VERSION}/proot-v${PROOT_VERSION}-x86_64-static"
elif [ "$ARCH" = "aarch64" ]; then
  DEB_ARCH="aarch64"
  PROOT_URL="https://github.com/proot-me/proot/releases/download/v${PROOT_VERSION}/proot-v${PROOT_VERSION}-aarch64-static"
else
  echo "Unsupported architecture: $ARCH"
  exit 1
fi

ROOTFS_URL="https://github.com/termux/proot-distro/releases/download/v4.26.0/debian-trixie-${DEB_ARCH}-pd-v4.26.0.tar.xz"

mkdir -p "$ROOTFS_DIR"

if [ ! -f "$ROOTFS_DIR/.installed" ]; then

  echo "[*] Downloading rootfs..."
  curl -L --fail --retry 5 -o /tmp/rootfs.tar.xz "$ROOTFS_URL"

  echo "[*] Extracting rootfs..."
  tar -xJf /tmp/rootfs.tar.xz -C "$ROOTFS_DIR"

  echo "[*] Downloading proot..."
  curl -L --fail -o "$ROOTFS_DIR/usr/local/bin/proot" "$PROOT_URL"

  chmod +x "$ROOTFS_DIR/usr/local/bin/proot"

  mkdir -p "$ROOTFS_DIR/etc"

  printf "nameserver 1.1.1.1\nnameserver 1.0.0.1\n" > "$ROOTFS_DIR/etc/resolv.conf"

  touch "$ROOTFS_DIR/.installed"

  rm -f /tmp/rootfs.tar.xz
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
