

### Install the required packages:
sudo yum install openscap-scanner scap-security-guide

### Can we run a report?
sudo oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_ospp --report /tmp/report.html /usr/share/xml/scap/ssg/content/ssg-rhel8-ds.xml
first scan gives “notapplicable”

### Now do this…

sudo cp /usr/share/openscap/cpe/openscap-cpe-dict.xml /usr/share/openscap/cpe/openscap-cpe-dict.xml.dist
sudo cp /usr/share/openscap/cpe/openscap-cpe-oval.xml /usr/share/openscap/cpe/openscap-cpe-oval.xml.dist
sudo curl -L https://raw.githubusercontent.com/OpenSCAP/openscap/maint-1.3/cpe/openscap-cpe-dict.xml -o /usr/share/openscap/cpe/openscap-cpe-dict.xml
sudo curl -L https://raw.githubusercontent.com/OpenSCAP/openscap/maint-1.3/cpe/openscap-cpe-oval.xml -o /usr/share/openscap/cpe/openscap-cpe-oval.xml

### Does it work yet?
sudo oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_cis --report /tmp/report.html /usr/share/xml/scap/ssg/content/ssg-rhel8-ds.xml

Still no…

### Now do this…
sudo sed -i \
  -e 's|idref="cpe:/o:redhat:enterprise_linux|idref="cpe:/o:centos:centos|g' \
  -e 's|ref_id="cpe:/o:redhat:enterprise_linux|ref_id="cpe:/o:centos:centos|g' \
  /usr/share/xml/scap/ssg/content/ssg-rhel*.xml

It replaces redhat:enterprise with centos:centos

Now it works!

### List all the different profiles available:
oscap info /usr/share/xml/scap/ssg/content/ssg-rhel8-ds.xml

### Run the report to check against the CIS benchmark:
sudo oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_cis --report /tmp/report.html /usr/share/xml/scap/ssg/content/ssg-rhel8-ds.xml

### Check the report.

