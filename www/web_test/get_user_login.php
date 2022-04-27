<?php


function get_user_ldap($userid,$password ) {

$uid = $userid;
$ldaphost = 'ldap://ldap.wezzel.com';
$search= 'dc=ldap,dc=wezzel,dc=com';
$ds = ldap_connect($ldaphost)
or die("Could not connect to $ldaphost");
  ldap_set_option($ds, LDAP_OPT_PROTOCOL_VERSION, 3);
  ldap_set_option($ds, LDAP_OPT_REFERRALS, 0);
  ldap_set_option($ds, LDAP_OPT_DEBUG_LEVEL, 7);
  if ($ds) 
  {
    $username = 'uid=' . $uid . ',ou=people,'.$search;
    $upasswd = $password;

    $ldapbind = ldap_bind($ds, $username, $upasswd);

    if ($ldapbind) 
        {
	    $message ="Ldap works!";
	    //print "Congratulations! $uid is authenticated.";
        }
    else 
        {print "Access Denied!";}
    // lookup info
    $filter='(uid='.$uid.')';
    $results = ldap_search($ds,$search,$filter);
    ldap_sort($ds,$results,'sn');
    $info = ldap_get_entries($ds, $results);
    
    // display info
    for ($i=0; $i<$info['count']; $i++) {
      $user_info[0] = $info[$i]['uid'][0];
      $user_info[1] = $info[$i]['cn'][0];
      $user_info[2] = $info[$i]['title'][0];
      $user_info[3] = $info[$i]['mail'][0];
      break;   
    }

    $_SESSION['LAST_ACTIVITY'] = time(); // update last activity time stamp

    // close ldap connection
    @ldap_close($ds);
    return $user_info;
  }
}
#print_r( get_user_ldap("wez","xx"));

?>

