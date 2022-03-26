#!/bin/bash
# Install Latest XRDP with XORGXRDP

# README
# Manual steps required first:
# Enable "Non-Free" repost in APT by adding "non-free" at the end of every URL in /etc/apt/sources.list

# Target Versions and Folders

echo "Waiting for the system install to finish."
until [ -f /tmp/continue.txt ]
do
     sleep 1
done
echo "Last command of the user-data detected.  Starting build "
dnf update -y
dnf install -y git  
#sleep 100
echo "All done."

# Script Completed
exit

