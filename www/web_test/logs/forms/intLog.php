 <?php

  session_start();

  $file  = '/var/log/ip_sec.log';

  $lines = shell_exec('cat ' . escapeshellarg($file) . "| grep '^192.168' | sort -n" );
  $lines .= shell_exec('cat ' . escapeshellarg($file) . "| grep '^10\.' | sort -n" );

  $lines_array = array_filter(preg_split('#[\r\n]+#', trim($lines)));

  echo json_encode($lines_array);
  ?>
