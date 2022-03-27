#!/bin/bash
HOST=`hostname`
IMG=ubuntu-20.04-server-cloudimg-amd64.img
INCR_IMG=incr_ubuntu-20.04-server-cloudimg-amd64.img
USER_DATA=user-data
DATA_DIR="./data/focal"
SSH_PORT=2332
RUN_SCRIPT="make_xrdp_xorgxrdp_deb_packages.sh"
FULL_RUN_SHA="full_run_sha.txt"

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

# get incr and show sha512 hashs of copy and original.
if [ ! -f "${IMG}" ]; then
  rsync -av ${DATA_DIR}/${INCR_IMG} ${IMG}
  echo "SHA validation"
  cat ${DATA_DIR}/${FULL_RUN_SHA}
  sha512sum -b ${DATA_DIR}/${INCR_IMG}
  sha512sum -b ${IMG}
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
  -pidfile ./pid.${SSH_PORT}

echo "Not sure how long to wait. Waiting around 20 seconds."
sleep 15
echo "Starting Run. Task to be done. Can take several minutes to update and configure system."
echo " Can ignore \" kex_exchange_identification: <msg> \" Error means system not up yet."

MY_KEY="/home/${USER}/.ssh/id_ed25519"
MY_OPTS_SCP="-i $MY_KEY -o LogLevel=ERROR -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -P ${SSH_PORT}"
MY_OPTS_SSH="-i $MY_KEY -o LogLevel=ERROR -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p ${SSH_PORT}"

date1=`date +%s`
date2=$(date -u --date @$((`date +%s` - $date1)) +%H:%M:%S)
until [ "`ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p ${SSH_PORT} -o LogLevel=ERROR ${USER}@${HOST}  ls /tmp | grep continue`" = "continue.txt" ]
do
        echo -ne "$(date -u --date @$((`date +%s` - $date1)) +%H:%M:%S)\r"
        date2=$(date -u --date @$((`date +%s` - $date1)) +%H:%M:%S)
        sleep 1
	ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p ${SSH_PORT} -o LogLevel=ERROR ${USER}@${HOST} sudo touch /tmp/continue.txt
done
echo "Yeah! ssh is working. Moving on."
scp $MY_OPTS_SCP ${RUN_SCRIPT}  ${USER}@${HOST}:.
ssh $MY_OPTS_SSH ${USER}@${HOST} chmod +x /home/${USER}/${RUN_SCRIPT}
ssh $MY_OPTS_SSH ${USER}@${HOST} touch /tmp/continue.txt
scp $MY_OPTS_SCP *_debian_dir_new.tgz ${USER}@${HOST}:/tmp/
ssh $MY_OPTS_SSH ${USER}@${HOST} sudo bash /home/${USER}/${RUN_SCRIPT}
scp $MY_OPTS_SCP ${USER}@${HOST}:/opt/*.deb ./data/
#scp $MY_OPTS_SCP ${USER}@${HOST}:/opt/*.tgz ./data/

ssh $MY_OPTS_SSH ${USER}@${HOST} sudo poweroff
kill $( cat pid.lock )
echo "Wait time was: ${date2}"
echo "Total Time:  $(date -u --date @$((`date +%s` - $date1)) +%H:%M:%S)"
rm -f ${DATA_DIR}/cloud.img meta-data ubuntu-20.04-server-cloudimg-amd64.img user-data pid.lock
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
