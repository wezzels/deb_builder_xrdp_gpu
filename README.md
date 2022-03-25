
#Howto setup a vm builder using as minimal software as possible,  
        
/*
prep_system.sh -- cofigure user and has the tar files for the build
  Usage: sudo ./prep_system.sh -u $username 
              ./prep_system.sh -f 
#Runs a full build including downloading the image for ubuntu. 
run_full_vm_process_build.sh  
  Usage: ./run_full_vm_process_build.sh
#Runs an incremental from a previous run of the full.   
run_incr_vm_process_build.sh  
  Usage: ./run_incr_vm_process_build.sh
#Develop script to make the build.
make_xrdp_xorgxrdp_deb_packages.sh  
  Runs from a call from the run_scripts.
*/
