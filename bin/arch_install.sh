#!/bin/bash

# 0 - SSH
# This isn't necessary but if you ssh into the computer all the other steps are copy and paste
# Set a password for root
passwd
# Get network access
iwctl

"""
# First, if you do not know your wireless device name, list all Wi-Fi devices: 
[iwd]# device list
# Then, to scan for networks: 
[iwd]# station device scan
# You can then list all available networks: 
[iwd]# station device get-networks
# Finally, to connect to a network: 
[iwd]# station device connect SSID
"""

# Start the ssh daemon
systemctl start sshd.service

# 1 - Partitioning:
cfdisk /dev/nvme0n1
# nvme0n1p1 = /boot, nvme0n1p2 = SWAP, nvme0n1p3 = encrypted root
# for the SWAP partition below, try and make it a bit bigger than your RAM, for hybernating
# o , 
# /dev/nvme0n1p1    512M          EFI System
# /dev/nvme0n1p2    (the rest)    Linux Filesystem  

# 2 Encrypt Partition
cryptsetup luksFormat --perf-no_read_workqueue --perf-no_write_workqueue --type luks2 --cipher aes-xts-plain64 --key-size 512 --iter-time 2000 --pbkdf argon2id --hash sha3-512 /dev/nvme0n1p2
cryptsetup --allow-discards --perf-no_read_workqueue --perf-no_write_workqueue --persistent open /dev/nvme0n1p2 crypt

# 3 - Formatting the partitions:
# the first one is our ESP partition, so for now we just need to format it
mkfs.vfat -F32 -n "EFI" /dev/nvme0n1p1
mkfs.btrfs -L ROOT /dev/mapper/crypt

# 4 - Create and Mount Subvolumes
# Create subvolumes for root, home, the package cache, snapshots and the entire Btrfs file system
mount /dev/mapper/crypt /mnt
btrfs sub create /mnt/@
btrfs sub create /mnt/@home
btrfs sub create /mnt/@pkg
btrfs sub create /mnt/@abs
btrfs sub create /mnt/@tmp
btrfs sub create /mnt/@srv
btrfs sub create /mnt/@snapshots
btrfs sub create /mnt/@btrfs
btrfs sub create /mnt/@swap
umount /mnt

# Mount the subvolumes
mount -o noatime,nodiratime,compress=zstd,commit=120,space_cache,ssd,discard=async,autodefrag,subvol=@ /dev/mapper/crypt /mnt
mkdir -p /mnt/{boot,home,var/cache/pacman/pkg,.snapshots,.swapvol,btrfs}
mount -o noatime,nodiratime,compress=zstd,commit=120,space_cache,ssd,discard=async,autodefrag,subvol=@home /dev/mapper/crypt /mnt/home
mount -o noatime,nodiratime,compress=zstd,commit=120,space_cache,ssd,discard=async,autodefrag,subvol=@pkg /dev/mapper/crypt /mnt/var/cache/pacman/pkg
mount -o noatime,nodiratime,compress=zstd,commit=120,space_cache,ssd,discard=async,autodefrag,subvol=@abs /dev/mapper/crypt /mnt/var/abs
mount -o noatime,nodiratime,compress=zstd,commit=120,space_cache,ssd,discard=async,autodefrag,subvol=@tmp /dev/mapper/crypt /mnt/var/tmp
mount -o noatime,nodiratime,compress=zstd,commit=120,space_cache,ssd,discard=async,autodefrag,subvol=@srv /dev/mapper/crypt /mnt/srv
mount -o noatime,nodiratime,compress=zstd,commit=120,space_cache,ssd,discard=async,autodefrag,subvol=@snapshots /dev/mapper/crypt /mnt/.snapshots
mount -o compress=no,space_cache,ssd,discard=async,subvol=@swap /dev/mapper/crypt /mnt/.swapvol
mount -o noatime,nodiratime,compress=zstd,commit=120,space_cache,ssd,discard=async,autodefrag,subvolid=5 /dev/mapper/crypt /mnt/btrfs

