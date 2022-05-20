#!/bin/bash


RedHat make repo
time ./run_full_make_updated_image.sh -t repo -o Rhel8 -r rhel_setup_repo.sh -p files/rhel-8.6-x86_64-dvd.iso,files/ansible-2.9.tgz,files/clamav-0.105.0.linux.x86_64.rpm,files/cvdupdate-1.1.0.tar.gz,bin/rhel_setup_webserver.sh,files/httpd.conf

time ./run_full_make_updated_image.sh -t image -o Rhel8 -r rhel_setup.sh

echo "Run of all tests" > run_times.txt
echo "`date`" >> run_times.txt
echo "---- Start ----" >> run_times.txt
echo "----Running fulls ----"  >> run_times.txt
echo "     ----Rocky Linux 8 iso_build" >> run_times.txt
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
