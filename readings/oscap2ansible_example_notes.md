### Docs:
https://github.com/RedHatDemos/SecurityDemos/blob/master/2019Labs/RHELSecurityLab/documentation/lab1_OpenSCAP.adoc

### Generate the report first:
sudo oscap xccdf eval --oval-results --profile cis --results-arf /tmp/arf.xml --report /tmp/report.html /usr/share/xml/scap/ssg/content/ssg-rhel8-ds.xml

### Now create the playbook based on the report:
oscap xccdf generate fix --fix-type ansible --result-id "" /tmp/arf.xml > playbook.yml

### Run the playbook against your server to force CIS compliance:
ansible-playbook -i hosts.ini playbook.yml --become

### Re-run the report and check the result:
sudo oscap xccdf eval --oval-results --profile cis --results-arf /tmp/arf.xml --report /tmp/report.html /usr/share/xml/scap/ssg/content/ssg-rhel8-ds.xml


## Now your Centos 8 server is almost 95% compliant with the CIS benchmark!
