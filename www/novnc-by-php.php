<?php
/**
 *  * GET /virtual_machines/:virtual_machine_id/console.xml
 *   * GET /virtual_machines/:id.xml
 *    *
 *     * The first will start the console session and give you the port number to connect to.
 *      *
 *       * The second call, you are looking for remote_access_password.
 *        */
$CPURL = ""; // Insert the IP/hostname for your OnApp CP here
$VMID = ""; // Insert the VM's unique ID here
$username = ""; // Insert your own username here
$password = ""; // Insert the password for your account here

$ch = curl_init("http://{$CPURL}/virtual_machines/{$VMID}/console.json");

curl_setopt($ch, CURLOPT_USERPWD, $username . ":" . $password);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
$result = curl_exec($ch);
$set_one = json_decode($result);
curl_setopt($ch, CURLOPT_URL, "http://{$CPURL}/virtual_machines/{$VMID}.json");
$result = curl_exec($ch);
$set_two = json_decode($result);
$port = $set_one->remote_access_session->port;
echo "PORT:\t" . $set_one->remote_access_session->port . PHP_EOL;
echo "REMOTE_KEY:\t" . $set_one->remote_access_session->remote_key . PHP_EOL;
$rap = $set_two->virtual_machine->remote_access_password;
echo "REMOTE_ACCESS_PASSWORD:\t" . $rap . PHP_EOL;
$un = "root";
$pw = $set_two->virtual_machine->initial_root_password;
echo "ROOTPASS:\t" . $pw . PHP_EOL;
curl_close($ch);
$constructedURL = "vnc://{$CPURL}:{$port}/?vncPassword=" . urlencode($rap);
echo $constructedURL . PHP_EOL;
shell_exec("open " . $constructedURL);
?>
