#!/bin/bash

echo "Run of all tests" > run_times.txt
echo "`date`" >> run_times.txt
echo "---- Start ----" >> run_times.txt
./prep_system.sh -f yes
kill $( ps -ef | grep qemu-system-x86_64 | xargs | cut -d" " -f2 )
rm -f pid.233* *.img user-data meta-data data/*/cloud.img
echo "----Running fulls ----"
echo "     ----process_build"
time ./run_full_vm_process_build.sh 
kill $( ps -ef | grep qemu-system-x86_64 | xargs | cut -d" " -f2 )
rm -f pid.233* *.img user-data meta-data data/*/cloud.img
echo "     ----AlmaLinux"
time ./run_full_vm_AlmaLinux.sh 
kill $( ps -ef | grep qemu-system-x86_64 | xargs | cut -d" " -f2 )
rm -f pid.233* *.img user-data meta-data data/*/cloud.img
echo "     ----Ubuntu"
time ./run_full_vm_Ubuntu.sh 
kill $( ps -ef | grep qemu-system-x86_64 | xargs | cut -d" " -f2 )
rm -f pid.233* *.img user-data meta-data data/*/cloud.img
echo "     ----AlmaISO"
time ./run_full_vm_AlmaISO.sh
kill $( ps -ef | grep qemu-system-x86_64 | xargs | cut -d" " -f2 )
rm -f pid.233* *.img user-data meta-data data/*/cloud.img
echo "     ----process_build"
echo "----Running incr ----"
time ./run_incr_vm_process_build.sh 
kill $( ps -ef | grep qemu-system-x86_64 | xargs | cut -d" " -f2 )
rm -f pid.233* *.img user-data meta-data data/*/cloud.img
echo "     ----AlmaLinux"
time ./run_incr_vm_AlmaLinux.sh
kill $( ps -ef | grep qemu-system-x86_64 | xargs | cut -d" " -f2 )
rm -f pid.233* *.img user-data meta-data data/*/cloud.img
echo "     ----Ubuntu"
time ./run_incr_vm_Ubuntu.sh
kill $( ps -ef | grep qemu-system-x86_64 | xargs | cut -d" " -f2 )
rm -f pid.233* *.img user-data meta-data data/*/cloud.img
echo "     ----AlmaISO"
time ./run_incr_vm_AlmaISO.sh
kill $( ps -ef | grep qemu-system-x86_64 | xargs | cut -d" " -f2 )
rm -f pid.233* *.img user-data meta-data data/*/cloud.img
echo "---- Finished ----" >> run_times.txt
