echo "For more information and instructions goto:
   https://kifarunix.com/install-and-setup-openldap-server-on-ubuntu-22-04/"
# Password for admin is somethng like rocketsarescarywhenshoot1000milesaway!
#User slappasswd to create your own.
ADMINPW="{SSHA}L/hNaCXE4FD8H8iWFMq4RbllcGYvByuL"
#ReadOnly account is password.
READONLYPW="{SSHA}aUYi3Q2Ps8o7UWxeSE51A0OZswOw81rp"
AUSER=wez
GUSER=dawn
DOMAIN=wezzel

if [ ! -f /usr/libexec/slapd ]; then
useradd -r -M -d /var/lib/openldap -s /usr/sbin/nologin ldap
usermod -a -G ssl-cert ldap

apt install libsasl2-dev make libtool libperl-dev \
	build-essential openssl libevent-dev \
	libargon2-dev sudo wget pkg-config \
	wiredtiger libsystemd-dev libssl-dev -y

VER=2.6.1
wget https://www.openldap.org/software/download/OpenLDAP/openldap-release/openldap-${VER}.tgz

tar xzf openldap-$VER.tgz

cd openldap-$VER

./configure --prefix=/usr --sysconfdir=/etc --disable-static \
	--enable-debug --with-tls=openssl --with-cyrus-sasl --enable-dynamic \
	--enable-crypt --enable-spasswd --enable-slapd --enable-modules \
	--enable-rlookups --enable-backends=mod --disable-sql \
	--enable-ppolicy=mod --enable-syslog --enable-overlays=mod --with-systemd --enable-wt=no

make depend

make 
make install 
fi


rm -rf /var/lib/openldap /etc/openldap/slapd.d
mkdir -p /var/lib/openldap /etc/openldap/slapd.d

chown -R ldap:ldap /var/lib/openldap

chown root:ldap /etc/openldap/slapd.conf

chmod 640 /etc/openldap/slapd.conf

mv /lib/systemd/system/slapd.service{,.old}

cat <<EOT> /etc/systemd/system/slapd.service
[Unit]
Description=OpenLDAP Server Daemon
After=syslog.target network-online.target
Documentation=man:slapd
Documentation=man:slapd-mdb

[Service]
Type=forking
PIDFile=/var/lib/openldap/slapd.pid
Environment="SLAPD_URLS=ldap:/// ldapi:/// ldaps:///"
Environment="SLAPD_OPTIONS=-F /etc/openldap/slapd.d"
ExecStart=/usr/libexec/slapd -u ldap -g ldap -h "ldap:/// ldapi:/// ldaps:///" -F /etc/openldap/slapd.d

[Install]
WantedBy=multi-user.target
EOT


SUDO_FORCE_REMOVE=yes apt install sudo-ldap -y


sudo -V |  grep -i "ldap"


find /usr/share/doc/ -iname schema.openldap

cp /usr/share/doc/sudo-ldap/schema.OpenLDAP  /etc/openldap/schema/sudo.schema

cat <<EOT> /etc/openldap/schema/sudo.ldif
dn: cn=sudo,cn=schema,cn=config
objectClass: olcSchemaConfig
cn: sudo
olcAttributeTypes: ( 1.3.6.1.4.1.15953.9.1.1 NAME 'sudoUser' DESC 'User(s) who may  run sudo' EQUALITY caseExactIA5Match SUBSTR caseExactIA5SubstringsMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.26 )
olcAttributeTypes: ( 1.3.6.1.4.1.15953.9.1.2 NAME 'sudoHost' DESC 'Host(s) who may run sudo' EQUALITY caseExactIA5Match SUBSTR caseExactIA5SubstringsMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.26 )
olcAttributeTypes: ( 1.3.6.1.4.1.15953.9.1.3 NAME 'sudoCommand' DESC 'Command(s) to be executed by sudo' EQUALITY caseExactIA5Match SYNTAX 1.3.6.1.4.1.1466.115.121.1.26 )
olcAttributeTypes: ( 1.3.6.1.4.1.15953.9.1.4 NAME 'sudoRunAs' DESC 'User(s) impersonated by sudo (deprecated)' EQUALITY caseExactIA5Match SYNTAX 1.3.6.1.4.1.1466.115.121.1.26 )
olcAttributeTypes: ( 1.3.6.1.4.1.15953.9.1.5 NAME 'sudoOption' DESC 'Options(s) followed by sudo' EQUALITY caseExactIA5Match SYNTAX 1.3.6.1.4.1.1466.115.121.1.26 )
olcAttributeTypes: ( 1.3.6.1.4.1.15953.9.1.6 NAME 'sudoRunAsUser' DESC 'User(s) impersonated by sudo' EQUALITY caseExactIA5Match SYNTAX 1.3.6.1.4.1.1466.115.121.1.26 )
olcAttributeTypes: ( 1.3.6.1.4.1.15953.9.1.7 NAME 'sudoRunAsGroup' DESC 'Group(s) impersonated by sudo' EQUALITY caseExactIA5Match SYNTAX 1.3.6.1.4.1.1466.115.121.1.26 )
olcObjectClasses: ( 1.3.6.1.4.1.15953.9.2.1 NAME 'sudoRole' SUP top STRUCTURAL DESC 'Sudoer Entries' MUST ( cn ) MAY ( sudoUser $ sudoHost $ sudoCommand $ sudoRunAs $ sudoRunAsUser $ sudoRunAsGroup $ sudoOption $ description ) )
EOT

