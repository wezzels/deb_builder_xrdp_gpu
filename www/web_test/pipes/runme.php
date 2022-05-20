<?php

$command = escapeshellcmd('du /');
$output = shell_exec($command);
echo $output;
?>
