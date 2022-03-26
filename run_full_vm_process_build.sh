#!/bin/bash
IMG=ubuntu-20.04-server-cloudimg-amd64.img
INCR_IMG=incr_ubuntu-20.04-server-cloudimg-amd64.img
USER_DATA=user-data
DATA_DIR="./data/focal"

mkdir -p $DATA_DIR

if getent group kvm | grep -q "\b${USER}\b"; then
  echo "User is in the KVM group continuing."
else
  echo "User not found in KVM.  Add the User to KVM and restart this session."
  exit 1
fi

MY_KEY="/home/${USER}/.ssh/id_ed25519"
if [ ! -f "$MY_KEY" ]; then
  ssh-keygen -b 4096 -t ed25519 -f $MY_KEY -q -N ""
fi

MY_OPTS_SCP="-i $MY_KEY -o LogLevel=ERROR -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -P 2333"
MY_OPTS_SSH="-i $MY_KEY -o LogLevel=ERROR -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p 2333"

#Cleanup old files if they exsist.
rm -f user-data meta-data ${DATA_DIR}/cloud.img "${IMG}"

if [ ! -f "${DATA_DIR}/${IMG}" ]; then
  wget -O "${DATA_DIR}/${IMG}" "https://cloud-images.ubuntu.com/releases/focal/release/${IMG}"	
fi


if [ ! -f "${IMG}" ]; then
  cp ${DATA_DIR}/${IMG} ${IMG}
  qemu-img resize "${IMG}" +10G
fi

if [ ! -f "${USER_DATA}" ]; then
echo "instance-id: $(uuidgen || echo i-softbuild)" > meta-data
  cat >user-data <<EOF
#cloud-config
users:
  - default
  - name: ${USER}
    groups: sudo
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh_import_id: None
    ssh-authorized-keys:
      - `cat /home/${USER}/.ssh/id_ed25519.pub`
    lock_passwd: false
package_upgrade: true
package_update: true
packages:
  - dpkg-dev 
  - devscripts
  - build-essential 
  - autoconf 
  - automake
  - autotools-dev
  - dh-make 
  - debhelper 
  - devscripts 
  - fakeroot
  - xutils 
  - x11-xserver-utils 
  - lintian 
  - pbuilder
  - libjpeg-turbo8
  - build-essential
  - make 
  - autoconf 
  - libtool 
  - intltool 
  - pkg-config 
  - nasm 
  - xserver-xorg-dev 
  - libssl-dev 
  - libpam0g-dev 
  - libjpeg-dev 
  - libfuse-dev 
  - libopus-dev 
  - libmp3lame-dev 
  - libxfixes-dev 
  - libxrandr-dev 
  - libgbm-dev 
  - libepoxy-dev 
  - libegl1-mesa-dev
  - libcap-dev 
  - libsndfile-dev 
  - libsndfile1-dev 
  - libspeex-dev 
  - libpulse-dev
  - libfdk-aac-dev 
  - pulseaudio
  - xserver-xorg
  - check
  - libperl5.30
  - libx11-dev
  - mime-support
  - nasm
  - libfakeroot
  - libmagic-mgc
  - tzdata
  - libxcb1
  - libpam0g-dev
  - libxrender-dev
  - libxdmcp6
  - libxau6
  - libglib2.0-0
  - x11proto-dev 
  - pkg-config
  - libxfixes-dev
  - systemd
  - libx11-6
  - libmagic1
  - file
  - perl-modules-5.30
  - gawk
  - libxrandr-dev
  - libsigsegv2
  - libssl-dev
  - libbsd0
runcmd:
  - [ touch, /tmp/continue.txt ]
#    - [ chmod, +x ,/tmp]
EOF
fi

cloud-localds --disk-format qcow2 ${DATA_DIR}/cloud.img "${USER_DATA}" 
qemu-system-x86_64 \
  -drive file="${IMG}",if=virtio \
  -drive file=${DATA_DIR}/cloud.img,if=virtio \
  -m 2G \
  -enable-kvm \
  -smp 2 \
  -vga virtio \
  -net nic,model=virtio -net tap,ifname=tap0,script=no,downscript=no \
  -name "Ubuntu Server" \
  -vnc :2 \
  -net user,hostfwd=tcp::2333-:22 \
  -net nic \
  -daemonize \
  -pidfile ./pid.lock

  #-net tap,ifname=tap0,script=no,downscript=no -net nic,model=virtio,macaddr=fa:34:f3:3f:d2:f4 \
echo "Not sure how long to wait. Waiting around 20 seconds."
sleep 5
echo "Starting Run. Task to be done."

until [ `ssh -q -i $MY_KEY -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p 2333 ${USER}@black exit ; echo $?` ]
do
	echo "Still going."
	sleep 1
done
echo "Yeah! ssh is working. Moving on."
scp $MY_OPTS_SCP make_xrdp_xorgxrdp_deb_packages.sh  ${USER}@black:.
ssh $MY_OPTS_SSH ${USER}@black chmod +x /home/${USER}/make_xrdp_xorgxrdp_deb_packages.sh
scp $MY_OPTS_SCP *_debian_dir_new.tgz ${USER}@black:/tmp/
ssh $MY_OPTS_SSH ${USER}@black sudo bash /home/${USER}/make_xrdp_xorgxrdp_deb_packages.sh
scp $MY_OPTS_SCP ${USER}@black:/opt/*.deb ./data/
#scp $MY_OPTS_SCP ${USER}@black:/opt/*.tgz ./data/

ssh $MY_OPTS_SSH ${USER}@black sudo poweroff
# removed so no output: -serial mon:stdio \

cp ubuntu-20.04-server-cloudimg-amd64.img ${DATA_DIR}/incr_ubuntu-20.04-server-cloudimg-amd64.img

rm -f ${DATA_DIR}/cloud.img meta-data ubuntu-20.04-server-cloudimg-amd64.img user-data
exit
#NOTES:
#copy a file from running vm.
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -P 2333 ${USER}@black:make* .
#copy file to running system.
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -P 2333 *.sh ${USER}@black:. 
#Poweroff machine
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p 2333 ${USER}@black sudo poweroff
#Clear out old known_host info
ssh-keygen -f "/home/${USER}/.ssh/known_hosts" -R "[black]:2333"
#make ssh key.
ssh-keygen -t ed25519
#make key without prompt
ssh-keygen -b 4096 -t ed25519 -f ./sshkey -q -N ""
#Specify key no check example
MY_KEY="./sshkey"
MY_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -P 2333"
ssh "$MY_OPTS" -i $MY_KEY ls -al /