cat <<EOT> /etc/openldap/slapd.ldif
dn: cn=config
objectClass: olcGlobal
cn: config
olcArgsFile: /var/lib/openldap/slapd.args
olcPidFile: /var/lib/openldap/slapd.pid

dn: cn=schema,cn=config
objectClass: olcSchemaConfig
cn: schema

dn: cn=module,cn=config
objectClass: olcModuleList
cn: module
olcModulepath: /usr/libexec/openldap
olcModuleload: back_mdb.la

include: file:///etc/openldap/schema/core.ldif
include: file:///etc/openldap/schema/cosine.ldif
include: file:///etc/openldap/schema/nis.ldif
include: file:///etc/openldap/schema/inetorgperson.ldif
include: file:///etc/openldap/schema/sudo.ldif
#include: file:///etc/openldap/schema/ppolicy.ldif
dn: olcDatabase=frontend,cn=config
objectClass: olcDatabaseConfig
objectClass: olcFrontendConfig
olcDatabase: frontend
olcAccess: to dn.base="cn=Subschema" by * read
olcAccess: to * 
  by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage 
  by * none

dn: olcDatabase=config,cn=config
objectClass: olcDatabaseConfig
olcDatabase: config
olcRootDN: cn=config
olcAccess: to * 
  by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage 
  by * none
EOT

slapadd -n 0 -F /etc/openldap/slapd.d -l /etc/openldap/slapd.ldif -u


slapadd -n 0 -F /etc/openldap/slapd.d -l /etc/openldap/slapd.ldif


chown -R ldap:ldap /etc/openldap/slapd.d

systemctl daemon-reload

systemctl status slapd


ldapmodify -Y EXTERNAL -H ldapi:/// -Q < EOT
dn: cn=config
changeType: modify
replace: olcLogLevel
olcLogLevel: stats
EOT

ldapsearch -Y EXTERNAL -H ldapi:/// -b cn=config "(objectClass=olcGlobal)" olcLogLevel -LLL -Q


echo "local4.* /var/log/slapd.log" >> /etc/rsyslog.d/51-slapd.conf

systemctl restart rsyslog slapd


cat <<EOT> /etc/logrotate.d/slapd
/var/log/slapd.log
{ 
        rotate 7
        daily
        missingok
        notifempty
        delaycompress
        compress
        postrotate
                /usr/lib/rsyslog/rsyslog-rotate
        endscript
}
EOT


systemctl restart logrotate


cat <<EOT> rootdn.ldif
dn: olcDatabase=mdb,cn=config
objectClass: olcDatabaseConfig
objectClass: olcMdbConfig
olcDatabase: mdb
olcDbMaxSize: 42949672960
olcDbDirectory: /var/lib/openldap
olcSuffix: dc=ldap,dc=${DOMAIN},dc=com
olcRootDN: cn=admin,dc=ldap,dc=${DOMAIN},dc=com
olcRootPW: ${ADMINPW}
olcDbIndex: uid pres,eq
olcDbIndex: cn,sn pres,eq,approx,sub
olcDbIndex: mail pres,eq,sub
olcDbIndex: objectClass pres,eq
olcDbIndex: loginShell pres,eq
olcDbIndex: sudoUser,sudoHost pres,eq
olcAccess: to attrs=userPassword,shadowLastChange,shadowExpire
  by self write
  by anonymous auth
  by dn.subtree="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage 
  by dn.subtree="ou=system,dc=ldap,dc=${DOMAIN},dc=com" read
  by * none
