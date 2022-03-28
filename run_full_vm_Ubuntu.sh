#!/bin/bash
HOST=`hostname`
IMG_URL=https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64.img
IMG=ubuntu-20.04-server-cloudimg-amd64.img
INCR_IMG=incr_ubuntu-20.04-server-cloudimg-amd64.img
USER_DATA=user-data
DATA_DIR="./data/focal_OS"
SSH_PORT=2333
RUN_SCRIPT="ubuntu_setup.sh"
FULL_RUN_SHA="full_run_sha.txt"

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

MY_OPTS_SCP="-i $MY_KEY -o LogLevel=ERROR -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -P ${SSH_PORT}"
MY_OPTS_SSH="-i $MY_KEY -o LogLevel=ERROR -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p ${SSH_PORT}"

#Cleanup old files if they exsist.
rm -f user-data meta-data ${DATA_DIR}/cloud.img "${IMG}"

if [ ! -f "${DATA_DIR}/${IMG}" ]; then
  wget -O "${DATA_DIR}/${IMG}" "${IMG_URL}"	
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
  - git 
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
  -net user,hostfwd=tcp::${SSH_PORT}-:22 \
  -net nic \
  -daemonize \
  -pidfile ./pid.${SSH_PORT}

echo "Not sure how long to wait. Waiting around 20 seconds."
sleep 15
echo "Starting Run. Task to be done. Can take several minutes to update and configure system."
echo " Can ignore \" kex_exchange_identification: <msg> \" Error means system not up yet."

date1=`date +%s`
date2=$(date -u --date @$((`date +%s` - $date1)) +%H:%M:%S)
until [ "`ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p ${SSH_PORT} -o LogLevel=ERROR ${USER}@${HOST}  ls /tmp | grep continue`" = "continue.txt" ]
do
        echo -ne "$(date -u --date @$((`date +%s` - $date1)) +%H:%M:%S)\r"
        date2=$(date -u --date @$((`date +%s` - $date1)) +%H:%M:%S)
        sleep 1
done

echo "Yeah! ssh is working. Moving on."
echo "host=${HOST}"
echo "run_script=${RUN_SCRIPT}"
scp $MY_OPTS_SCP ${RUN_SCRIPT}  ${USER}@${HOST}:${RUN_SCRIPT}
ssh $MY_OPTS_SSH ${USER}@${HOST} chmod +x /home/${USER}/${RUN_SCRIPT}
#scp $MY_OPTS_SCP *_debian_dir_new.tgz ${USER}@${HOST}:/tmp/
ssh $MY_OPTS_SSH ${USER}@${HOST} sudo bash /home/${USER}/${RUN_SCRIPT}
#scp $MY_OPTS_SCP ${USER}@${HOST}:/opt/*.deb ./data/
#scp $MY_OPTS_SCP ${USER}@${HOST}:/opt/*.tgz ./data/

# Basic shutdown process.
ssh $MY_OPTS_SSH ${USER}@${HOST} sudo shutdown -h now
timeout 30 wait $( cat pid.${SSH_PORT} )
kill $( cat pid.${SSH_PORT} )
sync
sync

#Copy image to incr and make sha512 hash.
rsync -av ${IMG} ${DATA_DIR}/incr_${IMG}
sha256sum -b ${DATA_DIR}/incr_${IMG}
echo "`sha256sum -b ${IMG}`" > ${DATA_DIR}/${FULL_RUN_SHA}

echo "Wait time was: ${date2}"
echo "Total Time:  $(date -u --date @$((`date +%s` - $date1)) +%H:%M:%S)"
rm -f ${DATA_DIR}/cloud.img meta-data ${IMG} user-data pid.lock

echo "-----" >> ./run_times.txt
echo "$0 , ${RUN_SCRIPT}" >> ./run_times.txt
echo "Wait time was: ${date2}" >> ./run_times.txt
echo "Total Time:  $(date -u --date @$((`date +%s` - $date1)) +%H:%M:%S)" >> ./run_times.txt

exit
#NOTES:
#copy a file from running vm.
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -P ${SSH_PORT} ${USER}@${HOST}:make* .
#copy file to running system.
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -P ${SSH_PORT} *.sh ${USER}@${HOST}:. 
#Poweroff machine
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p ${SSH_PORT} ${USER}@${HOST} sudo poweroff
#Clear out old known_host info
ssh-keygen -f "/home/${USER}/.ssh/known_hosts" -R "[${HOST}]:${SSH_PORT}"
#make ssh key.
ssh-keygen -t ed25519
#make key without prompt
ssh-keygen -b 4096 -t ed25519 -f ./sshkey -q -N ""
#Specify key no check example
MY_KEY="./sshkey"
MY_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -P ${SSH_PORT}"
ssh "$MY_OPTS" -i $MY_KEY ls -al /
