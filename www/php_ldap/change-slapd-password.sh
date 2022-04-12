#!/bin/bash
# License: MIT
# You can find a copy of the license here: http://opensource.org/licenses/MIT
# This simple script lets you change the LDAP admin password from
# a console on the LDAP server.

cd /tmp

set -o errexit
PASSWORD=$(slappasswd -h {SSHA})
echo "New hashed password is $PASSWORD"

cat > ./new-password.ldif <<EOFLDIF
dn: olcDatabase={1}hdb,cn=config
changetype: modify
replace: olcRootPW
olcRootPW: ${PASSWORD}
EOFLDIF

echo "New password LDIF is:"
cat ./new-password.ldif
echo ""

read -p "Proceed to change password [y/N] " -N 1 -s
echo ""
if test "${REPLY}" == "y"; then
	  echo Performing change...
	    ldapmodify -Y EXTERNAL -H ldapi:/// -f ./new-password.ldif
    else
	      echo Not performing change...
fi
