#!/bin/bash

echo "Run of all tests" > run_times.txt
echo "`date`" >> run_times.txt
echo "---- Start ----" >> run_times.txt
./prep_system.sh -f yes
kill $( ps -ef | grep qemu-system-x86_64 | xargs | cut -d" " -f2 )
rm -f pid.233* *.img user-data meta-data data/*/cloud.img
echo "----Running fulls ----"  >> run_times.txt
echo "     ----Rocky Linux 8 iso_build" >> run_times.txt
  time ./run_full_make_updated_image.sh -t mkiso \
	-o Rocky8 -r rocky_setup_ISO.sh \
	-g data/\*.iso
kill $( ps -ef | grep qemu-system-x86_64 | xargs | cut -d" " -f2 )
rm -f pid.233* *.img user-data meta-data data/*/cloud.img
echo "     ----CentOS Linux 8 iso_build" >> run_times.txt
  time ./run_full_make_updated_image.sh -t mkiso \
        -o CentOS8 -r centos_setup_ISO.sh \
        -g data/\*.iso
kill $( ps -ef | grep qemu-system-x86_64 | xargs | cut -d" " -f2 )
rm -f pid.233* *.img user-data meta-data data/*/cloud.img
echo "     ----Alma Linux 8 iso_build" >> run_times.txt
  time ./run_full_make_updated_image.sh -t mkiso \
        -o Alma8 -r alma_setup_ISO.sh \
        -g data/\*.iso
kill $( ps -ef | grep qemu-system-x86_64 | xargs | cut -d" " -f2 )
rm -f pid.233* *.img user-data meta-data data/*/cloud.img
echo "     ----Ubuntu 2004 Linux iso_build" >> run_times.txt
  time ./run_full_make_updated_image.sh -t mkiso \
        -o Ubuntu2004 -r ubuntu_setup_ISO.sh \
        -g data/\*.iso
kill $( ps -ef | grep qemu-system-x86_64 | xargs | cut -d" " -f2 )
rm -f pid.233* *.img user-data meta-data data/*/cloud.img 
echo "     ----Alma Linux 8 iso build image" >> run_times.txt
  time ./run_cdrom_test.sh -t mkisotoimg -o Alma8 -r alma_setup.sh

echo "----Running incr ----" >> run_times.txt

echo "     ----Rocky Linux 8 iso_build" >> run_times.txt
kill $( ps -ef | grep qemu-system-x86_64 | xargs | cut -d" " -f2 )
rm -f pid.233* *.img user-data meta-data data/*/cloud.img
  time ./run_incr_make_updated_image.sh -t mkiso \
        -o Rocky8 -r rocky_setup_ISO.sh \
        -g data/\*.iso
kill $( ps -ef | grep qemu-system-x86_64 | xargs | cut -d" " -f2 )
rm -f pid.233* *.img user-data meta-data data/*/cloud.img
echo "     ----CentOS Linux 8 iso_build" >> run_times.txt
  time ./run_incr_make_updated_image.sh -t mkiso \
        -o CentOS8 -r centos_setup_ISO.sh \
        -g data/\*.iso
kill $( ps -ef | grep qemu-system-x86_64 | xargs | cut -d" " -f2 )
rm -f pid.233* *.img user-data meta-data data/*/cloud.img
echo "     ----Alma Linux 8 iso_build" >> run_times.txt
  time ./run_incr_make_updated_image.sh -t mkiso \
        -o Alma8 -r alma_setup_ISO.sh \
        -g data/\*.iso
kill $( ps -ef | grep qemu-system-x86_64 | xargs | cut -d" " -f2 )
rm -f pid.233* *.img user-data meta-data data/*/cloud.img
echo "     ----Ubuntu 2004 Linux iso_build" >> run_times.txt
  time ./run_incr_make_updated_image.sh -t mkiso \
        -o Ubuntu2004 -r ubuntu_setup_ISO.sh \
        -g data/\*.iso
echo "---- Finished ----" >> run_times.txt