olcAccess: to dn.subtree="ou=system,dc=ldap,dc=${DOMAIN},dc=com" by dn.subtree="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage
  by * none
olcAccess: to dn.subtree="dc=ldap,dc=${DOMAIN},dc=com" by dn.subtree="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage
  by users read 
  by * none
EOT


ldapadd -Y EXTERNAL -H ldapi:/// -f rootdn.ldif

if [ ! -f "/etc/ssl/private/mycakey.pem" ]; then

rm -rf /etc/ldap/ssl
mkdir -p /etc/ldap/ssl


certtool --generate-privkey --bits 4096 --outfile /etc/ssl/private/mycakey.pem
cat <<EOT>>/etc/ssl/ca.info
cn = Wezzel Company
ca
cert_signing_key
expiration_days = 3650
EOT

certtool --generate-self-signed \
        --load-privkey /etc/ssl/private/mycakey.pem \
        --template /etc/ssl/ca.info \
        --outfile /usr/local/share/ca-certificates/mycacert.crt

update-ca-certificates

certtool --generate-privkey \
        --bits 2048 \
        --outfile /etc/ldap/ssl/ldap_key.pem

cat <<EOT>>/etc/ssl/ldap01.info
organization = Wezzel Company
cn = ldap.${DOMAIN}.com
tls_www_server
encryption_key
signing_key
expiration_days = 3650
EOT

sudo certtool --generate-certificate \
        --load-privkey /etc/ldap/ssl/ldap_key.pem \
        --load-ca-certificate /etc/ssl/certs/mycacert.pem \
        --load-ca-privkey /etc/ssl/private/mycakey.pem \
        --template /etc/ssl/ldap01.info \
        --outfile /etc/ldap/ssl/ldap_cert.pem

sudo chgrp openldap /etc/ldap/ssl/ldap_key.pem
sudo chmod 0640 /etc/ldap/ssl/ldap_key.pem
cp /usr/local/share/ca-certificates/mycacert.crt /etc/ssl/
cp /etc/ldap/ssl/ldap_key.pem /etc/ssl/private/
cp /etc/ldap/ssl/ldap_cert.pem /etc/ssl/certs/
chown -R root:ssl-cert /etc/ssl/private/
cat <<EOT> tls.ldif
dn: cn=config
changetype: modify
add: olcTLSCACertificateFile
olcTLSCACertificateFile: /etc/ssl/mycacert.crt
-
add: olcTLSCertificateFile
olcTLSCertificateFile: /etc/ssl/certs/ldap_cert.pem
-
add: olcTLSCertificateKeyFile
olcTLSCertificateKeyFile: /etc/ssl/private/ldap_key.pem
EOT

fi

ldapmodify -Y EXTERNAL -H ldapi:/// -f tls.ldif


slapcat -b "cn=config" | grep olcTLS

sed -i 's|/etc/ssl/certs/ca-certificates.crt|/etc/ssl/mycacert.crt|' /etc/ldap/ldap.conf

cat <<EOT> basedn.ldif
dn: dc=ldap,dc=${DOMAIN},dc=com
objectClass: dcObject
objectClass: organization
objectClass: top
o: wezzel
dc: ldap

dn: ou=groups,dc=ldap,dc=${DOMAIN},dc=com
objectClass: organizationalUnit
objectClass: top
ou: groups

dn: ou=people,dc=ldap,dc=${DOMAIN},dc=com
objectClass: organizationalUnit
objectClass: top
ou: people
EOT

ldapadd -Y EXTERNAL -H ldapi:/// -f basedn.ldif

cat <<EOT> users.ldif
dn: uid=${AUSER},ou=people,dc=ldap,dc=${DOMAIN},dc=com
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
uid: ${AUSER}
cn: ${AUSER}
sn: wezzel
loginShell: /bin/bash
uidNumber: 10000
gidNumber: 10000
homeDirectory: /home/${AUSER}
shadowMax: 60
shadowMin: 1
shadowWarning: 7
shadowInactive: 7
shadowLastChange: 0

dn: cn=${AUSER},ou=groups,dc=ldap,dc=${DOMAIN},dc=com
objectClass: posixGroup
cn: ${AUSER}
gidNumber: 10000
memberUid: ${AUSER}


