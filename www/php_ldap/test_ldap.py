#!/usr/bin/env python

import ldap, sys

LDAP_SERVER = 'ldaps://ldap.example.com:636'
LDAP_BASE = 'dc=example,dc=com'

try:
    conn = ldap.initialize(LDAP_SERVER)
except ldap.LDAPError, e:
    sys.stderr.write("Fatal Error.n")
    raise

# this may or may not raise an error, e.g. TLS error -8172
items = conn.search_s(LDAP_BASE, ldap.SCOPE_SUBTREE, attrlist=['dn'])
