#!/bin/bash
# Install Latest XRDP with XORGXRDP
ISO_URL=https://repo.almalinux.org/almalinux/8/isos/x86_64/AlmaLinux-8.5-x86_64-boot.iso
ISO=AlmaLinux-8.5-x86_64-boot.iso
ISO_NEW=custom-AlmaLinux-8.5.iso
WORKING_DIR=/tmp/workdir
DATA_DIR="`pwd`/data"
BUILD_PKG=configs.tar.gz
KS=custom.ks

#Another possibility: https://github.com/nomorespice/centos8-howto/wiki/How-to-install-CentOS-8-via-kickstart

# view groupinf this queries the list of packages. 
dnf groupinfo "Minimal Install"
dnf groupinfo "Core" "Guest Agents" "Standard"

#Get a list of dependancies for rpms
# examples from: https://www.golinuxcloud.com/how-to-get-complete-dependencies-list-of-rpm/
#   rpm -qR glibc
#   yum deplist glibc
#   repoquery -R --resolve --recursive glibc
#For Local
#   rpm -qpR glibc-2.17-222.el7.x86_64.rpm

# Install the software you want.  
  dnf install -y git
  dnf groupinstall -y  "Minimal Install"
# Create a list of software
  rpm -qa --queryformat %{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}'\n' > /tmp/rpms.txt
# Copy the files to the BaseOS and AppStream locations for the installer. 
  mkdir -p /data/custom_iso/BaseOS/Packages /data/custom_iso/AppStream/Packages

# Build the info and get the packages
 cat <<EOB>>/tmp/copy_rpms_to_myiso.sh
#!/bin/bash

RPM_FILE="/tmp/rpms.txt"
for pkg in `cat $RPM_FILE`; do
    RPM=`find /mnt/ -name $pkg*.rpm`
    if [[ $RPM =~ .*BaseOS.* ]];then
       cp -ap $RPM /data/custom_iso/BaseOS/Packages/
    elif [[ $RPM =~ .*AppStream.* ]];then
       cp -ap $RPM /data/custom_iso/AppStream/Packages/
    else
       echo "$pkg not found"
    fi
done
EOB 
chmod +x /tmp/copy_rpms_to_myiso.sh
/tmp/copy_rpms_to_myiso.sh


dnf install -y createrepo

