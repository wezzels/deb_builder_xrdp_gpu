#!/bin/bash
# Install REPO. Server disk size needs to be 200G+

# README
# Manual steps required first:
# Enable "Non-Free" repost in APT by adding "non-free" at the end of every URL in /etc/apt/sources.list

echo "Waiting for the system install to finish."
until [ -f /tmp/continue.txt ]
do
     sleep 1
done
echo "Last command of the user-data detected.  Starting build "

# Update system
apt-get update
apt-get -y dist-upgrade

# Install packages
apt-get -y install git htop ctags

# Clean Residues
apt-get autoremove -y
apt-get clean

# Will be adding in the test for the installer.

#https://www.linuxtechi.com/setup-local-apt-repository-server-ubuntu/

apt install -y apache2

systemctl enable apache2

mkdir -p /var/www/html/ubuntu

chown www-data:www-data /var/www/html/ubuntu

sudo apt update
sudo apt install -y apt-mirror

cp /etc/apt/mirror.list /etc/apt/mirror.list-bak

cat <<EOF> /etc/apt/mirror.list

############# config ###################
set base_path    /var/www/html/ubuntu
set nthreads     20
set _tilde 0
############# end config ##############
deb http://archive.ubuntu.com/ubuntu focal main restricted universe \
	 multiverse
deb http://archive.ubuntu.com/ubuntu focal-security main restricted \
	universe multiverse
deb http://archive.ubuntu.com/ubuntu focal-updates main restricted \
	universe multiverse
clean http://archive.ubuntu.com/ubuntu
EOF

mkdir -p /var/www/html/ubuntu/var
cp /var/spool/apt-mirror/var/postmirror.sh /var/www/html/ubuntu/var

apt-mirror

apt-mirror &

cat <<EOF> cnf.sh
#!/bin/bash
for p in "${1:-focal}"{,-{security,updates}}\
	/{main,restricted,universe,multiverse};do >&2 echo "${p}"
wget -q -c -r -np -R "index.html*"\
	 "http://archive.ubuntu.com/ubuntu/dists/${p}/cnf/Commands-amd64.xz"
wget -q -c -r -np -R "index.html*"\
	 "http://archive.ubuntu.com/ubuntu/dists/${p}/cnf/Commands-i386.xz"
 done
EOF 

 chmod +x cnf.sh
 bash  cnf.sh

sudo cp -av archive.ubuntu.com  /var/www/html/ubuntu/mirror/

#crontab -e
#00  01  *  *  *  /usr/bin/apt-mirror

# Script Completed
exit

