#!/bin/sh

ROOTFS_DIR=/home/container/ubuntu
PROOT_VERSION="5.3.0"

#############################
# ARCH
#############################

ARCH=$(uname -m)

if [ "$ARCH" != "x86_64" ]; then
  echo "❌ Tylko x86_64"
  exit 1
fi

#############################
# PROOT
#############################

mkdir -p /home/container/bin

if [ ! -f /home/container/bin/proot ]; then
  echo "📥 Pobieranie proot..."
  curl -L --retry 5 --retry-delay 3 \
  -o /home/container/bin/proot \
  "https://github.com/proot-me/proot/releases/download/v${PROOT_VERSION}/proot-v${PROOT_VERSION}-${ARCH}-static"

  chmod +x /home/container/bin/proot
fi

PROOT_BIN="/home/container/bin/proot"

#############################
# INSTALL CHECK
#############################

if [ -f "$ROOTFS_DIR/.installed" ] && [ -f "$ROOTFS_DIR/bin/bash" ]; then
  echo "✅ Ubuntu już zainstalowane"
else
  echo "📥 Instalowanie Ubuntu..."

  mkdir -p $ROOTFS_DIR

  curl -L --retry 5 --retry-delay 3 \
  -o "$ROOTFS_DIR/rootfs.tar.gz" \
  "https://github.com/CypherpunkArmory/UserLAnd-Assets-Ubuntu/releases/download/v0.0.12/x86_64-rootfs.tar.gz"

  tar -xzf "$ROOTFS_DIR/rootfs.tar.gz" -C $ROOTFS_DIR
  rm "$ROOTFS_DIR/rootfs.tar.gz"

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
--bind=/home/container:/host \
/bin/bash
