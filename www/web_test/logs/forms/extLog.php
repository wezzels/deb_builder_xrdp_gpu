 <?php

  session_start();

  $file  = '/var/log/detail.log';
  $temp  = shell_exec('for n in `cat /var/log/ip_sec.log | grep -v "^192.168\." | grep -v "10\." | grep -v "^0.0.0.0" | grep -v "^169.254\."` ; do echo "$n `geoiplookup $n | cut -d":" -f2` `whois $n | grep -m1 Organization | grep -v "IP Address not found" |cut -d":" -f2` `nslookup $n | grep -v "NXDOMAIN" | cut -d"=" -f2`"; done| grep -v Authoritative > /var/log/detail.log  ; sed -i "/^$/d" /var/log/detail.log');
  $lines = shell_exec('cat ' . escapeshellarg($file));

  $lines_array = array_filter(preg_split('#[\r\n]+#', trim($lines)));

  echo json_encode($lines_array);
  ?>
