wget -c https://s3.ec2imagebuilder-managed-resources-us-east-1-prod.amazonaws.com/components/stig-build-linux-high/3.6.0/LinuxAWSConfigureSTIG_3_6.tgz

#!/usr/bin/env bash

# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this
# software and associated documentation files (the "Software"), to deal in the Software
# without restriction, including without limitation the rights to use, copy, modify,
# merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# This script is intended to be ran on RHEL 8 and distros that were based off it.  Other distros of Linux have different sets of STIGs.

set -e

#--------------------------------------------
#STIGs for Red Hat 8, Version 1 Release 5.
#--------------------------------------------

#--------------
#CAT III\Low
#--------------

#Install policycoreutils if not already installed, V-230241
function V230241() {
    local Success="policycoreutils has been installed, per V-230241."
    local Failure="policycoreutils is not installed, skipping V-230241."

    echo
    if ! yum -q list installed policycoreutils &>/dev/null; then
        echo "${Failure}"
    else
        echo "${Success}"
    fi
}

#Configure SSH Server to use strong entropy, V-230253
function V230253() {
    local Regex1="^(\s*)SSH_USE_STRONG_RNG=\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)SSH_USE_STRONG_RNG=\S+(\s*#.*)?\s*$/\SSH_USE_STRONG_RNG=32\2/"
    local Regex3="^(\s*)SSH_USE_STRONG_RNG=32?\s*$"
    local Success="Configured SSH Server to use stron entropy, per V-230253."
    local Failure="Failed to configured SSH Server to use stron entropy, not in compliance V-230253."

    echo
    (grep -E -q "${Regex1}" /etc/sysconfig/sshd && sed -ri "${Regex2}" /etc/sysconfig/sshd) || echo "SSH_USE_STRONG_RNG=32" >>/etc/sysconfig/sshd
    (grep -E -q "${Regex3}" /etc/sysconfig/sshd && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Restrict access to the kernel message buffer, V-230269
function V230269() {
    local Regex1="^(\s*)#kernel.dmesg_restrict\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#kernel.dmesg_restrict\s*=\s*\S+(\s*#.*)?\s*$/\1kernel.dmesg_restrict = 1\2/"
    local Regex3="^(\s*)kernel.dmesg_restrict\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)kernel.dmesg_restrict\s*=\s*\S+(\s*#.*)?\s*$/\1kernel.dmesg_restrict = 1\2/"
    local Regex5="^(\s*)kernel.dmesg_restrict\s*=\s*1?\s*$"
    local Success="Restricted access to the kernel message buffer, per V-230269."
    local Failure="Failed to restrict access to the kernel message buffer, not in compliance V-230269."

    echo
    sysctl -w kernel.dmesg_restrict=1 &>/dev/null
    ( (grep -E -q "${Regex1}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex2}" /etc/sysctl.d/99-sysctl.conf) || (grep -E -q "${Regex3}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex4}" /etc/sysctl.d/99-sysctl.conf)) || echo "kernel.dmesg_restrict = 1" >>/etc/sysctl.d/99-sysctl.conf

    sysctl --quiet --system

    ( (grep -E -q "${Regex5}" /etc/sysctl.d/99-sysctl.conf && sysctl kernel.dmesg_restrict | grep -E -q "${Regex5}") && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Prevent kernel profiling by unpriviledged users, V-230270
function V230270() {
    local Regex1="^(\s*)#kernel.perf_event_paranoid\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#kernel.perf_event_paranoid\s*=\s*\S+(\s*#.*)?\s*$/\1kernel.perf_event_paranoid = 2\2/"
    local Regex3="^(\s*)kernel.perf_event_paranoid\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)kernel.perf_event_paranoid\s*=\s*\S+(\s*#.*)?\s*$/\1kernel.perf_event_paranoid = 2\2/"
    local Regex5="^(\s*)kernel.perf_event_paranoid\s*=\s*2?\s*$"
    local Success="Prevent kernel profiling by unpriviledged users, per V-230270."
    local Failure="Failed to prevent kernel profiling by unpriviledged users, not in compliance V-230270."

    echo
    sysctl -w kernel.perf_event_paranoid=2 &>/dev/null
    ( (grep -E -q "${Regex1}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex2}" /etc/sysctl.d/99-sysctl.conf) || (grep -E -q "${Regex3}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex4}" /etc/sysctl.d/99-sysctl.conf)) || echo "kernel.perf_event_paranoid = 2" >>/etc/sysctl.d/99-sysctl.conf

    sysctl --quiet --system

    ( (grep -E -q "${Regex5}" /etc/sysctl.d/99-sysctl.conf && sysctl kernel.perf_event_paranoid | grep -E -q "${Regex5}") && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set yum to remove software components after updated versions have been installed, V-230281
function V230281() {
    local Regex1="^(\s*)#clean_requirements_on_remove=\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#clean_requirements_on_remove=\S+(\s*#.*)?\s*$/clean_requirements_on_remove=True\2/"
    local Regex3="^(\s*)clean_requirements_on_remove=\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)clean_requirements_on_remove=\S+(\s*#.*)?\s*$/clean_requirements_on_remove=True\2/"
    local Regex5="^(\s*)clean_requirements_on_remove=True?\s*$"
    local Success="Yum set to remove unneeded packages, per V-230281."
    local Failure="Failed to set yum to remove unneeded packages, not in compliance V-230281."

    echo
    ( (grep -E -q "${Regex1}" /etc/yum.conf && sed -ri "${Regex2}" /etc/yum.conf) || (grep -E -q "${Regex3}" /etc/yum.conf && sed -ri "${Regex4}" /etc/yum.conf)) || echo "clean_requirements_on_remove=True" >>/etc/yum.conf
    (grep -E -q "${Regex5}" /etc/yum.conf && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set the rngd service is active, V-230285
function V230285() {
    local Success="Set the rngd service is active, per V-230285."
    local Failure="Failed to set the rngd service to active, not in compliance with V-230285."

    echo
    if systemctl is-active rngd.service | grep -E -q "active"; then
        systemctl enable rngd.service
        echo "${Success}"
    else
        systemctl start rngd.service
        systemctl enable rngd.service
        ( (systemctl is-active rngd.service | grep -E -q "active") && echo "${Success}") || {
            echo "${Failure}"
            exit 1
        }
    fi
}

#Use a seperate file system for /var, V-230292.  Needs to be done by an admin per their configuration

#Use a seperate file system for /var/log, V-230293.  Needs to be done by an admin per their configuration

#Use a seperate file system for the system audit data path, V-230294.  Needs to be done by an admin per their configuration

#Set mx concurrent sessions to 10, V-230346
function V230346() {
    local Regex1="^(\s*)#*\s*hard\s*maxlogins\s+\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#*\s*hard\s*maxlogins\s+\S+(\s*#.*)?\s*$/\* hard maxlogins 10\2/"
    local Regex3="^(\s*)\*\s*hard\s*maxlogins\s+\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)\*\s*hard\s*maxlogins\s+\S+(\s*#.*)?\s*$/\* hard maxlogins 10\2/"
    local Regex5="^(\s*)\*\s*hard\s*maxlogins\s*10?\s*$"
    local Success="Set max concurrent sessions to 10, per V-230346."
    local Failure="Failed to set max concurrent sessions to 10, not in compliance V-230346."

    echo
    ( (grep -E -q "${Regex1}" /etc/security/limits.conf && sed -ri "${Regex2}" /etc/security/limits.conf) || (grep -E -q "${Regex3}" /etc/security/limits.conf && sed -ri "${Regex4}" /etc/security/limits.conf)) || echo "* hard maxlogins 10" >>/etc/security/limits.conf
    (grep -E -q "${Regex5}" /etc/security/limits.conf && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set system to display the date and time of the last successful logon upon logon., V-230381
function V230381() {
    local Regex1="^\s*session\s+required\s+pam_lastlog.so\s*"
    local Regex2="s/^\s*session\s+required\s+pam_lastlog.so\s*showfailed\s*"
    local Regex3="session     required                   pam_lastlog.so showfailed"
    local Regex4="^(\s*)session\s+required\s+\s*pam_lastlog.so\s*showfailed\s*$"
    local Success="System set to display the date and time of the last successful logon upon logon, per V-230381."
    local Failure="Failed to set the system to display the date and time of the last successful logon upon logon, not in compliance with V-230381."

    echo
    (grep -E -q "${Regex1}" /etc/pam.d/postlogin && sed -ri "${Regex2}.*$/${Regex3}/" /etc/pam.d/postlogin) || echo "${Regex3}" >>/etc/pam.d/postlogin
    (grep -E -q "${Regex4}" /etc/pam.d/postlogin && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Prevent users from disabling session control mechanisms, V-230350

#Set RHEL8 to resolve audit information before writing to disk, V-230395
function V230395() {
    local Regex1="^(\s*)#\s*log_format\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#\s*log_format\s*=\s*\S+(\s*#.*)?\s*$/log_format = ENRICHED\2/"
    local Regex3="^(\s*)log_format\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)log_format\s*=\s*\S+(\s*#.*)?\s*$/log_format = ENRICHED\2/"
    local Regex5="^(\s*)log_format\s*=\s*ENRICHED\s*$"
    local Success="Audit information is resolved before writing to disk, per V-230395"
    local Failure="Failed to set audit information is resolved before writing to disk, not in compliance with V-230395."

    echo
    ( (grep -E -q "${Regex1}" /etc/audit/auditd.conf && sed -ri "${Regex2}" /etc/audit/auditd.conf) || (grep -E -q "${Regex3}" /etc/audit/auditd.conf && sed -ri "${Regex4}" /etc/audit/auditd.conf)) || echo "log_format = ENRICHED" >>/etc/audit/auditd.conf
    (grep -E -q "${Regex5}" /etc/audit/auditd.conf && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Enable audting of processes that start prior to the audit daemon, V-230468
function V230468() {
    local Regex1="^(\s*)GRUB_CMDLINE_LINUX=\S+(\s*.*)?\s*$"
    local Regex2="(\s*)audit=1(\s*.*)?\s*$"
    local Success="Set audit processes to start prior to audit daemon, per V-230468."
    local Failure="Failed set audit processes to start prior to audit daemon, not in compliance V-230468."

    echo
    grubby --update-kernel=ALL --args="audit=1"

    (grep -E -q "${Regex1}" /etc/default/grub && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Allocate an audit_backlog_limit of sufficient size to capture processes that start before the audit daemon, V-230469
function V230469() {
    local Regex1="^(\s*)GRUB_CMDLINE_LINUX=\S+(\s*.*)?\s*$"
    local Regex2="(\s*)audit_backlog_limit=8192(\s*.*)?\s*$"
    local Success="Set system to allocate audit_backlog_limit of sufficient size to capture processes that part prior to the audit daemon, per V-230469."
    local Failure="Failed to set system to allocate audit_backlog_limit of sufficient size to capture processes that part prior to the audit daemon, not in compliance V-230469."

    echo
    grubby --update-kernel=ALL --args="audit_backlog_limit=8192"

    (grep -E -q "${Regex1}" /etc/default/grub && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Enable Linux audit logging of the USBGuard daemon, V-230470

#Disable the chrony daemon from acting as a server, V-230485
function V230485() {
    local Regex1="^(\s*)#\s*port\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#\s*port\s*\S+(\s*#.*)?\s*$/port 0\2/"
    local Regex3="^(\s*)port\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)port\s*\S+(\s*#.*)?\s*$/port 0\2/"
    local Regex5="^(\s*)port\s*0\s*$"
    local Success="Disabled chrony daemon from acting as a server, per V-230485"
    local Failure="Failed to disabled chrony daemon from acting as a server, not in compliance with V-230485."

    echo
    ( (grep -E -q "${Regex1}" /etc/chrony.conf && sed -ri "${Regex2}" /etc/chrony.conf) || (grep -E -q "${Regex3}" /etc/chrony.conf && sed -ri "${Regex4}" /etc/chrony.conf)) || (echo "" >>/etc/chrony.conf && echo "# Chrony time server port" >>/etc/chrony.conf && echo "port 0" >>/etc/chrony.conf)
    (grep -E -q "${Regex5}" /etc/chrony.conf && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Disable network management of the chrony daemon, V-230486
function V230486() {
    local Regex1="^(\s*)#\s*cmdport\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#\s*cmdport\s*\S+(\s*#.*)?\s*$/cmdport 0\2/"
    local Regex3="^(\s*)cmdport\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)cmdport\s*\S+(\s*#.*)?\s*$/cmdport 0\2/"
    local Regex5="^(\s*)cmdport\s*0\s*$"
    local Success="Disabled network management of the chrony daemon, per V-230486"
    local Failure="Failed to disabled network management of the chrony daemon, not in compliance with V-230486."

    echo
    ( (grep -E -q "${Regex1}" /etc/chrony.conf && sed -ri "${Regex2}" /etc/chrony.conf) || (grep -E -q "${Regex3}" /etc/chrony.conf && sed -ri "${Regex4}" /etc/chrony.conf)) || (echo "" >>/etc/chrony.conf && echo "# Chrony network management port" >>/etc/chrony.conf && echo "cmdport 0" >>/etc/chrony.conf)
    (grep -E -q "${Regex5}" /etc/chrony.conf && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Enable mitigations aginst processor-based vulnerabilities, V-230491
function V230491() {
    local Regex1="^(\s*)GRUB_CMDLINE_LINUX=\S+(\s*.*)?\s*$"
    local Regex2="(\s*)pti=on(\s*.*)?\s*$"
    local Success="Set mitigations against processor-based vulnerabilities, per V-230491."
    local Failure="Failed to set mitigations against processor-based vulnerabilities, not in compliance V-230491."

    echo
    grubby --update-kernel=ALL --args="pti=on"

    (grep -E -q "${Regex1}" /etc/default/grub && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Disable the ability to load the ATM protocol kernel module, V-230494
function V230494() {
    local Regex1="^(\s*)#install\s*atm\s*\s+\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#install\s*atm\s+\S+(\s*#.*)?\s*$/install atm \/bin\/true\2/"
    local Regex3="^(\s*)install\s*atm\s+\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)install\s*atm\s+\S+(\s*#.*)?\s*$/install atm \/bin\/true\2/"
    local Regex5="^(\s*)install\s*atm\s*/bin/true\s*$"
    local Regex6="^(\s*)#blacklist\s*atm?\s*$"
    local Regex7="s/^(\s*)#blacklist\s*atm(.*)?\s*$/\blacklist atm\2/"
    local Regex8="^(\s*)blacklist\s*atm?\s*$"
    local Regex9="s/^(\s*)blacklist\s*atm(.*)?\s*$/\blacklist atm\2/"
    local Success="Disable the asynchronous transfer mode (ATM), per V-230494."
    local Failure="Failed to disable the asynchronous transfer mode (ATM), not in compliance V-230494."

    echo
    if [ -f "/etc/modprobe.d/blacklist.conf" ]; then
        ( (grep -E -q "${Regex1}" /etc/modprobe.d/blacklist.conf && sed -ri "${Regex2}" /etc/modprobe.d/blacklist.conf) || (grep -E -q "${Regex3}" /etc/modprobe.d/blacklist.conf && sed -ri "${Regex4}" /etc/modprobe.d/blacklist.conf)) || echo "install atm /bin/true" >>/etc/modprobe.d/blacklist.conf
        ( (grep -E -q "${Regex6}" /etc/modprobe.d/blacklist.conf && sed -ri "${Regex7}" /etc/modprobe.d/blacklist.conf) || (grep -E -q "${Regex8}" /etc/modprobe.d/blacklist.conf && sed -ri "${Regex9}" /etc/modprobe.d/blacklist.conf)) || echo "blacklist atm" >>/etc/modprobe.d/blacklist.conf
    else
        echo "install atm /bin/true" >>/etc/modprobe.d/blacklist.conf
        echo "blacklist atm" >>/etc/modprobe.d/blacklist.conf
    fi

    ( (grep -E -q "${Regex5}" /etc/modprobe.d/blacklist.conf && grep -E -q "${Regex8}" /etc/modprobe.d/blacklist.conf) && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Disable the controller area network (CAN) protocol kernel module, V-230495
function V230495() {
    local Regex1="^(\s*)#install\s*can\s*\s+\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#install\s*can\s+\S+(\s*#.*)?\s*$/install can \/bin\/true\2/"
    local Regex3="^(\s*)install\s*can\s+\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)install\s*can\s+\S+(\s*#.*)?\s*$/install can \/bin\/true\2/"
    local Regex5="^(\s*)install\s*can\s*/bin/true\s*$"
    local Regex6="^(\s*)#blacklist\s*can?\s*$"
    local Regex7="s/^(\s*)#blacklist\s*can(.*)?\s*$/\blacklist can\2/"
    local Regex8="^(\s*)blacklist\s*can?\s*$"
    local Regex9="s/^(\s*)blacklist\s*can(.*)?\s*$/\blacklist can\2/"
    local Success="Disable the controller area network (CAN), per V-230495."
    local Failure="Failed to disable the controller area network (CAN), not in compliance V-230495."

    echo
    ( (grep -E -q "${Regex1}" /etc/modprobe.d/blacklist.conf && sed -ri "${Regex2}" /etc/modprobe.d/blacklist.conf) || (grep -E -q "${Regex3}" /etc/modprobe.d/blacklist.conf && sed -ri "${Regex4}" /etc/modprobe.d/blacklist.conf)) || echo "install can /bin/true" >>/etc/modprobe.d/blacklist.conf
    ( (grep -E -q "${Regex6}" /etc/modprobe.d/blacklist.conf && sed -ri "${Regex7}" /etc/modprobe.d/blacklist.conf) || (grep -E -q "${Regex8}" /etc/modprobe.d/blacklist.conf && sed -ri "${Regex9}" /etc/modprobe.d/blacklist.conf)) || echo "blacklist can" >>/etc/modprobe.d/blacklist.conf
    ( (grep -E -q "${Regex5}" /etc/modprobe.d/blacklist.conf && grep -E -q "${Regex8}" /etc/modprobe.d/blacklist.conf) && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Disable the stream control transmission (SCTP) protocol kernel module, V-230496
function V230496() {
    local Regex1="^(\s*)#install\s*sctp\s*\s+\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#install\s*sctp\s+\S+(\s*#.*)?\s*$/install sctp \/bin\/true\2/"
    local Regex3="^(\s*)install\s*sctp\s+\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)install\s*sctp\s+\S+(\s*#.*)?\s*$/install sctp \/bin\/true\2/"
    local Regex5="^(\s*)install\s*sctp\s*/bin/true\s*$"
    local Regex6="^(\s*)#blacklist\s*sctp?\s*$"
    local Regex7="s/^(\s*)#blacklist\s*sctp(.*)?\s*$/\blacklist sctp\2/"
    local Regex8="^(\s*)blacklist\s*sctp?\s*$"
    local Regex9="s/^(\s*)blacklist\s*sctp(.*)?\s*$/\blacklist sctp\2/"
    local Success="Disable the stream control transmission (SCTP), per V-230496."
    local Failure="Failed to disable the stream control transmission (SCTP), not in compliance V-230496."

    echo
    ( (grep -E -q "${Regex1}" /etc/modprobe.d/blacklist.conf && sed -ri "${Regex2}" /etc/modprobe.d/blacklist.conf) || (grep -E -q "${Regex3}" /etc/modprobe.d/blacklist.conf && sed -ri "${Regex4}" /etc/modprobe.d/blacklist.conf)) || echo "install sctp /bin/true" >>/etc/modprobe.d/blacklist.conf
    ( (grep -E -q "${Regex6}" /etc/modprobe.d/blacklist.conf && sed -ri "${Regex7}" /etc/modprobe.d/blacklist.conf) || (grep -E -q "${Regex8}" /etc/modprobe.d/blacklist.conf && sed -ri "${Regex9}" /etc/modprobe.d/blacklist.conf)) || echo "blacklist sctp" >>/etc/modprobe.d/blacklist.conf
    ( (grep -E -q "${Regex5}" /etc/modprobe.d/blacklist.conf && grep -E -q "${Regex8}" /etc/modprobe.d/blacklist.conf) && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Disable the transparent inter-process communication (TIPC) protocol kernel module, V-230497
function V230497() {
    local Regex1="^(\s*)#install\s*tipc\s*\s+\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#install\s*tipc\s+\S+(\s*#.*)?\s*$/install tipc \/bin\/true\2/"
    local Regex3="^(\s*)install\s*tipc\s+\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)install\s*tipc\s+\S+(\s*#.*)?\s*$/install tipc \/bin\/true\2/"
    local Regex5="^(\s*)install\s*tipc\s*/bin/true\s*$"
    local Regex6="^(\s*)#blacklist\s*tipc?\s*$"
    local Regex7="s/^(\s*)#blacklist\s*tipc(.*)?\s*$/\blacklist tipc\2/"
    local Regex8="^(\s*)blacklist\s*tipc?\s*$"
    local Regex9="s/^(\s*)blacklist\s*tipc(.*)?\s*$/\blacklist tipc\2/"
    local Success="Disable the transparent inter-process communication (TIPC), per V-230497."
    local Failure="Failed to disable the transparent inter-process communication (TIPC), not in compliance V-230497."

    echo
    ( (grep -E -q "${Regex1}" /etc/modprobe.d/blacklist.conf && sed -ri "${Regex2}" /etc/modprobe.d/blacklist.conf) || (grep -E -q "${Regex3}" /etc/modprobe.d/blacklist.conf && sed -ri "${Regex4}" /etc/modprobe.d/blacklist.conf)) || echo "install tipc /bin/true" >>/etc/modprobe.d/blacklist.conf
    ( (grep -E -q "${Regex6}" /etc/modprobe.d/blacklist.conf && sed -ri "${Regex7}" /etc/modprobe.d/blacklist.conf) || (grep -E -q "${Regex8}" /etc/modprobe.d/blacklist.conf && sed -ri "${Regex9}" /etc/modprobe.d/blacklist.conf)) || echo "blacklist tipc" >>/etc/modprobe.d/blacklist.conf
    ( (grep -E -q "${Regex5}" /etc/modprobe.d/blacklist.conf && grep -E -q "${Regex8}" /etc/modprobe.d/blacklist.conf) && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Disable loading the cramfs kernel module, V-230498
function V230498() {
    local Regex1="^(\s*)#install\s*cramfs\s*\s+\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#install\s*cramfs\s+\S+(\s*#.*)?\s*$/install cramfs \/bin\/true\2/"
    local Regex3="^(\s*)install\s*cramfs\s+\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)install\s*cramfs\s+\S+(\s*#.*)?\s*$/install cramfs \/bin\/true\2/"
    local Regex5="^(\s*)install\s*cramfs\s*/bin/true\s*$"
    local Regex6="^(\s*)#blacklist\s*cramfs?\s*$"
    local Regex7="s/^(\s*)#blacklist\s*cramfs(.*)?\s*$/\blacklist cramfs\2/"
    local Regex8="^(\s*)blacklist\s*cramfs?\s*$"
    local Regex9="s/^(\s*)blacklist\s*cramfs(.*)?\s*$/\blacklist cramfs\2/"
    local Success="Disable loading the cramfs kernel module, per V-230498."
    local Failure="Failed to disable loading the cramfs kernel module, not in compliance V-230498."

    echo
    ( (grep -E -q "${Regex1}" /etc/modprobe.d/blacklist.conf && sed -ri "${Regex2}" /etc/modprobe.d/blacklist.conf) || (grep -E -q "${Regex3}" /etc/modprobe.d/blacklist.conf && sed -ri "${Regex4}" /etc/modprobe.d/blacklist.conf)) || echo "install cramfs /bin/true" >>/etc/modprobe.d/blacklist.conf
    ( (grep -E -q "${Regex6}" /etc/modprobe.d/blacklist.conf && sed -ri "${Regex7}" /etc/modprobe.d/blacklist.conf) || (grep -E -q "${Regex8}" /etc/modprobe.d/blacklist.conf && sed -ri "${Regex9}" /etc/modprobe.d/blacklist.conf)) || echo "blacklist cramfs" >>/etc/modprobe.d/blacklist.conf
    ( (grep -E -q "${Regex5}" /etc/modprobe.d/blacklist.conf && grep -E -q "${Regex8}" /etc/modprobe.d/blacklist.conf) && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Disable IEEE 1394 (FireWire) support in the kernel module, V-230499
function V230499() {
    local Regex1="^(\s*)#install\s*firewire-core\s*\s+\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#install\s*firewire-core\s+\S+(\s*#.*)?\s*$/install firewire-core \/bin\/true\2/"
    local Regex3="^(\s*)install\s*firewire-core\s+\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)install\s*firewire-core\s+\S+(\s*#.*)?\s*$/install firewire-core \/bin\/true\2/"
    local Regex5="^(\s*)install\s*firewire-core\s*/bin/true\s*$"
    local Regex6="^(\s*)#blacklist\s*firewire-core?\s*$"
    local Regex7="s/^(\s*)#blacklist\s*firewire-core(.*)?\s*$/\blacklist firewire-core\2/"
    local Regex8="^(\s*)blacklist\s*firewire-core?\s*$"
    local Regex9="s/^(\s*)blacklist\s*firewire-core(.*)?\s*$/\blacklist firewire-core\2/"
    local Success="Disable IEEE 1394 (FireWire) support in the kernel module, per V-230499."
    local Failure="Failed to disable IEEE 1394 (FireWire) support in the kernel module, not in compliance V-230499."

    echo
    ( (grep -E -q "${Regex1}" /etc/modprobe.d/blacklist.conf && sed -ri "${Regex2}" /etc/modprobe.d/blacklist.conf) || (grep -E -q "${Regex3}" /etc/modprobe.d/blacklist.conf && sed -ri "${Regex4}" /etc/modprobe.d/blacklist.conf)) || echo "install firewire-core /bin/true" >>/etc/modprobe.d/blacklist.conf
    ( (grep -E -q "${Regex6}" /etc/modprobe.d/blacklist.conf && sed -ri "${Regex7}" /etc/modprobe.d/blacklist.conf) || (grep -E -q "${Regex8}" /etc/modprobe.d/blacklist.conf && sed -ri "${Regex9}" /etc/modprobe.d/blacklist.conf)) || echo "blacklist firewire-core" >>/etc/modprobe.d/blacklist.conf
    ( (grep -E -q "${Regex5}" /etc/modprobe.d/blacklist.conf && grep -E -q "${Regex8}" /etc/modprobe.d/blacklist.conf) && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Verify the file integrity tool, AIDE, is configured to verify extended attributes, V-230551

#Verify the file integrity tool, AIDE, is configured to verify ACLs, V-230552

#Install rng-tools if not already installed, V-244527
function V244527() {
    local Success="rng-tools has been installed, per V-230275."
    local Failure="Failed to install rng-tools, not in compliance with V-230275."

    echo
    if ! yum -q list installed rng-tools &>/dev/null; then
        yum install -q -y rng-tools
        { (! yum -q list installed rng-tools &>/dev/null) && {
            echo "${Failure}"
            exit 1
        }; } || echo "${Success}"
    else
        echo "${Success}"
    fi
}

##Apply all compatible CATIII
function Low() {
    echo
    echo "----------------------------------"
    echo " Applying all compatible CAT IIIs"
    echo "----------------------------------"
    V230241
    V244527
    V230285

    #Check if openssh is installed, /etc/ssh
    if yum -q list installed openssh &>/dev/null; then
        V230253
    else
        echo
        echo "Openssh is not installed, skipping V-230253."
        fi

    #Check if system has been booted with systemd as init system
    if [ "${ISPid1}" = "1" ]; then
        V230269
        V230270
    else
        echo
        echo "System has not been booted with systemd as init system, skipping skipping V-230269 and V-230270."
    fi

    #Check if pam is installed for various settings, /etc/secuirty
    if yum -q list installed pam &>/dev/null; then
        V230346
        V230381
    else
        echo
        echo "Pam is not installed, skipping V-230346 and V-230381."
    fi

    #Check if audit is installed, /etc/audit
    if yum -q list installed audit &>/dev/null; then
        V230395
    else
        echo
        echo "audit is not installed, skipping V-230395."
    fi

    #Check if grub2-tools is installed, /etc/default/grub
    if yum -q list installed grub2-tools &>/dev/null; then
        V230468
        V230469
        V230491
    else
        echo
        echo "grub2-tools is not installed, skipping V-230468, V-230469, and V-230491."
    fi

    #Check if chrony is installed, /etc/chrony.conf
    if yum -q list installed chrony &>/dev/null; then
        V230485
        V230486
    else
        echo
        echo "chrony is not installed, skipping V-230485 and V-230486."
    fi

    #Check if kmod is installed, /etc/modprobe.d/
    if yum -q list installed kmod &>/dev/null; then
        V230494
        V230495
        V230496
        V230497
        V230498
        V230499
    else
        echo
        echo "kmod is not installed, skipping V-230494, V-230495, V-230496, V-230497, V-230498, and V-230499."
    fi

    V230281

    ########################
    #    Unworked STIGs    #
    ########################
    #V230292, V230293, V230294, V230350, V230470, V230551, V230552
}

#--------------
#CAT II\Medium
#--------------

#Set RHEL 8 to monitor all remote access methods, V-230228 and V-230477
function V230228() {
    local Regex1="^(\s*)#auth.*;authpriv.*;daemon.*\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#\s*auth.*;authpriv.*;daemon.*\s*\S+(\s*#.*)?\s*$/auth.*;authpriv.*;daemon.*                              \/var\/log\/secure\2/"
    local Regex3="^(\s*)auth.*;authpriv.*;daemon.*\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)auth.*;authpriv.*;daemon.*\s*\S+(\s*#.*)?\s*$/auth.*;authpriv.*;daemon.*                              \/var\/log\/secure\2/"
    local Regex5="^(\s*)auth.*;authpriv.*;daemon.*\s+/var/log/secure\s*$"
    local Success="rsyslog has been installed and configured, per V-230228 and V-230477."
    local Failure="Failed to install rsyslog and configured, not in compliance with V-230228 and V-230477."

    echo

    ( (grep -E -q "${Regex1}" /etc/rsyslog.conf && sed -ri "${Regex2}" /etc/rsyslog.conf) || (grep -E -q "${Regex3}" /etc/rsyslog.conf && sed -ri "${Regex4}" /etc/rsyslog.conf)) || (echo "" >>/etc/rsyslog.conf && echo "# Configure logging per STIG V-230228 and V-230477" >>/etc/rsyslog.conf && echo "auth.*;authpriv.*;daemon.*                              /var/log/secure" >>/etc/rsyslog.conf)
    (grep -E -q "${Regex5}" /etc/rsyslog.conf && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Install DoD root CA, V-230229

#Set system to create SHA512 hashed passwords, V-230231
function V230231() {
    local Regex1="^(\s*)ENCRYPT_METHOD\s+\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)ENCRYPT_METHOD\s*\S+(\s*#.*)?\s*$f/ENCRYPT_METHOD SHA512\2/"
    local Regex3="^\s*ENCRYPT_METHOD\s*SHA512\s*.*$"
    local Success="Passwords are set to be created with SHA512 hash, per V-230231."
    local Failure="Failed to set passwords to be created with SHA512 hash, not in compliance with V-230231."

    echo
    (grep -E -q "${Regex1}" /etc/login.defs && sed -ri "${Regex2}" /etc/login.defs) || echo "ENCRYPT_METHOD SHA512" >>/etc/login.defs
    (grep -E -q "${Regex3}" /etc/login.defs && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set password-auth to minimum number of hash rounds, V-230233
function V230233() {
    local Regex1="^(\s*)SHA_CRYPT_MIN_ROUNDS\s+\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)SHA_CRYPT_MIN_ROUNDS\s*\S+(\s*#.*)?\s*$f/SHA_CRYPT_MIN_ROUNDS 5000\2/"
    local Regex3="^\s*SHA_CRYPT_MIN_ROUNDS\s*5000\s*.*$"
    local Success="Password-auth is set to using a minimum number of hash rounds, per V-230233."
    local Failure="Failed to set password-auth to use a minimum number of hash rounds, not in compliance with V-230233."

    echo
    (grep -E -q "${Regex1}" /etc/login.defs && sed -ri "${Regex2}" /etc/login.defs) || echo "SHA_CRYPT_MIN_ROUNDS 5000" >>/etc/login.defs
    (grep -E -q "${Regex3}" /etc/login.defs && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Require authentication upon booting into rescue mode, V-230236
function V230236() {
    local Regex1="^(\s*)ExecStart=\S+(\s*.*)?\s*$"
    local Regex2="s/^(\s*)ExecStart=.*/ExecStart=-\/usr\/lib\/systemd\/systemd-sulogin-shell rescue/"
    local Regex3="^(\s*)ExecStart=-/usr/lib/systemd/systemd-sulogin-shell\s*rescue?\s*$"
    local Success="Configured authentication upon booting into rescue mode, per V-230236."
    local Failure="Failed to configure authentication upon booting into rescue mode, not in compliance V-230236."

    echo
    (grep -E -q "${Regex1}" /usr/lib/systemd/system/rescue.service && sed -ri "${Regex2}" /usr/lib/systemd/system/rescue.service) || echo "ExecStart=-/usr/lib/systemd/systemd-sulogin-shell rescue" >>/usr/lib/systemd/system/rescue.service
    (grep -E -q "${Regex3}" /usr/lib/systemd/system/rescue.service && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set password-auth to use SHA512, V-230237
function V230237() {
    local Regex1="^\s*password\s+sufficient\s+pam_unix.so\s+"
    local Regex2="/^\s*password\s+sufficient\s+pam_unix.so\s+/ { /^\s*password\s+sufficient\s+pam_unix.so(\s+\S+)*(\s+sha512)(\s+.*)?$/! s/^(\s*password\s+sufficient\s+pam_unix.so\s+)(.*)$/\1sha512 \2/ }"
    local Regex3="^\s*password\s+sufficient\s+pam_unix.so\s+.*sha512\s*.*$"
    local Success="Password-auth is set to use SHA512 encryption, per V-230237."
    local Failure="Failed to set password-auth to use SHA512 encryption, not in compliance with V-230237."

    echo
    (grep -E -q "${Regex1}" /etc/pam.d/password-auth && sed -ri "${Regex2}" /etc/pam.d/password-auth)
    (grep -E -q "${Regex3}" /etc/pam.d/password-auth && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Prevent system daemons from using Kerberos for authentication, V-230238

#Remove krb5-workstation if installed, V-230239
function V230239() {
    local Success="krb5-workstation has been removed, per V-230239."
    local Failure="Failed to remove krb5-workstation, not in compliance with V-230239."

    echo

    if yum -q list installed krb5-workstation &>/dev/null; then
        yum remove -q -y krb5-workstation &>/dev/null
        { (yum -q list installed krb5-workstation &>/dev/null) && {
            echo "${Failure}"
            exit 1
        }; } || echo "${Success}"
    else
        echo "${Success}"
    fi
}

#Set SELinux to enforce, V-230240
function V230240() {
    local Regex1="^(\s*)#SELINUX=\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#SELINUX=\S+(\s*#.*)?\s*$/SELINUX=enforcing\2/"
    local Regex3="^(\s*)SELINUX=\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)SELINUX=\S+(\s*#.*)?\s*$/SELINUX=enforcing\2/"
    local Regex5="^(\s*)SELINUX=enforcing?\s*$"
    local Success="Set SELinux to enforcing, per V-230240."
    local Failure="Failed to set SELinux to enforcing, not in compliance V-230240."

    echo
    ( (grep -E -q "${Regex1}" /etc/selinux/config && sed -ri "${Regex2}" /etc/selinux/config) || (grep -E -q "${Regex3}" /etc/selinux/config && sed -ri "${Regex4}" /etc/selinux/config)) || echo "SELINUX=enforcing" >>/etc/selinux/config
    (grep -E -q "${Regex5}" /etc/selinux/config && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set max clinet alive count period, V-230244
function V230244() {
    local Regex1="^(\s*)#ClientAliveCountMax\s+\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#ClientAliveCountMax\s+\S+(\s*#.*)?\s*$/\ClientAliveCountMax 0\2/"
    local Regex3="^(\s*)ClientAliveCountMax\s+\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)ClientAliveCountMax\s+\S+(\s*#.*)?\s*$/\ClientAliveCountMax 0\2/"
    local Regex5="^(\s*)ClientAliveCountMax\s*0?\s*$"
    local Success="Set SSH user timeout period to 0 secs, per V-230244."
    local Failure="Failed to set SSH user timeout period to 0 secs, not in compliance V-230244."

    echo
    ( (grep -E -q "${Regex1}" /etc/ssh/sshd_config && sed -ri "${Regex2}" /etc/ssh/sshd_config) || (grep -E -q "${Regex3}" /etc/ssh/sshd_config && sed -ri "${Regex4}" /etc/ssh/sshd_config)) || echo "ClientAliveCountMax 0" >>/etc/ssh/sshd_config
    (grep -E -q "${Regex5}" /etc/ssh/sshd_config && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Enable FIPS, V-230251

#Configure FIPS for SSH connections, V-230252

#Configure FIPS for OpenSSL, V-230254

#Configure OpenSSL to use a minimum of TLSv1.2, V-230255
function V230255() {
    local Regex1="^(\s*)#MinProtocol\s*=\s*\S+(\s*.*)?\s*$"
    local Regex2="s/^(\s*)#MinProtocol\s*=\s*\S+(\s*.*)?\s*$/MinProtocol = TLSv1.2\2/"
    local Regex3="^(\s*)MinProtocol\s*=\s*\S+(\s*.*)?\s*$"
    local Regex4="s/^(\s*)MinProtocol\s*=\s*\S+(\s*.*)?\s*$/MinProtocol = TLSv1.2\2/"
    local Regex5="^(\s*)MinProtocol\s*=\s*TLSv1.2?\s*$"
    local Regex6="^(\s*)#TLS.MinProtocol\s*=\s*\S+(\s*.*)?\s*$"
    local Regex7="s/^(\s*)#TLS.MinProtocol\s*=\s*\S+(\s*.*)?\s*$/TLS.MinProtocol = TLSv1.2\2/"
    local Regex8="^(\s*)TLS.MinProtocol\s*=\s*\S+(\s*.*)?\s*$"
    local Regex9="s/^(\s*)TLS.MinProtocol\s*=\s*\S+(\s*.*)?\s*$/TLS.MinProtocol = TLSv1.2\2/"
    local Regex10="^(\s*)TLS.MinProtocol\s*=\s*TLSv1.2?\s*$"
    local Regex11="^(\s*)#DTLS.MinProtocol\s*=\s*\S+(\s*.*)?\s*$"
    local Regex12="s/^(\s*)#DTLS.MinProtocol\s*=\s*\S+(\s*.*)?\s*$/DTLS.MinProtocol = DTLSv1.2\2/"
    local Regex13="^(\s*)DTLS.MinProtocol\s*=\s*\S+(\s*.*)?\s*$"
    local Regex14="s/^(\s*)DTLS.MinProtocol\s*=\s*\S+(\s*.*)?\s*$/DTLS.MinProtocol = DTLSv1.2\2/"
    local Regex15="^(\s*)DTLS.MinProtocol\s*=\s*DTLSv1.2?\s*$"
    local Success="Configured OpenSSL to use a minimum of TLSv1.2, per V-230255."
    local Failure="Failed to configure OpenSSL to use a minimum of TLSv1.2, not in compliance V-230255."

    echo

    CPVersion=$(rpm -q crypto-policies.noarch | grep -o "[0-9]\{8\}")

    if [[ "${CPVersion}" -lt "20210617" ]]; then
        ( (grep -E -q "${Regex1}" /etc/crypto-policies/back-ends/opensslcnf.config && sed -ri "${Regex2}" /etc/crypto-policies/back-ends/opensslcnf.config) || (grep -E -q "${Regex3}" /etc/crypto-policies/back-ends/opensslcnf.config && sed -ri "${Regex4}" /etc/crypto-policies/back-ends/opensslcnf.config)) || echo "MinProtocol = TLSv1.2" >>/etc/crypto-policies/back-ends/opensslcnf.config
        (grep -E -q "${Regex5}" /etc/crypto-policies/back-ends/opensslcnf.config && echo "${Success}") || {
            echo "${Failure}"
            exit 1
        }
    else
        ( (grep -E -q "${Regex6}" /etc/crypto-policies/back-ends/opensslcnf.config && sed -ri "${Regex7}" /etc/crypto-policies/back-ends/opensslcnf.config) || (grep -E -q "${Regex8}" /etc/crypto-policies/back-ends/opensslcnf.config && sed -ri "${Regex9}" /etc/crypto-policies/back-ends/opensslcnf.config)) || echo "TLS.MinProtocol = TLSv1.2" >>/etc/crypto-policies/back-ends/opensslcnf.config
        ( (grep -E -q "${Regex11}" /etc/crypto-policies/back-ends/opensslcnf.config && sed -ri "${Regex12}" /etc/crypto-policies/back-ends/opensslcnf.config) || (grep -E -q "${Regex13}" /etc/crypto-policies/back-ends/opensslcnf.config && sed -ri "${Regex14}" /etc/crypto-policies/back-ends/opensslcnf.config)) || echo "DTLS.MinProtocol = DTLSv1.2" >>/etc/crypto-policies/back-ends/opensslcnf.config
        ( (grep -E -q "${Regex10}" /etc/crypto-policies/back-ends/opensslcnf.config && grep -E -q "${Regex15}" /etc/crypto-policies/back-ends/opensslcnf.config) && echo "${Success}") || {
            echo "${Failure}"
            exit 1
        }
    fi
}

#Prevent the loading of a new kernel, V-230266
function V230266() {
    local Regex1="^(\s*)#kernel.kexec_load_disabled\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#kernel.kexec_load_disabled\s*=\s*\S+(\s*#.*)?\s*$/\1kernel.kexec_load_disabled = 1\2/"
    local Regex3="^(\s*)kernel.kexec_load_disabled\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)kernel.kexec_load_disabled\s*=\s*\S+(\s*#.*)?\s*$/\1kernel.kexec_load_disabled = 1\2/"
    local Regex5="^(\s*)kernel.kexec_load_disabled\s*=\s*1?\s*$"
    local Success="Prevented the loading of a new kernel, per V-230266."
    local Failure="Failed to prevent the loading of a new kernel, not in compliance V-230266."

    echo
    sysctl -w kernel.kexec_load_disabled=1 &>/dev/null
    ( (grep -E -q "${Regex1}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex2}" /etc/sysctl.d/99-sysctl.conf) || (grep -E -q "${Regex3}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex4}" /etc/sysctl.d/99-sysctl.conf)) || echo "kernel.kexec_load_disabled = 1" >>/etc/sysctl.d/99-sysctl.conf

    sysctl --quiet --system

    ( (grep -E -q "${Regex5}" /etc/sysctl.d/99-sysctl.conf && sysctl kernel.kexec_load_disabled | grep -E -q "${Regex5}") && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Enforce discretionary access control on symlinks, V-230267
function V230267() {
    local Regex1="^(\s*)#fs.protected_symlinks\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#fs.protected_symlinks\s*=\s*\S+(\s*#.*)?\s*$/\1fs.protected_symlinks = 1\2/"
    local Regex3="^(\s*)fs.protected_symlinks\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)fs.protected_symlinks\s*=\s*\S+(\s*#.*)?\s*$/\1fs.protected_symlinks = 1\2/"
    local Regex5="^(\s*)fs.protected_symlinks\s*=\s*1?\s*$"
    local Success="Enforced discretionary access control on symlinks, per V-230267."
    local Failure="Failed to enforce discretionary access control on symlinks, not in compliance V-230267."

    echo
    sysctl -w fs.protected_symlinks=1 &>/dev/null
    ( (grep -E -q "${Regex1}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex2}" /etc/sysctl.d/99-sysctl.conf) || (grep -E -q "${Regex3}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex4}" /etc/sysctl.d/99-sysctl.conf)) || echo "fs.protected_symlinks = 1" >>/etc/sysctl.d/99-sysctl.conf

    sysctl --quiet --system

    ( (grep -E -q "${Regex5}" /etc/sysctl.d/99-sysctl.conf && sysctl fs.protected_symlinks | grep -E -q "${Regex5}") && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Enforce discretionary access control on hardlinks, V-230268
function V230268() {
    local Regex1="^(\s*)#fs.protected_hardlinks\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#fs.protected_hardlinks\s*=\s*\S+(\s*#.*)?\s*$/\1fs.protected_hardlinks = 1\2/"
    local Regex3="^(\s*)fs.protected_hardlinks\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)fs.protected_hardlinks\s*=\s*\S+(\s*#.*)?\s*$/\1fs.protected_hardlinks = 1\2/"
    local Regex5="^(\s*)fs.protected_hardlinks\s*=\s*1?\s*$"
    local Success="Enforced discretionary access control on hardlinks, per V-230268."
    local Failure="Failed to enforce discretionary access control on hardlinks, not in compliance V-230268."

    echo
    sysctl -w fs.protected_hardlinks=1 &>/dev/null
    ( (grep -E -q "${Regex1}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex2}" /etc/sysctl.d/99-sysctl.conf) || (grep -E -q "${Regex3}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex4}" /etc/sysctl.d/99-sysctl.conf)) || echo "fs.protected_hardlinks = 1" >>/etc/sysctl.d/99-sysctl.conf

    sysctl --quiet --system

    ( (grep -E -q "${Regex5}" /etc/sysctl.d/99-sysctl.conf && sysctl fs.protected_hardlinks | grep -E -q "${Regex5}") && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Install openssl-pkcs11 if not already installed, V-230273
function V230273() {
    local Success="openssl-pkcs11 has been installed, per V-230273."
    local Failure="openssl-pkcs11 is not installed skipping, V-230273."

    echo
    if ! yum -q list installed openssl-pkcs11 &>/dev/null; then
        echo "${Failure}"
    else
        echo "${Success}"
    fi
}

#Set OCSP to check for multifactor auth, V-230274, multiple options org could use

#Install opensc if not already installed, V-230275
function V230275() {
    local Success="opensc has been installed, per V-230275."
    local Failure="opensc is not installed skipping, V-230275."

    echo
    if ! yum -q list installed opensc &>/dev/null; then
        echo "${Failure}"
    else
        echo "${Success}"
    fi
}

#Clear page allocator to prevent use-after-free attacks, V-230277
function V230277() {
    local Success="Clear page allocator set to prevent use-after-free attacks has been configured, per V-230277."
    local Failure="Failed to clear page allocator set to prevent use-after-free attacks has been configured, not in compliance with V-230277."

    echo
    grubby --update-kernel=ALL --args="page_poison=1"
    (grub2-editenv - list | grep -q "page_poison=1") && echo "${Success}" || {
        echo "${Failure}"
        exit 1
    }
}

#Disable virtual syscalls, V-230278
function V230278() {
    local Success="Disabled virtual syscalls has been configured, per V-230278."
    local Failure="Failed to disabled virtual syscalls, not in compliance with V-230278."

    echo
    grubby --update-kernel=ALL --args="vsyscall=none"
    (grub2-editenv - list | grep -q "vsyscall=none") && echo "${Success}" || {
        echo "${Failure}"
        exit 1
    }
}

#Clear SLUB/SLAB objects to prevent use-after-free attacks, V-230279
function V230279() {
    local Success="Clear SLUB/SLAB objects to prevent use-after-free attacks has been configured, per V-230279."
    local Failure="Failed to set to clear SLUB/SLAB objects to prevent use-after-free attacks, not in compliance with V-230279."

    echo
    grubby --update-kernel=ALL --args="slub_debug=P"
    (grub2-editenv - list | grep -q "slub_debug=P") && echo "${Success}" || {
        echo "${Failure}"
        exit 1
    }
}

#Set the OS to use virtual address space randomization, V-230280
function V230280() {
    local Regex1="^(\s*)#kernel.randomize_va_space\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#kernel.randomize_va_space\s*=\s*\S+(\s*#.*)?\s*$/\1kernel.randomize_va_space = 2\2/"
    local Regex3="^(\s*)kernel.randomize_va_space\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)kernel.randomize_va_space\s*=\s*\S+(\s*#.*)?\s*$/\1kernel.randomize_va_space = 2\2/"
    local Regex5="^(\s*)kernel.randomize_va_space\s*=\s*2?\s*$"
    local Success="Prevent kernel profiling by unpriviledged users, per V-230280."
    local Failure="Failed to prevent kernel profiling by unpriviledged users, not in compliance V-230280."

    echo
    sysctl -w kernel.randomize_va_space=2 &>/dev/null
    ( (grep -E -q "${Regex1}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex2}" /etc/sysctl.d/99-sysctl.conf) || (grep -E -q "${Regex3}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex4}" /etc/sysctl.d/99-sysctl.conf)) || echo "kernel.randomize_va_space = 2" >>/etc/sysctl.d/99-sysctl.conf

    sysctl --quiet --system

    ( (grep -E -q "${Regex5}" /etc/sysctl.d/99-sysctl.conf && sysctl kernel.randomize_va_space | grep -E -q "${Regex5}") && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set SELinux to use the targeted policy, V-230282
function V230282() {
    local Regex1="^(\s*)#SELINUXTYPE=\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#SELINUXTYPE=\S+(\s*#.*)?\s*$/SELINUXTYPE=targeted\2/"
    local Regex3="^(\s*)SELINUXTYPE=\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)SELINUXTYPE=\S+(\s*#.*)?\s*$/SELINUXTYPE=targeted\2/"
    local Regex5="^(\s*)SELINUXTYPE=targeted?\s*$"
    local Success="Set SELinux to use the targeted policy, per V-230282."
    local Failure="Failed to set SELinux to use the targeted policy, not in compliance V-230282."

    echo
    ( (grep -E -q "${Regex1}" /etc/selinux/config && sed -ri "${Regex2}" /etc/selinux/config) || (grep -E -q "${Regex3}" /etc/selinux/config && sed -ri "${Regex4}" /etc/selinux/config)) || echo "SELINUXTYPE=targeted" >>/etc/selinux/config
    (grep -E -q "${Regex5}" /etc/selinux/config && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set SSH to perform strict mode checking of home dir configuraiton files, V-230288
function V230288() {
    local Regex1="^(\s*)#StrictModes\s+\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#StrictModes\s+\S+(\s*#.*)?\s*$/\StrictModes yes\2/"
    local Regex3="^(\s*)StrictModes\s+\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)StrictModes\s+\S+(\s*#.*)?\s*$/\StrictModes yes\2/"
    local Regex5="^(\s*)StrictModes\s*yes?\s*$"
    local Success="Set SSH to perform strict mode checking of the home directory configuration files, per V-230288."
    local Failure="Failed to set SSH to perform strict mode checking of the home directory configuration files, not in compliance V-230288."

    echo
    ( (grep -E -q "${Regex1}" /etc/ssh/sshd_config && sed -ri "${Regex2}" /etc/ssh/sshd_config) || (grep -E -q "${Regex3}" /etc/ssh/sshd_config && sed -ri "${Regex4}" /etc/ssh/sshd_config)) || echo "StrictModes yes" >>/etc/ssh/sshd_config
    (grep -E -q "${Regex5}" /etc/ssh/sshd_config && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set SSH to only allow compression after successful authentication, V-230289
function V230289() {
    local Regex1="^(\s*)#Compression\s+\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#Compression\s+\S+(\s*#.*)?\s*$/\Compression no\2/"
    local Regex3="^(\s*)Compression\s+\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)Compression\s+\S+(\s*#.*)?\s*$/\Compression no\2/"
    local Regex5="^(\s*)Compression\s*no?\s*$"
    local Success="Set SSH to only allow compression after successful authentication, per V-230289."
    local Failure="Failed to set SSH to only allow compression after successful authentication, not in compliance V-230289."

    echo
    ( (grep -E -q "${Regex1}" /etc/ssh/sshd_config && sed -ri "${Regex2}" /etc/ssh/sshd_config) || (grep -E -q "${Regex3}" /etc/ssh/sshd_config && sed -ri "${Regex4}" /etc/ssh/sshd_config)) || echo "Compression no" >>/etc/ssh/sshd_config
    (grep -E -q "${Regex5}" /etc/ssh/sshd_config && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set to not allow authentication using known host, V-230290
function V230290 {
    local Regex1="^(\s*)#IgnoreUserKnownHosts\s+\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#IgnoreUserKnownHosts\s+\S+(\s*#.*)?\s*$/\IgnoreUserKnownHosts yes\2/"
    local Regex3="^(\s*)IgnoreUserKnownHosts\s+\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)IgnoreUserKnownHosts\s+\S+(\s*#.*)?\s*$/\IgnoreUserKnownHosts yes\2/"
    local Regex5="^(\s*)IgnoreUserKnownHosts\s*yes?\s*$"
    local Success="Set SSH to not allow authentication using known host authentication, per V-230290."
    local Failure="Failed to set SSH to not allow authentication using known host authentication, not in compliance V-230290."

    echo
    ( (grep -E -q "${Regex1}" /etc/ssh/sshd_config && sed -ri "${Regex2}" /etc/ssh/sshd_config) || (grep -E -q "${Regex3}" /etc/ssh/sshd_config && sed -ri "${Regex4}" /etc/ssh/sshd_config)) || echo "IgnoreUserKnownHosts yes" >>/etc/ssh/sshd_config
    (grep -E -q "${Regex5}" /etc/ssh/sshd_config && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set SSH to not allow KerberosAuthentication for authentication, V-230291
function V230291() {
    local Regex1="^(\s*)#KerberosAuthentication\s+\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#KerberosAuthentication\s+\S+(\s*#.*)?\s*$/\KerberosAuthentication no\2/"
    local Regex3="^(\s*)KerberosAuthentication\s+\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)KerberosAuthentication\s+\S+(\s*#.*)?\s*$/\KerberosAuthentication no\2/"
    local Regex5="^(\s*)KerberosAuthentication\s*no?\s*$"
    local Success="Set SSH to not allow KerberosAuthentication for authentication, per V-230291."
    local Failure="Failed to set SSH to not allow KerberosAuthentication for authentication, not in compliance V-230291."

    echo
    ( (grep -E -q "${Regex1}" /etc/ssh/sshd_config && sed -ri "${Regex2}" /etc/ssh/sshd_config) || (grep -E -q "${Regex3}" /etc/ssh/sshd_config && sed -ri "${Regex4}" /etc/ssh/sshd_config)) || echo "KerberosAuthentication no" >>/etc/ssh/sshd_config
    (grep -E -q "${Regex5}" /etc/ssh/sshd_config && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set SSH to prevent root logon, V-230296
function V230296() {
    local Regex1="^(\s*)#PermitRootLogin\s+\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#PermitRootLogin\s+\S+(\s*#.*)?\s*$/\PermitRootLogin no\2/"
    local Regex3="^(\s*)PermitRootLogin\s+\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)PermitRootLogin\s+\S+(\s*#.*)?\s*$/\PermitRootLogin no\2/"
    local Regex5="^(\s*)PermitRootLogin\s*no?\s*$"
    local Success="Set SSH to not allow connections from root, per V-230296."
    local Failure="Failed to set SSH to not allow connections from root, not in compliance V-230296."

    echo
    ( (grep -E -q "${Regex1}" /etc/ssh/sshd_config && sed -ri "${Regex2}" /etc/ssh/sshd_config) || (grep -E -q "${Regex3}" /etc/ssh/sshd_config && sed -ri "${Regex4}" /etc/ssh/sshd_config)) || echo "PermitRootLogin no" >>/etc/ssh/sshd_config
    (grep -E -q "${Regex5}" /etc/ssh/sshd_config && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set the rsyslog service is active, V-230298
function V230298() {
    local Success="Set the rsyslog service is active, per V-230298."
    local Failure="Failed to set the rsyslog service to active, not in compliance with V-230298."

    echo
    if systemctl is-active rsyslog.service | grep -E -q "active"; then
        systemctl enable rsyslog.service
        echo "${Success}"
    else
        systemctl start rsyslog.service
        systemctl enable rsyslog.service
        ( (systemctl is-active rsyslog.service | grep -E -q "active") && echo "${Success}") || {
            echo "${Failure}"
            exit 1
        }
    fi
}

#Disable kernel core dumps, V-230310
function V230310() {
    local Success="Set the kdump service to disabled, per V-230310."
    local Failure="Failed to set the kdump service to disabled, not in compliance with V-230310."
    local Notinstalled="The kdump service is not installed, compliant with V-230310."

    echo

    if ! systemctl list-unit-files --full -all | grep -E -q '^kdump.service '; then
        echo "${Notinstalled}"
    else
        if systemctl status kdump.service | grep -E -q "active"; then
            systemctl stop kdump.service &>/dev/null
            systemctl disable kdump.service &>/dev/null
        fi

        if systemctl status kdump.service | grep -E -q "failed"; then
            systemctl stop kdump.service &>/dev/null
            systemctl disable kdump.service &>/dev/null
        fi

        ( (systemctl status kdump.service | grep -E -q "disabled|dead") && echo "${Success}") || {
            echo "${Failure}"
            exit 1
        }
    fi
}

#Disable kernel.core_pattern, V-230311
function V230311() {
    local Regex1="^(\s*)#kernel.core_pattern\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#kernel.core_pattern\s*=\s*\S+(\s*#.*)?\s*$/\1kernel.core_pattern = |\/bin\/false\2/"
    local Regex3="^(\s*)kernel.core_pattern\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)kernel.core_pattern\s*=\s*\S+(\s*#.*)?\s*$/\1kernel.core_pattern = |\/bin\/false\2/"
    local Regex5="^(\s*)kernel.core_pattern\s*=\s*\|/bin/false?\s*$"
    local Success="Disabled the kernel.core_pattern, per V-230311."
    local Failure="Failed to disable the kernel.core_pattern, not in compliance V-230311."

    echo
    sysctl -w kernel.core_pattern="|/bin/false" &>/dev/null
    ( (grep -E -q "${Regex1}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex2}" /etc/sysctl.d/99-sysctl.conf) || (grep -E -q "${Regex3}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex4}" /etc/sysctl.d/99-sysctl.conf)) || echo "kernel.core_pattern = |/bin/false" >>/etc/sysctl.d/99-sysctl.conf

    sysctl --quiet --system

    ( (grep -E -q "${Regex5}" /etc/sysctl.d/99-sysctl.conf && sysctl kernel.core_pattern | grep -E -q "${Regex5}") && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Disable the acquiring, saving, and processing of core dumps, V-230312
function V230312() {
    local Success="Set systemd-coredump service to disabled, per V-230312"
    local Failure="Failed to set systemd-coredump to disabled, not in compliance with per V-230312"
    local Notinstalled="The systemd-coredump is not installed, compliant with V-230312."

    echo

    if ! systemctl list-unit-files --full -all | grep -E -q '^systemd-coredump.socket'; then
        echo "${Notinstalled}"
    else
        if systemctl status systemd-coredump.socket | grep -E -q "active"; then
            systemctl stop systemd-coredump.socket &>/dev/null
            systemctl disable systemd-coredump.socket &>/dev/null
            systemctl mask systemd-coredump.socket &>/dev/null
        fi

        if systemctl status systemd-coredump.socket | grep -E -q "failed"; then
            (systemctl status systemd-coredump.socket | grep -q "Loaded: masked" && echo "${Success}") || {
                echo "${Failure}"
                exit 1
            }
        else
            ( (systemctl status systemd-coredump.socket | grep -q "Loaded: masked" && systemctl status systemd-coredump.socket | grep -q "Active: inactive") && echo "${Success}") || {
                echo "${Failure}"
                exit 1
            }
        fi
    fi
}

#Set system to disable core dumps for all users, V-230313
function V230313() {
    local Regex1="^(\s*)#*\s*hard\s*core\s+\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#*\s*hard\s*core\s+\S+(\s*#.*)?\s*$/\* hard core 0\2/"
    local Regex3="^(\s*)\*\s*hard\s*core\s+\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)\*\s*hard\s*core\s+\S+(\s*#.*)?\s*$/\* hard core 0\2/"
    local Regex5="^(\s*)\*\s*hard\s*core\s*0?\s*$"
    local Success="Set system to disable core dumps for all users, per V-230313."
    local Failure="Failed to set system to disable core dumps for all users, not in compliance V-230313."

    echo
    ( (grep -E -q "${Regex1}" /etc/security/limits.conf && sed -ri "${Regex2}" /etc/security/limits.conf) || (grep -E -q "${Regex3}" /etc/security/limits.conf && sed -ri "${Regex4}" /etc/security/limits.conf)) || echo "* hard core 0" >>/etc/security/limits.conf
    (grep -E -q "${Regex5}" /etc/security/limits.conf && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set system to disable storing core dumps, V-230314
function V230314() {
    local Regex1="^(\s*)#Storage=\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#Storage=\S+(\s*#.*)?\s*$/Storage=none\2/"
    local Regex3="^(\s*)Storage=\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)Storage=\S+(\s*#.*)?\s*$/Storage=none\2/"
    local Regex5="^(\s*)Storage=none?\s*$"
    local Success="Set system to disable storing core dumps, per V-230314."
    local Failure="Failed to set system to disable storing core dumps, not in compliance V-230314."

    echo
    ( (grep -E -q "${Regex1}" /etc/systemd/coredump.conf && sed -ri "${Regex2}" /etc/systemd/coredump.conf) || (grep -E -q "${Regex3}" /etc/systemd/coredump.conf && sed -ri "${Regex4}" /etc/systemd/coredump.conf)) || echo "Storage=none" >>/etc/systemd/coredump.conf
    (grep -E -q "${Regex5}" /etc/systemd/coredump.conf && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set system to disable core dump backtraces, V-230315
function V230315() {
    local Regex1="^(\s*)#ProcessSizeMax=\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#ProcessSizeMax=\S+(\s*#.*)?\s*$/ProcessSizeMax=0\2/"
    local Regex3="^(\s*)ProcessSizeMax=\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)ProcessSizeMax=\S+(\s*#.*)?\s*$/ProcessSizeMax=0\2/"
    local Regex5="^(\s*)ProcessSizeMax=0?\s*$"
    local Success="Set system to disable core dump backtraces, per V-230315."
    local Failure="Failed to set system to disable core dump backtraces, not in compliance V-230315."

    echo
    ( (grep -E -q "${Regex1}" /etc/systemd/coredump.conf && sed -ri "${Regex2}" /etc/systemd/coredump.conf) || (grep -E -q "${Regex3}" /etc/systemd/coredump.conf && sed -ri "${Regex4}" /etc/systemd/coredump.conf)) || echo "ProcessSizeMax=0" >>/etc/systemd/coredump.conf
    (grep -E -q "${Regex5}" /etc/systemd/coredump.conf && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set system create a home directory on login, V-230324
function V230324() {
    local Regex1="^(\s*)CREATE_HOME\s+\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)CREATE_HOME\s+\S+(\s*#.*)?\s*$/\CREATE_HOME     yes\2/"
    local Regex3="^(\s*)CREATE_HOME\s*yes\s*$"
    local Success="Set system create a home directory on login, per V-230324."
    local Failure="Failed to set the system create a home directory on login, not in compliance with V-230324."

    echo
    (grep -E -q "${Regex1}" /etc/login.defs && sed -ri "${Regex2}" /etc/login.defs) || echo "CREATE_HOME     yes" >>/etc/login.defs
    (grep -E -q "${Regex3}" /etc/login.defs && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set system to not allow users to override SSH env variables, V-230330
function V230330() {
    local Regex1="^(\s*)#PermitUserEnvironment\s+\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#PermitUserEnvironment\s+\S+(\s*#.*)?\s*$/\PermitUserEnvironment no\2/"
    local Regex3="^(\s*)PermitUserEnvironment\s+\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)PermitUserEnvironment\s+\S+(\s*#.*)?\s*$/\PermitUserEnvironment no\2/"
    local Regex5="^(\s*)PermitUserEnvironment\s*no?\s*$"
    local Success="Set system to not allow users to override SSH env variables, per V-230330."
    local Failure="Failed to set system to not allow users to override SSH env variables, not in compliance V-230330."

    echo
    ( (grep -E -q "${Regex1}" /etc/ssh/sshd_config && sed -ri "${Regex2}" /etc/ssh/sshd_config) || (grep -E -q "${Regex3}" /etc/ssh/sshd_config && sed -ri "${Regex4}" /etc/ssh/sshd_config)) || echo "PermitUserEnvironment no" >>/etc/ssh/sshd_config
    (grep -E -q "${Regex5}" /etc/ssh/sshd_config && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set the system to lock accounts after 3 failed logon attemps within 15 mins, prevent system informaiton from being presented, and log the unsuccessful user names, V-230332, V-230334, V-230336, V-230338, V-230340, V-230342, V-230344
function V230332() {
    local Regex1="^\s*auth\s+required\s+pam_faillock.so\s*preauth\s*"
    local Regex2="s/^\s*auth\s+\s*\s*\s*required\s+pam_faillock.so\s*preauth\s*"
    local Regex3="auth        required                                     pam_faillock.so preauth dir=\/var\/log\/faillock silent audit deny=3 even_deny_root fail_interval=900 unlock_time=0"
    local Regex4="^\s*auth\s+required\s+pam_faillock.so\s*authfail\s*"
    local Regex5="s/^\s*auth\s+\s*\s*\s*required\s+pam_faillock.so\s*authfail\s*"
    local Regex6="auth        required                                     pam_faillock.so authfail dir=\/var\/log\/faillock unlock_time=0"
    local Regex7="^\s*account\s+required\s+pam_faillock.so\s*"
    local Regex8="s/^\s*account\s+\s*\s*\s*required\s+pam_faillock.so\s*"
    local Regex9="account     required                                     pam_faillock.so"
    local Regex10="^(\s*)auth\s+required\s+\s*pam_faillock.so\s*preauth\s*dir=/var/log/faillock\s*silent\s*audit\s*deny=3\s*even_deny_root\s*fail_interval=900\s*unlock_time=0\s*$"
    local Regex11="^(\s*)auth\s+required\s+\s*pam_faillock.so\s*authfail\s*dir=/var/log/faillock\s*unlock_time=0\s*$"
    local Regex12="^(\s*)account\s+required\s+\s*pam_faillock.so\s*$"
    local Success="Set the system to lock accounts after 3 failed logon attemps within 15 mins, prevent system informaiton from being presented, and log the unsuccessful user names. Setting per V-230332, V-230334, V-230336, V-230338, V-230340, V-230342, and V-230344."
    local Failure="Failed to set the system to lock accounts after 3 failed logon attemps within 15 mins, prevent system informaiton from being presented, and log the unsuccessful user names. Setting per V-230332, V-230334, V-230336, V-230338, V-230340, V-230342, and V-230344."

    echo
    (grep -E -q "${Regex1}" /etc/pam.d/system-auth && sed -ri "${Regex2}.*$/${Regex3}/" /etc/pam.d/system-auth) || echo "auth        required                                     pam_faillock.so preauth dir=/var/log/faillock silent audit deny=3 even_deny_root fail_interval=900 unlock_time=0" >>/etc/pam.d/system-auth
    (grep -E -q "${Regex1}" /etc/pam.d/password-auth && sed -ri "${Regex2}.*$/${Regex3}/" /etc/pam.d/password-auth) || echo "auth        required                                     pam_faillock.so preauth dir=/var/log/faillock silent audit deny=3 even_deny_root fail_interval=900 unlock_time=0" >>/etc/pam.d/password-auth
    (grep -E -q "${Regex4}" /etc/pam.d/system-auth && sed -ri "${Regex5}.*$/${Regex6}/" /etc/pam.d/system-auth) || echo "auth        required                                     pam_faillock.so authfail dir=/var/log/faillock unlock_time=0" >>/etc/pam.d/system-auth
    (grep -E -q "${Regex4}" /etc/pam.d/password-auth && sed -ri "${Regex5}.*$/${Regex6}/" /etc/pam.d/password-auth) || echo "auth        required                                     pam_faillock.so authfail dir=/var/log/faillock unlock_time=0" >>/etc/pam.d/password-auth
    (grep -E -q "${Regex7}" /etc/pam.d/system-auth && sed -ri "${Regex8}.*$/${Regex9}/" /etc/pam.d/system-auth) || echo "${Regex9}" >>/etc/pam.d/system-auth
    (grep -E -q "${Regex7}" /etc/pam.d/password-auth && sed -ri "${Regex8}.*$/${Regex9}/" /etc/pam.d/password-auth) || echo "${Regex9}" >>/etc/pam.d/password-auth

    ( (grep -E -q "${Regex10}" /etc/pam.d/password-auth && grep -E -q "${Regex10}" /etc/pam.d/system-auth)) || {
        echo "${Failure}"
        exit 1
    }
    ( (grep -E -q "${Regex11}" /etc/pam.d/password-auth && grep -E -q "${Regex11}" /etc/pam.d/system-auth)) || {
        echo "${Failure}"
        exit 1
    }
    ( (grep -E -q "${Regex12}" /etc/pam.d/password-auth && grep -E -q "${Regex12}" /etc/pam.d/system-auth) && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Configure System-auth and password-auth for RHEL 8.2+ as needed for V230333, 230335, 230337, 230339, 230341, 230343, 230345
function ConfigAuth() {
    local Regex1="^\s*auth\s+required\s+pam_faillock.so\s*preauth\s*"
    local Regex2="s/^\s*auth\s+\s*\s*\s*required\s+pam_faillock.so\s*preauth\s*"
    local Regex3="auth        required                                     pam_faillock.so preauth"
    local Regex4="^\s*auth\s+required\s+pam_faillock.so\s*authfail\s*"
    local Regex5="s/^\s*auth\s+\s*\s*\s*required\s+pam_faillock.so\s*authfail\s*"
    local Regex6="auth        required                                     pam_faillock.so authfail"
    local Regex7="^\s*account\s+required\s+pam_faillock.so\s*"
    local Regex8="s/^\s*account\s+\s*\s*\s*required\s+pam_faillock.so\s*"
    local Regex9="account     required                                     pam_faillock.so"
    local Regex10="^(\s*)auth\s+required\s+\s*pam_faillock.so\s*preauth\s*$"
    local Regex11="^(\s*)auth\s+required\s+\s*pam_faillock.so\s*authfail\s*$"
    local Regex12="^(\s*)account\s+required\s+\s*pam_faillock.so\s*$"
    local Success="System-Auth and password-auth are configured properly. Set per $1."
    local Failure="Failed to configure system-auth and password-auth are configured properly. Set per $1."

    echo
    (grep -E -q "${Regex1}" /etc/pam.d/system-auth && sed -ri "${Regex2}.*$/${Regex3}/" /etc/pam.d/system-auth) || (echo "" >>/etc/pam.d/system-auth && echo "${Regex3}" >>/etc/pam.d/system-auth)
    (grep -E -q "${Regex1}" /etc/pam.d/password-auth && sed -ri "${Regex2}.*$/${Regex3}/" /etc/pam.d/password-auth) || (echo "" >>/etc/pam.d/password-auth && echo "${Regex3}" >>/etc/pam.d/password-auth)
    (grep -E -q "${Regex4}" /etc/pam.d/system-auth && sed -ri "${Regex5}.*$/${Regex6}/" /etc/pam.d/system-auth) || echo "${Regex6}" >>/etc/pam.d/system-auth
    (grep -E -q "${Regex4}" /etc/pam.d/password-auth && sed -ri "${Regex5}.*$/${Regex6}/" /etc/pam.d/password-auth) || echo "${Regex6}" >>/etc/pam.d/password-auth
    (grep -E -q "${Regex7}" /etc/pam.d/system-auth && sed -ri "${Regex8}.*$/${Regex9}/" /etc/pam.d/system-auth) || (echo "" >>/etc/pam.d/system-auth && echo "${Regex9}" >>/etc/pam.d/system-auth)
    (grep -E -q "${Regex7}" /etc/pam.d/password-auth && sed -ri "${Regex8}.*$/${Regex9}/" /etc/pam.d/password-auth) || (echo "" >>/etc/pam.d/password-auth && echo "${Regex9}" >>/etc/pam.d/password-auth)

    ( (grep -E -q "${Regex10}" /etc/pam.d/password-auth && grep -E -q "${Regex10}" /etc/pam.d/system-auth)) || {
        echo "${Failure}"
        exit 1
    }
    ( (grep -E -q "${Regex11}" /etc/pam.d/password-auth && grep -E -q "${Regex11}" /etc/pam.d/system-auth)) || {
        echo "${Failure}"
        exit 1
    }
    ( (grep -E -q "${Regex12}" /etc/pam.d/password-auth && grep -E -q "${Regex12}" /etc/pam.d/system-auth) && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set to lock after 3 unsuccessful logon attempts, V-230333
function V230333() {
    local VulID="V-230333"
    local Regex1="^(\s*)#\s*deny\s*=\s*\s+\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#\s*deny\s*=\s+\S+(\s*#.*)?\s*$/\deny = 3\2/"
    local Regex3="^(\s*)deny\s*=\s*\s+\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)deny\s*=\s+\S+(\s*#.*)?\s*$/\deny = 3\2/"
    local Regex5="^(\s*)deny\s*=\s*3\s*$"

    local Success="System is set to lock accounts after three unsuccessful logon attempts, per ${VulID}."
    local Failure="Failed to set system to lock accounts after three unsuccessful logon attempts, not in compliance ${VulID}."

    ConfigAuth "${VulID}"
    echo
    ( (grep -E -q "${Regex1}" /etc/security/faillock.conf && sed -ri "${Regex2}" /etc/security/faillock.conf) || (grep -E -q "${Regex3}" /etc/security/faillock.conf && sed -ri "${Regex4}" /etc/security/faillock.conf)) || echo "deny = 3" >>/etc/security/faillock.conf
    (grep -E -q "${Regex5}" /etc/security/faillock.conf && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set to automatically lock an account after three logon attempts within 15 minutes, V-230335
function V230335() {
    local VulID="V-230335"
    local Regex1="^(\s*)#\s*fail_interval\s*=\s*\s+\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#\s*fail_interval\s*=\s+\S+(\s*#.*)?\s*$/fail_interval = 900\2/"
    local Regex3="^(\s*)fail_interval\s*=\s*\s+\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)fail_interval\s*=\s+\S+(\s*#.*)?\s*$/fail_interval = 900\2/"
    local Regex5="^(\s*)fail_interval\s*=\s*900\s*$"

    local Success="System is set to automatically lock an account after three logon attempts within 15 minutes, per ${VulID}."
    local Failure="Failed to set system to automatically lock an account after three logon attempts within 15 minutes, not in compliance ${VulID}."

    ConfigAuth "${VulID}"
    echo
    ( (grep -E -q "${Regex1}" /etc/security/faillock.conf && sed -ri "${Regex2}" /etc/security/faillock.conf) || (grep -E -q "${Regex3}" /etc/security/faillock.conf && sed -ri "${Regex4}" /etc/security/faillock.conf)) || echo "fail_interval = 900" >>/etc/security/faillock.conf
    (grep -E -q "${Regex5}" /etc/security/faillock.conf && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set to lock an account until the locked account is released by an admin, V-230337
function V230337() {
    local VulID="V-230337"
    local Regex1="^(\s*)#\s*unlock_time\s*=\s*\s+\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#\s*unlock_time\s*=\s+\S+(\s*#.*)?\s*$/unlock_time = 0\2/"
    local Regex3="^(\s*)unlock_time\s*=\s*\s+\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)unlock_time\s*=\s+\S+(\s*#.*)?\s*$/unlock_time = 0\2/"
    local Regex5="^(\s*)unlock_time\s*=\s*0\s*$"

    local Success="System is set to lock an account until the locked account is released by an admin, per ${VulID}."
    local Failure="Failed to set system to lock an account until the locked account is released by an admin, not in compliance ${VulID}."

    ConfigAuth "${VulID}"
    echo
    ( (grep -E -q "${Regex1}" /etc/security/faillock.conf && sed -ri "${Regex2}" /etc/security/faillock.conf) || (grep -E -q "${Regex3}" /etc/security/faillock.conf && sed -ri "${Regex4}" /etc/security/faillock.conf)) || echo "unlock_time = 0" >>/etc/security/faillock.conf
    (grep -E -q "${Regex5}" /etc/security/faillock.conf && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set to ensure account lockouts persist, V-230339
function V230339() {
    local VulID="V-230339"
    local Regex1="^(\s*)#\s*dir\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#\s*dir\s*=\s*\S+(\s*#.*)?\s*$/dir = \/var\/log\/faillock\2/"
    local Regex3="^(\s*)dir\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)dir\s*=\s*\S+(\s*#.*)?\s*$/dir = \/var\/log\/faillock\2/"
    local Regex5="^(\s*)dir\s*=\s*\/var\/log\/faillock\s*$"

    local Success="System is set to ensure account lockouts persist, per ${VulID}."
    local Failure="Failed to set system to ensure account lockouts persist, not in compliance ${VulID}."

    ConfigAuth "${VulID}"
    echo
    ( (grep -E -q "${Regex1}" /etc/security/faillock.conf && sed -ri "${Regex2}" /etc/security/faillock.conf) || (grep -E -q "${Regex3}" /etc/security/faillock.conf && sed -ri "${Regex4}" /etc/security/faillock.conf)) || echo "unlock_time = 0" >>/etc/security/faillock.conf
    (grep -E -q "${Regex5}" /etc/security/faillock.conf && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set to prevent system messages from being presented when three unsuccessful logon attempts occur, V-230341
function V230341() {
    local VulID="V-230341"
    local Regex1="^(\s*)#\s*silent\s*(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#\s*silent\s*(\s*#.*)?\s*$/silent\2/"
    local Regex3="^(\s*)silent\s*$"

    local Success="System is set to prevent system messages from being presented when three unsuccessful logon attempts occur, per ${VulID}."
    local Failure="Failed to set system to prevent system messages from being presented when three unsuccessful logon attempts occur, not in compliance ${VulID}."

    ConfigAuth "${VulID}"
    echo
    (grep -E -q "${Regex1}" /etc/security/faillock.conf && sed -ri "${Regex2}" /etc/security/faillock.conf) || grep -E -q "${Regex3}" /etc/security/faillock.conf || echo "silent" >>/etc/security/faillock.conf
    (grep -E -q "${Regex4}" /etc/security/faillock.conf && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set to log user name information when unsuccesful logon attempts occur, V-230343
function V230343() {
    local VulID="V-230343"
    local Regex1="^(\s*)#\s*audit\s*(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#\s*audit\s*(\s*#.*)?\s*$/audit\2/"
    local Regex3="^(\s*)audit\s*$"

    local Success="System is set to log user name information when unsuccesful logon attempts occur, per ${VulID}."
    local Failure="Failed to set system to log user name information when unsuccesful logon attempts occur, not in compliance ${VulID}."

    ConfigAuth "${VulID}"
    echo
    (grep -E -q "${Regex1}" /etc/security/faillock.conf && sed -ri "${Regex2}" /etc/security/faillock.conf) || grep -E -q "${Regex3}" /etc/security/faillock.conf || echo "audit" >>/etc/security/faillock.conf
    (grep -E -q "${Regex4}" /etc/security/faillock.conf && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set to include root when automatically locking an account until the locked account is released by an administrator, V-230345
function V230345() {
    local VulID="V-230345"
    local Regex1="^(\s*)#\s*even_deny_root\s*(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#\s*even_deny_root\s*(\s*#.*)?\s*$/even_deny_root\2/"
    local Regex3="^(\s*)even_deny_root\s*$"

    local Success="System is set to include root when automatically locking an account until the locked account is released by an administrator, per ${VulID}."
    local Failure="Failed to set system to include root when automatically locking an account until the locked account is released by an administrator, not in compliance ${VulID}."

    ConfigAuth "${VulID}"
    echo
    (grep -E -q "${Regex1}" /etc/security/faillock.conf && sed -ri "${Regex2}" /etc/security/faillock.conf) || grep -E -q "${Regex3}" /etc/security/faillock.conf || echo "even_deny_root" >>/etc/security/faillock.conf
    (grep -E -q "${Regex4}" /etc/security/faillock.conf && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Verify tmux is installed and enables the user to initiate a session lock command, V-230348 and V-244537
function V230348() {
    local Regex1="^(\s*)#set\s*-g\s*lock-command\s*\S+"
    local Regex2="s/^(\s*)#\s*set\s*-g\s*lock-command\s*\S+.*/set -g lock-command vlock/"
    local Regex3="^(\s*)set\s*-g\s*lock-command\s*\S+"
    local Regex4="s/^(\s*)set\s*-g\s*lock-command\s*\S+.*/set -g lock-command vlock/"
    local Regex5="^set\s*-g\s*lock-command\s*vlock\s*$"
    local Success="tmux is installed and users are able to initiate session lock on command, per V-230348 and V-244537."
    local Failure="Failed to install tmux and users are able to initiate session lock on command, not in compliance with V-230348 and V-244537."

    echo
    if [ -f "/etc/tmux.conf" ]; then
        ( (grep -E -q "${Regex1}" /etc/tmux.conf && sed -ri "${Regex2}" /etc/tmux.conf) || (grep -E -q "${Regex3}" /etc/tmux.conf && sed -ri "${Regex4}" /etc/tmux.conf)) || echo "set -g lock-command vlock" >>/etc/tmux.conf
    else
        echo "set -g lock-command vlock" >>/etc/tmux.conf
    fi

    (grep -E -q "${Regex5}" /etc/tmux.conf && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Ensure session control is automatically started at shell initialization, V-230349, needs rework
function V230349() {
    local Regex1="^(\s*)\[\s*-n\s*\"\\\$PS1\"\s*-a\s*-z\s*\"\\\$TMUX\"\s*\]\s*\&\&\s*exec\s*tmux\s*$"
    local Success="Ensured session control is automatically started at shell initialization, per V-230349."
    local Failure="Failed to ensure session control is automatically started at shell initialization, not in compliance with V-230349."

    echo
    grep -E -q "${Regex1}" /etc/bashrc || echo "[ -n \"\$PS1\" -a -z \"\$TMUX\" ] && exec tmux" >>/etc/bashrc
    (grep -E -q "${Regex1}" /etc/bashrc && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set CaC removal action to lock-screen, V-230351

#Set timeout to 900 sec, V-230353
function V230353() {
    local Regex1="^(\s*)#set\s*-g\s*lock-after-time\s*\S+"
    local Regex2="s/^(\s*)#\s*set\s*-g\s*lock-after-time\s*\S+.*/set -g lock-after-time 900/"
    local Regex3="^(\s*)set\s*-g\s*lock-after-time\s*\S+"
    local Regex4="s/^(\s*)set\s*-g\s*lock-after-time\s*\S+.*/set -g lock-after-time 900/"
    local Regex5="^set\s*-g\s*lock-after-time\s*900\s*$"
    local Success="tmux is installed and set terminal timeout period to 900 secs, per V-230353."
    local Failure="Failed to install tmux and set terminal timeout period to 900 secs, not in compliance V-230353."

    echo

    if [ -f "/etc/tmux.conf" ]; then
        ( (grep -E -q "${Regex1}" /etc/tmux.conf && sed -ri "${Regex2}" /etc/tmux.conf) || (grep -E -q "${Regex3}" /etc/tmux.conf && sed -ri "${Regex4}" /etc/tmux.conf)) || echo "set -g lock-after-time 900" >>/etc/tmux.conf
    else
        echo "set -g lock-after-time 900" >>/etc/tmux.conf
    fi

    (grep -E -q "${Regex5}" /etc/tmux.conf && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set system password complexity module is enabled in the password-auth file, V-230356
function V230356() {
    local Regex1="^(\s*)password\s+required\s+\s*pam_pwquality.so\s*$"
    local Success="Set system password complexity module is enabled in the password-auth file, per V-230356."
    local Failure="Failed to set the system password complexity module is enabled in the password-auth file, not in compliance V-230356."

    echo
    grep -E -q "${Regex1}" /etc/pam.d/password-auth || echo "password    required                                     pam_pwquality.so" >>/etc/pam.d/password-auth
    (grep -E -q "${Regex1}" /etc/pam.d/password-auth && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set passwords to require a number of uppercase characters, V-230357
function V230357() {
    local Regex1="^(\s*)#\s*ucredit\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#\s*ucredit\s*=\s*\S+(\s*#.*)?\s*$/ucredit = -1\2/"
    local Regex3="^(\s*)ucredit\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)ucredit\s*=\s*\S+(\s*#.*)?\s*$/ucredit = -1\2/"
    local Regex5="^(\s*)ucredit\s*=\s*-1\s*$"
    local Success="Password is set to require a number of uppercase characters, per V-230357"
    local Failure="Password isn't set to require a number of uppercase characters, not in compliance with V-230357."

    echo
    ( (grep -E -q "${Regex1}" /etc/security/pwquality.conf && sed -ri "${Regex2}" /etc/security/pwquality.conf) || (grep -E -q "${Regex3}" /etc/security/pwquality.conf && sed -ri "${Regex4}" /etc/security/pwquality.conf)) || echo "ucredit = -1" >>/etc/security/pwquality.conf
    (grep -E -q "${Regex5}" /etc/security/pwquality.conf && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set password to require a number of lowercase characters, V-230358
function V230358() {
    local Regex1="^(\s*)#\s*lcredit\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#\s*lcredit\s*=\s*\S+(\s*#.*)?\s*$/lcredit = -1\2/"
    local Regex3="^(\s*)lcredit\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)lcredit\s*=\s*\S+(\s*#.*)?\s*$/lcredit = -1\2/"
    local Regex5="^(\s*)lcredit\s*=\s*-1\s*$"
    local Success="Password is set to require a number of lowercase characters, per V-230358"
    local Failure="Password isn't set to require a number of lowercase characters, not in compliance with V-230358."

    echo
    ( (grep -E -q "${Regex1}" /etc/security/pwquality.conf && sed -ri "${Regex2}" /etc/security/pwquality.conf) || (grep -E -q "${Regex3}" /etc/security/pwquality.conf && sed -ri "${Regex4}" /etc/security/pwquality.conf)) || echo "ucredit = -1" >>/etc/security/pwquality.conf
    (grep -E -q "${Regex5}" /etc/security/pwquality.conf && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set password to require a number of numerical characters, V-230359
function V230359() {
    local Regex1="^(\s*)#\s*dcredit\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#\s*dcredit\s*=\s*\S+(\s*#.*)?\s*$/dcredit = -1\2/"
    local Regex3="^(\s*)dcredit\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)dcredit\s*=\s*\S+(\s*#.*)?\s*$/dcredit = -1\2/"
    local Regex5="^(\s*)dcredit\s*=\s*-1\s*$"
    local Success="Password is set to require a number of numerical characters, per V-230359"
    local Failure="Password isn't set to require a number of numerical characters, not in compliance with V-230359."

    echo
    ( (grep -E -q "${Regex1}" /etc/security/pwquality.conf && sed -ri "${Regex2}" /etc/security/pwquality.conf) || (grep -E -q "${Regex3}" /etc/security/pwquality.conf && sed -ri "${Regex4}" /etc/security/pwquality.conf)) || echo "ucredit = -1" >>/etc/security/pwquality.conf
    (grep -E -q "${Regex5}" /etc/security/pwquality.conf && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set max number of characters of the same class that can repeat, V-230360
function V230360() {
    local Regex1="^(\s*)#\s*maxclassrepeat\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#\s*maxclassrepeat\s*=\s*\S+(\s*#.*)?\s*$/\maxclassrepeat = 4\2/"
    local Regex3="^(\s*)maxclassrepeat\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)maxclassrepeat\s*=\s*\S+(\s*#.*)?\s*$/\maxclassrepeat = 4\2/"
    local Regex5="^(\s*)maxclassrepeat\s*=\s*4\s*$"
    local Success="Passwords are set to only allow 4 characters of the same class to repeat in a new password, per V-230360."
    local Failure="Failed to set passwords only allow 4 repeat characters of the same class in a new password, not in compliance with V-230360."

    echo
    ( (grep -E -q "${Regex1}" /etc/security/pwquality.conf && sed -ri "${Regex2}" /etc/security/pwquality.conf) || (grep -E -q "${Regex3}" /etc/security/pwquality.conf && sed -ri "${Regex4}" /etc/security/pwquality.conf)) || echo "maxclassrepeat = 4" >>/etc/security/pwquality.conf
    (grep -E -q "${Regex5}" /etc/security/pwquality.conf && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set max number of characters that can repeat, V-230361
function V230361() {
    local Regex1="^(\s*)#\s*maxrepeat\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#\s*maxrepeat\s*=\s*\S+(\s*#.*)?\s*$/\maxrepeat = 3\2/"
    local Regex3="^(\s*)maxrepeat\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)maxrepeat\s*=\s*\S+(\s*#.*)?\s*$/\maxrepeat = 3\2/"
    local Regex5="^(\s*)maxrepeat\s*=\s*3\s*$"
    local Success="Passwords are set to only allow 3 repeat characters in a new password, per V-230361."
    local Failure="Failed to set passwords to only allow 3 repeat characters in a new password, not in compliance with V-230361."

    echo
    ( (grep -E -q "${Regex1}" /etc/security/pwquality.conf && sed -ri "${Regex2}" /etc/security/pwquality.conf) || (grep -E -q "${Regex3}" /etc/security/pwquality.conf && sed -ri "${Regex4}" /etc/security/pwquality.conf)) || echo "maxrepeat = 3" >>/etc/security/pwquality.conf
    (grep -E -q "${Regex5}" /etc/security/pwquality.conf && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set min required classes of characters for a new password, V-230362
function V230362() {
    local Regex1="^(\s*)#\s*minclass\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#\s*minclass\s*=\s*\S+(\s*#.*)?\s*$/\minclass = 4\2/"
    local Regex3="^(\s*)minclass\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)minclass\s*=\s*\S+(\s*#.*)?\s*$/\minclass = 4\2/"
    local Regex5="^(\s*)minclass\s*=\s*4\s*$"
    local Success="Password set to use a min number of 4 character classes in a new password, per V-230362."
    local Failure="Failed to set password to use a min number of 4 character classes in a new password, not in compliance with V-230362."

    echo
    ( (grep -E -q "${Regex1}" /etc/security/pwquality.conf && sed -ri "${Regex2}" /etc/security/pwquality.conf) || (grep -E -q "${Regex3}" /etc/security/pwquality.conf && sed -ri "${Regex4}" /etc/security/pwquality.conf)) || echo "minclass = 4" >>/etc/security/pwquality.conf
    (grep -E -q "${Regex5}" /etc/security/pwquality.conf && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set min number of characters changed from old password, V-230363
function V230363() {
    local Regex1="^(\s*)#\s*difok\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#\s*difok\s*=\s*\S+(\s*#.*)?\s*$/\difok = 8\2/"
    local Regex3="^(\s*)difok\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)difok\s*=\s*\S+(\s*#.*)?\s*$/\difok = 8\2/"
    local Regex5="^(\s*)difok\s*=\s*8\s*$"
    local Success="Set so a min number of 8 characters are changed from the old password, per V-230363"
    local Failure="Failed to set the password to use a min number of 8 characters are changed from the old password, not in compliance with V-230363"

    echo
    ( (grep -E -q "${Regex1}" /etc/security/pwquality.conf && sed -ri "${Regex2}" /etc/security/pwquality.conf) || (grep -E -q "${Regex3}" /etc/security/pwquality.conf && sed -ri "${Regex4}" /etc/security/pwquality.conf)) || echo "difok = 8" >>/etc/security/pwquality.conf
    (grep -E -q "${Regex5}" /etc/security/pwquality.conf && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set password min lifetome to 1 day, V-230365
function V230365() {
    local Regex1="^(\s*)PASS_MIN_DAYS\s+\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)PASS_MIN_DAYS\s+\S+(\s*#.*)?\s*$/\PASS_MIN_DAYS 1\2/"
    local Regex3="^(\s*)PASS_MIN_DAYS\s*1\s*$"
    local Success="Passwords are set to have a minimum lifetime of 1 day, per V-230365."
    local Failure="Failed to set passwords to have a minimum lifetime of 1 day, not in compliance with V-230365."

    echo
    (grep -E -q "${Regex1}" /etc/login.defs && sed -ri "${Regex2}" /etc/login.defs) || echo "PASS_MIN_DAYS 1" >>/etc/login.defs
    getent passwd | cut -d ':' -f 1 | xargs -n1 chage --mindays 1
    (grep -E -q "${Regex3}" /etc/login.defs && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set password max lifetime to 60 days, V-230366, disabled due to able to break some build automaiton.
function V230366() {
    local Regex1="^(\s*)PASS_MAX_DAYS\s+\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)PASS_MAX_DAYS\s+\S+(\s*#.*)?\s*$/\PASS_MAX_DAYS 60\2/"
    local Regex3="^(\s*)PASS_MAX_DAYS\s*60\s*$"
    local Success="Passwords are set to have a maximum lifetime to 60 days, per V-230366."
    local Failure="Failed to set passwords to have a maximum lifetime to 60 days, not in compliance with V-230366."

    echo
    grep -E -q "${Regex1}" /etc/login.defs && sed -ri "${Regex2}" /etc/login.defs || echo "PASS_MAX_DAYS 60" >>/etc/login.defs
    getent passwd | cut -d ':' -f 1 | xargs -n1 chage --maxdays 60
    grep -E -q "${Regex3}" /etc/login.defs && echo "${Success}" || {
        echo "${Failure}"
        exit 1
    }
}

#Limit password reuse to 5 in the password-auth file, V-230368
function V230368() {
    local Regex1="^\s*password\s+required\s+\s*pam_pwhistory.so\s*use_authtok\s*remember=\S+(\s*#.*)?(\s+.*)$"
    local Regex2="s/^(\s*)password\s+required\s+\s*pam_pwhistory.so\s*use_authtok\s*remember=\S+(\s*#.*)\s*retry=\S+(\s*#.*)?\s*S/\password\s+required\s+\s*pam_pwhistory.so\s*use_authtok\s*remember=5\s*retry=3\2/"
    local Regex3="^(\s*)password\s+required\s+\s*pam_pwhistory.so\s*use_authtok\s*remember=5\s*retry=3\s*$"
    local Success="System is set to keep password history of the last 5 passwords in the password-auth file, per V-230368."
    local Failure="Failed to set the system to keep password history of the last 5 passwords in the password-auth file, not in compliance with V-230368."

    echo
    (grep -E -q "${Regex1}" /etc/pam.d/password-auth && sed -ri "${Regex2}" /etc/pam.d/password-auth) || echo "password    required                                    pam_pwhistory.so use_authtok remember=5 retry=3" >>/etc/pam.d/password-auth
    (grep -E -q "${Regex3}" /etc/pam.d/password-auth && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set min 15 character password length, V-230369
function V230369() {
    local Regex1="^(\s*)#\s*minlen\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#\s*minlen\s*=\s*\S+(\s*#.*)?\s*$/\minlen = 15\2/"
    local Regex3="^(\s*)minlen\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)minlen\s*=\s*\S+(\s*#.*)?\s*$/\minlen = 15\2/"
    local Regex5="^(\s*)minlen\s*=\s*15\s*$"
    local Success="Passwords are set to have a min of 15 characters, per V-230369."
    local Failure="Failed to set passwords to use a min of 15 characters, not in compliance with V-230369."

    echo
    ( (grep -E -q "${Regex1}" /etc/security/pwquality.conf && sed -ri "${Regex2}" /etc/security/pwquality.conf) || (grep -E -q "${Regex3}" /etc/security/pwquality.conf && sed -ri "${Regex4}" /etc/security/pwquality.conf)) || echo "crypt_style = sha512" >>/etc/security/pwquality.conf
    (grep -E -q "${Regex5}" /etc/security/pwquality.conf && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set password minimum length to 15 characters, V-230370, disabled due to able to break some build automaiton.
function V230370() {
    local Regex1="^(\s*)PASS_MIN_LEN\s+\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)PASS_MIN_LEN\s+\S+(\s*#.*)?\s*$/\PASS_MIN_LEN 15\2/"
    local Regex3="^(\s*)PASS_MIN_LEN\s*15\s*$"
    local Success="Passwords are set to use a minimum length to 15 characters, per V-230370."
    local Failure="Failed to set passwords to use a minimum length to 15 characters, not in compliance with V-230370."

    echo
    grep -E -q "${Regex1}" /etc/login.defs && sed -ri "${Regex2}" /etc/login.defs || echo "PASS_MIN_LEN 15" >>/etc/login.defs
    grep -E -q "${Regex3}" /etc/login.defs && echo "${Success}" || {
        echo "${Failure}"
        exit 1
    }
}

#Set password to require a number of special characters, V-230375
function V230375() {
    local Regex1="^(\s*)#\s*ocredit\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#\s*ocredit\s*=\s*\S+(\s*#.*)?\s*$/ocredit = -1\2/"
    local Regex3="^(\s*)ocredit\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)ocredit\s*=\s*\S+(\s*#.*)?\s*$/ocredit = -1\2/"
    local Regex5="^(\s*)ocredit\s*=\s*-1\s*$"
    local Success="Password is set to require a number of special characters, per V-230375"
    local Failure="Password isn't set to require a number of special characters, not in compliance with V-230375."

    echo
    ( (grep -E -q "${Regex1}" /etc/security/pwquality.conf && sed -ri "${Regex2}" /etc/security/pwquality.conf) || (grep -E -q "${Regex3}" /etc/security/pwquality.conf && sed -ri "${Regex4}" /etc/security/pwquality.conf)) || echo "ucredit = -1" >>/etc/security/pwquality.conf
    (grep -E -q "${Regex5}" /etc/security/pwquality.conf && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Prevent the use of dictonary words in passwords, V-230377
function V230377() {
    local Regex1="^(\s*)#\s*dictcheck\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#\s*dictcheck\s*=\s*\S+(\s*#.*)?\s*$/\dictcheck = 1\2/"
    local Regex3="^(\s*)dictcheck\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)dictcheck\s*=\s*\S+(\s*#.*)?\s*$/\dictcheck = 1\2/"
    local Regex5="^(\s*)dictcheck\s*=\s*1\s*$"
    local Success="System is set to prevent the use of dictonary words in a new password, per V-230377."
    local Failure="Failed to set the system to prevent the use of dictonary words in a new password, not in compliance with V-230377."

    echo
    ( (grep -E -q "${Regex1}" /etc/security/pwquality.conf && sed -ri "${Regex2}" /etc/security/pwquality.conf) || (grep -E -q "${Regex3}" /etc/security/pwquality.conf && sed -ri "${Regex4}" /etc/security/pwquality.conf)) || echo "dictcheck = 1" >>/etc/security/pwquality.conf
    (grep -E -q "${Regex5}" /etc/security/pwquality.conf && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set delay between failed logon attenpts, V-230378
function V230378() {
    local Regex1="^(\s*)FAIL_DELAY\s+\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)FAIL_DELAY\s+\S+(\s*#.*)?\s*$/\FAIL_DELAY 4\2/"
    local Regex3="^(\s*)FAIL_DELAY\s*4\s*$"
    local Success="Set a 4 sec delay between failed logon attempts, per V-230378."
    local Failure="Failed to set a 4 sec delay between failed logon attempts, not in compliance with V-230378."

    echo
    (grep -E -q "${Regex1}" /etc/login.defs && sed -ri "${Regex2}" /etc/login.defs) || echo "FAIL_DELAY 4" >>/etc/login.defs
    (grep -E -q "${Regex3}" /etc/login.defs && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set to provide feedback on last account access, V-230382
function V230382() {
    local Regex1="^(\s*)#PrintLastLog\s+\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#PrintLastLog\s+\S+(\s*#.*)?\s*$/\PrintLastLog yes\2/"
    local Regex3="^(\s*)PrintLastLog\s+\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)PrintLastLog\s+\S+(\s*#.*)?\s*$/\PrintLastLog yes\2/"
    local Regex5="^(\s*)PrintLastLog\s*yes?\s*$"
    local Success="Set SSH to inform users of when the last time their account connected, per V-230382."
    local Failure="Failed to set SSH to inform users of when the last time their account connected, not in compliance V-230382."

    echo
    ( (grep -E -q "${Regex1}" /etc/ssh/sshd_config && sed -ri "${Regex2}" /etc/ssh/sshd_config) || (grep -E -q "${Regex3}" /etc/ssh/sshd_config && sed -ri "${Regex4}" /etc/ssh/sshd_config)) || echo "PrintLastLog yes" >>/etc/ssh/sshd_config
    (grep -E -q "${Regex5}" /etc/ssh/sshd_config && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set system to apply the most restricted default permissions for all authenticated users, V-230383
function V230383() {
    local Regex1="^(\s*)UMASK\s+\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)UMASK\s+\S+(\s*#.*)?\s*$/\1UMASK           077\2/"
    local Regex3="^(\s*)UMASK\s*077\s*$"
    local Success="Set system to apply the most restricted default permissions for all authenticated users, per V-230383."
    local Failure="Failed to set the system to apply the most restricted default permissions for all authenticated users, not in compliance with V-230383."

    echo
    (grep -E -q "${Regex1}" /etc/login.defs && sed -ri "${Regex2}" /etc/login.defs) || echo "UMASK           077" >>/etc/login.defs
    (grep -E -q "${Regex3}" /etc/login.defs && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set audit to audit of successful/unsuccessful attempts to use execve, V-230386
function V230386() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+arch=b32\s+-S\s+execve\s+-C\s+uid!=euid\s+-F\s+euid=0\s+-k\s+execpriv\s*(#.*)?$"
    local Regex2="^\s*-a\s+always,exit\s+-F\s+arch=b64\s+-S\s+execve\s+-C\s+uid!=euid\s+-F\s+euid=0\s+-k\s+execpriv\s*(#.*)?$"
    local Regex3="^\s*-a\s+always,exit\s+-F\s+arch=b32\s+-S\s+execve\s+-C\s+gid!=egid\s+-F\s+egid=0\s+-k\s+execpriv\s*(#.*)?$"
    local Regex4="^\s*-a\s+always,exit\s+-F\s+arch=b64\s+-S\s+execve\s+-C\s+gid!=egid\s+-F\s+egid=0\s+-k\s+execpriv\s*(#.*)?$"
    local Success32="Auditing of successful/unsuccessful attempts to use execve is enabled on 32bit systems, per V-230386."
    local Success64="Auditing of successful/unsuccessful attempts to use execve is enabled on 64bit systems, per V-230386."
    local Failure32="Failed to set auditing of successful/unsuccessful attempts to use execve on 32bit systems, not in compliance with V-230386."
    local Failure64="Failed to set auditing of successful/unsuccessful attempts to use execve on 64bit systems, not in compliance with V-230386."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F arch=b32 -S execve -C uid!=euid -F euid=0 -k execpriv" >>/etc/audit/rules.d/audit.rules
    (uname -p | grep -q '64' && grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules) || echo "-a always,exit -F arch=b64 -S execve -C uid!=euid -F euid=0 -k execpriv" >>/etc/audit/rules.d/audit.rules
    grep -E -q "${Regex3}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F arch=b32 -S execve -C gid!=egid -F egid=0 -k execpriv" >>/etc/audit/rules.d/audit.rules
    (uname -p | grep -q '64' && grep -E -q "${Regex4}" /etc/audit/rules.d/audit.rules) || echo "-a always,exit -F arch=b64 -S execve -C gid!=egid -F egid=0 -k execpriv" >>/etc/audit/rules.d/audit.rules
    ( (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && grep -E -q "${Regex3}" /etc/audit/rules.d/audit.rules) && echo "${Success32}") || {
        echo "${Failure32}"
        exit 1
    }
    echo
    uname -p | grep -q '64' && { ( (grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules && grep -E -q "${Regex4}" /etc/audit/rules.d/audit.rules) && echo "${Success64}") || {
        echo "${Failure64}"
        exit 1
    }; } || echo "System is not a 64-bit architecture."
}

#Enabled cron logging, V-230387
function V230387() {
    local Regex1="^(\s*)#cron.\*\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#\s*cron.\*\s*\S+(\s*#.*)?\s*$/cron.\*                                                  \/var\/log\/cron\2/"
    local Regex3="^(\s*)cron.\*\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)cron.\*\s*\S+(\s*#.*)?\s*$/cron.\*                                                  \/var\/log\/cron\2/"
    local Regex5="^(\s*)cron.\*\s*\/var\/log\/cron\s*$"
    local Success="Cron logging is enabled, per V-230387."
    local Failure="Failed to enable cron logging, not in compliance with V-230387."

    echo
    ( (grep -E -q "${Regex1}" /etc/rsyslog.conf && sed -ri "${Regex2}" /etc/rsyslog.conf) || (grep -E -q "${Regex3}" /etc/rsyslog.conf && sed -ri "${Regex4}" /etc/rsyslog.conf)) || (echo "" >>/etc/rsyslog.conf && echo "# Configure cron logging per STIG V-230387" >>/etc/rsyslog.conf && echo "cron.*                                                  /var/log/cron" >>/etc/rsyslog.conf)
    (grep -E -q "${Regex5}" /etc/rsyslog.conf && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set RHEL8 to halt if the audit processing fails, V-230390
function V230390() {
    local Regex1="^(\s*)#\s*disk_error_action\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#\s*disk_error_action\s*=\s*\S+(\s*#.*)?\s*$/disk_error_action = HALT\2/"
    local Regex3="^(\s*)disk_error_action\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)disk_error_action\s*=\s*\S+(\s*#.*)?\s*$/disk_error_action = HALT\2/"
    local Regex5="^(\s*)disk_error_action\s*=\s*HALT\s*$"
    local Success="Set to halt if the audit process fails, per V-230390"
    local Failure="Failed to set to halt if the audit process fails, not in compliance with V-230390."

    echo
    ( (grep -E -q "${Regex1}" /etc/audit/auditd.conf && sed -ri "${Regex2}" /etc/audit/auditd.conf) || (grep -E -q "${Regex3}" /etc/audit/auditd.conf && sed -ri "${Regex4}" /etc/audit/auditd.conf)) || echo "disk_error_action = HALT" >>/etc/audit/auditd.conf
    (grep -E -q "${Regex5}" /etc/audit/auditd.conf && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set RHEL8 to halt if the audit storage is full, V-230392
function V230392() {
    local Regex1="^(\s*)#\s*disk_full_action\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#\s*disk_full_action\s*=\s*\S+(\s*#.*)?\s*$/disk_full_action = HALT\2/"
    local Regex3="^(\s*)disk_full_action\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)disk_full_action\s*=\s*\S+(\s*#.*)?\s*$/disk_full_action = HALT\2/"
    local Regex5="^(\s*)disk_full_action\s*=\s*HALT\s*$"
    local Success="Set to halt if the audit storage is full, per V-230392"
    local Failure="Failed to set to halt if the audit storage is full, not in compliance with V-230392."

    echo
    ( (grep -E -q "${Regex1}" /etc/audit/auditd.conf && sed -ri "${Regex2}" /etc/audit/auditd.conf) || (grep -E -q "${Regex3}" /etc/audit/auditd.conf && sed -ri "${Regex4}" /etc/audit/auditd.conf)) || echo "disk_full_action = HALT" >>/etc/audit/auditd.conf
    (grep -E -q "${Regex5}" /etc/audit/auditd.conf && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set audit to attach the hostname to logs, V-230394
function V230394() {
    local Regex1="^(\s*)#\s*name_format\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#\s*name_format\s*=\s*\S+(\s*#.*)?\s*$/name_format = hostname\2/"
    local Regex3="^(\s*)name_format\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)name_format\s*=\s*\S+(\s*#.*)?\s*$/name_format = hostname\2/"
    local Regex5="^(\s*)name_format\s*=\s*hostname\s*$"
    local Success="Set audit to attach the hostname to logs, per V-230394"
    local Failure="Failed to set audit to attach the hostname to logs, not in compliance with V-230394."

    echo
    ( (grep -E -q "${Regex1}" /etc/audit/auditd.conf && sed -ri "${Regex2}" /etc/audit/auditd.conf) || (grep -E -q "${Regex3}" /etc/audit/auditd.conf && sed -ri "${Regex4}" /etc/audit/auditd.conf)) || echo "name_format = hostname" >>/etc/audit/auditd.conf
    (grep -E -q "${Regex5}" /etc/audit/auditd.conf && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set audit logs to 0600 to prevent unauthorized access, V-230396 and V-230398
function V230396() {
    local Regex1="^(\s*)#\s*log_group\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#\s*log_group\s*=\s*\S+(\s*#.*)?\s*$/log_group = root\2/"
    local Regex3="^(\s*)log_group\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)log_group\s*=\s*\S+(\s*#.*)?\s*$/log_group = root\2/"
    local Regex5="^(\s*)log_group\s*=\s*root\s*$"
    local Success="Set logs to 0600 to prevent unauthorized access, per V-230396"
    local Failure="Failed to set logs to 0600 to prevent unauthorized access, not in compliance with V-230396."

    echo
    ( (grep -E -q "${Regex1}" /etc/audit/auditd.conf && sed -ri "${Regex2}" /etc/audit/auditd.conf) || (grep -E -q "${Regex3}" /etc/audit/auditd.conf && sed -ri "${Regex4}" /etc/audit/auditd.conf)) || echo "log_group = root" >>/etc/audit/auditd.conf
    (grep -E -q "${Regex5}" /etc/audit/auditd.conf && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set audit system to protect from unauthorized changes, V-230402
function V230402() {
    local Regex1="^(\s*)-e\s*2\s*(#.*)?$"
    local Success="Set system to protect from unauthorized changes, per V-230402"
    local Failure="Failed to set system to protect from unauthorized changes, not in compliance with V-230402."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-e 2" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set audit system to protect logon UIDs from unauthorized changes, V-230403
function V230403() {
    local Regex1="^(\s*)--loginuid-immutable\s*(#.*)?$"
    local Success="Set system to protect logon UIDs from unauthorized changes, per V-230403"
    local Failure="Failed to set system to protect logon UIDs from unauthorized changes, not in compliance with V-230403."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "--loginuid-immutable" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set audit to audit all account creations, modifications, disabling, and termination events that affect "/etc/shadow", V-230404
function V230404() {
    local Regex1="^\s*-w\s+/etc/shadow\s+-p\s+wa\s+-k\s+identity\s*(#.*)?$"
    local Success="Set to enable auditing of all account creations, modifications, disabling, and termination events the affect '/etc/shadow', per V-230404."
    local Failure="Failed to enable auditing of all account creations, modifications, disabling, and termination events the affect '/etc/shadow', not in compliance V-230404."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-w /etc/shadow -p wa -k identity" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set audit to audit all account creations, modifications, disabling, and termination events that affect "/etc/opasswd", V-230405
function V230405() {
    local Regex1="^\s*-w\s+/etc/security/opasswd\s+-p\s+wa\s+-k\s+identity\s*(#.*)?$"
    local Success="Set to enable auditing of all account creations, modifications, disabling, and termination events the affect '/etc/opasswd', per V-230405."
    local Failure="Failed to enable auditing of all account creations, modifications, disabling, and termination events the affect '/etc/opasswd', not in compliance V-230405."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-w /etc/security/opasswd -p wa -k identity" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set audit to audit all account creations, modifications, disabling, and termination events that affect "/etc/passwd", V-230406
function V230406() {
    local Regex1="^\s*-w\s+/etc/passwd\s+-p\s+wa\s+-k\s+identity\s*(#.*)?$"
    local Success="Auditing of all account creations, modifications, disabling, and termination events that affect '/etc/passwd', per V-230406."
    local Failure="Failed to set auditing of all account creations, modifications, disabling, and termination events that affect '/etc/passwd', not in compliance V-230406."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-w /etc/passwd -p wa -k identity" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set audit to audit all account creations, modifications, disabling, and termination events that affect "/etc/gshadow", V-230407
function V230407() {
    local Regex1="^\s*-w\s+/etc/gshadow\s+-p\s+wa\s+-k\s+identity\s*(#.*)?$"
    local Success="Auditing of all account creations, modifications, disabling, and termination events that affect '/etc/gshadow', per V-230407."
    local Failure="Failed to set auditing of all account creations, modifications, disabling, and termination events that affect '/etc/gshadow', not in compliance V-230407."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-w /etc/gshadow -p wa -k identity" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set audit to audit all account creations, modifications, disabling, and termination events that affect "/etc/group", V-230408
function V230408() {
    local Regex1="^\s*-w\s+/etc/group\s+-p\s+wa\s+-k\s+identity\s*(#.*)?$"
    local Success="Set to enable auditing of all account creations, modifications, disabling, and termination events the affect '/etc/group', per V-230408."
    local Failure="Failed to enable auditing of all account creations, modifications, disabling, and termination events the affect '/etc/group', not in compliance V-230408."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-w /etc/group -p wa -k identity" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set audit to audit all account creations, modifications, disabling, and termination events that affect "/etc/sudoers", V-230409
function V230409() {
    local Regex1="^\s*-w\s+/etc/sudoers\s+-p\s+wa\s+-k\s+identity\s*(#.*)?$"
    local Success="Set to enable auditing of all account creations, modifications, disabling, and termination events the affect '/etc/sudoers', per V-230409."
    local Failure="Failed to enable auditing of all account creations, modifications, disabling, and termination events the affect '/etc/sudoers', not in compliance V-230409."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-w /etc/sudoers -p wa -k identity" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set audit to audit all account creations, modifications, disabling, and termination events that affect "/etc/sudoers.d", V-230410
function V230410() {
    local Regex1="^\s*-w\s+/etc/sudoers.d/\s+-p\s+wa\s+-k\s+identity\s*(#.*)?$"
    local Success="Set to enable auditing of all account creations, modifications, disabling, and termination events the affect '/etc/sudoers.d', per V-230410."
    local Failure="Failed to enable auditing of all account creations, modifications, disabling, and termination events the affect '/etc/sudoers.d', not in compliance V-230410."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-w /etc/sudoers.d/ -p wa -k identity" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Install audit if not already installed, V-230411
function V230411() {
    local Success="audit has been installed, per V-230411."
    local Failure="audit is not installed, not in compliance with V-230411."

    echo

    if ! yum -q list installed audit &>/dev/null; then
        echo "${Failure}"
    else
        echo "${Success}"
    fi
}

#Set audit to audit of successful/unsuccessful attempts to use su, V-230412
function V230412() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+path=/usr/bin/su\s+-F\s+perm=x\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+privileged-priv_change\s*(#.*)?$"
    local Success="Auditing of successful/unsuccessful attempts to use su is enabled, per V-230412."
    local Failure="Failed to set auditing of successful/unsuccessful attempts to use su, not in compliance with V-230412."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F path=/usr/bin/su -F perm=x -F auid>=1000 -F auid!=unset -k privileged-priv_change" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set audit to audit of successful/unsuccessful attempts to use The RHEL 8 audit system must be configured to audit any usage of the setxattr, fsetxattr, lsetxattr, removexattr, fremovexattr, and lremovexattr system calls, V-230413
function V230413() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+arch=b32\s+-S\s+setxattr,fsetxattr,lsetxattr,removexattr,fremovexattr,lremovexattr\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_mod\s*(#.*)?$"
    local Regex2="^\s*-a\s+always,exit\s+-F\s+arch=b64\s+-S\s+setxattr,fsetxattr,lsetxattr,removexattr,fremovexattr,lremovexattr\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_mod\s*(#.*)?$"
    local Regex3="^\s*-a\s+always,exit\s+-F\s+arch=b32\s+-S\s+setxattr,fsetxattr,lsetxattr,removexattr,fremovexattr,lremovexattr\s+-F\s+auid=0\s+-k\s+perm_mod\s*(#.*)?$"
    local Regex4="^\s*-a\s+always,exit\s+-F\s+arch=b64\s+-S\s+setxattr,fsetxattr,lsetxattr,removexattr,fremovexattr,lremovexattr\s+-F\s+auid=0\s+-k\s+perm_mod\s*(#.*)?$"
    local Success32="Auditing of successful/unsuccessful attempts to use setxattr,fsetxattr,lsetxattr,removexattr,fremovexattr,lremovexattr is enabled on 32bit systems, per V-230413."
    local Success64="Auditing of successful/unsuccessful attempts to use setxattr,fsetxattr,lsetxattr,removexattr,fremovexattr,lremovexattr is enabled on 64bit systems, per V-230413."
    local Failure32="Failed to set auditing of successful/unsuccessful attempts to use setxattr,fsetxattr,lsetxattr,removexattr,fremovexattr,lremovexattr on 32bit systems, not in compliance with V-230413."
    local Failure64="Failed to set auditing of successful/unsuccessful attempts to use setxattr,fsetxattr,lsetxattr,removexattr,fremovexattr,lremovexattr on 64bit systems, not in compliance with V-230413."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F arch=b32 -S setxattr,fsetxattr,lsetxattr,removexattr,fremovexattr,lremovexattr -F auid>=1000 -F auid!=unset -k perm_mod" >>/etc/audit/rules.d/audit.rules
    (uname -p | grep -q '64' && grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules) || echo "-a always,exit -F arch=b64 -S setxattr,fsetxattr,lsetxattr,removexattr,fremovexattr,lremovexattr -F auid>=1000 -F auid!=unset -k perm_mod" >>/etc/audit/rules.d/audit.rules
    grep -E -q "${Regex3}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F arch=b32 -S setxattr,fsetxattr,lsetxattr,removexattr,fremovexattr,lremovexattr -F auid=0 -k perm_mod" >>/etc/audit/rules.d/audit.rules
    (uname -p | grep -q '64' && grep -E -q "${Regex4}" /etc/audit/rules.d/audit.rules) || echo "-a always,exit -F arch=b64 -S setxattr,fsetxattr,lsetxattr,removexattr,fremovexattr,lremovexattr -F auid=0 -k perm_mod" >>/etc/audit/rules.d/audit.rules
    ( (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && grep -E -q "${Regex3}" /etc/audit/rules.d/audit.rules) && echo "${Success32}") || {
        echo "${Failure32}"
        exit 1
    }
    echo
    uname -p | grep -q '64' && { ( (grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules && grep -E -q "${Regex4}" /etc/audit/rules.d/audit.rules) && echo "${Success64}") || {
        echo "${Failure64}"
        exit 1
    }; } || echo "System is not a 64-bit architecture."
}

#Set audit to audit of successful/unsuccessful attempts to use removexattr, V-230414
function V230414() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+arch=b32\s+-S\s+removexattr\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_mod\s*(#.*)?$"
    local Regex2="^\s*-a\s+always,exit\s+-F\s+arch=b64\s+-S\s+removexattr\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_mod\s*(#.*)?$"
    local Regex3="^\s*-a\s+always,exit\s+-F\s+arch=b32\s+-S\s+removexattr\s+-F\s+auid=0\s+-k\s+perm_mod\s*(#.*)?$"
    local Regex4="^\s*-a\s+always,exit\s+-F\s+arch=b64\s+-S\s+removexattr\s+-F\s+auid=0\s+-k\s+perm_mod\s*(#.*)?$"
    local Success32="Auditing of successful/unsuccessful attempts to use removexattr is enabled on 32bit systems, per V-230414."
    local Success64="Auditing of successful/unsuccessful attempts to use removexattr is enabled on 64bit systems, per V-230414."
    local Failure32="Failed to set auditing of successful/unsuccessful attempts to use removexattr on 32bit systems, not in compliance with V-230414."
    local Failure64="Failed to set auditing of successful/unsuccessful attempts to use removexattr on 64bit systems, not in compliance with V-230414."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F arch=b32 -S removexattr -F auid>=1000 -F auid!=unset -k perm_mod" >>/etc/audit/rules.d/audit.rules
    (uname -p | grep -q '64' && grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules) || echo "-a always,exit -F arch=b64 -S removexattr -F auid>=1000 -F auid!=unset -k perm_mod" >>/etc/audit/rules.d/audit.rules
    grep -E -q "${Regex3}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F arch=b32 -S removexattr -F auid=0 -k perm_mod" >>/etc/audit/rules.d/audit.rules
    (uname -p | grep -q '64' && grep -E -q "${Regex4}" /etc/audit/rules.d/audit.rules) || echo "-a always,exit -F arch=b64 -S removexattr -F auid=0 -k perm_mod" >>/etc/audit/rules.d/audit.rules
    ( (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && grep -E -q "${Regex3}" /etc/audit/rules.d/audit.rules) && echo "${Success32}") || {
        echo "${Failure32}"
        exit 1
    }
    echo
    uname -p | grep -q '64' && { ( (grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules && grep -E -q "${Regex4}" /etc/audit/rules.d/audit.rules) && echo "${Success64}") || {
        echo "${Failure64}"
        exit 1
    }; } || echo "System is not a 64-bit architecture."
}

#Set audit to audit of successful/unsuccessful attempts to use lsetxattr, V-230415
function V230415() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+arch=b32\s+-S\s+lsetxattr\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_mod\s*(#.*)?$"
    local Regex2="^\s*-a\s+always,exit\s+-F\s+arch=b64\s+-S\s+lsetxattr\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_mod\s*(#.*)?$"
    local Regex3="^\s*-a\s+always,exit\s+-F\s+arch=b32\s+-S\s+lsetxattr\s+-F\s+auid=0\s+-k\s+perm_mod\s*(#.*)?$"
    local Regex4="^\s*-a\s+always,exit\s+-F\s+arch=b64\s+-S\s+lsetxattr\s+-F\s+auid=0\s+-k\s+perm_mod\s*(#.*)?$"
    local Success32="Auditing of successful/unsuccessful attempts to use lsetxattr is enabled on 32bit systems, per V-230415."
    local Success64="Auditing of successful/unsuccessful attempts to use lsetxattr is enabled on 64bit systems, per V-230415."
    local Failure32="Failed to set auditing of successful/unsuccessful attempts to use lsetxattr on 32bit systems, not in compliance with V-230415."
    local Failure64="Failed to set auditing of successful/unsuccessful attempts to use lsetxattr on 64bit systems, not in compliance with V-230415."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F arch=b32 -S lsetxattr -F auid>=1000 -F auid!=unset -k perm_mod" >>/etc/audit/rules.d/audit.rules
    (uname -p | grep -q '64' && grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules) || echo "-a always,exit -F arch=b64 -S lsetxattr -F auid>=1000 -F auid!=unset -k perm_mod" >>/etc/audit/rules.d/audit.rules
    grep -E -q "${Regex3}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F arch=b32 -S lsetxattr -F auid=0 -k perm_mod" >>/etc/audit/rules.d/audit.rules
    (uname -p | grep -q '64' && grep -E -q "${Regex4}" /etc/audit/rules.d/audit.rules) || echo "-a always,exit -F arch=b64 -S lsetxattr -F auid=0 -k perm_mod" >>/etc/audit/rules.d/audit.rules
    ( (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && grep -E -q "${Regex3}" /etc/audit/rules.d/audit.rules) && echo "${Success32}") || {
        echo "${Failure32}"
        exit 1
    }
    echo
    uname -p | grep -q '64' && { ( (grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules && grep -E -q "${Regex4}" /etc/audit/rules.d/audit.rules) && echo "${Success64}") || {
        echo "${Failure64}"
        exit 1
    }; } || echo "System is not a 64-bit architecture."
}

#Set audit to audit of successful/unsuccessful attempts to use fsetxattr, V-230416
function V230416() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+arch=b32\s+-S\s+fsetxattr\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_mod\s*(#.*)?$"
    local Regex2="^\s*-a\s+always,exit\s+-F\s+arch=b64\s+-S\s+fsetxattr\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_mod\s*(#.*)?$"
    local Regex3="^\s*-a\s+always,exit\s+-F\s+arch=b32\s+-S\s+fsetxattr\s+-F\s+auid=0\s+-k\s+perm_mod\s*(#.*)?$"
    local Regex4="^\s*-a\s+always,exit\s+-F\s+arch=b64\s+-S\s+fsetxattr\s+-F\s+auid=0\s+-k\s+perm_mod\s*(#.*)?$"
    local Success32="Auditing of successful/unsuccessful attempts to use fsetxattr is enabled on 32bit systems, per V-230416."
    local Success64="Auditing of successful/unsuccessful attempts to use fsetxattr is enabled on 64bit systems, per V-230416."
    local Failure32="Failed to set auditing of successful/unsuccessful attempts to use fsetxattr on 32bit systems, not in compliance with V-230416."
    local Failure64="Failed to set auditing of successful/unsuccessful attempts to use fsetxattr on 64bit systems, not in compliance with V-230416."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F arch=b32 -S fsetxattr -F auid>=1000 -F auid!=unset -k perm_mod" >>/etc/audit/rules.d/audit.rules
    (uname -p | grep -q '64' && grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules) || echo "-a always,exit -F arch=b64 -S fsetxattr -F auid>=1000 -F auid!=unset -k perm_mod" >>/etc/audit/rules.d/audit.rules
    grep -E -q "${Regex3}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F arch=b32 -S fsetxattr -F auid=0 -k perm_mod" >>/etc/audit/rules.d/audit.rules
    (uname -p | grep -q '64' && grep -E -q "${Regex4}" /etc/audit/rules.d/audit.rules) || echo "-a always,exit -F arch=b64 -S fsetxattr -F auid=0 -k perm_mod" >>/etc/audit/rules.d/audit.rules
    ( (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && grep -E -q "${Regex3}" /etc/audit/rules.d/audit.rules) && echo "${Success32}") || {
        echo "${Failure32}"
        exit 1
    }
    echo
    uname -p | grep -q '64' && { ( (grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules && grep -E -q "${Regex4}" /etc/audit/rules.d/audit.rules) && echo "${Success64}") || {
        echo "${Failure64}"
        exit 1
    }; } || echo "System is not a 64-bit architecture."
}

#Set audit to audit of successful/unsuccessful attempts to use fremovexattr, V-230417
function V230417() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+arch=b32\s+-S\s+fremovexattr\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_mod\s*(#.*)?$"
    local Regex2="^\s*-a\s+always,exit\s+-F\s+arch=b64\s+-S\s+fremovexattr\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_mod\s*(#.*)?$"
    local Regex3="^\s*-a\s+always,exit\s+-F\s+arch=b32\s+-S\s+fremovexattr\s+-F\s+auid=0\s+-k\s+perm_mod\s*(#.*)?$"
    local Regex4="^\s*-a\s+always,exit\s+-F\s+arch=b64\s+-S\s+fremovexattr\s+-F\s+auid=0\s+-k\s+perm_mod\s*(#.*)?$"
    local Success32="Auditing of successful/unsuccessful attempts to use fremovexattr is enabled on 32bit systems, per V-230417."
    local Success64="Auditing of successful/unsuccessful attempts to use fremovexattr is enabled on 64bit systems, per V-230417."
    local Failure32="Failed to set auditing of successful/unsuccessful attempts to use fremovexattr on 32bit systems, not in compliance with V-230417."
    local Failure64="Failed to set auditing of successful/unsuccessful attempts to use fremovexattr on 64bit systems, not in compliance with V-230417."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F arch=b32 -S fremovexattr -F auid>=1000 -F auid!=unset -k perm_mod" >>/etc/audit/rules.d/audit.rules
    (uname -p | grep -q '64' && grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules) || echo "-a always,exit -F arch=b64 -S fremovexattr -F auid>=1000 -F auid!=unset -k perm_mod" >>/etc/audit/rules.d/audit.rules
    grep -E -q "${Regex3}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F arch=b32 -S fremovexattr -F auid=0 -k perm_mod" >>/etc/audit/rules.d/audit.rules
    (uname -p | grep -q '64' && grep -E -q "${Regex4}" /etc/audit/rules.d/audit.rules) || echo "-a always,exit -F arch=b64 -S fremovexattr -F auid=0 -k perm_mod" >>/etc/audit/rules.d/audit.rules
    ( (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && grep -E -q "${Regex3}" /etc/audit/rules.d/audit.rules) && echo "${Success32}") || {
        echo "${Failure32}"
        exit 1
    }
    echo
    uname -p | grep -q '64' && { ( (grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules && grep -E -q "${Regex4}" /etc/audit/rules.d/audit.rules) && echo "${Success64}") || {
        echo "${Failure64}"
        exit 1
    }; } || echo "System is not a 64-bit architecture."
}

#Set audit to audit of successful/unsuccessful attempts to use chage, V-230418
function V230418() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+path=/usr/bin/chage\s+-F\s+perm=x\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+privileged-chage\s*(#.*)?$"
    local Success="Auditing of successful/unsuccessful attempts to use chage is enabled, per V-230418."
    local Failure="Failed to set auditing of successful/unsuccessful attempts to use chage, not in compliance with V-230418."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F path=/usr/bin/chage -F perm=x -F auid>=1000 -F auid!=unset -k privileged-chage" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set audit to audit of successful/unsuccessful attempts to use chcon, V-230419
function V230419() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+path=/usr/bin/chcon\s+-F\s+perm=x\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_mod\s*(#.*)?$"
    local Success="Auditing of successful/unsuccessful attempts to use chcon is enabled, per V-230419."
    local Failure="Failed to set auditing of successful/unsuccessful attempts to use chcon, not in compliance with V-230419."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F path=/usr/bin/chcon -F perm=x -F auid>=1000 -F auid!=unset -k perm_mod" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set audit to audit of successful/unsuccessful attempts to use setxattr, V-230420
function V230420() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+arch=b32\s+-S\s+setxattr\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_mod\s*(#.*)?$"
    local Regex2="^\s*-a\s+always,exit\s+-F\s+arch=b64\s+-S\s+setxattr\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_mod\s*(#.*)?$"
    local Regex3="^\s*-a\s+always,exit\s+-F\s+arch=b32\s+-S\s+setxattr\s+-F\s+auid=0\s+-k\s+perm_mod\s*(#.*)?$"
    local Regex4="^\s*-a\s+always,exit\s+-F\s+arch=b64\s+-S\s+setxattr\s+-F\s+auid=0\s+-k\s+perm_mod\s*(#.*)?$"
    local Success32="Auditing of successful/unsuccessful attempts to use setxattr is enabled on 32bit systems, per V-230420."
    local Success64="Auditing of successful/unsuccessful attempts to use setxattr is enabled on 64bit systems, per V-230420."
    local Failure32="Failed to set auditing of successful/unsuccessful attempts to use setxattr on 32bit systems, not in compliance with V-230420."
    local Failure64="Failed to set auditing of successful/unsuccessful attempts to use setxattr on 64bit systems, not in compliance with V-230420."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F arch=b32 -S setxattr -F auid>=1000 -F auid!=unset -k perm_mod" >>/etc/audit/rules.d/audit.rules
    (uname -p | grep -q '64' && grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules) || echo "-a always,exit -F arch=b64 -S setxattr -F auid>=1000 -F auid!=unset -k perm_mod" >>/etc/audit/rules.d/audit.rules
    grep -E -q "${Regex3}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F arch=b32 -S setxattr -F auid=0 -k perm_mod" >>/etc/audit/rules.d/audit.rules
    (uname -p | grep -q '64' && grep -E -q "${Regex4}" /etc/audit/rules.d/audit.rules) || echo "-a always,exit -F arch=b64 -S setxattr -F auid=0 -k perm_mod" >>/etc/audit/rules.d/audit.rules
    ( (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && grep -E -q "${Regex3}" /etc/audit/rules.d/audit.rules) && echo "${Success32}") || {
        echo "${Failure32}"
        exit 1
    }
    echo
    uname -p | grep -q '64' && { ( (grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules && grep -E -q "${Regex4}" /etc/audit/rules.d/audit.rules) && echo "${Success64}") || {
        echo "${Failure64}"
        exit 1
    }; } || echo "System is not a 64-bit architecture."
}

#Set audit to audit of successful/unsuccessful attempts to use ssh-agent, V-230421
function V230421() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+path=/usr/bin/ssh-agent\s+-F\s+perm=x\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+privileged-ssh\s*(#.*)?$"
    local Success="Auditing of successful/unsuccessful attempts to use ssh-agent is enabled, per V-230421."
    local Failure="Failed to set auditing of successful/unsuccessful attempts to use ssh-agent, not in compliance with V-230421."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F path=/usr/bin/ssh-agent -F perm=x -F auid>=1000 -F auid!=unset -k privileged-ssh" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set audit to audit of successful/unsuccessful attempts to use passwd, V-230422
function V230422() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+path=/usr/bin/passwd\s+-F\s+perm=x\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+privileged-passwd\s*(#.*)?$"
    local Success="Auditing of successful/unsuccessful attempts to use passwd is enabled, per V-230422."
    local Failure="Failed to set auditing of successful/unsuccessful attempts to use passwd, not in compliance with V-230422."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F path=/usr/bin/passwd -F perm=x -F auid>=1000 -F auid!=unset -k privileged-passwd" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set audit to audit of successful/unsuccessful attempts to use mount, V-230423
function V230423() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+path=/usr/bin/mount\s+-F\s+perm=x\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+privileged-mount\s*(#.*)?$"
    local Success="Auditing of successful/unsuccessful attempts to use mount is enabled, per V-230423."
    local Failure="Failed to set auditing of successful/unsuccessful attempts to use mount, not in compliance with V-230423."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F path=/usr/bin/mount -F perm=x -F auid>=1000 -F auid!=unset -k privileged-mount" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set audit to audit of successful/unsuccessful attempts to use umount, V-230424
function V230424() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+path=/usr/bin/umount\s+-F\s+perm=x\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+privileged-mount\s*(#.*)?$"
    local Success="Auditing of successful/unsuccessful attempts to use umount is enabled, per V-230424."
    local Failure="Failed to set auditing of successful/unsuccessful attempts to use umount, not in compliance with V-230424."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F path=/usr/bin/umount -F perm=x -F auid>=1000 -F auid!=unset -k privileged-mount" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set audit to audit of successful/unsuccessful attempts to use mount, V-230425
function V230425() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+arch=b32\s+-S\s+mount\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+privileged-mount\s*(#.*)?$"
    local Regex2="^\s*-a\s+always,exit\s+-F\s+arch=b64\s+-S\s+mount\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+privileged-mount\s*(#.*)?$"
    local Success32="Auditing of the successful/unsuccessful access attempts to use mount on 32bit systems, per V-230425."
    local Success64="Auditing of the successful/unsuccessful access attempts to use mount on 64bit systems, per V-230425."
    local Failure32="Failed to set the auditing of successful/unsuccessful attempts to use mount on 32bit systems, not in compliance with V-230425."
    local Failure64="Failed to set the auditing of successful/unsuccessful attempts to use mount on 64bit systems, not in compliance with V-230425."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F arch=b32 -S mount -F auid>=1000 -F auid!=unset -k privileged-mount" >>/etc/audit/rules.d/audit.rules
    (uname -p | grep -q '64' && grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules) || echo "-a always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=unset -k privileged-mount" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success32}") || {
        echo "${Failure32}"
        exit 1
    }
    echo
    uname -p | grep -q '64' && { (grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules && echo "${Success64}") || {
        echo "${Failure64}"
        exit 1
    }; } || echo "System is not a 64-bit architecture."
}

#Set audit to audit of successful/unsuccessful attempts to use unix_update, V-230426
function V230426() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+path=/usr/sbin/unix_update\s+-F\s+perm=x\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+privileged-unix-update\s*(#.*)?$"
    local Success="Auditing of successful/unsuccessful attempts to use unix_update is enabled, per V-230426."
    local Failure="Failed to set auditing of successful/unsuccessful attempts to use unix_update, not in compliance with V-230426."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F path=/usr/sbin/unix_update -F perm=x -F auid>=1000 -F auid!=unset -k privileged-unix-update" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set audit to audit of successful/unsuccessful attempts to use postdrop, V-230427
function V230427() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+path=/usr/sbin/postdrop\s+-F\s+perm=x\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+privileged-unix-update\s*(#.*)?$"
    local Success="Auditing of successful/unsuccessful attempts to use postdrop is enabled, per V-230427."
    local Failure="Failed to set auditing of successful/unsuccessful attempts to use postdrop, not in compliance with V-230427."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F path=/usr/sbin/postdrop -F perm=x -F auid>=1000 -F auid!=unset -k privileged-unix-update" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set audit to audit of successful/unsuccessful attempts to use postqueue, V-230428
function V230428() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+path=/usr/sbin/postqueue\s+-F\s+perm=x\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+privileged-unix-update\s*(#.*)?$"
    local Success="Auditing of successful/unsuccessful attempts to use postqueue is enabled, per V-230428."
    local Failure="Failed to set auditing of successful/unsuccessful attempts to use postqueue, not in compliance with V-230428."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F path=/usr/sbin/postqueue -F perm=x -F auid>=1000 -F auid!=unset -k privileged-unix-update" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set audit to audit of successful/unsuccessful attempts to use semanage, V-230429
function V230429() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+path=/usr/sbin/semanage\s+-F\s+perm=x\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+privileged-unix-update\s*(#.*)?$"
    local Success="Auditing of successful/unsuccessful attempts to use semanage is enabled, per V-230429."
    local Failure="Failed to set auditing of successful/unsuccessful attempts to use semanage, not in compliance with V-230429."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F path=/usr/sbin/semanage -F perm=x -F auid>=1000 -F auid!=unset -k privileged-unix-update" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set audit to audit of successful/unsuccessful attempts to use setfiles, V-230430
function V230430() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+path=/usr/sbin/setfiles\s+-F\s+perm=x\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+privileged-unix-update\s*(#.*)?$"
    local Success="Auditing of successful/unsuccessful attempts to use setfiles is enabled, per V-230430."
    local Failure="Failed to set auditing of successful/unsuccessful attempts to use setfiles, not in compliance with V-230430."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F path=/usr/sbin/setfiles -F perm=x -F auid>=1000 -F auid!=unset -k privileged-unix-update" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set audit to audit of successful/unsuccessful attempts to use userhelper, V-230431
function V230431() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+path=/usr/sbin/userhelper\s+-F\s+perm=x\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+privileged-unix-update\s*(#.*)?$"
    local Success="Auditing of successful/unsuccessful attempts to use userhelper is enabled, per V-230431."
    local Failure="Failed to set auditing of successful/unsuccessful attempts to use userhelper, not in compliance with V-230431."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F path=/usr/sbin/userhelper -F perm=x -F auid>=1000 -F auid!=unset -k privileged-unix-update" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set audit to audit of successful/unsuccessful attempts to use setsebool, V-230432
function V230432() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+path=/usr/sbin/setsebool\s+-F\s+perm=x\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+privileged-unix-update\s*(#.*)?$"
    local Success="Auditing of successful/unsuccessful attempts to use setsebool is enabled, per V-230432."
    local Failure="Failed to set auditing of successful/unsuccessful attempts to use setsebool, not in compliance with V-230432."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F path=/usr/sbin/setsebool -F perm=x -F auid>=1000 -F auid!=unset -k privileged-unix-update" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set audit to audit of successful/unsuccessful attempts to use unix_chkpwd, V-230433
function V230433() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+path=/usr/sbin/unix_chkpwd\s+-F\s+perm=x\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+privileged-unix-update\s*(#.*)?$"
    local Success="Auditing of successful/unsuccessful attempts to use unix_chkpwd is enabled, per V-230433."
    local Failure="Failed to set auditing of successful/unsuccessful attempts to use unix_chkpwd, not in compliance with V-230433."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F path=/usr/sbin/unix_chkpwd -F perm=x -F auid>=1000 -F auid!=unset -k privileged-unix-update" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set audit to audit of successful/unsuccessful attempts to use ssh-keysign, V-230434
function V230434() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+path=/usr/libexec/openssh/ssh-keysign\s+-F\s+perm=x\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+privileged-ssh\s*(#.*)?$"
    local Success="Auditing of successful/unsuccessful attempts to use ssh-keysign is enabled, per V-230434."
    local Failure="Failed to set auditing of successful/unsuccessful attempts to use ssh-keysign, not in compliance with V-230434."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F path=/usr/libexec/openssh/ssh-keysign -F perm=x -F auid>=1000 -F auid!=unset -k privileged-ssh" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set audit to audit of successful/unsuccessful attempts to use setfacl, V-230435
function V230435() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+path=/usr/bin/setfacl\s+-F\s+perm=x\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_mod\s*(#.*)?$"
    local Success="Auditing of successful/unsuccessful attempts to use setfacl is enabled, per V-230435."
    local Failure="Failed to set auditing of successful/unsuccessful attempts to use setfacl, not in compliance with V-230435."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F path=/usr/bin/setfacl -F perm=x -F auid>=1000 -F auid!=unset -k perm_mod" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set audit to audit of successful/unsuccessful attempts to use pam_timestamp_check, V-230436
function V230436() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+path=/usr/sbin/pam_timestamp_check\s+-F\s+perm=x\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+privileged-pam_timestamp_check\s*(#.*)?$"
    local Success="Auditing of successful/unsuccessful attempts to use pam_timestamp_check is enabled, per V-230436."
    local Failure="Failed to set auditing of successful/unsuccessful attempts to use pam_timestamp_check, not in compliance with V-230436."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F path=/usr/sbin/pam_timestamp_check -F perm=x -F auid>=1000 -F auid!=unset -k privileged-pam_timestamp_check" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set audit to audit of successful/unsuccessful attempts to use newgrp, V-230437
function V230437() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+path=/usr/bin/newgrp\s+-F\s+perm=x\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+priv_cmd\s*(#.*)?$"
    local Success="Auditing of successful/unsuccessful attempts to use newgrp is enabled, per V-230437."
    local Failure="Failed to set auditing of successful/unsuccessful attempts to use newgrp, not in compliance with V-230437."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F path=/usr/bin/newgrp -F perm=x -F auid>=1000 -F auid!=unset -k priv_cmd" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set audit to audit of successful/unsuccessful attempts to use init_module,finit_module, V-230438
function V230438() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+arch=b32\s+-S\s+init_module,finit_module\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+module_chng\s*(#.*)?$"
    local Regex2="^\s*-a\s+always,exit\s+-F\s+arch=b64\s+-S\s+init_module,finit_module\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+module_chng\s*(#.*)?$"
    local Success32="Auditing of the successful/unsuccessful access attempts to use init_module,finit_module on 32bit systems, per V-230438."
    local Success64="Auditing of the successful/unsuccessful access attempts to use init_module,finit_module on 64bit systems, per V-230438."
    local Failure32="Failed to set the auditing of successful/unsuccessful attempts to use init_module,finit_module on 32bit systems, not in compliance with V-230438."
    local Failure64="Failed to set the auditing of successful/unsuccessful attempts to use init_module,finit_module on 64bit systems, not in compliance with V-230438."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F arch=b32 -S init_module,finit_module -F auid>=1000 -F auid!=unset -k module_chng" >>/etc/audit/rules.d/audit.rules
    (uname -p | grep -q '64' && grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules) || echo "-a always,exit -F arch=b64 -S init_module,finit_module -F auid>=1000 -F auid!=unset -k module_chng" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success32}") || {
        echo "${Failure32}"
        exit 1
    }
    echo
    uname -p | grep -q '64' && { (grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules && echo "${Success64}") || {
        echo "${Failure64}"
        exit 1
    }; } || echo "System is not a 64-bit architecture."
}

#Set audit to audit of successful/unsuccessful attempts to use rename,unlink,rmdir,renameat,unlinkat, V-230439
function V230439() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+arch=b32\s+-S\s+rename,unlink,rmdir,renameat,unlinkat\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+delete\s*(#.*)?$"
    local Regex2="^\s*-a\s+always,exit\s+-F\s+arch=b64\s+-S\s+rename,unlink,rmdir,renameat,unlinkat\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+delete\s*(#.*)?$"
    local Success32="Auditing of the successful/unsuccessful access attempts to use rename,unlink,rmdir,renameat,unlinkat on 32bit systems, per V-230439."
    local Success64="Auditing of the successful/unsuccessful access attempts to use rename,unlink,rmdir,renameat,unlinkat on 64bit systems, per V-230439."
    local Failure32="Failed to set the auditing of successful/unsuccessful attempts to use rename,unlink,rmdir,renameat,unlinkat on 32bit systems, not in compliance with V-230439."
    local Failure64="Failed to set the auditing of successful/unsuccessful attempts to use rename,unlink,rmdir,renameat,unlinkat on 64bit systems, not in compliance with V-230439."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F arch=b32 -S rename,unlink,rmdir,renameat,unlinkat -F auid>=1000 -F auid!=unset -k delete" >>/etc/audit/rules.d/audit.rules
    (uname -p | grep -q '64' && grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules) || echo "-a always,exit -F arch=b64 -S rename,unlink,rmdir,renameat,unlinkat -F auid>=1000 -F auid!=unset -k delete" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success32}") || {
        echo "${Failure32}"
        exit 1
    }
    echo
    uname -p | grep -q '64' && { (grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules && echo "${Success64}") || {
        echo "${Failure64}"
        exit 1
    }; } || echo "System is not a 64-bit architecture."
}

#Set audit to audit of successful/unsuccessful attempts to use renameat, V-230440
function V230440() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+arch=b32\s+-S\s+renameat\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+delete\s*(#.*)?$"
    local Regex2="^\s*-a\s+always,exit\s+-F\s+arch=b64\s+-S\s+renameat\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+delete\s*(#.*)?$"
    local Success32="Auditing of the successful/unsuccessful access attempts to use renameat on 32bit systems, per V-230440."
    local Success64="Auditing of the successful/unsuccessful access attempts to use renameat on 64bit systems, per V-230440."
    local Failure32="Failed to set the auditing of successful/unsuccessful attempts to use renameat on 32bit systems, not in compliance with V-230440."
    local Failure64="Failed to set the auditing of successful/unsuccessful attempts to use renameat on 64bit systems, not in compliance with V-230440."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F arch=b32 -S renameat -F auid>=1000 -F auid!=unset -k delete" >>/etc/audit/rules.d/audit.rules
    (uname -p | grep -q '64' && grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules) || echo "-a always,exit -F arch=b64 -S renameat -F auid>=1000 -F auid!=unset -k delete" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success32}") || {
        echo "${Failure32}"
        exit 1
    }
    echo
    uname -p | grep -q '64' && { (grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules && echo "${Success64}") || {
        echo "${Failure64}"
        exit 1
    }; } || echo "System is not a 64-bit architecture."
}

#Set audit to audit of successful/unsuccessful attempts to use rmdir, V-230441
function V230441() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+arch=b32\s+-S\s+rmdir\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+delete\s*(#.*)?$"
    local Regex2="^\s*-a\s+always,exit\s+-F\s+arch=b64\s+-S\s+rmdir\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+delete\s*(#.*)?$"
    local Success32="Auditing of the successful/unsuccessful access attempts to use rmdir on 32bit systems, per V-230441."
    local Success64="Auditing of the successful/unsuccessful access attempts to use rmdir on 64bit systems, per V-230441."
    local Failure32="Failed to set the auditing of successful/unsuccessful attempts to use rmdir on 32bit systems, not in compliance with V-230441."
    local Failure64="Failed to set the auditing of successful/unsuccessful attempts to use rmdir on 64bit systems, not in compliance with V-230441."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F arch=b32 -S rmdir -F auid>=1000 -F auid!=unset -k delete" >>/etc/audit/rules.d/audit.rules
    (uname -p | grep -q '64' && grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules) || echo "-a always,exit -F arch=b64 -S rmdir -F auid>=1000 -F auid!=unset -k delete" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success32}") || {
        echo "${Failure32}"
        exit 1
    }
    echo
    uname -p | grep -q '64' && { (grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules && echo "${Success64}") || {
        echo "${Failure64}"
        exit 1
    }; } || echo "System is not a 64-bit architecture."
}

#Set audit to audit of successful/unsuccessful attempts to use unlink, V-230442
function V230442() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+arch=b32\s+-S\s+unlink\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+delete\s*(#.*)?$"
    local Regex2="^\s*-a\s+always,exit\s+-F\s+arch=b64\s+-S\s+unlink\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+delete\s*(#.*)?$"
    local Success32="Auditing of the successful/unsuccessful access attempts to use unlink on 32bit systems, per V-230442."
    local Success64="Auditing of the successful/unsuccessful access attempts to use unlink on 64bit systems, per V-230442."
    local Failure32="Failed to set the auditing of successful/unsuccessful attempts to use unlink on 32bit systems, not in compliance with V-230442."
    local Failure64="Failed to set the auditing of successful/unsuccessful attempts to use unlink on 64bit systems, not in compliance with V-230442."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F arch=b32 -S unlink -F auid>=1000 -F auid!=unset -k delete" >>/etc/audit/rules.d/audit.rules
    (uname -p | grep -q '64' && grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules) || echo "-a always,exit -F arch=b64 -S unlink -F auid>=1000 -F auid!=unset -k delete" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success32}") || {
        echo "${Failure32}"
        exit 1
    }
    echo
    uname -p | grep -q '64' && { (grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules && echo "${Success64}") || {
        echo "${Failure64}"
        exit 1
    }; } || echo "System is not a 64-bit architecture."
}

#Set audit to audit of successful/unsuccessful attempts to use unlinkat, V-230443
function V230443() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+arch=b32\s+-S\s+unlinkat\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+delete\s*(#.*)?$"
    local Regex2="^\s*-a\s+always,exit\s+-F\s+arch=b64\s+-S\s+unlinkat\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+delete\s*(#.*)?$"
    local Success32="Auditing of the successful/unsuccessful access attempts to use unlinkat on 32bit systems, per V-230443."
    local Success64="Auditing of the successful/unsuccessful access attempts to use unlinkat on 64bit systems, per V-230443."
    local Failure32="Failed to set the auditing of successful/unsuccessful attempts to use unlinkat on 32bit systems, not in compliance with V-230443."
    local Failure64="Failed to set the auditing of successful/unsuccessful attempts to use unlinkat on 64bit systems, not in compliance with V-230443."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F arch=b32 -S unlinkat -F auid>=1000 -F auid!=unset -k delete" >>/etc/audit/rules.d/audit.rules
    (uname -p | grep -q '64' && grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules) || echo "-a always,exit -F arch=b64 -S unlinkat -F auid>=1000 -F auid!=unset -k delete" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success32}") || {
        echo "${Failure32}"
        exit 1
    }
    echo
    uname -p | grep -q '64' && { (grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules && echo "${Success64}") || {
        echo "${Failure64}"
        exit 1
    }; } || echo "System is not a 64-bit architecture."
}

#Set audit to audit of successful/unsuccessful attempts to use gpasswd, V-230444
function V230444() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+path=/usr/bin/gpasswd\s+-F\s+perm=x\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+privileged-gpasswd\s*(#.*)?$"
    local Success="Auditing of successful/unsuccessful attempts to use gpasswd is enabled, per V-230444."
    local Failure="Failed to set auditing of successful/unsuccessful attempts to use gpasswd, not in compliance with V-230444."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F path=/usr/bin/gpasswd -F perm=x -F auid>=1000 -F auid!=unset -k privileged-gpasswd" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set audit to audit of successful/unsuccessful attempts to use finit_module, V-230445
function V230445() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+arch=b32\s+-S\s+finit_module\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+module_chng\s*(#.*)?$"
    local Regex2="^\s*-a\s+always,exit\s+-F\s+arch=b64\s+-S\s+finit_module\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+module_chng\s*(#.*)?$"
    local Success32="Auditing of the successful/unsuccessful access attempts to use finit_module on 32bit systems, per V-230445."
    local Success64="Auditing of the successful/unsuccessful access attempts to use finit_module on 64bit systems, per V-230445."
    local Failure32="Failed to set the auditing of successful/unsuccessful attempts to use finit_module on 32bit systems, not in compliance with V-230445."
    local Failure64="Failed to set the auditing of successful/unsuccessful attempts to use finit_module on 64bit systems, not in compliance with V-230445."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F arch=b32 -S finit_module -F auid>=1000 -F auid!=unset -k module_chng" >>/etc/audit/rules.d/audit.rules
    (uname -p | grep -q '64' && grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules) || echo "-a always,exit -F arch=b64 -S finit_module -F auid>=1000 -F auid!=unset -k module_chng" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success32}") || {
        echo "${Failure32}"
        exit 1
    }
    echo
    uname -p | grep -q '64' && { (grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules && echo "${Success64}") || {
        echo "${Failure64}"
        exit 1
    }; } || echo "System is not a 64-bit architecture."
}

#Set audit to audit of successful/unsuccessful attempts to use delete_module, V-230446
function V230446() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+arch=b32\s+-S\s+delete_module\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+module_chng\s*(#.*)?$"
    local Regex2="^\s*-a\s+always,exit\s+-F\s+arch=b64\s+-S\s+delete_module\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+module_chng\s*(#.*)?$"
    local Success32="Auditing of the successful/unsuccessful access attempts to use delete_module on 32bit systems, per V-230446."
    local Success64="Auditing of the successful/unsuccessful access attempts to use delete_module on 64bit systems, per V-230446."
    local Failure32="Failed to set the auditing of successful/unsuccessful attempts to use delete_module on 32bit systems, not in compliance with V-230446."
    local Failure64="Failed to set the auditing of successful/unsuccessful attempts to use delete_module on 64bit systems, not in compliance with V-230446."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F arch=b32 -S delete_module -F auid>=1000 -F auid!=unset -k module_chng" >>/etc/audit/rules.d/audit.rules
    (uname -p | grep -q '64' && grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules) || echo "-a always,exit -F arch=b64 -S delete_module -F auid>=1000 -F auid!=unset -k module_chng" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success32}") || {
        echo "${Failure32}"
        exit 1
    }
    echo
    uname -p | grep -q '64' && { (grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules && echo "${Success64}") || {
        echo "${Failure64}"
        exit 1
    }; } || echo "System is not a 64-bit architecture."
}

#Set audit to audit of successful/unsuccessful attempts to use crontab, V-230447
function V230447() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+path=/usr/bin/crontab\s+-F\s+perm=x\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+privileged-crontab\s*(#.*)?$"
    local Success="Auditing of successful/unsuccessful attempts to use crontab is enabled, per V-230447."
    local Failure="Failed to set auditing of successful/unsuccessful attempts to use crontab, not in compliance with V-230447."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F path=/usr/bin/crontab -F perm=x -F auid>=1000 -F auid!=unset -k privileged-crontab" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set audit to audit of successful/unsuccessful attempts to use chsh, V-230448
function V230448() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+path=/usr/bin/chsh\s+-F\s+perm=x\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+priv_cmd\s*(#.*)?$"
    local Success="Auditing of successful/unsuccessful attempts to use chsh is enabled, per V-230448."
    local Failure="Failed to set auditing of successful/unsuccessful attempts to use chsh, not in compliance with V-230448."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F path=/usr/bin/chsh -F perm=x -F auid>=1000 -F auid!=unset -k priv_cmd" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set audit to audit of successful/unsuccessful attempts to use truncate,ftruncate,creat,open,openat,open_by_handle_at, V-230449
function V230449() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+arch=b32\s+-S\s+truncate,ftruncate,creat,open,openat,open_by_handle_at\s+-F\s+exit=-EPERM\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_access\s*(#.*)?$"
    local Regex2="^\s*-a\s+always,exit\s+-F\s+arch=b64\s+-S\s+truncate,ftruncate,creat,open,openat,open_by_handle_at\s+-F\s+exit=-EPERM\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_access\s*(#.*)?$"
    local Regex3="^\s*-a\s+always,exit\s+-F\s+arch=b32\s+-S\s+truncate,ftruncate,creat,open,openat,open_by_handle_at\s+-F\s+exit=-EACCES\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_access\s*(#.*)?$"
    local Regex4="^\s*-a\s+always,exit\s+-F\s+arch=b64\s+-S\s+truncate,ftruncate,creat,open,openat,open_by_handle_at\s+-F\s+exit=-EACCES\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_access\s*(#.*)?$"
    local Success32="Auditing of successful/unsuccessful attempts to use truncate,ftruncate,creat,open,openat,open_by_handle_at is enabled on 32bit systems, per V-230449."
    local Success64="Auditing of successful/unsuccessful attempts to use truncate,ftruncate,creat,open,openat,open_by_handle_at is enabled on 64bit systems, per V-230449."
    local Failure32="Failed to set auditing of successful/unsuccessful attempts to use truncate,ftruncate,creat,open,openat,open_by_handle_at on 32bit systems, not in compliance with V-230449."
    local Failure64="Failed to set auditing of successful/unsuccessful attempts to use truncate,ftruncate,creat,open,openat,open_by_handle_at on 64bit systems, not in compliance with V-230449."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F arch=b32 -S truncate,ftruncate,creat,open,openat,open_by_handle_at -F exit=-EPERM -F auid>=1000 -F auid!=unset -k perm_access" >>/etc/audit/rules.d/audit.rules
    (uname -p | grep -q '64' && grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules) || echo "-a always,exit -F arch=b64 -S truncate,ftruncate,creat,open,openat,open_by_handle_at -F exit=-EPERM -F auid>=1000 -F auid!=unset -k perm_access" >>/etc/audit/rules.d/audit.rules
    grep -E -q "${Regex3}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F arch=b32 -S truncate,ftruncate,creat,open,openat,open_by_handle_at -F exit=-EACCES -F auid>=1000 -F auid!=unset -k perm_access" >>/etc/audit/rules.d/audit.rules
    (uname -p | grep -q '64' && grep -E -q "${Regex4}" /etc/audit/rules.d/audit.rules) || echo "-a always,exit -F arch=b64 -S truncate,ftruncate,creat,open,openat,open_by_handle_at -F exit=-EACCES -F auid>=1000 -F auid!=unset -k perm_access" >>/etc/audit/rules.d/audit.rules
    ( (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && grep -E -q "${Regex3}" /etc/audit/rules.d/audit.rules) && echo "${Success32}") || {
        echo "${Failure32}"
        exit 1
    }
    echo
    uname -p | grep -q '64' && { ( (grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules && grep -E -q "${Regex4}" /etc/audit/rules.d/audit.rules) && echo "${Success64}") || {
        echo "${Failure64}"
        exit 1
    }; } || echo "System is not a 64-bit architecture."
}

#Set audit to audit of successful/unsuccessful attempts to use openat, V-230450
function V230450() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+arch=b32\s+-S\s+openat\s+-F\s+exit=-EPERM\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_access\s*(#.*)?$"
    local Regex2="^\s*-a\s+always,exit\s+-F\s+arch=b64\s+-S\s+openat\s+-F\s+exit=-EPERM\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_access\s*(#.*)?$"
    local Regex3="^\s*-a\s+always,exit\s+-F\s+arch=b32\s+-S\s+openat\s+-F\s+exit=-EACCES\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_access\s*(#.*)?$"
    local Regex4="^\s*-a\s+always,exit\s+-F\s+arch=b64\s+-S\s+openat\s+-F\s+exit=-EACCES\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_access\s*(#.*)?$"
    local Success32="Auditing of successful/unsuccessful attempts to use openat is enabled on 32bit systems, per V-230450."
    local Success64="Auditing of successful/unsuccessful attempts to use openat is enabled on 64bit systems, per V-230450."
    local Failure32="Failed to set auditing of successful/unsuccessful attempts to use openat on 32bit systems, not in compliance with V-230450."
    local Failure64="Failed to set auditing of successful/unsuccessful attempts to use openat on 64bit systems, not in compliance with V-230450."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F arch=b32 -S openat -F exit=-EPERM -F auid>=1000 -F auid!=unset -k perm_access" >>/etc/audit/rules.d/audit.rules
    (uname -p | grep -q '64' && grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules) || echo "-a always,exit -F arch=b64 -S openat -F exit=-EPERM -F auid>=1000 -F auid!=unset -k perm_access" >>/etc/audit/rules.d/audit.rules
    grep -E -q "${Regex3}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F arch=b32 -S openat -F exit=-EACCES -F auid>=1000 -F auid!=unset -k perm_access" >>/etc/audit/rules.d/audit.rules
    (uname -p | grep -q '64' && grep -E -q "${Regex4}" /etc/audit/rules.d/audit.rules) || echo "-a always,exit -F arch=b64 -S openat -F exit=-EACCES -F auid>=1000 -F auid!=unset -k perm_access" >>/etc/audit/rules.d/audit.rules
    ( (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && grep -E -q "${Regex3}" /etc/audit/rules.d/audit.rules) && echo "${Success32}") || {
        echo "${Failure32}"
        exit 1
    }
    echo
    uname -p | grep -q '64' && { ( (grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules && grep -E -q "${Regex4}" /etc/audit/rules.d/audit.rules) && echo "${Success64}") || {
        echo "${Failure64}"
        exit 1
    }; } || echo "System is not a 64-bit architecture."
}

#Set audit to audit of successful/unsuccessful attempts to use open, V-230451
function V230451() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+arch=b32\s+-S\s+open\s+-F\s+exit=-EPERM\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_access\s*(#.*)?$"
    local Regex2="^\s*-a\s+always,exit\s+-F\s+arch=b64\s+-S\s+open\s+-F\s+exit=-EPERM\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_access\s*(#.*)?$"
    local Regex3="^\s*-a\s+always,exit\s+-F\s+arch=b32\s+-S\s+open\s+-F\s+exit=-EACCES\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_access\s*(#.*)?$"
    local Regex4="^\s*-a\s+always,exit\s+-F\s+arch=b64\s+-S\s+open\s+-F\s+exit=-EACCES\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_access\s*(#.*)?$"
    local Success32="Auditing of successful/unsuccessful attempts to use open is enabled on 32bit systems, per V-230451."
    local Success64="Auditing of successful/unsuccessful attempts to use open is enabled on 64bit systems, per V-230451."
    local Failure32="Failed to set auditing of successful/unsuccessful attempts to use open on 32bit systems, not in compliance with V-230451."
    local Failure64="Failed to set auditing of successful/unsuccessful attempts to use open on 64bit systems, not in compliance with V-230451."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F arch=b32 -S open -F exit=-EPERM -F auid>=1000 -F auid!=unset -k perm_access" >>/etc/audit/rules.d/audit.rules
    (uname -p | grep -q '64' && grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules) || echo "-a always,exit -F arch=b64 -S open -F exit=-EPERM -F auid>=1000 -F auid!=unset -k perm_access" >>/etc/audit/rules.d/audit.rules
    grep -E -q "${Regex3}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F arch=b32 -S open -F exit=-EACCES -F auid>=1000 -F auid!=unset -k perm_access" >>/etc/audit/rules.d/audit.rules
    (uname -p | grep -q '64' && grep -E -q "${Regex4}" /etc/audit/rules.d/audit.rules) || echo "-a always,exit -F arch=b64 -S open -F exit=-EACCES -F auid>=1000 -F auid!=unset -k perm_access" >>/etc/audit/rules.d/audit.rules
    ( (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && grep -E -q "${Regex3}" /etc/audit/rules.d/audit.rules) && echo "${Success32}") || {
        echo "${Failure32}"
        exit 1
    }
    echo
    uname -p | grep -q '64' && { ( (grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules && grep -E -q "${Regex4}" /etc/audit/rules.d/audit.rules) && echo "${Success64}") || {
        echo "${Failure64}"
        exit 1
    }; } || echo "System is not a 64-bit architecture."
}

#Set audit to audit of successful/unsuccessful attempts to use open_by_handle_at, V-230452
function V230452() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+arch=b32\s+-S\s+open_by_handle_at\s+-F\s+exit=-EPERM\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_access\s*(#.*)?$"
    local Regex2="^\s*-a\s+always,exit\s+-F\s+arch=b64\s+-S\s+open_by_handle_at\s+-F\s+exit=-EPERM\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_access\s*(#.*)?$"
    local Regex3="^\s*-a\s+always,exit\s+-F\s+arch=b32\s+-S\s+open_by_handle_at\s+-F\s+exit=-EACCES\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_access\s*(#.*)?$"
    local Regex4="^\s*-a\s+always,exit\s+-F\s+arch=b64\s+-S\s+open_by_handle_at\s+-F\s+exit=-EACCES\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_access\s*(#.*)?$"
    local Success32="Auditing of successful/unsuccessful attempts to use open_by_handle_at is enabled on 32bit systems, per V-230452."
    local Success64="Auditing of successful/unsuccessful attempts to use open_by_handle_at is enabled on 64bit systems, per V-230452."
    local Failure32="Failed to set auditing of successful/unsuccessful attempts to use open_by_handle_at on 32bit systems, not in compliance with V-230452."
    local Failure64="Failed to set auditing of successful/unsuccessful attempts to use open_by_handle_at on 64bit systems, not in compliance with V-230452."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F arch=b32 -S open_by_handle_at -F exit=-EPERM -F auid>=1000 -F auid!=unset -k perm_access" >>/etc/audit/rules.d/audit.rules
    (uname -p | grep -q '64' && grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules) || echo "-a always,exit -F arch=b64 -S open_by_handle_at -F exit=-EPERM -F auid>=1000 -F auid!=unset -k perm_access" >>/etc/audit/rules.d/audit.rules
    grep -E -q "${Regex3}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F arch=b32 -S open_by_handle_at -F exit=-EACCES -F auid>=1000 -F auid!=unset -k perm_access" >>/etc/audit/rules.d/audit.rules
    (uname -p | grep -q '64' && grep -E -q "${Regex4}" /etc/audit/rules.d/audit.rules) || echo "-a always,exit -F arch=b64 -S open_by_handle_at -F exit=-EACCES -F auid>=1000 -F auid!=unset -k perm_access" >>/etc/audit/rules.d/audit.rules
    ( (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && grep -E -q "${Regex3}" /etc/audit/rules.d/audit.rules) && echo "${Success32}") || {
        echo "${Failure32}"
        exit 1
    }
    echo
    uname -p | grep -q '64' && { ( (grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules && grep -E -q "${Regex4}" /etc/audit/rules.d/audit.rules) && echo "${Success64}") || {
        echo "${Failure64}"
        exit 1
    }; } || echo "System is not a 64-bit architecture."
}

#Set audit to audit of successful/unsuccessful attempts to use ftruncate, V-230453
function V230453() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+arch=b32\s+-S\s+ftruncate\s+-F\s+exit=-EPERM\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_access\s*(#.*)?$"
    local Regex2="^\s*-a\s+always,exit\s+-F\s+arch=b64\s+-S\s+ftruncate\s+-F\s+exit=-EPERM\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_access\s*(#.*)?$"
    local Regex3="^\s*-a\s+always,exit\s+-F\s+arch=b32\s+-S\s+ftruncate\s+-F\s+exit=-EACCES\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_access\s*(#.*)?$"
    local Regex4="^\s*-a\s+always,exit\s+-F\s+arch=b64\s+-S\s+ftruncate\s+-F\s+exit=-EACCES\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_access\s*(#.*)?$"
    local Success32="Auditing of successful/unsuccessful attempts to use ftruncate is enabled on 32bit systems, per V-230453."
    local Success64="Auditing of successful/unsuccessful attempts to use ftruncate is enabled on 64bit systems, per V-230453."
    local Failure32="Failed to set auditing of successful/unsuccessful attempts to use ftruncate on 32bit systems, not in compliance with V-230453."
    local Failure64="Failed to set auditing of successful/unsuccessful attempts to use ftruncate on 64bit systems, not in compliance with V-230453."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F arch=b32 -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=unset -k perm_access" >>/etc/audit/rules.d/audit.rules
    (uname -p | grep -q '64' && grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules) || echo "-a always,exit -F arch=b64 -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=unset -k perm_access" >>/etc/audit/rules.d/audit.rules
    grep -E -q "${Regex3}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F arch=b32 -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=unset -k perm_access" >>/etc/audit/rules.d/audit.rules
    (uname -p | grep -q '64' && grep -E -q "${Regex4}" /etc/audit/rules.d/audit.rules) || echo "-a always,exit -F arch=b64 -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=unset -k perm_access" >>/etc/audit/rules.d/audit.rules
    ( (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && grep -E -q "${Regex3}" /etc/audit/rules.d/audit.rules) && echo "${Success32}") || {
        echo "${Failure32}"
        exit 1
    }
    echo
    uname -p | grep -q '64' && { ( (grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules && grep -E -q "${Regex4}" /etc/audit/rules.d/audit.rules) && echo "${Success64}") || {
        echo "${Failure64}"
        exit 1
    }; } || echo "System is not a 64-bit architecture."
}

#Set audit to audit of successful/unsuccessful attempts to use creat, V-230454
function V230454() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+arch=b32\s+-S\s+creat\s+-F\s+exit=-EPERM\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_access\s*(#.*)?$"
    local Regex2="^\s*-a\s+always,exit\s+-F\s+arch=b64\s+-S\s+creat\s+-F\s+exit=-EPERM\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_access\s*(#.*)?$"
    local Regex3="^\s*-a\s+always,exit\s+-F\s+arch=b32\s+-S\s+creat\s+-F\s+exit=-EACCES\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_access\s*(#.*)?$"
    local Regex4="^\s*-a\s+always,exit\s+-F\s+arch=b64\s+-S\s+creat\s+-F\s+exit=-EACCES\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_access\s*(#.*)?$"
    local Success32="Auditing of successful/unsuccessful attempts to use creat is enabled on 32bit systems, per V-230454."
    local Success64="Auditing of successful/unsuccessful attempts to use creat is enabled on 64bit systems, per V-230454."
    local Failure32="Failed to set auditing of successful/unsuccessful attempts to use creat on 32bit systems, not in compliance with V-230454."
    local Failure64="Failed to set auditing of successful/unsuccessful attempts to use creat on 64bit systems, not in compliance with V-230454."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F arch=b32 -S creat -F exit=-EPERM -F auid>=1000 -F auid!=unset -k perm_access" >>/etc/audit/rules.d/audit.rules
    (uname -p | grep -q '64' && grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules) || echo "-a always,exit -F arch=b64 -S creat -F exit=-EPERM -F auid>=1000 -F auid!=unset -k perm_access" >>/etc/audit/rules.d/audit.rules
    grep -E -q "${Regex3}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F arch=b32 -S creat -F exit=-EACCES -F auid>=1000 -F auid!=unset -k perm_access" >>/etc/audit/rules.d/audit.rules
    (uname -p | grep -q '64' && grep -E -q "${Regex4}" /etc/audit/rules.d/audit.rules) || echo "-a always,exit -F arch=b64 -S creat -F exit=-EACCES -F auid>=1000 -F auid!=unset -k perm_access" >>/etc/audit/rules.d/audit.rules
    ( (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && grep -E -q "${Regex3}" /etc/audit/rules.d/audit.rules) && echo "${Success32}") || {
        echo "${Failure32}"
        exit 1
    }
    echo
    uname -p | grep -q '64' && { ( (grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules && grep -E -q "${Regex4}" /etc/audit/rules.d/audit.rules) && echo "${Success64}") || {
        echo "${Failure64}"
        exit 1
    }; } || echo "System is not a 64-bit architecture."
}

#Set audit to audit of successful/unsuccessful attempts to use chown,fchown,fchownat,lchown, V-230455
function V230455() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+arch=b32\s+-S\s+chown,fchown,fchownat,lchown\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_mod\s*(#.*)?$"
    local Regex2="^\s*-a\s+always,exit\s+-F\s+arch=b64\s+-S\s+chown,fchown,fchownat,lchown\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_mod\s*(#.*)?$"
    local Success32="Auditing of successful/unsuccessful attempts to use chown,fchown,fchownat,lchown is enabled on 32bit systems, per V-230455."
    local Success64="Auditing of successful/unsuccessful attempts to use chown,fchown,fchownat,lchown is enabled on 64bit systems, per V-230455."
    local Failure32="Failed to set auditing of successful/unsuccessful attempts to use chown,fchown,fchownat,lchown on 32bit systems, not in compliance with V-230455."
    local Failure64="Failed to set auditing of successful/unsuccessful attempts to use chown,fchown,fchownat,lchown on 64bit systems, not in compliance with V-230455."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F arch=b32 -S chown,fchown,fchownat,lchown -F auid>=1000 -F auid!=unset -k perm_mod" >>/etc/audit/rules.d/audit.rules
    (uname -p | grep -q '64' && grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules) || echo "-a always,exit -F arch=b64 -S chown,fchown,fchownat,lchown -F auid>=1000 -F auid!=unset -k perm_mod" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success32}") || {
        echo "${Failure32}"
        exit 1
    }
    echo
    uname -p | grep -q '64' && { (grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules && echo "${Success64}") || {
        echo "${Failure64}"
        exit 1
    }; } || echo "System is not a 64-bit architecture."
}

#Set audit to audit of successful/unsuccessful attempts to use chmod,fchmod,fchmodat, V-230456
function V230456() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+arch=b32\s+-S\s+chmod,fchmod,fchmodat\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_mod\s*(#.*)?$"
    local Regex2="^\s*-a\s+always,exit\s+-F\s+arch=b64\s+-S\s+chmod,fchmod,fchmodat\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_mod\s*(#.*)?$"
    local Success32="Auditing of successful/unsuccessful attempts to use chmod,fchmod,fchmodat is enabled on 32bit systems, per V-230456."
    local Success64="Auditing of successful/unsuccessful attempts to use chmod,fchmod,fchmodat is enabled on 64bit systems, per V-230456."
    local Failure32="Failed to set auditing of successful/unsuccessful attempts to use chmod,fchmod,fchmodat on 32bit systems, not in compliance with V-230456."
    local Failure64="Failed to set auditing of successful/unsuccessful attempts to use chmod,fchmod,fchmodat on 64bit systems, not in compliance with V-230456."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F arch=b32 -S chmod,fchmod,fchmodat -F auid>=1000 -F auid!=unset -k perm_mod" >>/etc/audit/rules.d/audit.rules
    (uname -p | grep -q '64' && grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules) || echo "-a always,exit -F arch=b64 -S chmod,fchmod,fchmodat -F auid>=1000 -F auid!=unset -k perm_mod" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success32}") || {
        echo "${Failure32}"
        exit 1
    }
    echo
    uname -p | grep -q '64' && { (grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules && echo "${Success64}") || {
        echo "${Failure64}"
        exit 1
    }; } || echo "System is not a 64-bit architecture."
}

#Set audit to audit of successful/unsuccessful attempts to use lchown, V-230457
function V230457() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+arch=b32\s+-S\s+lchown\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_mod\s*(#.*)?$"
    local Regex2="^\s*-a\s+always,exit\s+-F\s+arch=b64\s+-S\s+lchown\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_mod\s*(#.*)?$"
    local Success32="Auditing of successful/unsuccessful attempts to use lchown is enabled on 32bit systems, per V-230457."
    local Success64="Auditing of successful/unsuccessful attempts to use lchown is enabled on 64bit systems, per V-230457."
    local Failure32="Failed to set auditing of successful/unsuccessful attempts to use lchown on 32bit systems, not in compliance with V-230457."
    local Failure64="Failed to set auditing of successful/unsuccessful attempts to use lchown on 64bit systems, not in compliance with V-230457."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F arch=b32 -S lchown -F auid>=1000 -F auid!=unset -k perm_mod" >>/etc/audit/rules.d/audit.rules
    (uname -p | grep -q '64' && grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules) || echo "-a always,exit -F arch=b64 -S lchown -F auid>=1000 -F auid!=unset -k perm_mod" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success32}") || {
        echo "${Failure32}"
        exit 1
    }
    echo
    uname -p | grep -q '64' && { (grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules && echo "${Success64}") || {
        echo "${Failure64}"
        exit 1
    }; } || echo "System is not a 64-bit architecture."
}

#Set audit to audit of successful/unsuccessful attempts to use fchownat, V-230458
function V230458() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+arch=b32\s+-S\s+fchownat\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_mod\s*(#.*)?$"
    local Regex2="^\s*-a\s+always,exit\s+-F\s+arch=b64\s+-S\s+fchownat\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_mod\s*(#.*)?$"
    local Success32="Auditing of successful/unsuccessful attempts to use fchownat is enabled on 32bit systems, per V-230458."
    local Success64="Auditing of successful/unsuccessful attempts to use fchownat is enabled on 64bit systems, per V-230458."
    local Failure32="Failed to set auditing of successful/unsuccessful attempts to use fchownat on 32bit systems, not in compliance with V-230458."
    local Failure64="Failed to set auditing of successful/unsuccessful attempts to use fchownat on 64bit systems, not in compliance with V-230458."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F arch=b32 -S fchownat -F auid>=1000 -F auid!=unset -k perm_mod" >>/etc/audit/rules.d/audit.rules
    (uname -p | grep -q '64' && grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules) || echo "-a always,exit -F arch=b64 -S fchownat -F auid>=1000 -F auid!=unset -k perm_mod" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success32}") || {
        echo "${Failure32}"
        exit 1
    }
    echo
    uname -p | grep -q '64' && { (grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules && echo "${Success64}") || {
        echo "${Failure64}"
        exit 1
    }; } || echo "System is not a 64-bit architecture."
}

#Set audit to audit of successful/unsuccessful attempts to use fchown, V-230459
function V230459() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+arch=b32\s+-S\s+fchown\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_mod\s*(#.*)?$"
    local Regex2="^\s*-a\s+always,exit\s+-F\s+arch=b64\s+-S\s+fchown\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_mod\s*(#.*)?$"
    local Success32="Auditing of successful/unsuccessful attempts to use fchown is enabled on 32bit systems, per V-230459."
    local Success64="Auditing of successful/unsuccessful attempts to use fchown is enabled on 64bit systems, per V-230459."
    local Failure32="Failed to set auditing of successful/unsuccessful attempts to use fchown on 32bit systems, not in compliance with V-230459."
    local Failure64="Failed to set auditing of successful/unsuccessful attempts to use fchown on 64bit systems, not in compliance with V-230459."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F arch=b32 -S fchown -F auid>=1000 -F auid!=unset -k perm_mod" >>/etc/audit/rules.d/audit.rules
    (uname -p | grep -q '64' && grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules) || echo "-a always,exit -F arch=b64 -S fchown -F auid>=1000 -F auid!=unset -k perm_mod" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success32}") || {
        echo "${Failure32}"
        exit 1
    }
    echo
    uname -p | grep -q '64' && { (grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules && echo "${Success64}") || {
        echo "${Failure64}"
        exit 1
    }; } || echo "System is not a 64-bit architecture."
}

#Set audit to audit of successful/unsuccessful attempts to use fchmodat, V-230460
function V230460() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+arch=b32\s+-S\s+fchmodat\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_mod\s*(#.*)?$"
    local Regex2="^\s*-a\s+always,exit\s+-F\s+arch=b64\s+-S\s+fchmodat\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_mod\s*(#.*)?$"
    local Success32="Auditing of successful/unsuccessful attempts to use fchmodat is enabled on 32bit systems, per V-230460."
    local Success64="Auditing of successful/unsuccessful attempts to use fchmodat is enabled on 64bit systems, per V-230460."
    local Failure32="Failed to set auditing of successful/unsuccessful attempts to use fchmodat on 32bit systems, not in compliance with V-230460."
    local Failure64="Failed to set auditing of successful/unsuccessful attempts to use fchmodat on 64bit systems, not in compliance with V-230460."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F arch=b32 -S fchmodat -F auid>=1000 -F auid!=unset -k perm_mod" >>/etc/audit/rules.d/audit.rules
    (uname -p | grep -q '64' && grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules) || echo "-a always,exit -F arch=b64 -S fchmodat -F auid>=1000 -F auid!=unset -k perm_mod" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success32}") || {
        echo "${Failure32}"
        exit 1
    }
    echo
    uname -p | grep -q '64' && { (grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules && echo "${Success64}") || {
        echo "${Failure64}"
        exit 1
    }; } || echo "System is not a 64-bit architecture."
}

#Set audit to audit of successful/unsuccessful attempts to use fchmod, V-230461
function V230461() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+arch=b32\s+-S\s+fchmod\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_mod\s*(#.*)?$"
    local Regex2="^\s*-a\s+always,exit\s+-F\s+arch=b64\s+-S\s+fchmod\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_mod\s*(#.*)?$"
    local Success32="Auditing of successful/unsuccessful attempts to use fchmod is enabled on 32bit systems, per V-230461."
    local Success64="Auditing of successful/unsuccessful attempts to use fchmod is enabled on 64bit systems, per V-230461."
    local Failure32="Failed to set auditing of successful/unsuccessful attempts to use fchmod on 32bit systems, not in compliance with V-230461."
    local Failure64="Failed to set auditing of successful/unsuccessful attempts to use fchmod on 64bit systems, not in compliance with V-230461."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F arch=b32 -S fchmod -F auid>=1000 -F auid!=unset -k perm_mod" >>/etc/audit/rules.d/audit.rules
    (uname -p | grep -q '64' && grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules) || echo "-a always,exit -F arch=b64 -S fchmod -F auid>=1000 -F auid!=unset -k perm_mod" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success32}") || {
        echo "${Failure32}"
        exit 1
    }
    echo
    uname -p | grep -q '64' && { (grep -E -q "${Regex2}" /etc/audit/rules.d/audit.rules && echo "${Success64}") || {
        echo "${Failure64}"
        exit 1
    }; } || echo "System is not a 64-bit architecture."
}

#Set audit to audit of successful/unsuccessful attempts to use sudo, V-230462
function V230462() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+path=/usr/bin/sudo\s+-F\s+perm=x\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+priv_cmd\s*(#.*)?$"
    local Success="Auditing of successful/unsuccessful attempts to use sudo is enabled, per V-230462."
    local Failure="Failed to set auditing of successful/unsuccessful attempts to use sudo, not in compliance with V-230462."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F path=/usr/bin/sudo -F perm=x -F auid>=1000 -F auid!=unset -k priv_cmd" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set audit to audit of successful/unsuccessful attempts to use usermod, V-230463
function V230463() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+path=/usr/sbin/usermod\s+-F\s+perm=x\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+privileged-usermod\s*(#.*)?$"
    local Success="Auditing of successful/unsuccessful attempts to use usermod is enabled, per V-230463."
    local Failure="Failed to set auditing of successful/unsuccessful attempts to use usermod, not in compliance with V-230463."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F path=/usr/sbin/usermod -F perm=x -F auid>=1000 -F auid!=unset -k privileged-usermod" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set audit to audit of successful/unsuccessful attempts to use chacl, V-230464
function V230464() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+path=/usr/bin/chacl\s+-F\s+perm=x\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+perm_mod\s*(#.*)?$"
    local Success="Auditing of successful/unsuccessful attempts to use chacl is enabled, per V-230464."
    local Failure="Failed to set auditing of successful/unsuccessful attempts to use chacl, not in compliance with V-230464."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F path=/usr/bin/chacl -F perm=x -F auid>=1000 -F auid!=unset -k perm_mod" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set audit to audit the use kmod, V-230465
function V230465() {
    local Regex1="^\s*-a\s+always,exit\s+-F\s+path=/usr/bin/kmod\s+-F\s+perm=x\s+-F\s+auid>=1000\s+-F\s+auid!=unset\s+-k\s+modules\s*(#.*)?$"
    local Success="Auditing of successful/unsuccessful attempts to use kmod is enabled, per V-230465."
    local Failure="Failed to set auditing of successful/unsuccessful attempts to use kmod, not in compliance with V-230465."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-a always,exit -F path=/usr/bin/kmod -F perm=x -F auid>=1000 -F auid!=unset -k modules" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set audit to audit of successful/unsuccessful modifications to faillock, V-230466
function V230466() {
    local Regex1="^(\s*)#\s*dir\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#\s*dir\s*=\s*\S+(\s*#.*)?\s*$/dir = \/var\/log\/faillock\2/"
    local Regex3="^(\s*)dir\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)dir\s*=\s*\S+(\s*#.*)?\s*$/dir = \/var\/log\/faillock\2/"
    local Regex5="^(\s*)dir\s*=\s*\/var\/log\/faillock\s*$"
    local Regex6="^\s*-w\s+/var/log/faillock\s+-p\s+wa\s+-k\s+logins\s*(#.*)?$"
    local Success82="Set faillock logging path, per V-230466."
    local Failure82="Failed to set faillock logging path, not in compliance V-230466."
    local Success="Auditing of successful/unsuccessful attempts to use faillock, per V-230466."
    local Failure="Failed to set auditing of when successful/unsuccessful attempts to use faillock occur, not in compliance V-230466."

    echo
    grep -E -q "${Regex6}" /etc/audit/rules.d/audit.rules || echo "-w /var/log/faillock -p wa -k logins" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex6}" /etc/audit/rules.d/audit.rules && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set audit to audit of successful/unsuccessful modifications to lastlog, V-230467
function V230467() {
    local Regex1="^\s*-w\s+/var/log/lastlog\s+-p\s+wa\s+-k\s+logins\s*(#.*)?$"
    local Success="Auditing of successful/unsuccessful attempts to use lastlog, per V-230467."
    local Failure="Failed to set auditing of when successful/unsuccessful attempts to use lastlog occur, not in compliance V-230467."

    echo
    grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules || echo "-w /var/log/lastlog -p wa -k logins" >>/etc/audit/rules.d/audit.rules
    (grep -E -q "${Regex1}" /etc/audit/rules.d/audit.rules && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Install rsyslog-gnutls if not already installed, V-230478
function V230478() {
    local Success="rsyslog-gnutls has been installed, per V-230478."
    local Failure="rsyslog-gnutls is not installed, skipping V-230478."

    echo
    if ! yum -q list installed rsyslog-gnutls &>/dev/null; then
        echo "${Failure}"
    else
        echo "${Success}"
    fi
}

#Set audit queue action once audit logs are full, V-230480
function V230480() {
    local Regex1="^(\s*)#\s*overflow_action\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#\s*overflow_action\s*=\s*\S+(\s*#.*)?\s*$/overflow_action = syslog\2/"
    local Regex3="^(\s*)overflow_action\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)overflow_action\s*=\s*\S+(\s*#.*)?\s*$/overflow_action = syslog\2/"
    local Regex5="^(\s*)overflow_action\s*=\s*syslog\s*$"
    local Success="Set audit queue action once audit logs are full, per V-230480"
    local Failure="Failed to set audit queue action once audit logs are full, not in compliance with V-230480."

    echo
    ( (grep -E -q "${Regex1}" /etc/audit/auditd.conf && sed -ri "${Regex2}" /etc/audit/auditd.conf) || (grep -E -q "${Regex3}" /etc/audit/auditd.conf && sed -ri "${Regex4}" /etc/audit/auditd.conf)) || echo "overflow_action = syslog" >>/etc/audit/auditd.conf
    (grep -E -q "${Regex5}" /etc/audit/auditd.conf && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Remove abrt* if installed, V-230488
function V230488() {
    local Success="abrt* has been removed, per V-230488."
    local Failure="Failed to remove abrt*, not in compliance with V-230488."

    echo

    if yum -q list installed abrt* &>/dev/null; then
        yum remove -q -y abrt* &>/dev/null
        { (yum -q list installed abrt* &>/dev/null) && {
            echo "${Failure}"
            exit 1
        }; } || echo "${Success}"
    else
        echo "${Success}"
    fi
}

#Remove sendmail if installed, V-230489
function V230489() {
    local Success="sendmail has been removed, per V-230489."
    local Failure="Failed to remove sendmail, not in compliance with V-230489."

    echo

    if yum -q list installed sendmail &>/dev/null; then
        yum remove -q -y sendmail &>/dev/null
        { (yum -q list installed sendmail &>/dev/null) && {
            echo "${Failure}"
            exit 1
        }; } || echo "${Success}"
    else
        echo "${Success}"
    fi
}

#Disable system automounter, V-230502
function V230502() {
    local Success="Disabled AUTOFS on the system, per V-230502."
    local Failure="Failed to disabled AUTOFS on the system, not in compliance with V-230502."
    local Notinstalled="AUTOFS was not installed on the system.  Disabled by default, per V-230502."

    echo
    if ! systemctl list-unit-files --full -all | grep -E -q '^autofs.service'; then
        echo "${Notinstalled}"
    else
        if systemctl status autofs.service | grep -E -q "active"; then
            systemctl stop autofs.service &>/dev/null
            systemctl disable autofs.service &>/dev/null
        fi

        if systemctl status autofs.service | grep -E -q "failed"; then
            systemctl stop autofs.service &>/dev/null
            systemctl disable autofs.service &>/dev/null
        fi

        ( (systemctl status autofs.service | grep -E -q "disabled|dead") && echo "${Success}") || {
            echo "${Failure}"
            exit 1
        }
    fi
}

#Disable the USB Storage kernel module, V-230503.
function V230503() {
    local Regex1="^\s*#install\s*usb-storage\s*/bin/true\s*"
    local Regex2="s/^(\s*)#install\s*usb-storage\s*(\s*#.*)?\s*$/\install usb-storage \/bin\/true\2/"
    local Regex3="^(\s*)install\s*usb-storage\s*(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)install\s*usb-storage\s*(\s*#.*)?\s*$/\install usb-storage \/bin\/true\2/"
    local Regex5="^(\s*)install\s*usb-storage\s*/bin/true?\s*$"
    local Regex6="^(\s*)#blacklist usb-storage\s*(\s*#.*)?\s*$"
    local Regex7="s/^(\s*)#blacklist usb-storage\s*(\s*#.*)?\s*$/\blacklist usb-storage\2/"
    local Regex8="^(\s*)blacklist\s*usb-storage\s*(\s*#.*)?\s*$"
    local Regex9="s/^(\s*)blacklist usb-storage\s*(\s*#.*)?\s*$/\blacklist usb-storage\2/"
    local Regex10="^(\s*)blacklist\s*usb-storage?\s*$"
    local Success="Disabled the ability to load USB Storage kernel module, per V-230503."
    local Failure="Failed to disable the ability to load USB Storage kernel module on the system, not in compliance V-230503."

    if [ ! -d "/etc/modprobe.d/" ]; then
        mkdir -p /etc/modprobe.d/
    fi

    if [ -f "/etc/modprobe.d/blacklist.conf" ]; then
        ( (grep -E -q "${Regex1}" /etc/modprobe.d/blacklist.conf && sed -ri "${Regex2}" /etc/modprobe.d/blacklist.conf) || (grep -E -q "${Regex3}" /etc/modprobe.d/blacklist.conf && sed -ri "${Regex4}" /etc/modprobe.d/blacklist.conf)) || echo "install usb-storage /bin/true" >>/etc/modprobe.d/blacklist.conf
        ( (grep -E -q "${Regex6}" /etc/modprobe.d/blacklist.conf && sed -ri "${Regex7}" /etc/modprobe.d/blacklist.conf) || (grep -E -q "${Regex8}" /etc/modprobe.d/blacklist.conf && sed -ri "${Regex9}" /etc/modprobe.d/blacklist.conf)) || echo "blacklist usb-storage" >>/etc/modprobe.d/blacklist.conf
    else
        echo -e "install usb-storage /bin/true" >>/etc/modprobe.d/blacklist.conf
        echo -e "blacklist usb-storage" >>/etc/modprobe.d/blacklist.conf
    fi

    echo
    (grep -E -q "${Regex5}" /etc/modprobe.d/blacklist.conf && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
    echo
    (grep -E -q "${Regex10}" /etc/modprobe.d/blacklist.conf && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Install openssh-server and enable if not already installed, V-230526 and V-244549
function V230526() {
    local Success="openssh-server has been installed and enabled, per V-230526 and V-244549."
    local Failure="Failed to install and enable openssh-server, not in compliance with V-230526 and V-244549."

    echo
    if ! yum -q list installed openssh-server &>/dev/null; then
        yum install -q -y openssh-server
    else
        if systemctl is-active sshd.service | grep -E -q "active"; then
            systemctl enable sshd.service
            echo "${Success}"
        else
            systemctl start sshd.service
            systemctl enable sshd.service
            ( (systemctl is-active sshd.service | grep -E -q "active") && echo "${Success}") || {
                echo "${Failure}"
                exit 1
            }
        fi
    fi
}

#Set SSH to renegotiation SSH connections frequently to the server, V-230527
function V230527() {
    local Regex1="^(\s*)#\s*\s*\s*RekeyLimit\s*\S+(\s*.*)?\s*$"
    local Regex2="s/^(\s*)#RekeyLimit\s+\S+(\s*.*)?\s*$/\RekeyLimit 1G 1h/"
    local Regex3="^(\s*)RekeyLimit\s+\S+(\s*.*)?\s*$"
    local Regex4="s/^(\s*)RekeyLimit\s+\S+(\s*.*)?\s*$/\RekeyLimit 1G 1h/"
    local Regex5="^(\s*)RekeyLimit\s*1G\s*1h?\s*$"
    local Success="Set SSH to renegotiation SSH connections frequently to the server, per V-230527."
    local Failure="Failed to set SSH to renegotiation SSH connections frequently to the server, not in compliance V-230527."

    echo
    ( (grep -E -q "${Regex1}" /etc/ssh/sshd_config && sed -ri "${Regex2}" /etc/ssh/sshd_config) || (grep -E -q "${Regex3}" /etc/ssh/sshd_config && sed -ri "${Regex4}" /etc/ssh/sshd_config)) || echo "RekeyLimit 1G 1h" >>/etc/ssh/sshd_config
    (grep -E -q "${Regex5}" /etc/ssh/sshd_config && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set SSH to renegotiation SSH connections frequently to the client, V-230528
function V230528() {
    local Regex1="^(\s*)#RekeyLimit\s*\S+(\s*.*)?\s*$"
    local Regex2="s/^(\s*)#RekeyLimit\s+\S+(\s*.*)?\s*$/\RekeyLimit 1G 1h/"
    local Regex3="^(\s*)RekeyLimit\s+\S+(\s*.*)?\s*$"
    local Regex4="s/^(\s*)RekeyLimit\s+\S+(\s*.*)?\s*$/\RekeyLimit 1G 1h/"
    local Regex5="^(\s*)RekeyLimit\s*1G\s*1h?\s*$"
    local Success="Set SSH to renegotiation SSH connections frequently to the client, per V-230528."
    local Failure="Failed to set SSH to renegotiation SSH connections frequently to the client, not in compliance V-230528."

    echo
    ( (grep -E -q "${Regex1}" /etc/ssh/ssh_config && sed -ri "${Regex2}" /etc/ssh/ssh_config) || (grep -E -q "${Regex3}" /etc/ssh/ssh_config && sed -ri "${Regex4}" /etc/ssh/ssh_config)) || echo "RekeyLimit 1G 1h" >>/etc/ssh/ssh_config
    (grep -E -q "${Regex5}" /etc/ssh/ssh_config && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Disable and mask debug-shell, V-230532
function V230532() {
    local Success="debug-shell is disabled, per V-230532"
    local Failure="debug-shell hasn't been disabled, not in compliance with per V-230532"
    local Notinstalled="debug-shell was not installed on the system.  Disabled by default, per V-230532."

    echo

    if ! systemctl list-unit-files --full -all | grep -E -q '^debug-shell.service'; then
        echo "${Notinstalled}"
    else
        if systemctl status debug-shell.service | grep -E -q "active"; then
            systemctl stop debug-shell.service &>/dev/null
            systemctl disable debug-shell.service &>/dev/null
            systemctl mask debug-shell.service &>/dev/null
        fi

        if systemctl status debug-shell.service | grep -E -q "failed"; then
            (systemctl status debug-shell.service | grep -q "Loaded: masked" && echo "${Success}") || {
                echo "${Failure}"
                exit 1
            }
        else
            ( (systemctl status debug-shell.service | grep -q "Loaded: masked" && systemctl status debug-shell.service | grep -q "Active: inactive") && echo "${Success}") || {
                echo "${Failure}"
                exit 1
            }
        fi
    fi
}

#Set OS to not accept IPv6 ICMP redirects, V-230535
function V230535() {
    local Regex1="^(\s*)#net.ipv6.conf.default.accept_redirects\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#net.ipv6.conf.default.accept_redirects\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv6.conf.default.accept_redirects = 0\2/"
    local Regex3="^(\s*)net.ipv6.conf.default.accept_redirects\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)net.ipv6.conf.default.accept_redirects\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv6.conf.default.accept_redirects = 0\2/"
    local Regex5="^(\s*)net.ipv6.conf.default.accept_redirects\s*=\s*0?\s*$"
    local Success="Set system to not accept ICMP redirects on IPv6, per V-230535."
    local Failure="Failed to set the system to not accept ICMP redirects on IPv6, not in compliance V-230535."

    echo
    sysctl -w net.ipv6.conf.default.accept_redirects=0 &>/dev/null
    ( (grep -E -q "${Regex1}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex2}" /etc/sysctl.d/99-sysctl.conf) || (grep -E -q "${Regex3}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex4}" /etc/sysctl.d/99-sysctl.conf)) || echo "net.ipv6.conf.default.accept_redirects = 0" >>/etc/sysctl.d/99-sysctl.conf

    sysctl --quiet --system

    ( (grep -E -q "${Regex5}" /etc/sysctl.d/99-sysctl.conf && sysctl net.ipv6.conf.default.accept_redirects | grep -E -q "${Regex5}") && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set OS to not allow sending ICMP redirects, V-230536
function V230536() {
    local Regex1="^(\s*)#net.ipv4.conf.all.send_redirects\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#net.ipv4.conf.all.send_redirects\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv4.conf.all.send_redirects = 0\2/"
    local Regex3="^(\s*)net.ipv4.conf.all.send_redirects\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)net.ipv4.conf.all.send_redirects\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv4.conf.all.send_redirects = 0\2/"
    local Regex5="^(\s*)net.ipv4.conf.all.send_redirects\s*=\s*0?\s*$"
    local Success="Set system to not send ICMP redirects on IPv4, per V-230536."
    local Failure="Failed to set the system to not send ICMP redirects on IPv4, not in compliance V-230536."

    echo
    sysctl -w net.ipv4.conf.all.send_redirects=0 &>/dev/null
    ( (grep -E -q "${Regex1}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex2}" /etc/sysctl.d/99-sysctl.conf) || (grep -E -q "${Regex3}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex4}" /etc/sysctl.d/99-sysctl.conf)) || echo "net.ipv4.conf.all.send_redirects = 0" >>/etc/sysctl.d/99-sysctl.conf

    sysctl --quiet --system

    ( (grep -E -q "${Regex5}" /etc/sysctl.d/99-sysctl.conf && sysctl net.ipv4.conf.all.send_redirects | grep -E -q "${Regex5}") && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set OS to not respond to ICMP, V-230537
function V230537() {
    local Regex1="^(\s*)#net.ipv4.icmp_echo_ignore_broadcasts\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#net.ipv4.icmp_echo_ignore_broadcasts\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv4.icmp_echo_ignore_broadcasts = 1\2/"
    local Regex3="^(\s*)net.ipv4.icmp_echo_ignore_broadcasts\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)net.ipv4.icmp_echo_ignore_broadcasts\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv4.icmp_echo_ignore_broadcasts = 1\2/"
    local Regex5="^(\s*)net.ipv4.icmp_echo_ignore_broadcasts\s*=\s*1?\s*$"
    local Success="Set system to not respond to ICMP on IPv4, per V-230537."
    local Failure="Failed to set the system to not respond to ICMP on IPv4, not in compliance V-230537."

    echo
    sysctl -w net.ipv4.icmp_echo_ignore_broadcasts=1 &>/dev/null
    ( (grep -E -q "${Regex1}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex2}" /etc/sysctl.d/99-sysctl.conf) || (grep -E -q "${Regex3}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex4}" /etc/sysctl.d/99-sysctl.conf)) || echo "net.ipv4.icmp_echo_ignore_broadcasts = 1" >>/etc/sysctl.d/99-sysctl.conf

    sysctl --quiet --system

    ( (grep -E -q "${Regex5}" /etc/sysctl.d/99-sysctl.conf && sysctl net.ipv4.icmp_echo_ignore_broadcasts | grep -E -q "${Regex5}") && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set OS to not accept IPv6 source-routed packets, V-230538
function V230538() {
    local Regex1="^(\s*)#net.ipv6.conf.all.accept_source_route\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#net.ipv6.conf.all.accept_source_route\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv6.conf.all.accept_source_route = 0\2/"
    local Regex3="^(\s*)net.ipv6.conf.all.accept_source_route\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)net.ipv6.conf.all.accept_source_route\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv6.conf.all.accept_source_route = 0\2/"
    local Regex5="^(\s*)net.ipv6.conf.all.accept_source_route\s*=\s*0?\s*$"
    local Success="Set system to not accept IPv6 source-routed packets, per V-230538."
    local Failure="Failed to set the system to not accept IPv6 source-routed packets, not in compliance V-230538."

    echo
    sysctl -w net.ipv6.conf.all.accept_source_route=0 &>/dev/null
    ( (grep -E -q "${Regex1}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex2}" /etc/sysctl.d/99-sysctl.conf) || (grep -E -q "${Regex3}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex4}" /etc/sysctl.d/99-sysctl.conf)) || echo "net.ipv6.conf.all.accept_source_route = 0" >>/etc/sysctl.d/99-sysctl.conf

    sysctl --quiet --system

    ( (grep -E -q "${Regex5}" /etc/sysctl.d/99-sysctl.conf && sysctl net.ipv6.conf.all.accept_source_route | grep -E -q "${Regex5}") && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set OS to not accept IPv6 source-routed packets by default, V-230539
function V230539() {
    local Regex1="^(\s*)#net.ipv6.conf.default.accept_source_route\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#net.ipv6.conf.default.accept_source_route\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv6.conf.default.accept_source_route = 0\2/"
    local Regex3="^(\s*)net.ipv6.conf.default.accept_source_route\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)net.ipv6.conf.default.accept_source_route\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv6.conf.default.accept_source_route = 0\2/"
    local Regex5="^(\s*)net.ipv6.conf.default.accept_source_route\s*=\s*0?\s*$"
    local Success="Set system to not accept IPv6 source-routed packets by default, per V-230539."
    local Failure="Failed to set the system to not accept IPv6 source-routed packets by default, not in compliance V-230539."

    echo
    sysctl -w net.ipv6.conf.default.accept_source_route=0 &>/dev/null
    ( (grep -E -q "${Regex1}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex2}" /etc/sysctl.d/99-sysctl.conf) || (grep -E -q "${Regex3}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex4}" /etc/sysctl.d/99-sysctl.conf)) || echo "net.ipv6.conf.default.accept_source_route = 0" >>/etc/sysctl.d/99-sysctl.conf

    sysctl --quiet --system

    ( (grep -E -q "${Regex5}" /etc/sysctl.d/99-sysctl.conf && sysctl net.ipv6.conf.default.accept_source_route | grep -E -q "${Regex5}") && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set OS to not perform IPv6 packet forwarding unless system is a router, V-230540
function V230540() {
    local Regex1="^(\s*)#net.ipv6.conf.all.forwarding\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#net.ipv6.conf.all.forwarding\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv6.conf.all.forwarding = 0\2/"
    local Regex3="^(\s*)net.ipv6.conf.all.forwarding\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)net.ipv6.conf.all.forwarding\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv6.conf.all.forwarding = 0\2/"
    local Regex5="^(\s*)net.ipv6.conf.all.forwarding\s*=\s*0?\s*$"
    local Success="Set system to not perform IPv6 package forwarding, per V-230540."
    local Failure="Failed to set the system to not perform IPv6 package forwarding, not in compliance V-230540."

    echo
    sysctl -w net.ipv6.conf.all.forwarding=0 &>/dev/null
    ( (grep -E -q "${Regex1}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex2}" /etc/sysctl.d/99-sysctl.conf) || (grep -E -q "${Regex3}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex4}" /etc/sysctl.d/99-sysctl.conf)) || echo "net.ipv6.conf.all.forwarding = 0" >>/etc/sysctl.d/99-sysctl.conf

    sysctl --quiet --system

    ( (grep -E -q "${Regex5}" /etc/sysctl.d/99-sysctl.conf && sysctl net.ipv6.conf.all.forwarding | grep -E -q "${Regex5}") && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#System must not accept router advertisements on IPv6 interfaces, V-230541
function V230541() {
    local Regex1="^(\s*)#net.ipv6.conf.all.accept_ra\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#net.ipv6.conf.all.accept_ra\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv6.conf.all.accept_ra = 0\2/"
    local Regex3="^(\s*)net.ipv6.conf.all.accept_ra\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)net.ipv6.conf.all.accept_ra\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv6.conf.all.accept_ra = 0\2/"
    local Regex5="^(\s*)net.ipv6.conf.all.accept_ra\s*=\s*0?\s*$"
    local Success="Set system to not accept router advertisements on IPv6 interfaces, per V-230541"
    local Failure="Failed to set system to not accept router advertisements on IPv6 interfaces, not in compliance with per V-230541"

    echo
    sysctl -w net.ipv6.conf.all.accept_ra=0 &>/dev/null
    ( (grep -E -q "${Regex1}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex2}" /etc/sysctl.d/99-sysctl.conf) || (grep -E -q "${Regex3}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex4}" /etc/sysctl.d/99-sysctl.conf)) || echo "net.ipv6.conf.all.accept_ra = 0" >>/etc/sysctl.d/99-sysctl.conf

    sysctl --quiet --system

    ( (grep -E -q "${Regex5}" /etc/sysctl.d/99-sysctl.conf && sysctl net.ipv6.conf.all.accept_ra | grep -E -q "${Regex5}") && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#System must not accept router advertisements on IPv6 interfaces by default, V-230542
function V230542() {
    local Regex1="^(\s*)#net.ipv6.conf.default.accept_ra\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#net.ipv6.conf.default.accept_ra\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv6.conf.default.accept_ra = 0\2/"
    local Regex3="^(\s*)net.ipv6.conf.default.accept_ra\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)net.ipv6.conf.default.accept_ra\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv6.conf.default.accept_ra = 0\2/"
    local Regex5="^(\s*)net.ipv6.conf.default.accept_ra\s*=\s*0?\s*$"
    local Success="Set system to not accept router advertisements on IPv6 interfaces by default, per V-230542"
    local Failure="Failed to set system to not accept router advertisements on IPv6 interfaces by default, not in compliance with per V-230542"

    echo
    sysctl -w net.ipv6.conf.default.accept_ra=0 &>/dev/null
    ( (grep -E -q "${Regex1}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex2}" /etc/sysctl.d/99-sysctl.conf) || (grep -E -q "${Regex3}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex4}" /etc/sysctl.d/99-sysctl.conf)) || echo "net.ipv6.conf.default.accept_ra = 0" >>/etc/sysctl.d/99-sysctl.conf

    sysctl --quiet --system

    ( (grep -E -q "${Regex5}" /etc/sysctl.d/99-sysctl.conf && sysctl net.ipv6.conf.default.accept_ra | grep -E -q "${Regex5}") && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set OS to not allow interfaces to perform ICMP redirects, V-230543
function V230543() {
    local Regex1="^(\s*)#net.ipv4.conf.default.send_redirects\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#net.ipv4.conf.default.send_redirects\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv4.conf.default.send_redirects = 0\2/"
    local Regex3="^(\s*)net.ipv4.conf.default.send_redirects\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)net.ipv4.conf.default.send_redirects\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv4.conf.default.send_redirects = 0\2/"
    local Regex5="^(\s*)net.ipv4.conf.default.send_redirects\s*=\s*0?\s*$"
    local Success="Set system to not peform ICMP redirects on IPv4 by default, per V-230543."
    local Failure="Failed to set the system to not peform ICMP redirects on IPv4 by default, not in compliance V-230543."

    echo
    sysctl -w net.ipv4.conf.default.send_redirects=0 &>/dev/null
    ( (grep -E -q "${Regex1}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex2}" /etc/sysctl.d/99-sysctl.conf) || (grep -E -q "${Regex3}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex4}" /etc/sysctl.d/99-sysctl.conf)) || echo "net.ipv4.conf.default.send_redirects = 0" >>/etc/sysctl.d/99-sysctl.conf

    sysctl --quiet --system

    ( (grep -E -q "${Regex5}" /etc/sysctl.d/99-sysctl.conf && sysctl net.ipv4.conf.default.send_redirects | grep -E -q "${Regex5}") && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set OS to ignore IPv6 ICMP redirects, V-230544
function V230544() {
    local Regex1="^(\s*)#net.ipv6.conf.all.accept_redirects\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#net.ipv6.conf.all.accept_redirects\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv6.conf.all.accept_redirects = 0\2/"
    local Regex3="^(\s*)net.ipv6.conf.all.accept_redirects\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)net.ipv6.conf.all.accept_redirects\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv6.conf.all.accept_redirects = 0\2/"
    local Regex5="^(\s*)net.ipv6.conf.all.accept_redirects\s*=\s*0?\s*$"
    local Success="Set system to ignore IPv4 or IPv6 ICMP redirect messages, per V-230544."
    local Failure="Failed to set the system to ignore IPv4 or IPv6 ICMP redirect messages, not in compliance V-230544."

    echo
    sysctl -w net.ipv6.conf.all.accept_redirects=0 &>/dev/null
    ( (grep -E -q "${Regex1}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex2}" /etc/sysctl.d/99-sysctl.conf) || (grep -E -q "${Regex3}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex4}" /etc/sysctl.d/99-sysctl.conf)) || echo "net.ipv6.conf.all.accept_redirects = 0" >>/etc/sysctl.d/99-sysctl.conf

    sysctl --quiet --system

    ( (grep -E -q "${Regex5}" /etc/sysctl.d/99-sysctl.conf && sysctl net.ipv6.conf.all.accept_redirects | grep -E -q "${Regex5}") && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#System disable access to network bpf syscall from unprivileged processes, V-230545
function V230545() {
    local Regex1="^(\s*)#kernel.unprivileged_bpf_disabled\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#kernel.unprivileged_bpf_disabled\s*=\s*\S+(\s*#.*)?\s*$/\1kernel.unprivileged_bpf_disabled = 1\2/"
    local Regex3="^(\s*)kernel.unprivileged_bpf_disabled\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)kernel.unprivileged_bpf_disabled\s*=\s*\S+(\s*#.*)?\s*$/\1kernel.unprivileged_bpf_disabled = 1\2/"
    local Regex5="^(\s*)kernel.unprivileged_bpf_disabled\s*=\s*1?\s*$"
    local Success="Set system to disable access to network bpf syscall from unprivileged processes, per V-230545"
    local Failure="Failed to set system to disable access to network bpf syscall from unprivileged processes, not in compliance with per V-230545"

    echo
    sysctl -w kernel.unprivileged_bpf_disabled=1 &>/dev/null
    ( (grep -E -q "${Regex1}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex2}" /etc/sysctl.d/99-sysctl.conf) || (grep -E -q "${Regex3}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex4}" /etc/sysctl.d/99-sysctl.conf)) || echo "kernel.unprivileged_bpf_disabled = 1" >>/etc/sysctl.d/99-sysctl.conf

    sysctl --quiet --system

    ( (grep -E -q "${Regex5}" /etc/sysctl.d/99-sysctl.conf && sysctl kernel.unprivileged_bpf_disabled | grep -E -q "${Regex5}") && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#System restrict usage of ptrace to descendant processes, V-230546
function V230546() {
    local Regex1="^(\s*)#kernel.yama.ptrace_scope\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#kernel.yama.ptrace_scope\s*=\s*\S+(\s*#.*)?\s*$/\1kernel.yama.ptrace_scope = 1\2/"
    local Regex3="^(\s*)kernel.yama.ptrace_scope\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)kernel.yama.ptrace_scope\s*=\s*\S+(\s*#.*)?\s*$/\1kernel.yama.ptrace_scope = 1\2/"
    local Regex5="^(\s*)kernel.yama.ptrace_scope\s*=\s*1?\s*$"
    local Success="Set system to restrict usage of ptrace to descendant processes, per V-230546"
    local Failure="Failed to set system to restrict usage of ptrace to descendant processes, not in compliance with per V-230546"

    echo
    sysctl -w kernel.yama.ptrace_scope=1 &>/dev/null
    ( (grep -E -q "${Regex1}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex2}" /etc/sysctl.d/99-sysctl.conf) || (grep -E -q "${Regex3}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex4}" /etc/sysctl.d/99-sysctl.conf)) || echo "kernel.yama.ptrace_scope = 1" >>/etc/sysctl.d/99-sysctl.conf

    sysctl --quiet --system

    ( (grep -E -q "${Regex5}" /etc/sysctl.d/99-sysctl.conf && sysctl kernel.yama.ptrace_scope | grep -E -q "${Regex5}") && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#System restricts exposed kernel pointer addresses access, V-230547
function V230547() {
    local Regex1="^(\s*)#kernel.kptr_restrict\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#kernel.kptr_restrict\s*=\s*\S+(\s*#.*)?\s*$/\1kernel.kptr_restrict = 1\2/"
    local Regex3="^(\s*)kernel.kptr_restrict\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)kernel.kptr_restrict\s*=\s*\S+(\s*#.*)?\s*$/\1kernel.kptr_restrict = 1\2/"
    local Regex5="^(\s*)kernel.kptr_restrict\s*=\s*1?\s*$"
    local Success="Set system to restricts exposed kernel pointer addresses access, per V-230547"
    local Failure="Failed to set system to restricts exposed kernel pointer addresses access, not in compliance with per V-230547"

    echo
    sysctl -w kernel.kptr_restrict=1 &>/dev/null
    ( (grep -E -q "${Regex1}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex2}" /etc/sysctl.d/99-sysctl.conf) || (grep -E -q "${Regex3}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex4}" /etc/sysctl.d/99-sysctl.conf)) || echo "kernel.kptr_restrict = 1" >>/etc/sysctl.d/99-sysctl.conf

    sysctl --quiet --system

    ( (grep -E -q "${Regex5}" /etc/sysctl.d/99-sysctl.conf && sysctl kernel.kptr_restrict | grep -E -q "${Regex5}") && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Disable the use of user namespaces, V-230548
function V230548() {
    local Regex1="^(\s*)#user.max_user_namespaces\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#user.max_user_namespaces\s*=\s*\S+(\s*#.*)?\s*$/\1user.max_user_namespaces = 0\2/"
    local Regex3="^(\s*)user.max_user_namespaces\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)user.max_user_namespaces\s*=\s*\S+(\s*#.*)?\s*$/\1user.max_user_namespaces = 0\2/"
    local Regex5="^(\s*)user.max_user_namespaces\s*=\s*0?\s*$"
    local Success="Enforced discretionary access control on hardlinks, per V-230268."
    local Failure="Failed to enforce discretionary access control on hardlinks, not in compliance V-230268."

    echo
    sysctl -w user.max_user_namespaces=0 &>/dev/null
    ( (grep -E -q "${Regex1}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex2}" /etc/sysctl.d/99-sysctl.conf) || (grep -E -q "${Regex3}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex4}" /etc/sysctl.d/99-sysctl.conf)) || echo "user.max_user_namespaces = 0" >>/etc/sysctl.d/99-sysctl.conf

    sysctl --quiet --system

    ( (grep -E -q "${Regex5}" /etc/sysctl.d/99-sysctl.conf && sysctl user.max_user_namespaces | grep -E -q "${Regex5}") && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#System must use reverse path filtering on all IPv4 interfaces, V-230549
function V230549() {
    local Regex1="^(\s*)#net.ipv4.conf.all.rp_filter\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#net.ipv4.conf.all.rp_filter\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv4.conf.all.rp_filter = 1\2/"
    local Regex3="^(\s*)net.ipv4.conf.all.rp_filter\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)net.ipv4.conf.all.rp_filter\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv4.conf.all.rp_filter = 1\2/"
    local Regex5="^(\s*)net.ipv4.conf.all.rp_filter\s*=\s*1?\s*$"
    local Success="Set system to use reverse path filtering on all IPv4 interfaces, per V-230549"
    local Failure="Failed to set system to use reverse path filtering on all IPv4 interfaces, not in compliance with per V-230549"

    echo
    sysctl -w net.ipv4.conf.all.rp_filter=1 &>/dev/null
    ( (grep -E -q "${Regex1}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex2}" /etc/sysctl.d/99-sysctl.conf) || (grep -E -q "${Regex3}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex4}" /etc/sysctl.d/99-sysctl.conf)) || echo "net.ipv4.conf.all.rp_filter = 1" >>/etc/sysctl.d/99-sysctl.conf

    sysctl --quiet --system

    ( (grep -E -q "${Regex5}" /etc/sysctl.d/99-sysctl.conf && sysctl net.ipv4.conf.all.rp_filter | grep -E -q "${Regex5}") && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set SSH X11 forwarding ensabled, V-230555
function V230555() {
    local Regex1="^(\s*)#X11Forwarding\s+\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#X11Forwarding\s+\S+(\s*#.*)?\s*$/\X11Forwarding no\2/"
    local Regex3="^(\s*)X11Forwarding\s+\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)X11Forwarding\s+\S+(\s*#.*)?\s*$/\X11Forwarding no\2/"
    local Regex5="^(\s*)X11Forwarding\s*no\s*$"
    local Success="Set SSH X11 forwarding ensabled, per V-230555."
    local Failure="Failed to set SSH X11 forwarding ensabled, not in compliance with V-230555."

    echo
    ( (grep -E -q "${Regex1}" /etc/ssh/sshd_config && sed -ri "${Regex2}" /etc/ssh/sshd_config) || (grep -E -q "${Regex3}" /etc/ssh/sshd_config && sed -ri "${Regex4}" /etc/ssh/sshd_config)) || echo "X11Forwarding no" >>/etc/ssh/sshd_config
    (grep -E -q "${Regex5}" /etc/ssh/sshd_config && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set SSH X11 UseLocalhost ensabled, V-230556
function V230556() {
    local Regex1="^(\s*)#X11UseLocalhost\s+\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#X11UseLocalhost\s+\S+(\s*#.*)?\s*$/\X11UseLocalhost yes\2/"
    local Regex3="^(\s*)X11UseLocalhost\s+\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)X11UseLocalhost\s+\S+(\s*#.*)?\s*$/\X11UseLocalhost yes\2/"
    local Regex5="^(\s*)X11UseLocalhost\s*yes\s*$"
    local Success="Set SSH X11 forwarding ensabled, per V-230556."
    local Failure="Failed to set SSH X11 forwarding ensabled, not in compliance with V-230556."

    echo
    ( (grep -E -q "${Regex1}" /etc/ssh/sshd_config && sed -ri "${Regex2}" /etc/ssh/sshd_config) || (grep -E -q "${Regex3}" /etc/ssh/sshd_config && sed -ri "${Regex4}" /etc/ssh/sshd_config)) || echo "X11UseLocalhost yes" >>/etc/ssh/sshd_config
    (grep -E -q "${Regex5}" /etc/ssh/sshd_config && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Remove gssproxy if installed, V-230559
function V230559() {
    local Success="gssproxy has been removed, per V-230559."
    local Failure="Failed to remove gssproxy, not in compliance with V-230559."

    echo

    if yum -q list installed gssproxy &>/dev/null; then
        yum remove -q -y gssproxy &>/dev/null
        { (yum -q list installed gssproxy &>/dev/null) && {
            echo "${Failure}"
            exit 1
        }; } || echo "${Success}"
    else
        echo "${Success}"
    fi
}

#Remove iprutils if installed, V-230560
function V230560() {
    local Success="iprutils has been removed, per V-230560."
    local Failure="Failed to remove iprutils, not in compliance with V-230560."

    echo

    if yum -q list installed iprutils &>/dev/null; then
        yum remove -q -y iprutils &>/dev/null
        { (yum -q list installed iprutils &>/dev/null) && {
            echo "${Failure}"
            exit 1
        }; } || echo "${Success}"
    else
        echo "${Success}"
    fi
}

#Remove tuned if installed, V-230561
function V230561() {
    local Success="tuned has been removed, per V-230561."
    local Failure="Failed to remove tuned, not in compliance with V-230561."

    echo

    if yum -q list installed tuned &>/dev/null; then
        yum remove -q -y tuned &>/dev/null
        { (yum -q list installed tuned &>/dev/null) && {
            echo "${Failure}"
            exit 1
        }; } || echo "${Success}"
    else
        echo "${Success}"
    fi
}

#Remove krb5-server if installed, V-237640
function V237640() {
    local Success="krb5-server has been removed, per V-237640."
    local Failure="Failed to remove krb5-server, not in compliance with V-237640."

    echo

    if yum -q list installed krb5-server &>/dev/null; then
        yum remove -q -y krb5-server &>/dev/null
        { (yum -q list installed krb5-server &>/dev/null) && {
            echo "${Failure}"
            exit 1
        }; } || echo "${Success}"
    else
        echo "${Success}"
    fi
}

#System must use the invoking user's password when using sudo, V-237642
function V237642() {
    local Regex1="^(\s*)#Defaults\s+\!targetpw(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#Defaults\s+\!targetpw(\s*#.*)?\s*$/\Defaults   !targetpw\2/"
    local Regex3="^(\s*)Defaults\s+\!targetpw(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)Defaults\s+\!targetpw(\s*#.*)?\s*$/\Defaults   !targetpw\2/"

    local Regex5="^(\s*)#Defaults\s+\!rootpw(\s*#.*)?\s*$"
    local Regex6="s/^(\s*)#Defaults\s+\!rootpw(\s*#.*)?\s*$/\Defaults   !rootpw\2/"
    local Regex7="^(\s*)Defaults\s+\!rootpw(\s*#.*)?\s*$"
    local Regex8="s/^(\s*)Defaults\s+\!rootpw(\s*#.*)?\s*$/\Defaults   !rootpw\2/"

    local Regex9="^(\s*)#Defaults\s+\!runaspw(\s*#.*)?\s*$"
    local Regex10="s/^(\s*)#Defaults\s+\!runaspw(\s*#.*)?\s*$/\Defaults   !runaspw\2/"
    local Regex11="^(\s*)Defaults\s+\!runaspw(\s*#.*)?\s*$"
    local Regex12="s/^(\s*)Defaults\s+\!runaspw(\s*#.*)?\s*$/\Defaults   !runaspw\2/"

    local Regex13="^(\s*)Defaults\s+\!targetpw?\s*$"
    local Regex14="^(\s*)Defaults\s+\!rootpw?\s*$"
    local Regex15="^(\s*)Defaults\s+\!runaspw?\s*$"
    local Success="Set system to use the invoking user's password when using sudo, per V-237642."
    local Failure="Failed to set system to use the invoking user's password when using sudo, not in compliance V-237642."

    echo
    ( (grep -E -q "${Regex1}" /etc/sudoers && sed -ri "${Regex2}" /etc/sudoers) || (grep -E -q "${Regex3}" /etc/sudoers && sed -ri "${Regex4}" /etc/sudoers)) || echo "Defaults   !targetpw" >>/etc/sudoers
    ( (grep -E -q "${Regex5}" /etc/sudoers && sed -ri "${Regex6}" /etc/sudoers) || (grep -E -q "${Regex7}" /etc/sudoers && sed -ri "${Regex8}" /etc/sudoers)) || echo "Defaults   !rootpw" >>/etc/sudoers
    ( (grep -E -q "${Regex9}" /etc/sudoers && sed -ri "${Regex10}" /etc/sudoers) || (grep -E -q "${Regex11}" /etc/sudoers && sed -ri "${Regex12}" /etc/sudoers)) || echo "Defaults   !runaspw" >>/etc/sudoers
    ( (grep -E -q "${Regex13}" /etc/sudoers && grep -E -q "${Regex14}" /etc/sudoers && grep -E -q "${Regex15}" /etc/sudoers) && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#System must require re-authentication when using sudo
function V237643() {
    local Regex1="^(\s*)#Defaults\s+timestamp_timeout\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#Defaults\s+timestamp_timeout\S+(\s*#.*)?\s*$/\Defaults   timestamp_timeout=0\2/"
    local Regex3="^(\s*)Defaults\s+timestamp_timeout\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)Defaults\s+timestamp_timeout\S+(\s*#.*)?\s*$/\Defaults   timestamp_timeout=0\2/"
    local Regex5="^(\s*)Defaults\s+timestamp_timeout=0?\s*$"
    local Success="Set system to require re-authentication when using sudo, per V-237635."
    local Failure="Failed to set system to require re-authentication when using sudo, not in compliance V-237635."

    echo
    ( (grep -E -q "${Regex1}" /etc/sudoers && sed -ri "${Regex2}" /etc/sudoers) || (grep -E -q "${Regex3}" /etc/sudoers && sed -ri "${Regex4}" /etc/sudoers)) || echo "Defaults   timestamp_timeout=0" >>/etc/sudoers
    (grep -E -q "${Regex5}" /etc/sudoers && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set system-auth to minimum number of hash rounds, V-244520
function V244520() {
    local Regex1="^\s*password\s+sufficient\s+pam_unix.so\s+"
    local Regex2="/^\s*password\s+sufficient\s+pam_unix.so\s+/ { /^\s*password\s+sufficient\s+pam_unix.so(\s+\S+)*(\s+rounds=5000)(\s+.*)?$/! s/^(\s*password\s+sufficient\s+pam_unix.so\s+)(.*)$/\1rounds=5000 \2/ }"
    local Regex3="^\s*password\s+sufficient\s+pam_unix.so\s+.*rounds=5000\s*.*$"
    local Success="System-auth is set to using a minimum number of hash rounds, per V-244520."
    local Failure="Failed to set system-auth to use a minimum number of hash rounds, not in compliance with V-244520."

    echo
    (grep -E -q "${Regex1}" /etc/pam.d/system-auth && sed -ri "${Regex2}" /etc/pam.d/system-auth)
    (grep -E -q "${Regex3}" /etc/pam.d/system-auth && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Require authentication upon booting into emergency mode, V-244523
function V244523() {
    local Regex1="^(\s*)ExecStart=\S+(\s*.*)?\s*$"
    local Regex2="s/^(\s*)ExecStart=.*/ExecStart=-\/usr\/lib\/systemd\/systemd-sulogin-shell emergency/"
    local Regex3="^(\s*)ExecStart=-/usr/lib/systemd/systemd-sulogin-shell\s*emergency?\s*$"
    local Success="Configured authentication upon booting into emergency mode, per V-244523."
    local Failure="Failed to configure authentication upon booting into emergency mode, not in compliance V-244523."

    echo
    (grep -E -q "${Regex1}" /usr/lib/systemd/system/emergency.service && sed -ri "${Regex2}" /usr/lib/systemd/system/emergency.service) || echo "ExecStart=-/usr/lib/systemd/systemd-sulogin-shell emergency" >>/usr/lib/systemd/system/emergency.service
    (grep -E -q "${Regex3}" /usr/lib/systemd/system/emergency.service && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set system-auth to use SHA512, V-244524
function V244524() {
    local Regex1="^\s*password\s+sufficient\s+pam_unix.so\s+"
    local Regex2="/^\s*password\s+sufficient\s+pam_unix.so\s+/ { /^\s*password\s+sufficient\s+pam_unix.so(\s+\S+)*(\s+sha512)(\s+.*)?$/! s/^(\s*password\s+sufficient\s+pam_unix.so\s+)(.*)$/\1sha512 \2/ }"
    local Regex3="^\s*password\s+sufficient\s+pam_unix.so\s+.*sha512\s*.*$"
    local Success="System-auth is set to use SHA512 encryption, per V-244524."
    local Failure="Failed to set system-auth to use SHA512 encryption, not in compliance with V-244524."

    echo
    (grep -E -q "${Regex1}" /etc/pam.d/system-auth && sed -ri "${Regex2}" /etc/pam.d/system-auth)
    (grep -E -q "${Regex3}" /etc/pam.d/system-auth && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set timeout period, V-244525
function V244525() {
    local Regex1="^(\s*)#ClientAliveInterval\s+\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#ClientAliveInterval\s+\S+(\s*#.*)?\s*$/\ClientAliveInterval 600\2/"
    local Regex3="^(\s*)ClientAliveInterval\s+\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)ClientAliveInterval\s+\S+(\s*#.*)?\s*$/\ClientAliveInterval 600\2/"
    local Regex5="^(\s*)ClientAliveInterval\s*600?\s*$"
    local Success="Set SSH user timeout interval, per V-244525."
    local Failure="Failed to set SSH user timeout period to 0 secs, not in compliance V-244525."

    echo
    ( (grep -E -q "${Regex1}" /etc/ssh/sshd_config && sed -ri "${Regex2}" /etc/ssh/sshd_config) || (grep -E -q "${Regex3}" /etc/ssh/sshd_config && sed -ri "${Regex4}" /etc/ssh/sshd_config)) || echo "ClientAliveInterval 600" >>/etc/ssh/sshd_config
    (grep -E -q "${Regex5}" /etc/ssh/sshd_config && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Configure SSH Server to use strong entropy, V-244526
function V244526() {
    local Regex1="^(\s*)#\s*CRYPTO_POLICY=(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#\s*CRYPTO_POLICY=(\s*#.*)?\s*$/\# CRYPTO_POLICY=\2/"
    local Regex3="^(\s*)CRYPTO_POLICY=(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)CRYPTO_POLICY=(\s*#.*)?\s*$/\# CRYPTO_POLICY=\2/"
    local Regex5="^(\s*)#\s*CRYPTO_POLICY=?\s*$"
    local Success="Configured SSH Server to use stron entropy, per V-244526."
    local Failure="Failed to configured SSH Server to use stron entropy, not in compliance V-244526."

    echo
    ( (grep -E -q "${Regex1}" /etc/sysconfig/sshd && sed -ri "${Regex2}" /etc/sysconfig/sshd) || (grep -E -q "${Regex3}" /etc/sysconfig/sshd && sed -ri "${Regex4}" /etc/sysconfig/sshd)) || echo "# CRYPTO_POLICY=" >>/etc/sysconfig/sshd
    (grep -E -q "${Regex5}" /etc/sysconfig/sshd && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set SSH to not allow GSSAPIAuthentication for authentication, V-244528
function V244528() {
    local Regex1="^(\s*)#GSSAPIAuthentication\s+\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#GSSAPIAuthentication\s+\S+(\s*#.*)?\s*$/\GSSAPIAuthentication no\2/"
    local Regex3="^(\s*)GSSAPIAuthentication\s+\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)GSSAPIAuthentication\s+\S+(\s*#.*)?\s*$/\GSSAPIAuthentication no\2/"
    local Regex5="^(\s*)GSSAPIAuthentication\s*no?\s*$"
    local Success="Set SSH to not allow GSSAPIAuthentication for authentication, per V-244528."
    local Failure="Failed to set SSH to not allow GSSAPIAuthentication for authentication, not in compliance V-244528."

    echo
    ( (grep -E -q "${Regex1}" /etc/ssh/sshd_config && sed -ri "${Regex2}" /etc/ssh/sshd_config) || (grep -E -q "${Regex3}" /etc/ssh/sshd_config && sed -ri "${Regex4}" /etc/ssh/sshd_config)) || echo "GSSAPIAuthentication no" >>/etc/ssh/sshd_config
    (grep -E -q "${Regex5}" /etc/ssh/sshd_config && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#/var/tmp must use a seperate file system, V-244529

#Set the system to use the pam_faillock.so module, V-244533 and V-244534
function V244533() {
    local Regex1="^\s*auth\s+required\s+pam_faillock.so\s*preauth\s*"
    local Regex2="s/^\s*auth\s+\s*\s*\s*required\s+pam_faillock.so\s*preauth\s*"
    local Regex3="auth        required                                     pam_faillock.so preauth"
    local Regex4="^\s*auth\s+required\s+pam_faillock.so\s*authfail\s*"
    local Regex5="s/^\s*auth\s+\s*\s*\s*required\s+pam_faillock.so\s*authfail\s*"
    local Regex6="auth        required                                     pam_faillock.so authfail"
    local Regex7="^\s*account\s+required\s+pam_faillock.so\s*"
    local Regex8="s/^\s*account\s+\s*\s*\s*required\s+pam_faillock.so\s*"
    local Regex9="account     required                                     pam_faillock.so"
    local Regex10="^(\s*)auth\s+required\s+\s*pam_faillock.so\s*preauth\s*$"
    local Regex11="^(\s*)auth\s+required\s+\s*pam_faillock.so\s*authfail\s*$"
    local Regex12="^(\s*)account\s+required\s+\s*pam_faillock.so\s*$"
    local Success="Set the system to use the pam_faillock.so module. Setting per V-244533 and V-244534."
    local Failure="Failed to set the system to use the pam_faillock.so module. Setting per V-244533 and V-244534."

    echo
    (grep -E -q "${Regex1}" /etc/pam.d/system-auth && sed -ri "${Regex2}.*$/${Regex3}/" /etc/pam.d/system-auth) || echo "auth        required                                     pam_faillock.so preauth" >>/etc/pam.d/system-auth
    (grep -E -q "${Regex1}" /etc/pam.d/password-auth && sed -ri "${Regex2}.*$/${Regex3}/" /etc/pam.d/password-auth) || echo "auth        required                                     pam_faillock.so preauth" >>/etc/pam.d/password-auth
    (grep -E -q "${Regex4}" /etc/pam.d/system-auth && sed -ri "${Regex5}.*$/${Regex6}/" /etc/pam.d/system-auth) || echo "auth        required                                     pam_faillock.so authfail" >>/etc/pam.d/system-auth
    (grep -E -q "${Regex4}" /etc/pam.d/password-auth && sed -ri "${Regex5}.*$/${Regex6}/" /etc/pam.d/password-auth) || echo "auth        required                                     pam_faillock.so authfail" >>/etc/pam.d/password-auth
    (grep -E -q "${Regex7}" /etc/pam.d/system-auth && sed -ri "${Regex8}.*$/${Regex9}/" /etc/pam.d/system-auth) || echo "${Regex9}" >>/etc/pam.d/system-auth
    (grep -E -q "${Regex7}" /etc/pam.d/password-auth && sed -ri "${Regex8}.*$/${Regex9}/" /etc/pam.d/password-auth) || echo "${Regex9}" >>/etc/pam.d/password-auth

    ( (grep -E -q "${Regex10}" /etc/pam.d/password-auth && grep -E -q "${Regex10}" /etc/pam.d/system-auth)) || {
        echo "${Failure}"
        exit 1
    }
    ( (grep -E -q "${Regex11}" /etc/pam.d/password-auth && grep -E -q "${Regex11}" /etc/pam.d/system-auth)) || {
        echo "${Failure}"
        exit 1
    }
    ( (grep -E -q "${Regex12}" /etc/pam.d/password-auth && grep -E -q "${Regex12}" /etc/pam.d/system-auth) && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set the auditd service is active, V-244542
function V244542() {
    local Success="Set the auditd service is active, per V-244542."
    local Failure="Failed to set the auditd service to active, not in compliance with V-244542."

    echo
    if systemctl is-active auditd.service | grep -E -q "active"; then
        systemctl enable auditd.service
        echo "${Success}"
    else
        systemctl start auditd.service
        systemctl enable auditd.service
        ( (systemctl is-active auditd.service | grep -E -q "active") && echo "${Success}") || {
            echo "${Failure}"
            exit 1
        }
    fi
}

#Set OS to not accept IPv4 ICMP redirects, V-244550
function V244550() {
    local Regex1="^(\s*)#net.ipv4.conf.default.accept_redirects\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#net.ipv4.conf.default.accept_redirects\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv4.conf.default.accept_redirects = 0\2/"
    local Regex3="^(\s*)net.ipv4.conf.default.accept_redirects\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)net.ipv4.conf.default.accept_redirects\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv4.conf.default.accept_redirects = 0\2/"
    local Regex5="^(\s*)net.ipv4.conf.default.accept_redirects\s*=\s*0?\s*$"
    local Success="Set system to not accept ICMP redirects on IPv4, per V-244550."
    local Failure="Failed to set the system to not accept ICMP redirects on IPv4, not in compliance V-244550."

    echo
    sysctl -w net.ipv4.conf.default.accept_redirects=0 &>/dev/null
    ( (grep -E -q "${Regex1}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex2}" /etc/sysctl.d/99-sysctl.conf) || (grep -E -q "${Regex3}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex4}" /etc/sysctl.d/99-sysctl.conf)) || echo "net.ipv4.conf.default.accept_redirects = 0" >>/etc/sysctl.d/99-sysctl.conf

    sysctl --quiet --system

    ( (grep -E -q "${Regex5}" /etc/sysctl.d/99-sysctl.conf && sysctl net.ipv4.conf.default.accept_redirects | grep -E -q "${Regex5}") && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set OS to not accept IPv4 or IPv6 source-routed packets, V-244551
function V244551() {
    local Regex1="^(\s*)#net.ipv4.conf.all.accept_source_route\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#net.ipv4.conf.all.accept_source_route\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv4.conf.all.accept_source_route = 0\2/"
    local Regex3="^(\s*)net.ipv4.conf.all.accept_source_route\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)net.ipv4.conf.all.accept_source_route\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv4.conf.all.accept_source_route = 0\2/"
    local Regex5="^(\s*)net.ipv4.conf.all.accept_source_route\s*=\s*0?\s*$"
    local Success="Set system to not accept IPv4 or IPv6 source-routed packets, per V-244551."
    local Failure="Failed to set the system to not accept IPv4 or IPv6 source-routed packets, not in compliance V-244551."

    echo
    sysctl -w net.ipv4.conf.all.accept_source_route=0 &>/dev/null
    ( (grep -E -q "${Regex1}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex2}" /etc/sysctl.d/99-sysctl.conf) || (grep -E -q "${Regex3}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex4}" /etc/sysctl.d/99-sysctl.conf)) || echo "net.ipv4.conf.all.accept_source_route = 0" >>/etc/sysctl.d/99-sysctl.conf

    sysctl --quiet --system

    ( (grep -E -q "${Regex5}" /etc/sysctl.d/99-sysctl.conf && sysctl net.ipv4.conf.all.accept_source_route | grep -E -q "${Regex5}") && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set OS to not accept IPv4 source-routed packets by default, V-244552
function V244552() {
    local Regex1="^(\s*)#net.ipv4.conf.default.accept_source_route\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#net.ipv4.conf.default.accept_source_route\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv4.conf.default.accept_source_route = 0\2/"
    local Regex3="^(\s*)net.ipv4.conf.default.accept_source_route\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)net.ipv4.conf.default.accept_source_route\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv4.conf.default.accept_source_route = 0\2/"
    local Regex5="^(\s*)net.ipv4.conf.default.accept_source_route\s*=\s*0?\s*$"
    local Success="Set system to not accept IPv4 source-routed packets by default, per V-244552."
    local Failure="Failed to set the system to not accept IPv4 source-routed packets by default, not in compliance V-244552."

    echo
    sysctl -w net.ipv4.conf.default.accept_source_route=0 &>/dev/null
    ( (grep -E -q "${Regex1}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex2}" /etc/sysctl.d/99-sysctl.conf) || (grep -E -q "${Regex3}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex4}" /etc/sysctl.d/99-sysctl.conf)) || echo "net.ipv4.conf.default.accept_source_route = 0" >>/etc/sysctl.d/99-sysctl.conf

    sysctl --quiet --system

    ( (grep -E -q "${Regex5}" /etc/sysctl.d/99-sysctl.conf && sysctl net.ipv4.conf.default.accept_source_route | grep -E -q "${Regex5}") && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set OS to ignore IPv4 ICMP redirects, V-244553
function V244553() {
    local Regex1="^(\s*)#net.ipv4.conf.all.accept_redirects\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#net.ipv4.conf.all.accept_redirects\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv4.conf.all.accept_redirects = 0\2/"
    local Regex3="^(\s*)net.ipv4.conf.all.accept_redirects\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)net.ipv4.conf.all.accept_redirects\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv4.conf.all.accept_redirects = 0\2/"
    local Regex5="^(\s*)net.ipv4.conf.all.accept_redirects\s*=\s*0?\s*$"
    local Success="Set system to ignore IPv4 or IPv6 ICMP redirect messages, per V-244553."
    local Failure="Failed to set the system to ignore IPv4 or IPv6 ICMP redirect messages, not in compliance V-244553."

    echo
    sysctl -w net.ipv6.conf.all.accept_redirects=0 &>/dev/null
    ( (grep -E -q "${Regex1}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex2}" /etc/sysctl.d/99-sysctl.conf) || (grep -E -q "${Regex3}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex4}" /etc/sysctl.d/99-sysctl.conf)) || echo "net.ipv4.conf.all.accept_redirects = 0" >>/etc/sysctl.d/99-sysctl.conf

    sysctl --quiet --system

    ( (grep -E -q "${Regex5}" /etc/sysctl.d/99-sysctl.conf && sysctl net.ipv4.conf.all.accept_redirects | grep -E -q "${Regex5}") && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Enable hardening of Berkeley Packet Filter Just-in-time compiler, V-244554
function V244554() {
    local Regex1="^(\s*)#net.core.bpf_jit_harden\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#net.core.bpf_jit_harden\s*=\s*\S+(\s*#.*)?\s*$/\1net.core.bpf_jit_harden = 2\2/"
    local Regex3="^(\s*)net.core.bpf_jit_harden\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)net.core.bpf_jit_harden\s*=\s*\S+(\s*#.*)?\s*$/\1net.core.bpf_jit_harden = 2\2/"
    local Regex5="^(\s*)net.core.bpf_jit_harden\s*=\s*2?\s*$"
    local Success="Set system to enable hardening of Berkeley Packet Filter Just-in-time compiler, per V-244554."
    local Failure="Failed to set the system to enable hardening of Berkeley Packet Filter Just-in-time compiler, not in compliance V-244554."

    echo
    sysctl -w net.core.bpf_jit_harden=2 &>/dev/null
    ( (grep -E -q "${Regex1}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex2}" /etc/sysctl.d/99-sysctl.conf) || (grep -E -q "${Regex3}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex4}" /etc/sysctl.d/99-sysctl.conf)) || echo "net.core.bpf_jit_harden = 2" >>/etc/sysctl.d/99-sysctl.conf

    sysctl --quiet --system

    ( (grep -E -q "${Regex5}" /etc/sysctl.d/99-sysctl.conf && sysctl net.core.bpf_jit_harden | grep -E -q "${Regex5}") && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set OS to not perform IPv4 packet forwarding unless system is a router, V-250317
function V250317() {
    local Regex1="^(\s*)#net.ipv4.ip_forward\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#net.ipv4.ip_forward\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv4.ip_forward = 0\2/"
    local Regex3="^(\s*)net.ipv4.ip_forward\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)net.ipv4.ip_forward\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv4.ip_forward = 0\2/"
    local Regex5="^(\s*)net.ipv4.ip_forward\s*=\s*0?\s*$"
    local Success="Set system to not perform IPv4 package forwarding, per V-250317."
    local Failure="Failed to set the system to not perform package IPv4 forwarding, not in compliance V-250317."

    echo
    sysctl -w net.ipv4.ip_forward=0 &>/dev/null
    ( (grep -E -q "${Regex1}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex2}" /etc/sysctl.d/99-sysctl.conf) || (grep -E -q "${Regex3}" /etc/sysctl.d/99-sysctl.conf && sed -ri "${Regex4}" /etc/sysctl.d/99-sysctl.conf)) || echo "net.ipv4.ip_forward = 0" >>/etc/sysctl.d/99-sysctl.conf

    sysctl --quiet --system

    ( (grep -E -q "${Regex10}" /etc/sysctl.d/99-sysctl.conf && sysctl net.ipv6.conf.all.forwarding | grep -E -q "${Regex10}") && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#System must have AIDE installed, V-251710
function V251710() {
    local Success="AIDE has been installed, per V-251710."
    local Failure="AIDE is not installed, not in compliance with V-251710."

    echo

    if ! yum -q list installed aide &>/dev/null; then
        yum install -q -y aide
        { (! yum -q list installed aide &>/dev/null) && {
            echo "${Failure}"
            exit 1
        }; } || echo "${Success}"
    else
        echo "${Success}"
    fi
}

#System must specify the default "include" dir, V-251711
function V251711() {
    local Regex1="^(\s*)#includedir\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#includedir\s*\S+(\s*#.*)?\s*$/\#includedir   \/etc\/sudoers.d\2/"
    local Regex3="^(\s*)#includedir\s+\/etc\/sudoers.d\s*$"
    local Success="Set system to use the invoking user's password when using sudo, per V-251711."
    local Failure="Failed to set system to use the invoking user's password when using sudo, not in compliance V-251711."

    echo
    (grep -E -q "${Regex1}" /etc/sudoers && sed -ri "${Regex2}" /etc/sudoers) || echo "includedir   /etc/sudoers.d" >>/etc/sudoers
    (grep -E -q "${Regex3}" /etc/sudoers && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#System must not be configured to bypass password requirements for privilege escalation, V-251712

#Set system password complexity module is enabled in the system-auth file, V-251713
function V251713() {
    local Regex1="^(\s*)password\s+required\s+\s*pam_pwquality.so\s*$"
    local Success="Set system password complexity module is enabled in the system-auth file, per V-251713."
    local Failure="Failed to set the system password complexity module is enabled in the system-auth file, not in compliance V-251713."

    echo
    grep -E -q "${Regex1}" /etc/pam.d/system-auth || echo "password    required                                     pam_pwquality.so" >>/etc/pam.d/system-auth
    (grep -E -q "${Regex1}" /etc/pam.d/system-auth && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set systems below 8.4 ensure the password complexity module in the system-auth file is set to 3 retires or less, V-251714
function V251714() {
    local Regex1="^\s*password\s+required\s+pam_pwquality.so\s*"
    local Regex2="s/^\s*password\s+\s*\s*\s*required\s+pam_pwquality.so\s*"
    local Regex3="password    required                                     pam_pwquality.so retry=3"
    local Regex4="^(\s*)password\s+required\s+\s*pam_pwquality.so\s*retry=3\s*$"
    local Success="Set systems below 8.4 ensure the password complexity module in the system-auth file is set to 3 retires or less, per V-251714."
    local Failure="Failed to set systems below 8.4 ensure the password complexity module in the system-auth file is set to 3 retires or less, not in compliance V-251714."

    echo
    (grep -E -q "${Regex1}" /etc/pam.d/system-auth && sed -ri "${Regex2}.*$/${Regex3}/" /etc/pam.d/system-auth) || echo "password    required                                     pam_pwquality.so retry=3" >>/etc/pam.d/system-auth
    (grep -E -q "${Regex4}" /etc/pam.d/system-auth && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set systems below 8.4 ensure the password complexity module in the password-auth file is set to 3 retires or less, V-251715
function V251715() {
    local Regex1="^\s*password\s+required\s+pam_pwquality.so\s*"
    local Regex2="s/^\s*password\s+\s*\s*\s*required\s+pam_pwquality.so\s*"
    local Regex3="password    required                                     pam_pwquality.so retry=3"
    local Regex4="^(\s*)password\s+required\s+\s*pam_pwquality.so\s*retry=3\s*$"
    local Success="Set systems below 8.4 ensure the password complexity module in the password-auth file is set to 3 retires or less, per V-251715."
    local Failure="Failed to set systems below 8.4 ensure the password complexity module in the password-auth file is set to 3 retires or less, not in compliance V-251715."

    echo
    (grep -E -q "${Regex1}" /etc/pam.d/password-auth && sed -ri "${Regex2}.*$/${Regex3}/" /etc/pam.d/password-auth) || echo "password    required                                     pam_pwquality.so retry=3" >>/etc/pam.d/password-auth
    (grep -E -q "${Regex4}" /etc/pam.d/password-auth && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set systems 8.4 and higher ensure the password complexity module is set to 3 retires or less, V-251716
function V251716() {
    local Regex1="^(\s*)#\s*retry\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#\s*retry\s*=\s*\S+(\s*#.*)?\s*$/retry = 3\2/"
    local Regex3="^(\s*)retry\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)retry\s*=\s*\S+(\s*#.*)?\s*$/retry = 3\2/"
    local Regex5="^(\s*)retry\s*=\s*3\s*$"
    local Success="Set systems 8.4 and higher ensure the password complexity module is set to 3 retires or less, per V-251716."
    local Failure="Failed to set systems 8.4 and higher ensure the password complexity module is set to 3 retires or less, not in compliance V-251716."

    echo
    ( (grep -E -q "${Regex1}" /etc/security/pwquality.conf && sed -ri "${Regex2}" /etc/security/pwquality.conf) || (grep -E -q "${Regex3}" /etc/security/pwquality.conf && sed -ri "${Regex4}" /etc/security/pwquality.conf)) || echo "retry = 3" >>/etc/security/pwquality.conf
    (grep -E -q "${Regex5}" /etc/security/pwquality.conf && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Limit password reuse to 5 in the system-auth file, V-251717
function V251717() {
    local Regex1="^\s*password\s+required\s+\s*pam_pwhistory.so\s*use_authtok\s*remember=\S+(\s*#.*)?(\s+.*)$"
    local Regex2="s/^(\s*)password\s+required\s+\s*pam_pwhistory.so\s*use_authtok\s*remember=\S+(\s*#.*)\s*retry=\S+(\s*#.*)?\s*S/\password\s+required\s+\s*pam_pwhistory.so\s*use_authtok\s*remember=5\s*retry=3\2/"
    local Regex3="^(\s*)password\s+required\s+\s*pam_pwhistory.so\s*use_authtok\s*remember=5\s*retry=3\s*$"
    local Success="System is set to keep password history of the last 5 passwords in the system-auth file, per V-251717."
    local Failure="Failed to set the system to keep password history of the last 5 passwords in the system-auth file, not in compliance with V-251717."

    echo
    (grep -E -q "${Regex1}" /etc/pam.d/system-auth && sed -ri "${Regex2}" /etc/pam.d/system-auth) || echo "password    required                                    pam_pwhistory.so use_authtok remember=5 retry=3" >>/etc/pam.d/system-auth
    (grep -E -q "${Regex3}" /etc/pam.d/system-auth && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Set the graphical display manager must not be the default target, V-251718
function V251718() {
    local Success="Set the graphical display manager must not be the default target, per V-251718."
    local Failure="Failed to set the graphical display manager to not be the default target, not in compliance with V-251718."

    echo

    if systemctl get-default | grep -E -q "multi-user.target"; then
        echo "${Success}"
    else
        systemctl set-default multi-user.target
        ( (systemctl get-default | grep -E -q "multi-user.target") && echo "${Success}") || {
            echo "${Failure}"
            exit 1
        }
    fi
}

#Apply all CATIIs
function Medium() {
    echo
    echo "----------------------------------"
    echo " Applying all compatible CAT IIs"
    echo "----------------------------------"
    #Check if rsyslog is installed, /etc/rsyslog.conf
    if yum -q list installed rsyslog &>/dev/null; then
        V230228
        V230298
        V230387
    else
        echo
        echo "rsyslog is not installed, skipping V-230228, V-230298, and V-230387."
    fi

    #Check if Shadow-utils is installed for various settings, /etc/login.defs, /etc/default/useradd
    if yum -q list installed shadow-utils &>/dev/null; then
        V230231
        V230233
        V230324
        V230365
        V230370
        V230378
        V230383
    else
        echo
        echo "Shadow-utils is not installed, skipping V-230231, V-230233, V-230324, V-230365, V-230370, V-230378, and V-230383."
    fi

    #Check if systemd is installed, /etc/sysctl.d
    if yum -q list installed systemd &>/dev/null; then
        V230236
        V230314
        V230315
        V244523
    else
        echo
        echo "systemd is not installed skipping V-230236, V-230314, V-230315, and V-244523."
    fi

    #Check if system has been booted with systemd as init system
    if [ "${ISPid1}" = "1" ]; then
        V230266
        V230267
        V230268
        V230280
        V230310
        V230311
        V230312
        V230502
        V230532
        V230535
        V230536
        V230537
        V230538
        V230539
        V230540
        V230541
        V230542
        V230543
        V230544
        V230545
        V230546
        V230547
        V230548
        V230549
        V244550
        V244551
        V244552
        V244553
        V244554
        V250317
        V251718
    else
        echo
        echo "System has not been booted with systemd as init system, skipping V-230266, V-230267, V-230268, V-230280, V-230310, \
V-230311, V-230312, V-230502, V-230532, V-230535, V-230536, V-230537, V-230538, V-230539, V-230540, V-230541, V-230542, V-230543, \
V-230544, V-230545, V-230546, V-230547, V-230548, V-230549, V-244550, V-244551, V-244552, V-244553, V-244554, V-250317, and V-251718."
    fi

    #Check if pam is installed for various settings, /etc/secuirty
    if yum -q list installed pam &>/dev/null; then
        V230237
        V230313
        V230356
        V230357
        V230358
        V230359
        V230360
        V230361
        V230362
        V230363
        V230368
        V230369
        V230375
        V230377
        V244524
        V244533
        V251717

        if [[ $(echo "${Version}") < "8.4" ]]; then
            V251714
            V251715
        else
            V251716
        fi

        if [[ $(echo "${Version}") < "8.2" ]]; then
            V230332 #also applies 230334, 230336, 230338, 230340, 230342, 230344
        else
            V230333
            V230335
            V230337
            V230339
            V230341
            V230343
            V230345
        fi
    else
        echo
        echo "Pam is not installed, skipping V-230237, V-230313, V-230356, V-230357, V-230358, V-230359, V-230360, \
V-230361, V-230362, V-230368, V-230369, V-230375, V-230377, V-244524, V-244533, and V-251717."
    fi

    #Check if selinux is installed for various settings, /etc/selinux
    if yum -q list installed selinux &>/dev/null; then
        V230240
        V230282
    else
        echo
        echo "selinux is not installed, skipping V-230240 and V-230282."
    fi

    #Check if crypto-policies is installed, /etc/crypto-policies
    if yum -q list installed crypto-policies &>/dev/null; then
        V230255
    else
        echo
        echo "crypto-policies is not installed, skipping V-230255."
    fi

    #Check if grub2-tools is installed, /etc/default/grub
    if yum -q list installed grub2-tools &>/dev/null; then
        V230277
        V230278
        V230279
    else
        echo
        echo "grub2-tools is not installed, skipping V-23027, V-230278, and V-230279"
    fi

    #Check if tmux is installed
    if yum -q list installed tmux &>/dev/null; then
        V230348
        V230349
        V230353
    else
        echo
        echo "tmux is not installed, skipping V-230348, V-230349, and V-230353."
    fi

    #Check if audit is installed, /etc/audit
    if yum -q list installed audit &>/dev/null; then
        V230386
        V230390
        V230392
        V230394
        V230396
        V230402
        V230403
        V230404
        V230405
        V230406
        V230407
        V230408
        V230409
        V230410
        V230411
        V230412
        V230413
        V230418
        V230419
        V230421
        V230422
        V230423
        V230424
        V230425
        V230426
        V230427
        V230428
        V230429
        V230430
        V230431
        V230432
        V230433
        V230434
        V230435
        V230436
        V230437
        V230438
        V230439
        V230444
        V230446
        V230447
        V230448
        V230449
        V230455
        V230456
        V230462
        V230463
        V230464
        V230465
        V230466
        V230467
        V230480
        V244542
    else
        echo
        echo "audit is not installed, skipping V-230386, V-230390, V-230392, V-230394, V-230396, V-230402, V-230403, \
V-230404, V-230405, V-230406, V-230407, V-230408, V-230409, V-230410, V-230411, V-230412, V-230413, V-230418, V-230419, \
V-230421, V-230422, V-230423, V-230424, V-230425, V-230426, V-230427, V-230428, V-230429, V-230430, V-230431, V-230432, \
V-230433, V-230434, V-230435, V-230436, V-230437, V-230438, V-230439, V-230444, V-230446, V-230447, V-230448, V-230449, \
V-230455, V-230456, V-230462, V-230463, V-230464, V-230465, V-230466, V-230467, V-230480, and V-244542."
    fi

    #Check if kmod is installed, /etc/modprobe.d/
    if yum -q list installed kmod &>/dev/null; then
        V230503
    else
        echo
        echo "kmod is not installed, skipping V-230503."
    fi

    #Check if openssh-server is installed
    if yum -q list installed openssh-server &>/dev/null; then
        V230244
        V230288
        V230289
        V230290
        V230291
        V230296
        V230330
        V230382
        V230526
        V230527
        V230555
        V230556
        V244526
        V244528
    else
        echo
        echo "openssh-server is not installed, skipping V-230244, V-230288, V-230289, V-230290, V-230291, V-230296, \
V-230330, V-230382, V-230526, V-230527, V2-30555, V-244525, V-244526, and V-244528."
    fi

    #Check if sudo is installed, /etc/sudoers
    if yum -q list installed sudo &>/dev/null; then
        V237642
        V237643
        V251711
    else
        echo
        echo "sudo is not installed, skipping V-237642, V-237643, and V-251711."
    fi

    V230239
    V230273
    V230275
    V230478
    V230488
    V230489
    V230559
    V230560
    V230561
    V237640

    ########################
    #    Unworked STIGs    #
    ########################
    #V230229, V230251, V230252, V230254, V230274, V230351, V251710

    ########################
    #   Deprecated STIGs   #
    ########################
    #V230414, V230415, V230416, V230417, V230420, V230440, V230441, V230442, V230443, V230445
    #V230450, V230451, V230452, V230453, V230454, V230457, V230458, V230459, V230460, V230461
    #V230528, V244520

    ##################################
    #  Blocked Due to issue with IB  #
    ##################################
    #V230366, V204402
}

#------------------
#CAT I STIGS\High
#------------------

#Verify that gpgcheck is Globally Activated, V-230264
function V230264() {
    local Regex1="^(\s*)gpgcheck\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)gpgcheck\s*=\s*\S+(\s*#.*)?\s*$/gpgcheck=1\2/"
    local Regex3="^(\s*)gpgcheck\s*=\s*1\s*$"
    local Success="Yum is now set to require certificates for installations, per V-230264"
    local Failure="Yum was not properly set to use certificates for installations, not in compliance with V-230264"

    echo
    (grep -E -q "${Regex1}" /etc/yum.conf && sed -ri "${Regex2}" /etc/yum.conf) || echo "gpgcheck=1" >>/etc/yum.conf
    (grep -E -q "${Regex3}" /etc/yum.conf && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Verify that local gpgcheck is activated, V-230265
function V230265() {
    local Regex1="^(\s*)localpkg_gpgcheck\s*=\s*\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)localpkg_gpgcheck\s*=\s*\S+(\s*#.*)?\s*$/localpkg_gpgcheck=True\2/"
    local Regex3="^(\s*)localpkg_gpgcheck\s*=\s*True\s*$"
    local Success="Yum is now set to require certificates for local installs, per V-230265"
    local Failure="Yum was not properly set to use certificates for local installs, not in compliance with V-230265"

    echo
    (grep -E -q "${Regex1}" /etc/dnf/dnf.conf && sed -ri "${Regex2}" /etc/dnf/dnf.conf) || echo "localpkg_gpgcheck=True" >>/etc/dnf/dnf.conf
    (grep -E -q "${Regex3}" /etc/dnf/dnf.conf && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Remove telnet-server if installed, V-230487
function V230487() {
    local Success="telnet-server has been removed, per V-230487."
    local Failure="Failed to remove telnet-server, not in compliance with V-230487."

    echo

    if yum -q list installed telnet-server &>/dev/null; then
        yum remove -q -y telnet-server &>/dev/null
        { (yum -q list installed telnet-server &>/dev/null) && {
            echo "${Failure}"
            exit 1
        }; } || echo "${Success}"
    else
        echo "${Success}"
    fi
}

#Remove rsh-server if installed, V-230492
function V230492() {
    local Success="rsh-server has been removed, per V-230492."
    local Failure="Failed to remove rsh-server, not in compliance with V-230492."

    echo

    if yum -q list installed rsh-server &>/dev/null; then
        yum remove -q -y rsh-server &>/dev/null
        { (yum -q list installed rsh-server &>/dev/null) && {
            echo "${Failure}"
            exit 1
        }; } || echo "${Success}"
    else
        echo "${Success}"
    fi
}

#Disable and mask  Ctrl-Alt-Delete, V-230529
function V230529() {
    local Success="Ctrl-Alt-Delete is disabled, per V-230529"
    local Failure="Ctrl-Alt-Delete hasn't been disabled, not in compliance with per V-230529"
    local Notinstalled="ctrl-alt-del.target was not installed on the system.  Disabled by default, per V-230529."

    echo

    if ! systemctl list-unit-files --full -all | grep -E -q '^ctrl-alt-del.target'; then
        echo "${Notinstalled}"
    else
        if systemctl status ctrl-alt-del.target | grep -E -q "active"; then
            systemctl stop ctrl-alt-del.target &>/dev/null
            systemctl disable ctrl-alt-del.target &>/dev/null
            systemctl mask ctrl-alt-del.target &>/dev/null
        fi

        if systemctl status ctrl-alt-del.target | grep -E -q "failed"; then
            (systemctl status ctrl-alt-del.target | grep -q "Loaded: masked" && echo "${Success}") || {
                echo "${Failure}"
                exit 1
            }
        else
            ( (systemctl status ctrl-alt-del.target | grep -q "Loaded: masked" && systemctl status ctrl-alt-del.target | grep -q "Active: inactive") && echo "${Success}") || {
                echo "${Failure}"
                exit 1
            }
        fi
    fi
}

#Disable Ctrl-Alt-Delete burst key, V-230531
function V230531() {
    local Regex1="^(\s*)#CtrlAltDelBurstAction=\S+(\s*#.*)?\s*$"
    local Regex2="s/^(\s*)#CtrlAltDelBurstAction=\S+(\s*#.*)?\s*$/CtrlAltDelBurstAction=none\2/"
    local Regex3="^(\s*)CtrlAltDelBurstAction=\S+(\s*#.*)?\s*$"
    local Regex4="s/^(\s*)CtrlAltDelBurstAction=\S+(\s*#.*)?\s*$/CtrlAltDelBurstAction=none\2/"
    local Regex5="^(\s*)CtrlAltDelBurstAction=none?\s*$"
    local Success="Disable Ctrl-Alt-Delete burst key, per V-230531."
    local Failure="Failed to disable Ctrl-Alt-Delete burst key, not in compliance V-230531."

    echo
    ( (grep -E -q "${Regex1}" /etc/systemd/system.conf && sed -ri "${Regex2}" /etc/systemd/system.conf) || (grep -E -q "${Regex3}" /etc/systemd/system.conf && sed -ri "${Regex4}" /etc/systemd/system.conf)) || echo "CtrlAltDelBurstAction=none" >>/etc/systemd/system.conf
    (grep -E -q "${Regex5}" /etc/systemd/system.conf && echo "${Success}") || {
        echo "${Failure}"
        exit 1
    }
}

#Remove tftp-server if installed, V-230533
function V230533() {
    local Success="tftp-server has been removed, per V-230533."
    local Failure="Failed to remove tftp-server, not in compliance with V-230533."

    echo

    if yum -q list installed tftp-server &>/dev/null; then
        yum remove -q -y tftp-server &>/dev/null
        { (yum -q list installed tftp-server &>/dev/null) && {
            echo "${Failure}"
            exit 1
        }; } || echo "${Success}"
    else
        echo "${Success}"
    fi
}

#Remove vsftpd if installed, V-230558
function V230558() {
    local Success="vsftpd has been removed, per V-230558."
    local Failure="Failed to remove vsftpd, not in compliance with V-230558."

    echo

    if yum -q list installed vsftpd &>/dev/null; then
        yum remove -q -y vsftpd &>/dev/null
        { (yum -q list installed vsftpd &>/dev/null) && {
            echo "${Failure}"
            exit 1
        }; } || echo "${Success}"
    else
        echo "${Success}"
    fi
}

function High() {
    echo
    echo "----------------------------------"
    echo "  Applying all compatible CAT Is"
    echo "----------------------------------"
    #Check if dnf-data is installed, /etc/dnf/
    if yum -q list installed dnf-data &>/dev/null; then
        V230265
    else
        echo
        echo "dnf-data is not installed, skipping V-230265."
    fi

    #Check if system has been booted with systemd as init system
    if [ "${ISPid1}" = "1" ]; then
        V230529
        V230531
    else
        echo
        echo "System has not been booted with systemd as init system, skipping V-230529 and V-230531."
    fi

    V230264
    V230487
    V230492
    V230533
    V230558
}

#------------------
#Clean up
#------------------

function Cleanup() {
    echo
    (rm -rf "${StagingPath}" && echo "Staging directory has been cleaned.") || echo "Failed to clean up the staging directory."
}

#Setting variable for default input
Level=${1:-"High"}
StagingPath=${2:-"/var/tmp/STIG"}

#Check if system has been booted with systemd as init system
ISPid1=$(pidof systemd || echo "404")

#Get OS
OSFile=/etc/os-release
if [ -e ${OSFile} ]; then
    . ${OSFile}
    Version="$VERSION_ID"
else
    echo "The file ${OSFile} does not exist. Failed to determine OS version."
    exit 1
fi

#Setting script to run through all stigs if no input is detected.
if [ "${Level}" = "High" ]; then
    echo
    echo "------------------------------------------"
    echo " Applying all compatible CAT Is and lower"
    echo "------------------------------------------"
    Low
    Medium
    High
elif [ "${Level}" = "Medium" ]; then
    echo
    echo "-------------------------------------------"
    echo " Applying all compatible CAT IIs and lower"
    echo "-------------------------------------------"
    Low
    Medium
elif [ "${Level}" = "Low" ]; then
    echo
    echo "--------------------------------------------"
    echo " Applying all compatible CAT IIIs and lower"
    echo "--------------------------------------------"
    Low
else
    for Level in "$@"; do
        "${Level}"
    done
fi

Cleanup

systemctl restart rngd.service &>/dev/null

if yum -q list installed openssh-server &>/dev/null; then
    systemctl restart sshd &>/dev/null
fi

if yum -q list installed audit &>/dev/null; then
    service auditd restart &>/dev/null
fi

echo
exit 0
