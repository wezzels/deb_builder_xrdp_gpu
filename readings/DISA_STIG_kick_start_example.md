# SCAP Security Guide profile kickstart for Red Hat Enterprise Linux 7 Server
# Version: 0.0.2
# Date: 2015-08-02
#
# Based on:
# http://fedoraproject.org/wiki/Anaconda/Kickstart
# https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Installation_Guide/sect-kickstart-syntax.html
# http://usgcb.nist.gov/usgcb/content/configuration/workstation-ks.cfg

# Install a fresh new system (optional)
install

# Set language to use during installation and the default language to use on the installed system (required)
lang en_US.UTF-8

text
skipx
eula --agreed

# Set system keyboard type / layout (required)
keyboard us

# Configure network information for target system and activate network devices in the installer environment (optional)
# --onboot      enable device at a boot time
# --device      device to be activated and / or configured with the network command
# --bootproto   method to obtain networking configuration for device (default dhcp)
# --noipv6      disable IPv6 on this device
network --onboot yes --device eth0 --bootproto dhcp --noipv6

# Set the system's root password (required)
# Plaintext password is: server
# Refer to e.g. http://fedoraproject.org/wiki/Anaconda/Kickstart#rootpw to see how to create
# encrypted password form for different plaintext password
rootpw --iscrypted $6$rhel6usgcb$aS6oPGXcPKp3OtFArSrhRwu6sN8q2.yEGY7AIwDOQd23YCtiz9c5mXbid1BzX9bmXTEZi.hCzTEXFosVBI5ng0

# Configure firewall settings for the system (optional)
# --enabled     reject incoming connections that are not in response to outbound requests
# --ssh         allow sshd service through the firewall
firewall --disable

# Set up the authentication options for the system (required)
# --enableshadow        enable shadowed passwords by default
# --passalgo            hash / crypt algorithm for new passwords
# See the manual page for authconfig for a complete list of possible options.
authconfig --enableshadow --passalgo=sha512

services --disabled="chronyd" --enabled="sshd"
# State of SELinux on the installed system (optional)
# Defaults to enforcing
selinux --enforcing

# Set the system time zone (required)
timezone --utc America/New_York

# Specify how the bootloader should be installed (required)
# Plaintext password is: password
# Refer to e.g. http://fedoraproject.org/wiki/Anaconda/Kickstart#rootpw to see how to create
# encrypted password form for different plaintext password
bootloader --location=mbr --append="crashkernel=auto rhgb quiet" --password=$6$rhel6usgcb$kOzIfC4zLbuo3ECp1er99NRYikN419wxYMmons8Vm/37Qtg0T8aB9dKxHwqapz8wWAFuVkuI/UJqQBU92bA5C0

# Initialize (format) all disks (optional)
zerombr

# The following partition layout scheme assumes disk of size 20GB or larger
# Modify size of partitions appropriately to reflect actual machine's hardware
# 
# Remove Linux partitions from the system prior to creating new ones (optional)
# --linux       erase all Linux partitions
# --initlabel   initialize the disk label to the default based on the underlying architecture
ignoredisk --only-use=vda
clearpart --linux --initlabel

user --name=centos --uid=2222 --gid=2000 --gecos=automated
# Create primary system partitions (required for installs)
part /boot --fstype=xfs --size=512
part pv.01 --grow --size=1

# Create a Logical Volume Management (LVM) group (optional)
volgroup VolGroup --pesize=4096 pv.01

# Create particular logical volumes (optional)
logvol / --fstype=xfs --name=rootfs --vgname=VolGroup --size=12288 
# CCE-26557-9: Ensure /home Located On Separate Partition
logvol /home --fstype=xfs --name=home --vgname=VolGroup --size=1024 --fsoptions="nodev"
# CCE-26435-8: Ensure /tmp Located On Separate Partition
logvol /tmp --fstype=xfs --name=tmp --vgname=VolGroup --size=1024 --fsoptions="nodev,noexec,nosuid"
# CCE-26639-5: Ensure /var Located On Separate Partition
logvol /var --fstype=xfs --name=var --vgname=VolGroup --size=2048 --mkfsoptions="-n ftype=1" --fsoptions="nodev"
# CCE-26215-4: Ensure /var/log Located On Separate Partition
logvol /var/log --fstype=xfs --name=var_log --vgname=VolGroup --size=1024 --fsoptions="nodev"
# CCE-26436-6: Ensure /var/log/audit Located On Separate Partition
logvol /var/log/audit --fstype=xfs --name=var_log_audit --vgname=VolGroup --size=512 --fsoptions="nodev"
logvol swap --name=lv_swap --vgname=VolGroup --size=2016

#%addon org_fedora_oscap
#        content-type = scap-security-guide
#        profile = ospp-rhel7-server
#%end

# Packages selection (%packages section is required)
%packages

# Require 'Server with GUI' package environment to be installed
@^minimal
@core
-aic94xx-firmware
-atmel-firmware
-b43-openfwwf
-bfa-firmware
-ipw2100-firmware
-ipw2200-firmware
-ivtv-firmware
-iwl100-firmware
-iwl1000-firmware
-iwl3945-firmware
-iwl4965-firmware
-iwl5000-firmware
-iwl5150-firmware
-iwl6000-firmware
-iwl6000g2a-firmware
-iwl6050-firmware
-libertas-usb8388-firmware
-ql2100-firmware
-ql2200-firmware
-ql23xx-firmware
-ql2400-firmware
-ql2500-firmware
-rt61pci-firmware
-rt73usb-firmware
-zd1211-firmware
sudo
rsyslog
openssh-server
# Install selected additional packages (required by PCI-DSS profile)
# CCE-27024-9: Install AIDE
aide


%end # End of %packages section

%post --log /root/oscap.log

yum update -y
%end # End of %post section


# Reboot after the installation is complete (optional)
# --eject       attempt to eject CD or DVD media before rebooting
reboot --eject
