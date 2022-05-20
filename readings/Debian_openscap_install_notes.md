OPENSCAP 101
===

+ Install openscap for debian
`apt-get install libopenscap8 -y`

+ Install openscap-ssh for remote scan
`wget https://raw.githubusercontent.com/OpenSCAP/openscap/maint-1.2/utils/oscap-ssh`

+ Install security guides
`wget https://github.com/ComplianceAsCode/content/releases/download/v0.1.50/scap-security-guide-0.1.50.zip`

+ Unzip security guides
`unzip scap-security-guide-0.1.50.zip`

+ Scanning
`oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_standard --report ~/192.168.1.104.html ssg-debian9-ds-1.2.xml`

Compile from sources for Debian 10
---

```
git clone https://github.com/OpenSCAP/openscap.git
cd openscap
mkdir -p build
sudo apt-get install -y cmake libdbus-1-dev libdbus-glib-1-dev libcurl4-openssl-dev \
libgcrypt20-dev libselinux1-dev libxslt1-dev libgconf2-dev libacl1-dev libblkid-dev \
libcap-dev libxml2-dev libldap2-dev libpcre3-dev python-dev swig libxml-parser-perl \
libxml-xpath-perl libperl-dev libbz2-dev librpm-dev g++ libapt-pkg-dev libyaml-dev \
libxmlsec1-dev libxmlsec1-openssl
cd build/
cmake ../
make
#python3 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())"
#cmake ../ -DPYTHON_SITE_PACKAGES_INSTALL_DIR=/usr/local/lib/python3.6/dist-packages
#make install
#https://fossies.org/linux/openscap/docs/developer/developer.adoc
sed -i '79 i set(CPACK_DEBIAN_PACKAGE_DEPENDS "NONE")' CPackConfig.cmake
sed -i '79 i set(CPACK_PACKAGE_CONTACT "NONE")' CPackConfig.cmake
sed -i '79 i set(CPACK_DEBIAN_PACKAGE_MAINTAINER "")' CPackConfig.cmake
cpack -G DEB
```
### Specific for 18.04
# Using OpenSCAP on Ubuntu 18.04 LTS 

## Installation Instructions

First we install the following packages to use the openscap command-line tool:
 sudo apt-get install libopenscap8 python-openscap

We will also install the SCAP security guide: 
 sudo apt install ssg-base ssg-debderived ssg-debian ssg-nondebian ssg-applications

Please note that both of these packages come from Universe and are not covered by Ubuntu Advantage by default. 
Details of the packages can be found here: [https://packages.ubuntu.com/search?suite=bionic&searchon=names&keywords=ssg](https://packages.ubuntu.com/search?suite=bionic&searchon=names&keywords=ssg). 

However, we would recommend pulling the latest OpenSCAP security guide from github to get the latest scans:
```
apt-get install cmake make expat libopenscap8 libxml2-utils ninja-build python3-jinja2 python3-yaml xsltproc
git clone https://github.com/ComplianceAsCode/content.git
```

Then you can build the content for 18.04:
```
 ./build_product ubuntu18.04
```

## Running a Scan

After installing the command-line tool and the SCAP security guide, the policies can be found in directory: 
```
 /usr/share/scap-security-guide/
```

or if you built from source: 

```
/home/calvinh/content/build/
```

There is a bug with Debian (https://github.com/ComplianceAsCode/content/issues/2421) which is fixed by the following procedure: 

```
configure openscap to specify its cpe dir to point to scap-security-guide dir, this will permit openscap to use the scap-security-guide cpe files for the xccdf evaluation
OR copy the scap-security-guide ssg-ubuntu1604-cpe*.xml in the default openscap cpe dir (/usr/share/openscap/cpe)
```

So let's run the command: 

```
sudo cp /home/calvinh/content/build/ssg-ubuntu1804-cpe-dictionary.xml /usr/share/openscap/cpe/openscap-cpe-dict.xml
```

and to run a scan: 

```
oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_standard --results xccdf_org.ssgproject.content_profile_standard.xml --report xccdf_org.ssgproject.content_profile_standard.html ssg-ubuntu1804-ds-1.2.xml
```

You should now receive a set of results of the scan. 


