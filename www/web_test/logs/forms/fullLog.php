 <?php

  session_start();

  $file  = '/var/log/ip_sec.log';

  $lines = shell_exec('cat ' . escapeshellarg($file) . '| sort -h' );

  $lines_array = array_filter(preg_split('#[\r\n]+#', trim($lines)));

  echo json_encode($lines_array);
  ?>
