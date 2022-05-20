#!/bin/bash
# Install https://wiki.almalinux.org/Mirrors.html

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

