#!/bin/sh

ROOTFS_DIR=/home/container
ARCH=$(uname -m)
PROOT_VERSION="5.3.0"

if [ "$ARCH" = "x86_64" ]; then
  DEB_ARCH="x86_64"
elif [ "$ARCH" = "aarch64" ]; then
  DEB_ARCH="aarch64"
else
  echo "Unsupported architecture: $ARCH"
  exit 1
fi

ROOTFS_URL="https://github.com/termux/proot-distro/releases/download/v4.26.0/debian-trixie-${DEB_ARCH}-pd-v4.26.0.tar.xz"

mkdir -p $ROOTFS_DIR

if [ ! -e $ROOTFS_DIR/.installed ]; then
  curl -L -o /tmp/rootfs.tar.xz "$ROOTFS_URL"
  tar -xJf /tmp/rootfs.tar.xz -C $ROOTFS_DIR

  curl -Lo $ROOTFS_DIR/usr/local/bin/proot \
  "https://github.com/proot-me/proot/releases/download/v${PROOT_VERSION}/proot-v${PROOT_VERSION}-${ARCH}-static"

  chmod 755 $ROOTFS_DIR/usr/local/bin/proot

  printf "nameserver 1.1.1.1\nnameserver 1.0.0.1" > $ROOTFS_DIR/etc/resolv.conf

  touch $ROOTFS_DIR/.installed
fi

$ROOTFS_DIR/usr/local/bin/proot \
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
