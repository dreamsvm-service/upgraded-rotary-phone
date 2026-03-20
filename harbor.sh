#!/bin/sh

set -e

ROOTFS_DIR=/home/container
ARCH=$(uname -m)
PROOT_VERSION="5.3.0"

if [ "$ARCH" = "x86_64" ]; then
  PROOT_URL="https://github.com/proot-me/proot/releases/download/v${PROOT_VERSION}/proot-v${PROOT_VERSION}-x86_64-static"
  ROOTFS_URL="https://www.dropbox.com/s/lx1xwi69gxasbeq/amd64-rootfs-20170318T102216Z.tar.gz?dl=1"
elif [ "$ARCH" = "aarch64" ]; then
  PROOT_URL="https://github.com/proot-me/proot/releases/download/v${PROOT_VERSION}/proot-v${PROOT_VERSION}-aarch64-static"
  ROOTFS_URL="https://www.dropbox.com/s/zxfg8aosr7zzmg8/arm64-rootfs-20170318T102424Z.tar.gz?dl=1"
else
  echo "Unsupported architecture: $ARCH"
  exit 1
fi

mkdir -p "$ROOTFS_DIR"

if [ ! -f "$ROOTFS_DIR/.installed" ]; then

  curl -L --fail -o /tmp/rootfs.tar.gz "$ROOTFS_URL"

  tar -xzf /tmp/rootfs.tar.gz -C "$ROOTFS_DIR"

  if [ -d "$ROOTFS_DIR/amd64-rootfs-20170318T102216Z" ]; then
    mv "$ROOTFS_DIR/amd64-rootfs-20170318T102216Z"/* "$ROOTFS_DIR"/ 2>/dev/null || true
    rm -rf "$ROOTFS_DIR/amd64-rootfs-20170318T102216Z"
  fi

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
--root-id \
--link2symlink \
--kill-on-exit \
--cwd=/root \
--bind=/proc \
--bind=/dev \
--bind=/sys \
--bind=/tmp \
/bin/bash
