#!/bin/bash
# Install https://www.golinuxcloud.com/local-offline-yum-dnf-repo-http-rocky-linux-8/

# README
# Manual steps required first:
# Enable 

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

