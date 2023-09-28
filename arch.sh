#! /bin/bash

# Globals
HOSTNAME="arch"
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
}

mount_partitions(){
  # Mount
  mount $ROOTPART /mnt
  mount --mkdir $BOOTPART /mnt/boot
  swapon $SWAPPART
}

set_keyboard(){
  # Set keyboard layout
  loadkeys us

  
}

set_datetime(){
  # Update system clock
  timedatectl
}

generate_fstab(){
  genfstab -U /mnt >> /mnt/etc/fstab
}

copy_provisions(){
  git clone https://github.com/xerocuil/provisions.git /mnt/provisions
}

change_root(){
  arch-chroot /mnt
}

install_essentials(){
  pacstrap -K /mnt base linux linux-firmware git tmux
}

set_locale(){
  # Set time locale
  ln -sf /usr/share/zoneinfo/$REGION /etc/localtime
  hwclock --systohc
  sed -i '1i# Custom settings\nLANG=de_DE.UTF-8\n\n' /etc/locale.gen

  # Set hostname
  echo -e "$HOSTNAME" > /etc/hostname

  # Set root password
  echo -e "Would you like to change the root password?\n[y/n]\n"
  read set_password
  if [[ set_password == "y" ]];then
    passwd
  fi
}

# Install bootloader (GRUB)
bootloader(){
  pacman -S grub efibootmgr
  grub-install --target=x86_64-efi --efi-directory=/mnt/boot --bootloader-id=GRUB
}


# get_arch
# set_locale
# create_partitions
# init
# bootloader
