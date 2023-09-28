#! /bin/bash

# Globals
HDDDEV=/dev/sda
BOOTSIZE=300M
SWAPSIZE=16G
BOOTPART=${HDDDEV}1
SWAPPART=${HDDDEV}2
ROOTPART=${HDDDEV}3
REGION="America/New_York"

get_arch(){
  # Get arch/boot mode
  arch=$(cat /sys/firmware/efi/fw_platform_size)

  if [[ $arch == 32 ]]; then
    echo -e "32-bit IA32 UEFI\n"
  elif [[ $arch == 64 ]]; then
    echo -e "64-bit x64 UEFI\n"
  else
    echo -e "\n"
  fi
}

create_partitions(){
  # Make
  parted -s $HDDDEV \
    mklabel msdos \
    mkpart primary 1M 300MB \
    mkpart primary 301MB 16685MB \
    mkpart primary 16686MB 100%
  # Format
  mkfs.fat -F 32 -n "boot" $BOOTPART
  mkswap $SWAPPART
  mkfs.ext4 $ROOTPART
  # Mount
  mount $ROOTPART /mnt
  mount --mkdir $BOOTPART /mnt/boot
  swapon $SWAPPART
}

set_locale(){
  # Set keyboard layout
  loadkeys us

  # Update system clock
  timedatectl
}

init(){
  # Install essential packages
  pacstrap -K /mnt base linux linux-firmware

  # Configure Fstab
  genfstab -U /mnt >> /mnt/etc/fstab

  # Change root
  arch-chroot /mnt

  # Set time zone/clock
  ln -sf /usr/share/zoneinfo/$REGION /etc/localtime
  hwclock --systohc
}

# get_arch
# set_locale
# create_partitions
# init