dn: uid=${GUSER},ou=people,dc=ldap,dc=${DOMAIN},dc=com
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
uid: ${GUSER}
cn: ${GUSER}
sn: wezzel
loginShell: /bin/bash
uidNumber: 10001
gidNumber: 10001
homeDirectory: /home/${GUSER}
shadowMax: 60
shadowMin: 1
shadowWarning: 7
shadowInactive: 7
shadowLastChange: 0

dn: cn=${GUSER},ou=groups,dc=ldap,dc=${DOMAIN},dc=com
objectClass: posixGroup
cn: ${GUSER}
gidNumber: 10001
memberUid: ${GUSER}

EOT

ldapadd -Y EXTERNAL -H ldapi:/// -f users.ldif

echo "Enter password for user ${AUSER}...."
ldappasswd -H ldapi:/// -Y EXTERNAL -S "uid=${AUSER},ou=people,dc=ldap,dc=${DOMAIN},dc=com"
echo "Enter password for user ${GUSER}...."
ldappasswd -H ldapi:/// -Y EXTERNAL -S "uid=${GUSER},ou=people,dc=ldap,dc=${DOMAIN},dc=com"

ldapsearch -Q -LLL -Y EXTERNAL -H ldapi:/// -b cn=config '(olcDatabase={1}mdb)' olcAccess

cat <<EOT>  bindDNuser.ldif
dn: ou=system,dc=ldap,dc=${DOMAIN},dc=com
objectClass: organizationalUnit
objectClass: top
ou: system

dn: cn=readonly,ou=system,dc=ldap,dc=${DOMAIN},dc=com
objectClass: organizationalRole
objectClass: simpleSecurityObject
cn: readonly
userPassword: ${READONLYPW}
description: Bind DN user for LDAP Operations
EOT

ldapadd -Y EXTERNAL -H ldapi:/// -f bindDNuser.ldif

cat <<EOT> ppolicy.ldif
dn: cn=ppolicy,cn=schema,cn=config
objectClass: olcSchemaConfig
cn: ppolicy
olcAttributeTypes: {0}( 1.3.6.1.4.1.42.2.27.8.1.1 NAME 'pwdAttribute' EQUALITY
  objectIdentifierMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.38 )
olcAttributeTypes: {1}( 1.3.6.1.4.1.42.2.27.8.1.2 NAME 'pwdMinAge' EQUALITY in
 tegerMatch ORDERING integerOrderingMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.27
  SINGLE-VALUE )
olcAttributeTypes: {2}( 1.3.6.1.4.1.42.2.27.8.1.3 NAME 'pwdMaxAge' EQUALITY in
 tegerMatch ORDERING integerOrderingMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.27
  SINGLE-VALUE )
olcAttributeTypes: {3}( 1.3.6.1.4.1.42.2.27.8.1.4 NAME 'pwdInHistory' EQUALITY
  integerMatch ORDERING integerOrderingMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1
 .27 SINGLE-VALUE )
olcAttributeTypes: {4}( 1.3.6.1.4.1.42.2.27.8.1.5 NAME 'pwdCheckQuality' EQUAL
 ITY integerMatch ORDERING integerOrderingMatch SYNTAX 1.3.6.1.4.1.1466.115.12
 1.1.27 SINGLE-VALUE )
olcAttributeTypes: {5}( 1.3.6.1.4.1.42.2.27.8.1.6 NAME 'pwdMinLength' EQUALITY
  integerMatch ORDERING integerOrderingMatch  SYNTAX 1.3.6.1.4.1.1466.115.121.
 1.27 SINGLE-VALUE )
olcAttributeTypes: {6}( 1.3.6.1.4.1.42.2.27.8.1.7 NAME 'pwdExpireWarning' EQUA
 LITY integerMatch ORDERING integerOrderingMatch  SYNTAX 1.3.6.1.4.1.1466.115.
 121.1.27 SINGLE-VALUE )
olcAttributeTypes: {7}( 1.3.6.1.4.1.42.2.27.8.1.8 NAME 'pwdGraceAuthNLimit' EQ
 UALITY integerMatch ORDERING integerOrderingMatch  SYNTAX 1.3.6.1.4.1.1466.11
 5.121.1.27 SINGLE-VALUE )
olcAttributeTypes: {8}( 1.3.6.1.4.1.42.2.27.8.1.9 NAME 'pwdLockout' EQUALITY b
 ooleanMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.7 SINGLE-VALUE )
olcAttributeTypes: {9}( 1.3.6.1.4.1.42.2.27.8.1.10 NAME 'pwdLockoutDuration' E
 QUALITY integerMatch ORDERING integerOrderingMatch  SYNTAX 1.3.6.1.4.1.1466.1
 15.121.1.27 SINGLE-VALUE )
