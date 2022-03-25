#!/bin/bash
# Install Latest XRDP with XORGXRDP

# README
# Manual steps required first:
# Enable "Non-Free" repost in APT by adding "non-free" at the end of every URL in /etc/apt/sources.list

# Target Versions and Folders
XORGXRDP_VERSION=0.2.15
XRDP_VERSION=0.9.18
BUILD_DIR=/tmp/xrdpbuild

echo "Waiting for the system install to finish."
until [ -f /tmp/continue.txt ]
do
     sleep 1
done
echo "Last command of the user-data detected.  Starting build "

# Cleanup last build resources 
rm -f -r $BUILD_DIR /opt/*
mkdir -p $BUILD_DIR


# Build and Install XRDP
cd $BUILD_DIR
wget https://github.com/neutrinolabs/xrdp/releases/download/v$XRDP_VERSION/xrdp-$XRDP_VERSION.tar.gz
tar xvzf xrdp-*.tar.gz

cd xrdp-$XRDP_VERSION

# removed as we are testing new dirs.
  #cat <<EOB> $BUILD_DIR/xrdp_debian_dir.b64
  #---needs updating---
  #EOB

  # removed as we are testing new dirs.
  #base64 --decode $BUILD_DIR/xrdp_debian_dir.b64 > $BUILD_DIR/xrdp_debian_dir.tgz 
  #tar -zxvf $BUILD_DIR/xrdp_debian_dir.tgz
#End remove

tar -zxvf /tmp/xrdp_debian_dir_new.tgz

#fix to make sure dh version is compatibility set
echo 10 > debian/compat

dpkg-buildpackage -rfakeroot

echo "XRDP has been installed"

# Build and Install XORGXRDP
cd $BUILD_DIR

git clone -b nvidia_hack_helper1 https://github.com/jsorg71/xorgxrdp.git
cd xorgxrdp

#Tests does not run without significant software installed. Also configs changed.
# To enable. make these changes to /etc/X11/Xwrapper.config
#  allowed_users=anybody
#  needs_root_rights=no
#Disable the tests.
sed -i '3i\exit 0\' tests/xorg-test-run.sh 


#Removed as we are testing new dir.
  #cat <<EOB> $BUILD_DIR/xorgxrdp_debian_dir.b64
  #---Needs update---
  #EOB

  #base64 --decode $BUILD_DIR/xorgxrdp_debian_dir.b64 > $BUILD_DIR/xorgxrdp_debian_dir.tgz
  #tar -zxvf $BUILD_DIR/xorgxrdp_debian_dir.tgz
  #cp $BUILD_DIR/xorgxrdp_debian_dir.tgz $BUILD_DIR/xrdp_debian_dir.tgz /opt
#End Removed.

tar -zxvf /tmp/xorgxrdp_debian_dir_new.tgz

export PKG_CONFIG_PATH=$BUILD_DIR/xrdp-$XRDP_VERSION/
export XRDP_CFLAGS=-I$BUILD_DIR/xrdp-$XRDP_VERSION/common 
export XRDP_LIBS=" "

#fix to make sure dh version is compatibility set
echo 10 > debian/compat

dpkg-buildpackage -rfakeroot

cd $BUILD_DIR
# copy the deb packages to the /opt directory
cp *.deb /opt

echo "XORGXRDP has been installed"

# Cleanup
cd /tmp
rm -f -r $BUILD_DIR

# Clean Residues
apt-get autoremove -y
apt-get clean

# Will be adding in the test for the installer.
exit
# Enable Service
systemctl enable xrdp
systemctl start xrdp

# Script Completed
exit

