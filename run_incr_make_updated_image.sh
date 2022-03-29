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
task_array=("image|mkiso|mkisotoimg|process")
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

if [ ! -z "${RUN_CMD}" ]; then
	if [ ! -e bin/"${RUN_CMD}" ]; then
    		echo "${RUN_CMD} is not found in bin/"
	else
		RUN_SCRIPT="${RUN_CMD}"
	fi
else 
	echo "Run script must be set."
	exit 1
fi

if [ -z "${PUT_FILES}" ]; then
    	PUT_FILES=" "
fi

if [ -z "${GET_FILES}" ]; then
    	GET_FILES=" "
fi

echo "os type = ${SET_OS}"
echo "task type = ${SET_TASK}"
echo "get files = ${GET_FILES}" 
echo "put files = ${PUT_FILES}" 
echo "run command = ${RUN_CMD}"
echo "data dir = ${DATA_DIR} "
echo "hostnane = ${HOST}"
echo "image url = ${IMG_URL}"
echo "image size = ${IMG_SIZE}"
echo "image name = ${IMG}"
echo "incr image = ${INCR_IMG}"
echo "user-data file = ${USER_DATA}"
echo "port for ssh = ${SSH_PORT}"
echo "script to run = ${RUN_SCRIPT}"
echo "name of sha file= ${FULL_RUN_SHA}"

#if [ "$SET_FILES" == "yes" ]

#fi	

#Make storage area if does not exist.
mkdir -p $DATA_DIR

#Kill all processes that could cause an issue.  Will need to be narrowed done later. 
kill $( ps -ef | grep qemu-system-x86_64 | xargs | cut -d" " -f2 )


#Cleanup old files if they exist.
rm -f pid.23* user-data meta-data ${DATA_DIR}/cloud.img "${IMG}"

if [ ! -f "${DATA_DIR}/${INCR_IMG}" ]; then
	  echo "Incr_image is not found. Must run a full first."
	    exit
fi

# get incr and show sha512 hashs of copy and original.
if [ ! -f "${IMG}" ]; then
	  rsync -av ${DATA_DIR}/${INCR_IMG} ${IMG}
	    echo "SHA validation"
	      cat ${DATA_DIR}/${FULL_RUN_SHA}
	      #  sha256sum -b ${DATA_DIR}/${INCR_IMG}
	      #  sha256sum -b ${IMG}
fi

qemu-system-x86_64 \
  -drive file="${IMG}",if=virtio \
  -m 2G \
  -enable-kvm \
  -smp 2 \
  -vga virtio \
  -net nic,model=virtio -net tap,ifname=tap0,script=no,downscript=no \
  -name "AlmaLinux Server" \
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

echo "my key file = ${MY_KEY}"
echo "my ssh options: ${MY_OPTS_SSH}"

until [ "`ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p ${SSH_PORT} -o LogLevel=ERROR ${USER}@${HOST}  ls /tmp | grep continue`" = "continue.txt" ]
do
        echo -ne "$(date -u --date @$((`date +%s` - $date1)) +%H:%M:%S)\r"
        date2=$(date -u --date @$((`date +%s` - $date1)) +%H:%M:%S)
	ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p ${SSH_PORT} -o LogLevel=ERROR ${USER}@${HOST} sudo touch /tmp/continue.txt
        sleep 1
done

echo "--- ssh is working. Put ${RUN_SCRIPT} ${PUT_FILES}."
scp -o LogLevel=ERROR -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -P ${SSH_PORT} bin/${RUN_SCRIPT} ${USER}@${HOST}:.

echo "--- Running ${RUN_SCRIPT}."
ssh -o LogLevel=ERROR -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p ${SSH_PORT}  ${USER}@${HOST} chmod +x /home/${USER}/${RUN_SCTIPT}
ssh -o LogLevel=ERROR -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p ${SSH_PORT}  ${USER}@${HOST} sudo bash /home/${USER}/${RUN_SCRIPT}
echo "--- Finished ${RUN_SCRIPT}."


if [ "${GET_FILES}" == " " ]; then
  scp -o LogLevel=ERROR -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -P ${SSH_PORT} ${USER}@${HOST}:${GET_FILES} ./data/
fi

ssh -o LogLevel=ERROR -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p ${SSH_PORT} ${USER}@${HOST} sudo sync && sync && shutdown -h now && sleep 10 && poweroff
# Umm causes error. Needs looking into. 
#timeout 30 wait $( cat pid.${SSH_PORT} )
kill $( cat pid.${SSH_PORT} )
sync
sync
rsync -av ${IMG} ${DATA_DIR}/incr_${IMG}

sha256sum -b ${DATA_DIR}/incr_${IMG}
echo "`sha256sum -b ${IMG}`" > ${DATA_DIR}/${FULL_RUN_SHA}

echo "Wait time was: ${date2}"
echo "Total Time:  $(date -u --date @$((`date +%s` - $date1)) +%H:%M:%S)"
rm -f ${DATA_DIR}/cloud.img meta-data ${IMG} user-data pid.${SSH_PORT}

echo "-----" >> ./run_times.txt
echo "$0 , ${RUN_SCRIPT}" >> ./run_times.txt
echo "Wait time was: ${date2}" >> ./run_times.txt
echo "Total Time:  $(date -u --date @$((`date +%s` - $date1)) +%H:%M:%S)" >> ./run_times.txt

exit
