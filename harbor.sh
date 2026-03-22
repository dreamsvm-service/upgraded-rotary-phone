#!/bin/sh

ROOTFS_DIR=/home/container
PROOT_VERSION="5.3.0"

#############################
# ARCH CHECK
#############################

ARCH=$(uname -m)

if [ "$ARCH" != "x86_64" ]; then
  echo "❌ Tylko x86_64"
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
# UBUNTU INSTALL CHECK
#############################

if [ -f "$ROOTFS_DIR/.installed" ] && [ -f "$ROOTFS_DIR/bin/bash" ]; then
  echo "✅ Ubuntu już zainstalowane — pomijam pobieranie"
else
  echo "📥 Instalowanie Ubuntu (UserLAnd rootfs)..."

  rm -rf $ROOTFS_DIR/*
  mkdir -p $ROOTFS_DIR

  curl -Lo /tmp/rootfs.tar.gz \
  "https://github.com/CypherpunkArmory/UserLAnd-Assets-Ubuntu/releases/download/v0.0.12/x86_64-rootfs.tar.gz"

  tar -xzf /tmp/rootfs.tar.gz -C $ROOTFS_DIR

  echo "🌐 DNS..."
  echo "nameserver 1.1.1.1" > $ROOTFS_DIR/etc/resolv.conf
  echo "nameserver 1.0.0.1" >> $ROOTFS_DIR/etc/resolv.conf

  mkdir -p $ROOTFS_DIR/proc $ROOTFS_DIR/dev $ROOTFS_DIR/sys $ROOTFS_DIR/tmp

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
