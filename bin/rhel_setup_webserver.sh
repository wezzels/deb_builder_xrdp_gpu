echo "---Installing firewalld"
dnf install -y firewalld
systemctl unmask firewalld
systemctl start firewalld
systemctl enable firewalld
echo "---Enabling firewalld"
firewall-cmd --state
firewall-cmd --zone=public --permanent --add-service=http
firewall-cmd --zone=public --permanent --add-service=https
firewall-cmd --reload
firewall-cmd --list-all

echo "---Configuring httpd for repos."
ip4=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)

setfacl -R -m u:httpd:rwx /var/repo/
chcon -Rt httpd_sys_content_t /var/repo/
rm -f /etc/httpd/conf.d/welcome.conf
rm -f /etc/httpd/conf.d/httpd.conf
cp httpd.conf /etc/httpd/conf/

httpd -t 
systemctl restart httpd

mkdir -p /usr/local/lib/systemd/system
cp -f rhel_setup_httprepo.sh /usr/local/bin/set_ip_httprepo.sh
chmod 0755 /usr/local/bin/set_ip_httprepo.sh

cat <<EOL>/usr/local/lib/systemd/system/setip4repo.service
[Unit]

Description=Runs /usr/local/bin/set_ip_httprepo.sh


[Service]

ExecStart=/usr/local/bin/set_ip_httprepo.sh


[Install]

WantedBy=multi-user.target
EOL

ln -s /usr/local/lib/systemd/system/setip4repo.service /etc/systemd/system/setip4repo.service
systemctl daemon-reload
systemctl start setip4repo
systemctl enable setip4repo
