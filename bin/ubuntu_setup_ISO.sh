#!/bin/bash
# Install Latest 
ISO_URL=https://releases.ubuntu.com/20.04.4/ubuntu-20.04.4-live-server-amd64.iso
ISO=ubuntu-20.04.4-live-server-amd64.iso
ISO_NEW=custom-ubuntu-20.04.4-live-server-amd64.iso
WORKING_DIR=/tmp/workdir
DATA_DIR="`pwd`/data"
BUILD_PKG=configs.tar.gz
KS=custom.ks

# Target Versions and Folders

echo "Waiting for the system install to finish."
until [ -f /tmp/continue.txt ]
do
     sleep 1
done

rm -f zerofile

# install apt software needed.
apt-get install -y p7zip-full
apt-get install -y xorriso
apt-get install -y isolinux
apt-get -y update
apt-get -y clean
apt-get -y autoclean

# Download ISO Installer:
if [ ! -f "${DATA_DIR}/${ISO}" ]; then
  mkdir -p ${DATA_DIR}	
  wget -O ${DATA_DIR}/${ISO} ${ISO_URL}
fi

#echo "28ccdb56450e643bad03bb7bcf7507ce3d8d90e8bf09e38f6bd9ac298a98eaad *ubuntu-20.04.4-live-server-amd64.iso" | shasum -a 256 --check

# Create ISO distribution dirrectory:
mkdir -p iso/nocloud/

# Extract ISO using 7z:
###7z x ubuntu-20.04.4-live-server-amd64.iso -x'![BOOT]' -oiso
# Or extract ISO using xorriso and fix permissions:
xorriso -osirrox on -indev "${DATA_DIR}/${ISO}" -extract / iso && chmod -R +w iso

# Create empty meta-data file:
touch iso/nocloud/meta-data

cat <<EOF> ./user-data
#cloud-config
autoinstall:
  version: 1
  interactive-sections:
    - network
    - storage
  locale: en_US.UTF-8
  keyboard:
    layout: us
  ssh:
    allow-pw: true
    install-server: false
  late-commands:
    - curtin in-target --target=/target -- apt-get --purge -y --quiet=2 remove apport bcache-tools btrfs-progs byobu cloud-guest-utils cloud-initramfs-copymods cloud-initramfs-dyn-netconf friendly-recovery fwupd landscape-common lxd-agent-loader ntfs-3g open-vm-tools plymouth plymouth-theme-ubuntu-text popularity-contest rsync screen snapd sosreport tmux ufw
    - curtin in-target --target=/target -- apt-get --purge -y --quiet=2 autoremove
    - curtin in-target --target=/target -- apt-get clean
    - sed -i 's/ENABLED=1/ENABLED=0/' /target/etc/default/motd-news
    - sed -i 's|# en_US.UTF-8 UTF-8|en_US.UTF-8 UTF-8|' /target/etc/locale.gen
    - curtin in-target --target=/target -- locale-gen
    - ln -fs /dev/null /target/etc/systemd/system/connman.service
    - ln -fs /dev/null /target/etc/systemd/system/display-manager.service
    - ln -fs /dev/null /target/etc/systemd/system/motd-news.service
    - ln -fs /dev/null /target/etc/systemd/system/motd-news.timer
    - ln -fs /dev/null /target/etc/systemd/system/plymouth-quit-wait.service
    - ln -fs /dev/null /target/etc/systemd/system/plymouth-start.service
    - ln -fs /dev/null /target/etc/systemd/system/systemd-resolved.service
    - ln -fs /usr/share/zoneinfo/Europe/Kiev /target/etc/localtime
    - rm -f /target/etc/resolv.conf
    - printf 'nameserver 8.8.8.8\nnameserver 1.1.1.1\noptions timeout:1\noptions attempts:1\noptions rotate\n' > /target/etc/resolv.conf
    - rm -f /target/etc/update-motd.d/10-help-text
    - rm -rf /target/root/snap
    - rm -rf /target/snap
    - rm -rf /target/var/lib/snapd
    - rm -rf /target/var/snap
    - curtin in-target --target=/target -- passwd -q -u root
    - curtin in-target --target=/target -- passwd -q -x -1 root
    - curtin in-target --target=/target -- passwd -q -e root
    - sed -i 's|^root:.:|root:$6$3b873df474b55246$GIpSsujar7ihMzG8urUKpzF9/2yZJhR.msyFRa5ouGXOKRCVszsc4aBcE2yi3IuFVxtAGwrPKin2WAzK3qOtB.:|' /target/etc/shadow
  user-data:
    disable_root: false
EOF

# Copy user-data file:
cp -f user-data iso/nocloud/user-data


# Update boot flags with cloud-init autoinstall:
## Should look similar to this: initrd=/casper/initrd quiet autoinstall ds=nocloud;s=/cdrom/nocloud/ ---
sed -i 's|---|autoinstall ds=nocloud\\\;s=/cdrom/nocloud/ ---|g' iso/boot/grub/grub.cfg
sed -i 's|---|autoinstall ds=nocloud;s=/cdrom/nocloud/ ---|g' iso/isolinux/txt.cfg

# Disable mandatory md5 checksum on boot:
md5sum iso/.disk/info > iso/md5sum.txt
sed -i 's|iso/|./|g' iso/md5sum.txt

# (Optionally) Regenerate md5:
# The find will warn 'File system loop detected' and return non-zero exit status on the 'ubuntu' symlink to '.'
# To avoid that, temporarily move it out of the way
mv iso/ubuntu .
(cd iso; find '!' -name "md5sum.txt" '!' -path "./isolinux/*" -follow -type f -exec "$(which md5sum)" {} \; > ../md5sum.txt)
mv md5sum.txt iso/
mv ubuntu iso

# Create Install ISO from extracted dir (Ubuntu):
xorriso -as mkisofs -r \
  -V Ubuntu\ custom\ amd64 \
  -o ${DATA_DIR}/${ISO_NEW} \
  -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot \
  -boot-load-size 4 -boot-info-table \
  -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot \
  -isohybrid-gpt-basdat -isohybrid-apm-hfsplus \
  -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin  \
  iso/boot iso

echo "--- Clean apt packages."
apt-get -y update
apt-get -y clean
apt-get -y autoclean
rm -rf iso user-data /tmp/*

#sleep 500
# After install:
# - login with 'root:root' and change root user password
# - set correct hostname with 'hostnamectl'
