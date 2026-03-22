#!/bin/sh

ROOTFS_DIR=/home/container
PROOT_VERSION="5.3.0"

#############################
# ARCH
#############################

ARCH=$(uname -m)

if [ "$ARCH" = "x86_64" ]; then
  ARCH_ALT=amd64
elif [ "$ARCH" = "aarch64" ]; then
  ARCH_ALT=arm64
else
  echo "Unsupported architecture: $ARCH"
  exit 1
fi

#############################
# PROOT (AUTO DOWNLOAD)
#############################

mkdir -p $ROOTFS_DIR/usr/local/bin

if [ ! -f $ROOTFS_DIR/usr/local/bin/proot ]; then
  echo "Downloading proot..."
  curl -Lo $ROOTFS_DIR/usr/local/bin/proot \
  "https://github.com/proot-me/proot/releases/download/v${PROOT_VERSION}/proot-v${PROOT_VERSION}-${ARCH}-static"
  chmod +x $ROOTFS_DIR/usr/local/bin/proot
fi

PROOT_BIN="$ROOTFS_DIR/usr/local/bin/proot"

#############################
# MENU
#############################

clear
echo "========================="
echo "   SELECT DISTRO"
echo "========================="
echo "1) Alpine Linux (lekki)"
echo "2) Ubuntu 22.04 (x86_64 only)"
echo "========================="

read -p "Wybierz (1/2): " CHOICE

#############################
# UBUNTU
#############################

if [ "$CHOICE" = "2" ]; then
  if [ "$ARCH" != "x86_64" ]; then
    echo "Ubuntu działa tylko na x86_64"
    exit 1
  fi

  if [ ! -e $ROOTFS_DIR/.installed ]; then
    echo "Instalowanie Ubuntu..."

    curl -Lo /tmp/rootfs.tar.xz \
    "https://github.com/termux/proot-distro/releases/download/v4.7.0/ubuntu-jammy-x86_64-pd-v4.7.0.tar.xz"

    mkdir -p $ROOTFS_DIR
    tar -xJf /tmp/rootfs.tar.xz -C $ROOTFS_DIR

    echo "nameserver 1.1.1.1" > $ROOTFS_DIR/etc/resolv.conf
    echo "nameserver 1.0.0.1" >> $ROOTFS_DIR/etc/resolv.conf

    touch $ROOTFS_DIR/.installed
  fi

  echo "Start Ubuntu..."

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
fi

#############################
# ALPINE (DEFAULT)
#############################

ALPINE_VERSION="3.9"
ALPINE_FULL_VERSION="3.9.6"
APK_TOOLS_VERSION="2.14.0-r2"

if [ ! -e $ROOTFS_DIR/.installed ]; then
  echo "Instalowanie Alpine..."

  curl -Lo /tmp/rootfs.tar.gz \
  "https://dl-cdn.alpinelinux.org/v${ALPINE_VERSION}/releases/${ARCH}/alpine-minirootfs-${ALPINE_FULL_VERSION}-${ARCH}.tar.gz"

  mkdir -p $ROOTFS_DIR
  tar -xzf /tmp/rootfs.tar.gz -C $ROOTFS_DIR
fi

if [ ! -e $ROOTFS_DIR/.installed ]; then
  echo "Instalowanie pakietów Alpine..."

  curl -Lo /tmp/apk-tools-static.apk \
  "https://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION}/main/${ARCH}/apk-tools-static-${APK_TOOLS_VERSION}.apk"

  tar -xzf /tmp/apk-tools-static.apk -C /tmp/

  /tmp/sbin/apk.static \
    -X "https://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION}/main/" \
    -U --allow-untrusted \
    --root $ROOTFS_DIR add alpine-base apk-tools
fi

if [ ! -e $ROOTFS_DIR/.installed ]; then
  echo "nameserver 1.1.1.1" > $ROOTFS_DIR/etc/resolv.conf
  echo "nameserver 1.0.0.1" >> $ROOTFS_DIR/etc/resolv.conf

  rm -rf /tmp/rootfs.tar.gz /tmp/apk-tools-static.apk /tmp/sbin
  touch $ROOTFS_DIR/.installed
fi

echo "Start Alpine..."

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
/bin/sh
