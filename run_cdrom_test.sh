#!/bin/bash

if [ "$EUID" -eq 0 ]
then 
	echo "Do not run with admin privileges."
  	exit
fi

while getopts ":o:t:r:p:g:h:" flag
do
    case "${flag}" in
        o) SET_OS=${OPTARG};;
	t) SET_TASK=${OPTARG};;
	r) RUN_CMD=${OPTARG};;
        p) PUT_FILES=${OPTARG};;
        g) GET_FILES=${OPTARG};;
	h) SHOW_HELP="help";;
    esac
done

if [ ! -z "${SHOW_HELP}" ]; then
	echo "USAGE: ./run_cmd.sh -o <OSTYPE> -t <TASK> -r <RUN_SCRIPT> -p <PUT_FILES or DIRS> -g <GET_FILES or DIRS>"
	echo "          -o (Alma8,CentOS8,Rocky8,Ubuntu2004)"
	echo "          -t (image,mkiso,mkisotoimg,process)"
        echo "          -r script must be found in bin directory."
	echo "          -p ex: *.iso Assets/ /tmp/*x11.lock"
	echo "          -p ex: *.tgz data_dir/ /tmp/*x11.lock"
fi


IFS="|"
task_array=("mkisotoimg|process")
if [ ! -z "${SET_TASK}" ]; then
        if [[ "${IFS}${task_array[*]}${IFS}" =~ "${IFS}${SET_TASK}${IFS}" ]]; then
                #./bin/${SET_TASK}Linux.sh
		echo "Task ${SET_TASK} selected." 
        else
                echo "The task ${SET_TASK} not found"
		echo "Available tasks are: ${task_array[*]}"
                exit 1
        fi  
else
  	echo "Must select a task. use -t <task>"
        echo "Available tasks are: ${task_array[*]}"
        exit 1	

fi

IFS="|"
os_array=("Alma8|CentOS8|Rocky8|Ubuntu2004")
if [ ! -z "${SET_OS}" ]; then
	if [[ "${IFS}${os_array[*]}${IFS}" =~ "${IFS}${SET_OS}${IFS}" ]]; then
    		. ./cfgs/${SET_OS}Linux.cfg
	else
		echo "OS not found"
		echo "Available OS types are: ${os_array[*]}"
		exit 1
	fi
else
  echo "Must select an OS."
  exit 1  
fi

#if [ ! -z "${RUN_CMD}" ]; then
#	if [ ! -e bin/"${RUN_CMD}" ]; then
#    		echo "${RUN_CMD} is not found in bin/"
#		exit 1
#	else
#		echo "using prompt "
#		RUN_SCRIPT="${RUN_CMD}"
#	fi
#else 
#	echo "Run script must be set."
#	exit 1
#fi

if [ -z "${PUT_FILES}" ]; then
    	PUT_FILES=" "
fi

if [ -z "${GET_FILES}" ]; then
    	GET_FILES=" "
fi

if [ -z "${USER}" ]; then
        USER="builder"
fi

if [ ! -f "${DATA_DIR}/sshkey" ]; then
        ssh-keygen -b 4096 -t ed25519 -f ${DATA_DIR}/sshkey -q -N ""
fi
MY_KEY="${DATA_DIR}/sshkey"
MY_SSH_ACCESS_KEY="`cat ${DATA_DIR}/sshkey.pub`"

echo "os type          = ${SET_OS}"
echo "task type        = ${SET_TASK}"
echo "get files        = ${GET_FILES}" 
echo "put files        = ${PUT_FILES}" 
echo "run command      = ${RUN_CMD}"
echo "data dir         = ${DATA_DIR} "
echo "hostnane         = ${HOST}"
echo "image url        = ${IMG_URL}"
echo "image size       = ${IMG_SIZE}"
echo "image name       = ${IMG}"
echo "incr image       = ${INCR_IMG}"
echo "new image        = ${NEW_IMG}"
echo "iso url          = ${ISO_URL}"
echo "iso name         = ${ISO}"
echo "iso custom       = ${ISO_NEW}"
echo "user-data file   = ${USER_DATA}"
echo "port for ssh     = ${SSH_PORT}"
echo "script to run    = ${RUN_SCRIPT}"
echo "name of sha file = ${FULL_RUN_SHA}"
echo "my key file      = ${MY_KEY}"
echo "my key file      = ${MY_SSH_ACCESS_KEY}"
echo "my ssh options   = ${MY_OPTS_SSH}"


