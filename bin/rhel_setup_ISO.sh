#!/bin/bash
# Install Latest 
ISO_URL=<Manual>
ISO=rhel-8.6-x86_64-boot.iso
ISO_FULL=rhel-8.6-x86_64-DVD.iso
ISO_NEW=custom-rhel-8.6-x86_64-boot.iso
ISO_NEW_REPO=custom-rhel-8.6-x86_64-boot_w_repo.iso
ISO_LABEL=Rhel-8.6-x86_64-dvd
WORKING_DIR=/tmp/workdir
DATA_DIR="`pwd`/data"
BUILD_PKG=configs.tar.gz
KS=ks.cfg

# Target Versions and Folders

echo "Waiting for the system install to finish."
until [ -f /tmp/continue.txt ]
do
     sleep 1
done
cp -f local-rhel8.repo /etc/yum.repos.d/local-rhel8.repo 

echo "Last command of the user-data detected.  Starting build "
dnf makecache --refresh
dnf update  -y
dnf install -y git  
dnf install -y createrepo genisoimage isomd5sum syslinux
dnf install -y wget
echo "...Starting copy ISO to working dir"
mkdir -p ${DATA_DIR}
mkdir -p ${WORKING_DIR}
if [ ! -f "${DATA_DIR}/${ISO}" ]; then
  wget -q -O "${DATA_DIR}/${ISO}" "${ISO_URL}"
fi
mkdir -p ${WORKING_DIR}/customiso
mkdir -p ${WORKING_DIR}/originaliso
mount -o loop ${DATA_DIR}/${ISO} ${WORKING_DIR}/originaliso
rsync -av --progress  ${WORKING_DIR}/originaliso/ ${WORKING_DIR}/customiso/
umount ${WORKING_DIR}/originaliso
echo "...Finish copying ISO to working directory."

echo "...Start create a working directory for customizations."
if [ ! -d /tmp/Assets ]; then
	mkdir -p /tmp/Assets
	touch /tmp/Assets/file
fi

cp -r /tmp/Assets ${WORKING_DIR}/customiso/
echo "...Finish create a working directory for customizations."

createrepo -dpo  ${WORKING_DIR}/customiso/ ${WORKING_DIR}/customiso/Assets/
echo "...Finish create a working directory for customizations."

echo "...Start edit grub and isolinux menus.."
sed -i 's/set default="1"/set default="0"/g'  ${WORKING_DIR}/customiso/EFI/BOOT/grub.cfg
sed -i 's/set timeout="1"/set timeout="0"/g'  ${WORKING_DIR}/customiso/EFI/BOOT/grub.cfg
sed -i 's/inst.stage2=hd:LABEL=CentOS-Stream-8-x86_64-dvd quiet inst.text/inst.ks=cdrom:\/ks.cfg inst.stage2=hd:LABEL=CentOS-Stream-8-x86_64-dvd/g' ${WORKING_DIR}/customiso/EFI/BOOT/grub.cfg

sed -i 's/timeout 600/timeout 10/g' ${WORKING_DIR}/customiso/isolinux/isolinux.cfg
sed -i '/  menu default/d' ${WORKING_DIR}/customiso/isolinux/isolinux.cfg
sed -i '/menu label ^Install/a \ \ menu default' ${WORKING_DIR}/customiso/isolinux/isolinux.cfg
sed -i 's/inst.stage2=hd:LABEL=CentOS-Stream-8-x86_64-dvd quiet/inst.ks=cdrom:\/ks.cfg inst.stage2=hd:LABEL=CentOS-Stream-8-x86_64-dvd/g' ${WORKING_DIR}/customiso/isolinux/isolinux.cfg

echo "...Finish edit grub and isolinux menus.."

echo "...Start kickstart setup."
cp -f ${KS} ${WORKING_DIR}/customiso/ks.cfg
mount -o loop ${WORKING_DIR}/customiso/images/efiboot.img ${WORKING_DIR}/originaliso
#sed -i '/linuxefi/s/$/ inst.ks=cdrom:\/isolinux\/ks.cfg/' ${WORKING_DIR}/originaliso/EFI/BOOT/grub.cfg
umount ${WORKING_DIR}/originaliso
echo "---Finished kickstart setup."

echo "...Start create custom ISO."
mkisofs -o ${DATA_DIR}/${ISO_NEW} -b isolinux/isolinux.bin -J -R -l -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot -e images/efiboot.img -no-emul-boot -graft-points -V "CentOS-Stream-8-x86_64-dvd" ${WORKING_DIR}/customiso/

# Fixes USB boot issues and adds the checksum in the iso. 
isohybrid --uefi ${DATA_DIR}/${ISO_NEW}
implantisomd5 ${DATA_DIR}/${ISO_NEW}

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
