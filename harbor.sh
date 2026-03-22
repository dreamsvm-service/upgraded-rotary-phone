#!/bin/sh

ROOTFS_DIR=/home/container
PROOT_VERSION="5.3.0"

#############################
# ARCH
#############################

ARCH=$(uname -m)

if [ "$ARCH" != "x86_64" ]; then
  echo "❌ Ten skrypt obsługuje tylko x86_64"
  exit 1
fi

#############################
# PROOT
#############################

mkdir -p $ROOTFS_DIR/usr/local/bin

if [ ! -f $ROOTFS_DIR/usr/local/bin/proot ]; then
  echo "📥 Pobieranie proot..."
  curl -Lo $ROOTFS_DIR/usr/local/bin/proot \
  "https://github.com/proot-me/proot/releases/download/v${PROOT_VERSION}/proot-v${PROOT_VERSION}-${ARCH}-static"
  chmod +x $ROOTFS_DIR/usr/local/bin/proot
fi

PROOT_BIN="$ROOTFS_DIR/usr/local/bin/proot"

#############################
# UBUNTU INSTALL
#############################

if [ ! -e $ROOTFS_DIR/.installed ]; then
  echo "📥 Pobieranie Ubuntu..."

  curl -Lo /tmp/rootfs.tar.xz \
  "https://github.com/termux/proot-distro/releases/download/v4.7.0/ubuntu-jammy-x86_64-pd-v4.7.0.tar.xz"

  mkdir -p $ROOTFS_DIR
  tar -xJf /tmp/rootfs.tar.xz -C $ROOTFS_DIR

  echo "🌐 Ustawianie DNS..."
  echo "nameserver 1.1.1.1" > $ROOTFS_DIR/etc/resolv.conf
  echo "nameserver 1.0.0.1" >> $ROOTFS_DIR/etc/resolv.conf

  touch $ROOTFS_DIR/.installed
fi

#############################
# START
#############################

echo "🚀 Start Ubuntu..."

exec $PROOT_BIN \
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