cp /mnt/BaseOS/repodata/*comps*.xml BaseOS/comps_base.xml
cp /mnt/AppStream/repodata/*comps*.xml AppStream/comps_app.xml

createrepo -g comps_app.xml AppStream/
#view the files
ls -l BaseOS/repodata/ AppStream/repodata/
ls -l /mnt/AppStream/repodata/*modules*

cp /mnt/AppStream/repodata/*modules.yaml* AppStream/
gunzip *-modules.yaml.gz
ls -l *modules*.yaml

modifyrepo_c --mdtype=modules AppStream/modules.yaml AppStream/repodata/

cp *-modules.yaml modules.yaml

ls -l AppStream/repodata/

cat <<EOK>> /tmp/ks.cfg
#platform=x86, AMD64, or Intel EM64T
#version=RHEL8
repo --name="AppStream" --baseurl=file:///run/install/repo/AppStream

# Only use sda disk
ignoredisk --only-use=sda

# System bootloader configuration
bootloader --append="rhgb novga console=ttyS0,115200 console=tty0 panic=1" --location=mbr --driveorder="sda" --boot-drive=sda

# Clear the Master Boot Record
zerombr

# Partition clearing information
clearpart --all

# Reboot after installation
reboot

# Use text mode install
text

# Use CDROM
cdrom

# Keyboard layouts
keyboard --vckeymap=us --xlayouts=''

# System language
lang en_US.UTF-8

# Installation logging level
logging --level=info

# Network information
network --bootproto=dhcp --device=enp0s3 --noipv6 --activate --hostname server1.example.com

# Root password
rootpw --iscrypted $1$oXhMRzpse6FeGBc1uF2JmG2xTeSWPL9

# System authorization information
authselect --enableshadow --passalgo=sha512

# SELinux configuration
selinux --disabled

firstboot --disable

# Do not configure the X Window System
skipx

# System services
services --disabled="kdump,rpcbind,sendmail,postfix,chronyd"

# System timezone
timezone America/Denver --isUtc --ntpservers=pool.ntp.org

# Disk partitioning information
autopart --type=lvm

%packages
@^minimal-environment
smartmontools
sysstat
tmux
tuned
zip
%end

%addon com_redhat_kdump --disable --reserve-mb='auto'
%end
EOK

#Change the grub menu
#	From:	append initrd=initrd.img inst.stage2=hd:LABEL=CentOS-8-BaseOS-x86_64 quiet
#	To:	append initrd=initrd.img inst.repo=cdrom ks=cdrom:/ks.cfg quiet

dnf install -y genisoimage
mkisofs -o /tmp/new.iso -b isolinux/isolinux.bin -c isolinux/boot.cat --no-emul-boot --boot-load-size 4 --boot-info-table -J -R -V "CentOS-8-2-2004-x86_64-dvd" .

# README
# Manual steps required first:
# Enable "Non-Free" repost in APT by adding "non-free" at the end of every URL in /etc/apt/sources.list

#ls ../autoinstall/hardening/ComplianceAsCode-content-hardening/products/rhel8/kickstart/ssg-rhel8-stig-ks.cfg
#ls ../autoinstall/hardening/ComplianceAsCode-content-hardening/products/rhel8/kickstart/ssg-rhel8-stig_gui-ks.cfg


#get cdrom installer
#get hardening repositries (ComplianceAsCode,RedhatGov,Mitre,ansible-lockdown)...
#get kickstart -- pulling from repo if applicable.
#Make ISO w/ks -- uefi and legacy builds
#Make image    -- tbd
#run audit tool 
#run hardening
#run audit tool
#compare results

#Repeat after updating hardening repos


# Target Versions and Folders

echo "Waiting for the system install to finish."
until [ -f /tmp/continue.txt ]
do
     sleep 1
done
echo "Last command of the user-data detected.  Starting build "
dnf makecache --refresh
dnf update  -y
dnf install -y git  
dnf install -y xorriso
dnf install -y wget
echo "...Starting copy ISO to working dir"
mkdir -p ${DATA_DIR}
mkdir -p ${WORKING_DIR}
if [ ! -f "${DATA_DIR}/${ISO}" ]; then
  wget -q -O "${DATA_DIR}/${ISO}" "${ISO_URL}"
fi
mount -o loop ${DATA_DIR}/${ISO} /mnt
mkdir -p ${WORKING_DIR}
cp -r /mnt/. ${WORKING_DIR}/customiso
umount /mnt
echo "...Finish copying ISO to working directory."

echo "...Start kickstart setup."
cp ${KS} ${WORKING_DIR}/customiso/isolinux/ks.cfg
sed -i '/append\ initrd/s/$/ inst.ks=cdrom:\/isolinux\/ks.cfg/' ${WORKING_DIR}/customiso/isolinux/isolinux.cfg
sed -i '/linuxefi/s/$/ inst.ks=cdrom:\/isolinux\/ks.cfg/' ${WORKING_DIR}/customiso/EFI/BOOT/grub.cfg
mount -o loop ${WORKING_DIR}/customiso/images/efiboot.img /mnt
sed -i '/linuxefi/s/$/ inst.ks=cdrom:\/isolinux\/ks.cfg/' /mnt/EFI/BOOT/grub.cfg
umount /mnt
echo "---Finished kickstart setup."

echo "...Start create custom ISO."
xorriso -as mkisofs -o ${DATA_DIR}/${ISO_NEW} -V "AlmaLinux 8 x86_64" \
-c isolinux/boot.cat -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 \
-boot-info-table -eltorito-alt-boot \
-e images/efiboot.img -no-emul-boot -R -J ${WORKING_DIR}/customiso
echo "...Finished create custom ISO."

#echo "Pausing for a while."
#sleep 500
echo "All done."

# Script Completed
exit
# 	NOTES and ideas pulled from various places.

#Different ISO build. 
xorriso -as mkisofs -o /isos/centOS8.iso -V "CentOS-8-1-1911-x86_64-dvd" -c isolinux/boot.cat -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot -e images/efiboot.img -no-emul-boot -R -J .
https://www.golinuxcloud.com/create-custom-iso-rhel-centos-8/


#Media
#	https://repo.almalinux.org/almalinux/8/isos/x86_64/AlmaLinux-8.5-x86_64-boot.iso        #700M
#	https://repo.almalinux.org/almalinux/8/isos/x86_64/AlmaLinux-8.5-x86_64-dvd.iso         #10G
#	https://repo.almalinux.org/almalinux/8/isos/x86_64/AlmaLinux-8.5-x86_64-minimal.iso     #2G

#Reference
#	https://gist.github.com/VerosK/326ea836aaf1ee40b8d02d410707ca8f #centos complete build of version 7
#       https://github.com/AlmaLinux/sig-livemedia                      #live image that runs off of dvd / cdrom
#       https://github.com/AlmaLinux/cloud-images                       #Default process used to make cloud image.

#Make a password hash
#	$ plaintext='password'
#	$ password=$(openssl passwd -6 $plaintext)
#	$ echo $password
#	$6$Lftvi9K28UlI8X.B$5knQkRMIieQzoeTgakK5oGrtGLU/tf2pbaakSkp0bbPqC.4k9HoreE./UH4QR7RZFH2Kg2QrxODkIeCw.CO5O0

mount -o loop /dev/cdrom /mnt
mkdir /ISO
cp -r /mnt/. /ISO/kickstart.iso
umount /mnt
cp kickstart.cfg /ISO/kickstart.iso/isolinux/ks.cfg
sed -i '/append\ initrd/s/$/ inst.ks=cdrom:\/isolinux\/ks.cfg/' /ISO/kickstart.iso/isolinux/isolinux.cfg
sed -i '/linuxefi/s/$/ inst.ks=cdrom:\/isolinux\/ks.cfg/' /ISO/kickstart.iso/EFI/BOOT/grub.cfg
mount -o loop /ISO/kickstart.iso/images/efiboot.img /mnt
sed -i '/linuxefi/s/$/ inst.ks=cdrom:\/isolinux\/ks.cfg/' /mnt/EFI/BOOT/grub.cfg
umount /mnt

xorriso -as mkisofs -o /ISOs/test.iso -V "CentOS 7 x86_64" \
-c isolinux/boot.cat -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 \
-boot-info-table -eltorito-alt-boot \
-e images/efiboot.img -no-emul-boot -R -J /ISO/kickstart.iso/


#Kickstart changes that may need to happen.
exit
%include /tmp/uefi
%include /tmp/legacy

%pre --logfile /tmp/kickstart.install.pre.log

clearpart --all --initlabel

if [ -d /sys/firmware/efi ] ; then

 cat >> /tmp/uefi <<END

part /boot --fstype="ext4" --size=512
part /boot/efi --fstype="vfat" --size=1024
part swap  --size=100  --fstype=swap
part pv.13 --size=1 --grow
volgroup VolGroup00 pv.13
logvol / --fstype xfs --name=rootsys --vgname=VolGroup00 --size=3000

END

else

 cat >> /tmp/legacy <<END

part /boot  --fstype=ext4 --size=300
part pv.6 --size=1000 --grow --ondisk=$d1
part swap  --size=100  --fstype=swap
part pv.13 --size=1 --grow
volgroup VolGroup00 pv.13
logvol / --fstype xfs --name=rootsys --vgname=VolGroup00 --size=3000

END

fi

if [ -d /sys/firmware/efi ] ; then
touch /tmp/legacy
else
touch /tmp/uefi
fi
chvt 1
