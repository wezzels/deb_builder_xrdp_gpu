#!/bin/bash
# Install

# README
# Manual steps required first:
# Enable 

df -h
ip a

ISO_NAME="rhel-8.6-x86_64-dvd.iso"

echo "Waiting for the system install to finish."
until [ -f /tmp/continue.txt ]
do
     sleep 1
done
echo "Last command of the user-data detected.  Starting build "

mkdir -p  /mnt/disc
mount -o loop ${ISO_NAME} /mnt/disc
rsync -av /mnt/disc/. /var/repo/
#cp /mnt/disc/media.repo /etc/yum.repos.d/rhel8dvd.repo
chmod 644 /etc/yum.repos.d/rhel8dvd.repo
cat <<EOF > /etc/yum.repos.d/rhel8dvd.repo
[InstallMedia]
name=DVD for Red Hat Enterprise Linux 8.6.0
mediaid=1359576196.686790
metadata_expire=-1
gpgcheck=1
enabled=1
baseurl=file:///var/repo/BaseOS/
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release

[InstallMedia-AppStream]
name=Red Hat Enterprise Linux 8.6.0
mediaid=None
metadata_expire=-1
gpgcheck=1
enabled=1
baseurl=file:///var/repo/AppStream/
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
EOF
chmod 644 /etc/yum.repos.d/rhel8dvd.repo

diff /mnt/disc/media.repo /etc/yum.repos.d/rhel8dvd.repo

umount /mnt/disc
rm ${ISO_NAME}

yum clean all
yum repolist enabled

dnf makecache --refresh
dnf update -y
dnf install -y git yum-utils createrepo httpd

tar -zxf ansible-2.9.tgz
rm -f ansible-2.9.tgz
mv ansible-2.9 /var/repo

createrepo -v /var/repo/ansible-2.9/

cat <<EOF > /etc/yum.repos.d/ansible-2.9.repo
[Ansible-2.9]
name=Red Hat Ansible 2.9
mediaid=None
metadata_expire=-1
gpgcheck=0
enabled=1
baseurl=file:///var/repo/ansible-2.9/
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
EOF

mkdir -p /var/repo/clamav/database
mv clamav-0.105.0.linux.x86_64.rpm /var/repo/clamav/
createrepo -v /var/repo/clamav

cat <<EOF > /etc/yum.repos.d/clamav.repo
[ClamAV-105]
name=Red Hat ClamAV .105
mediaid=None
metadata_expire=-1
gpgcheck=0
enabled=1
baseurl=file:///var/repo/clamav/
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
EOF

yum clean all
yum repolist enabled

dnf makecache --refresh
dnf update -y
dnf install -y ansible clamav

dnf install -y python3-pip
pip3 install cvdupdate
/usr/local/bin/cvd config set --dbdir /var/repo/clamav/database
/usr/local/bin/cvd update

echo "---Keys Installed ---"
cat `pwd`/.ssh/authorized_keys
ls -alZ `pwd`/.ssh/authorized_keys

# Will be adding in the test for the installer.
echo "Running webserver setup."
bash ./rhel_setup_webserver.sh
bash ./rhel_setup_httprepo.sh
echo "Finished webserver config."
rm -Rf /var/lib/cloud/instances/*
rm -Rf /var/lib/cloud/instance
rm -Rf /var/lib/cloud/data/*

rm -rf /etc/resolv.conf /run/cloud-init
#userdel -rf cloud-user
hostnamectl set-hostname localhost.localdomain
rm /etc/NetworkManager/conf.d/99-cloud-init.conf

# Script Completed
exit