olcAttributeTypes: {10}( 1.3.6.1.4.1.42.2.27.8.1.11 NAME 'pwdMaxFailure' EQUAL
 ITY integerMatch ORDERING integerOrderingMatch  SYNTAX 1.3.6.1.4.1.1466.115.1
 21.1.27 SINGLE-VALUE )
olcAttributeTypes: {11}( 1.3.6.1.4.1.42.2.27.8.1.12 NAME 'pwdFailureCountInter
 val' EQUALITY integerMatch ORDERING integerOrderingMatch  SYNTAX 1.3.6.1.4.1.
 1466.115.121.1.27 SINGLE-VALUE )
olcAttributeTypes: {12}( 1.3.6.1.4.1.42.2.27.8.1.13 NAME 'pwdMustChange' EQUAL
 ITY booleanMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.7 SINGLE-VALUE )
olcAttributeTypes: {13}( 1.3.6.1.4.1.42.2.27.8.1.14 NAME 'pwdAllowUserChange' 
 EQUALITY booleanMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.7 SINGLE-VALUE )
olcAttributeTypes: {14}( 1.3.6.1.4.1.42.2.27.8.1.15 NAME 'pwdSafeModify' EQUAL
 ITY booleanMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.7 SINGLE-VALUE )
olcAttributeTypes: {15}( 1.3.6.1.4.1.4754.1.99.1 NAME 'pwdCheckModule' DESC 'L
 oadable module that instantiates "check_password() function' EQUALITY caseExa
 ctIA5Match SYNTAX 1.3.6.1.4.1.1466.115.121.1.26 SINGLE-VALUE )
olcAttributeTypes: {16}( 1.3.6.1.4.1.42.2.27.8.1.30 NAME 'pwdMaxRecordedFailur
 e' EQUALITY integerMatch ORDERING integerOrderingMatch  SYNTAX 1.3.6.1.4.1.
 1466.115.121.1.27 SINGLE-VALUE )
olcObjectClasses: {0}( 1.3.6.1.4.1.4754.2.99.1 NAME 'pwdPolicyChecker' SUP top
  AUXILIARY MAY pwdCheckModule )
olcObjectClasses: {1}( 1.3.6.1.4.1.42.2.27.8.2.1 NAME 'pwdPolicy' SUP top AUXI
 LIARY MUST pwdAttribute MAY ( pwdMinAge $ pwdMaxAge $ pwdInHistory $ pwdCheck
 Quality $ pwdMinLength $ pwdExpireWarning $ pwdGraceAuthNLimit $ pwdLockout $
  pwdLockoutDuration $ pwdMaxFailure $ pwdFailureCountInterval $ pwdMustChange
  $ pwdAllowUserChange $ pwdSafeModify $ pwdMaxRecordedFailure ) )
EOT

ldapadd -Y EXTERNAL -H ldapi:/// -f ppolicy.ldif

ufw allow "OpenLDAP LDAP"
ufw allow "OpenLDAP LDAPS"



echo "Setup the memberof ...."

ldapsearch -LLL -Y EXTERNAL -H ldapi:/// -b  cn=config -LLL | grep -i module

find / -iname memberof.la

cat <<EOT> update-module.ldif
dn: cn=module{0},cn=config
changetype: modify
add: olcModuleLoad
olcModuleLoad: memberof.la
EOT

ldapadd -Y EXTERNAL -H ldapi:/// -f update-module.ldif

cat <<EOT> load-memberof-module.ldif

dn: cn=module,cn=config
cn: module
objectClass: olcModuleList
olcModuleLoad: memberof.la
olcModulePath: /usr/libexec/openldap
EOT
ldapadd -Y EXTERNAL -H ldapi:/// -f load-memberof-module.ldif

ldapsearch -LLL -Y EXTERNAL -H ldapi:/// -b  cn=config -LLL | grep -i module

ldapsearch -LLL -Y EXTERNAL -H ldapi:/// -b  cn=config olcDatabase | grep mdb

cat <<EOT> add-memberof-overlay.ldif

dn: olcOverlay=memberof,olcDatabase={1}mdb,cn=config
objectClass: olcMemberOf
objectClass: olcOverlayConfig
objectClass: olcConfig
objectClass: top
olcOverlay: memberof 
olcMemberOfRefInt: TRUE
olcMemberOfDangling: ignore
olcMemberOfGroupOC: groupOfNames
olcMemberOfMemberAD: member
olcMemberOfMemberOfAD: memberOf
EOT


