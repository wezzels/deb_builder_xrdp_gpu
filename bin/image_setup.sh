#!/bin/bash
# Install Latest XRDP with XORGXRDP

# README
# Manual steps required first:
# Enable "Non-Free" repost in APT by adding "non-free" at the end of every URL in /etc/apt/sources.list

echo "Waiting for the system install to finish."
until [ -f /tmp/continue.txt ]
do
     sleep 1
done
echo "Last command of the user-data detected.  Starting build "

if [ -f "/usr/bin/apt" ]; then
	
# Update system
apt-get update
apt-get -y dist-upgrade

# Install packages
apt-get -y install git htop ctags

# Clean Residues
apt-get autoremove -y
apt-get clean
else

dnf makecache --refresh
dnf update -y
dnf install -y git
fi
echo "---Keys Installed ---"
cat `pwd`/.ssh/authorized_keys
ls -alZ `pwd`/.ssh/authorized_keys

# Will be adding in the test for the installer.
exit
# Enable Service
systemctl enable xrdp
systemctl start xrdp

# Script Completed
exit