#if [ "$SET_FILES" == "yes" ]

#fi	

#Make storage area if does not exist.
mkdir -p $DATA_DIR

#Kill all processes that could cause an issue.  Will need to be narrowed done later. 
kill $( ps -ef | grep qemu-system-x86_64 | xargs | cut -d" " -f2 )


#Cleanup old files if they exsist.
rm -f pid.* user-data meta-data ${DATA_DIR}/cloud.img "${IMG}"

#Make a blank image if needed. 
if [ ! -f "${DATA_DIR}/${IMG_NEW}" ]; then
  qemu-img create -f qcow2 ${DATA_DIR}/${IMG_NEW} 1G
else
	echo " Error: built IMAGE w/${ISO_NEW} failed"
	echo "  please remove ${DATA_DIR}/${IMG_NEW} first."
	exit 1
fi

# Move ISO image into directory for testing. 
#if [ ! -f "${ISO}" ]; then
#  rsync -av data/${ISO} ${DATA_DIR}/${ISO}
#else
#  echo "Error: Must run ISO builder first."
#  exit
#fi

if [ ! -f "${IMG}" ]; then
  cp ${DATA_DIR}/${IMG_NEW} ${IMG}
  qemu-img resize "${IMG}" +20G
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
#package_upgrade: true
#package_update: true
runcmd:
  - [ touch, /tmp/continue.txt ]
#    - [ chmod, +x ,/tmp]
EOF
fi

#cloud-localds --disk-format qcow2 ${DATA_DIR}/cloud.img "${USER_DATA}"
#cp cloud-init/user-data
echo "access key = ${MY_SSH_ACCESS_KEY}"
sed -i "s#<MY_SSH_ACCESS_KEY>#${MY_SSH_ACCESS_KEY}#" user-data


#cloud-localds --disk-format qcow2 ${DATA_DIR}/cloud.img "${USER_DATA}" 
qemu-system-x86_64 \
  -cpu host \
  -drive file="${IMG}",if=virtio \
  -m 2G \
  -boot d \
  -cdrom ${DATA_DIR}/${ISO_NEW} \
  -enable-kvm \
  -smp 2 \
  -vga virtio \
  -net nic,model=virtio -net tap,ifname=${NET_TAP},script=no,downscript=no \
  -name "Build Linux" \
  -vnc 127.0.0.1:2 \
  -net user,id=${NET_TAP},hostfwd=tcp::${SSH_PORT}-:22 \
  -net nic \
  -daemonize \
  -pidfile ./pid.${SSH_PORT}

  #-spice port=5902,password=password \
  #-vnc 127.0.0.1:2, password \

echo "Not sure how long to wait. Waiting around 20 seconds."
sleep 15
echo "Starting Run. Task to be done. Can take several minutes to update and configure system."
echo " Waiting for build to complete.  Can take 20 - 50 minutes dependingon network speed."

date1=`date +%s`
date2=$(date -u --date @$((`date +%s` - $date1)) +%H:%M:%S)


PID=`cat ./pid.${SSH_PORT}`
tail --pid=$PID -f /dev/null

sync
sync
time qemu-img convert -O qcow2 -p -c ${IMG} ${DATA_DIR}/${IMG_NEW}
#rsync -av ${IMG} ${DATA_DIR}/${IMG_NEW}

#sha256sum -b ${DATA_DIR}/${IMG_NEW}
echo "`sha256sum -b ${IMG_NEW}`" > ${DATA_DIR}/${FULL_RUN_SHA}

echo "Wait time was: ${date2}"
echo "Total Time:  $(date -u --date @$((`date +%s` - $date1)) +%H:%M:%S)"
rm -f ${DATA_DIR}/cloud.img meta-data ${IMG} user-data pid.${SSH_PORT}

echo "-----" >> ./run_times.txt
echo "$0 , ${RUN_SCRIPT}" >> ./run_times.txt
echo "Wait time was: ${date2}" >> ./run_times.txt
echo "Total Time:  $(date -u --date @$((`date +%s` - $date1)) +%H:%M:%S)" >> ./run_times.txt

exit
