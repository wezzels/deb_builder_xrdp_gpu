




exit
#install made for ubi8

#!/usr/bin/env bash
dnf install -y openscap-scanner bzip2 wget unzip && \
wget https://github.com/ComplianceAsCode/content/releases/download/v0.1.61/scap-security-guide-0.1.61-oval-5.10.zip && \
unzip scap-security-guide-0.1.61-oval-5.10.zip && \
oscap xccdf eval \
  --verbose ERROR \
  --fetch-remote-resources \
  --profile "xccdf_org.ssgproject.content_profile_stig" \
  --results compliance_output_report.xml \
  --report report.html "scap-security-guide-0.1.61-oval-5.10/ssg-rhel8-ds.xml"
