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
sleep 100
echo "All done."

dnf install -y yum-utils
dnf install -y nginx

systemctl enable nginx --now

cat<<EOF> /etc/nginx/conf.d/repo.conf
# vi /etc/nginx/conf.d/repos.conf
server {
        listen   80;
        server_name  reposerver.example.com;
        root   /usr/share/nginx/html/repos;
	index index.html; 
	location / {
                autoindex on;
        }
}
EOF
systemctl restart nginx
systemctl status nginx

firewall-cmd --zone=public --permanent --add-service=http
firewall-cmd --zone=public --permanent --add-service=https
firewall-cmd --reload

getenforce
chcon -Rt httpd_sys_content_t /usr/share/nginx/html/repos/

cat <<EOF> /etc/yum.repos.d/localrepo.repo
[localrepo-base]
name=RockyLinux Base
baseurl=http://reposerver.example.com/baseos/
gpgcheck=0
enabled=1

[localrepo-appstream]
name=RockyLinux Base
baseurl=http://reposerver.example.com/appstream/
gpgcheck=0
enabled=1
EOF

dnf clean all  
dnf repolist
#https://www.golinuxcloud.com/local-offline-yum-dnf-repo-http-rocky-linux-8/

dnf reposync -g --delete -p /usr/share/nginx/html/repos/ --repoid=baseos --newest-only --download-metadata
dnf reposync -g --delete -p /usr/share/nginx/html/repos/ --repoid=appstream --newest-only --download-metadata

cat <<EOF>>repo.update
#!/bin/bash
/bin/dnf reposync -g --delete -p /usr/share/nginx/html/repos/ --repoid=baseos --newest-only --download-metadata
/bin/dnf reposync -g --delete -p /usr/share/nginx/html/repos/ --repoid=appstream --newest-only --download-metadata
EOF
# Script Completed
exit

