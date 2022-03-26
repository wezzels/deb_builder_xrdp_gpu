#!/bin/bash
HOST=`hostname`
IMG_URL=https://repo.almalinux.org/almalinux/8/cloud/x86_64/images/AlmaLinux-8-GenericCloud-latest.x86_64.qcow2
IMG=AlmaLinux-8-GenericCloud-latest.x86_64.img
INCR_IMG=incr_AlmaLinux-8-GenericCloud-latest.x86_64.img
USER_DATA=user-data
DATA_DIR="./data/almalinux8"
SSH_PORT=2334
RUN_SCRIPT="alma_setup.sh"

mkdir -p ${DATA_DIR}

if getent group kvm | grep -q "\b${USER}\b"; then
  echo "User is in the KVM group continuing."
    
else
  echo "User not found in KVM.  Add the User to KVM and restart this session."
  exit 1
fi

if [ ! -f "${DATA_DIR}/${INCR_IMG}" ]; then
  echo "Incr_image is not found. Must run a full first."
  exit
fi

if [ ! -f "${IMG}" ]; then
  cp ${DATA_DIR}/${INCR_IMG} ${IMG}
fi

qemu-system-x86_64 \
  -drive file="${IMG}",if=virtio \
  -m 2G \
  -enable-kvm \
  -smp 2 \
  -vga virtio \
  -net nic,model=virtio -net tap,ifname=tap0,script=no,downscript=no \
  -name "Ubuntu Server" \
  -net user,hostfwd=tcp::${SSH_PORT}-:22 \
  -display none \
  -net nic \
  -daemonize \
  -pidfile ./pid.lock

echo "Not sure how long to wait. Waiting around 20 seconds."
sleep 15
echo "Starting Run. Task to be done."
MY_KEY="/home/${USER}/.ssh/id_ed25519"
MY_OPTS_SCP="-i $MY_KEY -o LogLevel=ERROR -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -P ${SSH_PORT}"
MY_OPTS_SSH="-i $MY_KEY -o LogLevel=ERROR -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p ${SSH_PORT}"

until [ `ssh -q -i $MY_KEY -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p ${SSH_PORT} ${USER}@${HOST} exit ; echo $?` ]
do
	echo "Still going."
	sleep 1
done
echo "Yeah! ssh is working. Moving on."
scp $MY_OPTS_SCP ${RUN_SCRIPT}  ${USER}@${HOST}:.
ssh $MY_OPTS_SSH ${USER}@${HOST} chmod +x /home/${USER}/${RUN_SCRIPT}
ssh $MY_OPTS_SSH ${USER}@${HOST} sudo touch /tmp/continue.txt
#scp $MY_OPTS_SCP *_debian_dir_new.tgz ${USER}@${HOST}:/tmp/
ssh $MY_OPTS_SSH ${USER}@${HOST} sudo bash /home/${USER}/${RUN_SCRIPT}
#scp $MY_OPTS_SCP ${USER}@${HOST}:/opt/*.deb ./data/
#scp $MY_OPTS_SCP ${USER}@${HOST}:/opt/*.tgz ./data/

ssh $MY_OPTS_SSH ${USER}@${HOST} sudo poweroff
# removed so no output: -serial mon:stdio \

rm -f ${DATA_DIR}/cloud.img meta-data ${IMG} user-data
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
