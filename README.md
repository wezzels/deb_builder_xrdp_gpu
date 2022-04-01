# Howto setup a vm builder using as minimal software as possible.  
        
prep_system.sh -- cofigure user and has the tar files for the build

```Usage: sudo ./prep_system.sh -u $username 
              ./prep_system.sh -f 
```

#Runs a full build including downloading the image for ubuntu. 
```
 time ./run_full_make_updated_image.sh -o Alma8 -t image -r alma_setup.sh 
 time ./run_incr_make_updated_image.sh -o Alma8 -t mkiso -r alma_setup_ISO.sh
 time ./run_cdrom_test.sh -t mkisotoimg -o Alma8 
 time ./run_incr_make_updated_image.sh -o Rocky8 -t mkiso -r rocky_setup_ISO.sh
 time ./run_incr_make_updated_image.sh -o CentOS8 -t mkiso -r centos_setup_ISO.sh
 time ./run_incr_make_updated_image.sh -o Ubuntu2004 -t mkiso -r ubuntu_setup_ISO.sh
 time ./run_cdrom_test.sh -t mkisotoimg -o Ubuntu2004
```
#Runs an incremental from a previous run of the full.   
```
## Instructions:

  Install ubuntu 20.04 on a physical machine make sure user is in KVM group. Install qemu-kvm. 

`git clone https://github.com/wezzels/deb_builder_xrdp_gpu.git`

run to following:

Administration steps to enable a general user to use a tun interface with no need for root. 

`sudo prep_system.sh -u <username> `

This adds some debian tar files to make a couple packages.        

`time ./prep_system.sh -f yes `

## This will run a full build and create and download the correct files. After will run the incr version. Incr versions startup at about 1/4th the time it takes a full to build.      
#Enable the user to be able to use a tap0 network interface without root.  Needs to be done after a reboot.
```
git clone https://github.com/wezzels/deb_builder_xrdp_gpu.git
sudo prep_system -u <user>
./run_all.sh
```
resulting times will be in run_times.txt
```
```
