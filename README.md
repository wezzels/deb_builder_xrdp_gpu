# Howto setup a vm builder using as minimal software as possible.  
        
prep_system.sh -- cofigure user and has the tar files for the build

`Usage: sudo ./prep_system.sh -u $username 
              ./prep_system.sh -f `
#Runs a full build including downloading the image for ubuntu. 
run_full_vm_process_build.sh  
  Usage: ./run_full_vm_process_build.sh
#Runs an incremental from a previous run of the full.   
run_incr_vm_process_build.sh  
  Usage: ./run_incr_vm_process_build.sh
#Develop script to make the build.
make_xrdp_xorgxrdp_deb_packages.sh  
  Runs from a call from the run_scripts.


## Instructions:

  Install ubuntu 20.04 on a physical machine make sure user is in KVM group. Install qemu-kvm. 

`git clone https://github.com/wezzels/deb_builder_xrdp_gpu.git`

run to following:

Administration steps to enable a general user to use a tun interface with no need for root. 

`sudo prep_system.sh -u <username> `

This adds some debian tar files to make a couple packages.        

`time ./prep_system.sh -f yes `

## This will run a full build and create and download the correct files. After will run the incr version. Incr versions startup at about 1/4th the time it takes a full to build.      

`time ./run_full_vm_process_build.sh`

`time ./run_incr_vm_process_build.sh`

`time ./run_full_vm_AlmaLinux.sh`

`time ./run_incr_vm_AlmaLinux.sh`

`time ./run_full_vm_Ubuntu.sh`

`time ./run_incr_vm_Ubuntu.sh`
