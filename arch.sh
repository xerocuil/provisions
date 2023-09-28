#! /bin/bash

# Globals
HDDDEV=/dev/sda
BOOTSIZE=300M
SWAPSIZE=16G
BOOTPART=$HDDDEV1
SWAPPART=$HDDDEV2
ROOTPART=$HDDDEV3

# Functions
# create_partitions(){
#   fdisk $HDDDEV <<EEOF
#   n
#   p
#   1

#   +$BOOTSIZE
#   n
#   p
#   2

#   +$SWAPSIZE
#   n
#   p
#   3


# EEOF
#   exit 0
# }

create_partitions(){
  parted -s $HDDDEV \
    mklabel msdos \
    mkpart primary 1M 300MB \
    mkpart primary 301MB 16000MB \
    mkpart primary 16001MB 100% 
}

format_partitions(){
  mkswap $SWAPPART
  mkfs.ext4 $ROOTPART
}


set_locale(){
  # Set keyboard layout
  loadkeys us

  # Update system clock
  timedatectl
}

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