# Create Swapfile
truncate -s 0 /mnt/.swapvol/swapfile
chattr +C /mnt/.swapvol/swapfile
btrfs property set /mnt/.swapvol/swapfile compression none
fallocate -l 16G /mnt/.swapvol/swapfile
chmod 600 /mnt/.swapvol/swapfile
mkswap /mnt/.swapvol/swapfile
swapon /mnt/.swapvol/swapfile

# Mount the EFI partition
mount /dev/nvme0n1p1 /mnt/boot

# 5 Base System and /etc/fstab
# (this is the time where you change the mirrorlist, if that's your thing)
# The following assumes you have an AMD CPU & GPU
pacstrap /mnt base base-devel linux linux-firmware amd-ucode btrfs-progs sbsigntools \
    neovim zstd go iwd networkmanager mesa vulkan-radeon libva-mesa-driver mesa-vdpau \
    xf86-video-amdgpu docker libvirt qemu openssh refind zsh zsh-completions \
    zsh-autosuggestions zsh-history-substring-search zsh-syntax-highlighting git \
    pigz pbzip2

# generate the fstab
genfstab -U /mnt > /mnt/etc/fstab

# 6 System Configuration
# Use timedatectl(1) to ensure the system clock is accurate
timedatectl set-ntp true
# chroot into the new system
arch-chroot /mnt

# Replace username with the name for your new user
export USER=username
# Replace hostname with the name for your host
export HOST=hostname
# Replace Europe/London with your Region/City
export TZ="Europe/London"
# - set root password 
passwd
# - set locale
echo "en_US.UTF-8 UTF-8" > locale.gen
locale-gen
echo "LANG=\"en_US.UTF-8\"" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf
export LANG="en_US.UTF-8"
export LC_COLLATE="C"
# - set timezone
ln -sf /usr/share/zoneinfo/$TZ /etc/localtime
hwclock -uw # or hwclock --systohc --utc
# - set hostname
echo $HOST > /etc/hostname
# - add user 
useradd -mg users -G wheel,storage,power,docker,libvirt,kvm -s /bin/zsh $USER
passwd $USER
echo "$USER ALL=(ALL) ALL" >> /etc/sudoers 
echo "Defaults timestamp_timeout=0" >> /etc/sudoers
# - set hosts
cat << EOF >> /etc/hosts
echo "# <ip-address>	<hostname.domain.org>	<hostname>"
echo "127.0.0.1	localhost"
echo "::1		localhost"
echo "127.0.1.1	$HOST.localdomain	$HOST" 
EOF
# - Set Network Manager iwd backend
echo "[device]" > /etc/NetworkManager/conf.d/nm.conf
echo "wifi.backend=iwd" >> /etc/NetworkManager/conf.d/nm.conf

# - Preventing snapshot slowdowns
echo 'PRUNENAMES = ".snapshots"' >> /etc/updatedb.conf

# 6 - fix the mkinitcpio.conf to contain what we actually need.
sed -i 's/BINARIES=()/BINARIES=("\/usr\/bin\/btrfs")/' /etc/mkinitcpio.conf
# If using amdgpu and would like earlykms
# sed -i 's/MODULES=()/MODULES=(amdgpu)/' /etc/mkinitcpio.conf
sed -i 's/#COMPRESSION="lz4"/COMPRESSION="lz4"/' mkinitcpio.conf
sed -i 's/#COMPRESSION_OPTIONS=()/COMPRESSION_OPTIONS=(-9)/' mkinitcpio.conf
# if you have more than 1 btrfs drive
# sed -i 's/^HOOKS/HOOKS=(base systemd autodetect modconf block sd-encrypt resume btrfs filesystems keyboard fsck)/' mkinitcpio.conf
# else
sed -i 's/^HOOKS/HOOKS=(base systemd autodetect modconf block sd-encrypt resume filesystems keyboard fsck)/' mkinitcpio.conf

mkinitcpio -p linux

# 10 Bootloader
su $USER
cd ~
git clone https://aur.archlinux.org/yay.git && cd yay
makepkg -si
cd .. && sudo rm -dR yay
yay -S shim-signed pamac-aur

# If you use a bare git to store dotfiles install them now
# git clone --bare https://github.com/user/repo.git $HOME/.repo
exit