ldapadd -Y EXTERNAL -H ldapi:/// -f add-memberof-overlay.ldif

find / -iname refint.la

cat <<EOT> add-refint.ldif
dn: cn=module{0},cn=config
changetype: modify
add: olcModuleLoad
olcModuleLoad: refint.la
EOT
ldapadd -Y EXTERNAL -H ldapi:/// -f add-refint.ldif

cat <<EOT> member-group.ldif
dn: cn=admins,ou=groups,dc=ldap,dc=${DOMAIN},dc=com
objectClass: groupOfNames
cn: admins
#member: uid=${GUSER},ou=people,dc=ldap,dc=${DOMAIN},dc=com
member: uid=${AUSER},ou=people,dc=ldap,dc=${DOMAIN},dc=com
EOT
ldapadd -Y EXTERNAL -H ldapi:/// -f member-group.ldif

ldapsearch -H ldapi:/// -Y EXTERNAL -LLL -b "dc=ldap,dc=${DOMAIN},dc=com" cn=admins

ldapsearch -H ldapi:/// -Y EXTERNAL -LLL -b "dc=ldap,dc=${DOMAIN},dc=com" memberOf

cat <<EOT> memberof.ldif
dn: uid=dawn,ou=people,dc=ldap,dc=${DOMAIN},dc=com
changetype: modify
add: memberOf
memberOf: cn=admins,ou=groups,dc=ldap,dc=${DOMAIN},dc=com
EOT

ldapadd -Y EXTERNAL -H ldapi:/// -f memberof.ldif

ldapsearch -H ldapi:/// -Y EXTERNAL -LLL -b "dc=ldap,dc=${DOMAIN},dc=com" uid=* memberOf

echo "Want more info:
  Got ot here:  https://kifarunix.com/how-to-create-openldap-member-groups/
    They are the ones who came up with this."


echo "installing sssd now for testing."

apt-get install -y sssd

cat <<EOT> /etc/sssd/sssd.conf
[sssd]
services = nss, pam, sudo
config_file_version = 2
domains = default

[sudo]

[nss]

[pam]
offline_credentials_expiration = 60

[domain/default]
ldap_id_use_start_tls = True
debug_level = 10
cache_credentials = True
ldap_search_base = dc=ldap,dc=${DOMAIN},dc=com
id_provider = ldap
auth_provider = ldap
chpass_provider = ldap
access_provider = ldap
sudo_provider = ldap
ldap_uri = ldaps://ldap.${DOMAIN}.com:636
ldap_default_bind_dn = cn=readonly,ou=system,dc=ldap,dc=${DOMAIN},dc=com
ldap_default_authtok = password
ldap_tls_reqcert = demand
ldap_tls_cacert = /etc/ssl/mycacert.crt
ldap_tls_cacertdir = /etc/ssl/certs
ldap_search_timeout = 50
ldap_network_timeout = 60
ldap_sudo_search_base = ou=SUDOers,dc=ldap,dc=${DOMAIN},dc=com
ldap_access_order = filter
ldap_access_filter = memberOf=cn=admins,ou=groups,dc=ldap,dc=${DOMAIN},dc=com
#User the following filter for standard machines. 
#ldap_access_filter = memberOf=cn=people,ou=groups,dc=ldap,dc=${DOMAIN},dc=com
EOT

chmod 600 /etc/sssd/sssd.conf

systemctl stop sssd;rm -rf /var/lib/sss/db/*;systemctl start sssd

ldapsearch -H ldapi:/// -Y EXTERNAL -LLL -b "dc=ldap,dc=${DOMAIN},dc=com" cn=sudo

cat <<EOT> addtosudo.ldif
dn: cn=sudo,ou=SUDOers,dc=ldap,dc=${DOMAIN},dc=com
changetype: modify
add: sudoUser
sudoUser: ${AUSER}
EOT


ldapadd -Y EXTERNAL -H ldapi:/// -f addtosudo.ldif


ldapsearch -H ldapi:/// -Y EXTERNAL -LLL -b "dc=ldap,dc=${DOMAIN},dc=com" cn=sudo

echo "the admin user is found and the generic user is not."
sudo -U ${AUSER} -ll
sudo -U ${GUSER} -ll

echo "System should be build.  Now you can try to ssh as the admin user: ${AUSER}   and then the generic user: ${GUSER}"
echo "Generic user is not allowed to login ad the ldap server is an administration level system."

