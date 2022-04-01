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
#echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAVLw7sZf8AHqMItQGBof678xeH+HZaziI8lvqmAP8Ar wez@black" | tee -a  /home/wez/.ssh/authorized_keys
#echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDexd0ljlcVqHbRrWkpSldsV/7H+KKT3jfd4pNjZm3f3NUr04XWt8G+idWcmjs8cw7n1r1NkwQR7qVtgwbfKqnP5F/FMfYyujAfLX6r/H14FMO1GJM1eK+u8cMj2Odym8n20WJ5NLP8cN1k92yhghkdQKchFwK4wPoXSIWOfHxnTJITy//Y1mO2FMGfTx5u5TfXsxVNBLWjaTg74wD9xCZ9noMiUXz0LDrMefG+Lj/S5dZLd8kD0JQs8Psl8fQAZi9HYvTh6ngSe9IZ6hS04p0hWYwPvqIeZpYWGqK4+I8GW+8WXoYBwCBBEzTDW5zepMQm1/fDDCRXDsoDIlg/MRSvQfe5YqrpU9UuveAXoZmM3MVjJjh5/DLx5mZgiYVwBRWzKONBRzkjrBZ5nF4svb99UHV2sC3F61lDcHsGhk2eDEM2TtvUfQFuHy2ZaxFLvhBX8SrQsvU4btrAMgQZ34EFXgefYvl4sAPKAuz4NLQTJ3eE+IIzds4Z6tCyooOHyAU= wez@black" | tee -a  /home/wez/.ssh/authorized_keys
echo "Last command of the user-data detected.  Starting build "
dnf makecache --refresh
dnf update -y
dnf install -y git  
echo "---Keys Installed ---"
cat /home/wez/.ssh/authorized_keys
ls -alZ /home/wez/.ssh/authorized_keys

#official AlmaLinux mirror via rsync:
/usr/bin/rsync -avSH -f 'R .~tmp~' --delete-delay --delay-updates rsync://rsync.repo.almalinux.org/almalinux/ /almalinux/dir/on/your/server/
#Create a cron task to sync it periodically (we recommend updating the mirror every 3 hours):
#create repo update
#0 */3 * * * /usr/bin/flock -n /var/run/almalinux_rsync.lock -c "/usr/bin/rsync -avSH \
  #-f 'R .~tmp~' --delete-delay --delay-updates rsync://rsync.repo.almalinux.org/almalinux/ /almalinux/dir/on/your/server/"

sleep 100
echo "All done."

# Script Completed
exit