refind-install --shim /usr/share/shim-signed/shimx64.efi --localkeys
sbsign --key /etc/refind.d/keys/refind_local.key --cert /etc/refind.d/keys/refind_local.crt --output /boot/vmlinuz-linux /boot/vmlinuz-linux
mkdir /etc/pacman.d/hooks

cat << EOF > /etc/pacman.d/hooks/999-sign_kernel_for_secureboot.hook
"""
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = linux
Target = linux-lts
Target = linux-hardened
Target = linux-zen

[Action]
Description = Signing kernel with Machine Owner Key for Secure Boot
When = PostTransaction
Exec = /usr/bin/find /boot/ -maxdepth 1 -name 'vmlinuz-*' -exec /usr/bin/sh -c '/usr/bin/sbsign --key /etc/refind.d/keys/refind_local.key --cert /etc/refind.d/keys/refind_local.crt --output {} {}'
Depends = sbsigntools
Depends = findutils
Depends = grep
EOF

cat << EOF > /etc/pacman.d/hooks/refind.hook
[Trigger]
Operation=Upgrade
Type=Package
Target=refind

[Action]
Description = Updating rEFInd on ESP
When=PostTransaction
Exec=/usr/bin/refind-install --shim /usr/share/shim-signed/shimx64.efi --localkeys
EOF

cat << EOF > /etc/pacman.d/hooks/zsh.hook
[Trigger]
Operation = Install
Operation = Upgrade
Operation = Remove
Type = Path
Target = usr/bin/*
[Action]
Depends = zsh
When = PostTransaction
Exec = /usr/bin/install -Dm644 /dev/null /var/cache/zsh/pacman
EOF

cat << EOF > /etc/udev/rules.d/60-ioschedulers.rules
# set scheduler for NVMe
ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"
# set scheduler for SSD and eMMC
ACTION=="add|change", KERNEL=="sd[a-z]|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
# set scheduler for rotating disks
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
EOF

# Optimize Makepkg
sed -i 's/^CFLAGS/CFLAGS="-march=native -mtune=native -O2 -pipe -fstack-protector-strong --param=ssp-buffer-size=4 -fno-plt"/' /etc/makepkg.conf
sed -i 's/^CXXFLAGS/CXXFLAGS="${CFLAGS}"/' /etc/makepkg.conf
sed -i 's/^#RUSTFLAGS/RUSTFLAGS="-C opt-level=2 -C target-cpu=native"/' etc/makepkg.conf
sed -i 's/^#BUILDDIR/BUILDDIR=\/tmp\/makepkg makepkg/' etc/makepkg.conf
sed -i 's/^#MAKEFLAGS/MAKEFLAGS="-j$(getconf _NPROCESSORS_ONLN) --quiet"/' etc/makepkg.conf
sed -i 's/^COMPRESSGZ/COMPRESSGZ=(pigz -c -f -n)/' etc/makepkg.conf
sed -i 's/^COMPRESSBZ2/COMPRESSBZ2=(pbzip2 -c -f)/' etc/makepkg.conf
sed -i 's/^COMPRESSXZ/COMPRESSXZ=(xz -T "$(getconf _NPROCESSORS_ONLN)" -c -z --best -)/' etc/makepkg.conf
sed -i 's/^COMPRESSZST/COMPRESSZST=(zstd -c -z -q --ultra -T0 -22 -)/' etc/makepkg.conf
sed -i 's/^COMPRESSLZ/COMPRESSLZ=(lzip -c -f)/' etc/makepkg.conf
sed -i 's/^COMPRESSLRZ/COMPRESSLRZ=(lrzip -9 -q)/' etc/makepkg.conf
sed -i 's/^COMPRESSLZO/COMPRESSLZO=(lzop -q --best)/' etc/makepkg.conf
sed -i 's/^COMPRESSZ/COMPRESSZ=(compress -c -f)/' etc/makepkg.conf
sed -i 's/^COMPRESSLZ4/COMPRESSLZ4=(lz4 -q --best)/' etc/makepkg.conf

# Misc options
sed -i 's/#UseSyslog/UseSyslog/' etc/pacman.conf
sed -i 's/#Color/Color\\\nILoveCandy/' etc/pacman.conf
sed -i 's/#TotalDownload/TotalDownload/' etc/pacman.conf
sed -i 's/#CheckSpace/CheckSpace/' etc/pacman.conf

# Get resume  offset for BTRFS swapfile
cd /root/
curl -LJO https://raw.githubusercontent.com/osandov/osandov-linux/master/scripts/btrfs_map_physical.c
gcc -O2 -o btrfs_map_physical btrfs_map_physical.c
rm btrfs_map_physical.c
mv btrfs_map_physical /usr/local/bin

mkdir /boot/EFI/refind/themes
git clone https://github.com/dheishman/refind-dreary.git /boot/EFI/refind/themes/refind-dreary
mv  /boot/EFI/refind/themes/refind-dreary/highres /boot/EFI/refind/themes/refind-dreary-tmp
rm -dR /boot/EFI/refind/themes/refind-dreary
mv /boot/EFI/refind/themes/refind-dreary-tmp /boot/EFI/refind/themes/refind-dreary

# Replace 1920 1080 with your monitors resolution
sed -i 's/#resolution 3/resolution 1920 1080/' /boot/EFI/refind/refind.conf
sed -i 's/#use_graphics_for osx,linux/use_graphics_for linux/' /boot/EFI/refind/refind.conf
sed -i 's/#scanfor internal,external,optical,manual/scanfor manual,external/' /boot/EFI/refind/refind.conf

# add the UUID to the options (example below)
cat << EOF >> /boot/EFI/refind/refind.conf
menuentry "Arch Linux" {
    icon     icon /EFI/refind/themes/refind-dreary/icons/os_arch.png
    volume   "Arch Linux"
    loader   /vmlinuz-linux
    initrd   /initramfs-linux.img
    options  "rd.luks.name=$(blkid /dev/nvme0n1p2 | cut -d " " -f2 | cut -d '=' -f2 | sed 's/\"//g')=crypt root=/dev/mapper/crypt rootflags=subvol=@ resume=/dev/mapper/crypt resume_offset=$( echo "$(btrfs_map_physical /.swapvol/swapfile | head -n2 | tail -n1 | awk '{print $6}') / $(getconf PAGESIZE) " | bc) rw quiet nmi_watchdog=0 add_efi_memmap initrd=/amd-ucode.img"
    submenuentry "Boot using fallback initramfs" {
        initrd /boot/initramfs-linux-fallback.img
    }
}

include themes/refind-dreary/theme.conf
EOF

# Laptop Battery Life Improvements
echo "vm.dirty_writeback_centisecs = 6000" > /etc/sysctl.d/dirty.conf
echo "load-module module-suspend-on-idle" >> /etc/pulse/default.pa
if [ $(( $(lspci -k | grep snd_ac97_codec | wc -l) + 1 )) -gt 1 ]; then echo "options snd_ac97_codec power_save=1" > /etc/modprobe.d/audio_powersave.conf; fi
if [ $(( $(lspci -k | grep snd_hda_intel | wc -l) + 1 )) -gt 1 ]; then echo "options snd_hda_intel power_save=1" > /etc/modprobe.d/audio_powersave.conf; fi
if [ $(lsmod | grep '^iwl.vm' | awk '{print $1}') == "iwlmvm" ]; then echo "options iwlwifi power_save=1" > /etc/modprobe.d/iwlwifi.conf; echo "options iwlmvm power_scheme=3" >> /etc/modprobe.d/iwlwifi.conf; fi
if [ $(lsmod | grep '^iwl.vm' | awk '{print $1}') == "iwldvm" ]; then echo "options iwldvm force_cam=0" >> /etc/modprobe.d/iwlwifi.conf; fi
echo 'ACTION=="add", SUBSYSTEM=="scsi_host", KERNEL=="host*", ATTR{link_power_management_policy}="med_power_with_dipm"' > /etc/udev/rules.d/hd_power_save.rules

# 11 - reboot into your new install
exit
umount -R /mnt
swapoff -a
reboot

# 12 - After instalation
systemctl enable --now NetworkManager
systemctl enable --now sshd
sudo pacman -S snapper sddm
sudo umount /.snapshots
sudo rm -r /.snapshots
sudo snapper -c root create-config /
sudo mount -a
sudo chmod 750 -R /.snapshots
