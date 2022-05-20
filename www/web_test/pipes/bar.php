<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.0.0-beta1/jquery.min.js"></script>
<?php

$OS = array(
    'rhel'=>'Red Hat 8',
    'cent'=>'CentOS 8',
    'alma'=>'Alma Linux 8',
    'rock'=>'Rocky Linux 8',
    'ubut'=>'Ubuntu Linux 20.04',
    'ubut'=>'Ubuntu Linux 22.04'
);

$type = array( 
    'LEGACY'=>'legacy', 
    'UEFI'=>'uefi'     
);

$task = array(
	'mkimg'=>'Create Image',
	'mkiso'=>'Create ISO/UDF',
	'iso2img'=>'Run ISO build',
	'getimg'=>'Grab generic image',
	'ansible'=>'install ansible from git',
	'unansible'=>'Run exceptions from git',
	'stigs'=>'Run stig roles',
	'unstigs'=>'Run stig exceptions'
);
?>
<style>
.btn-styled {
    font-size: 14px;
    margin: 8px;
    padding: 0 10px;
    line-height: 2;
}
</style>
<div id="pipeline">
<form name="addPipe" action="" >
<select name="OS">
<option value="">-----O/S-----</option>
<?php
    asort($OS);
    reset($OS);
    foreach($OS as $p => $w):
        echo '<option value="'.$p.'">'.$w.'</option>'; 
    endforeach;
?>
</select>

<select name="BIOS">
<option value="">----BIOS-------</option>
<?php
    asort($type);
    reset($type); 
    foreach($type as $p => $w):
        echo '<option value="'.$p.'">'.$w.'</option>';
    endforeach;
?>
</select>

<select name="TASK">
<option value="">---Task-Script---</option>
<?php
    asort($task);
    reset($task);
    foreach($task as $p => $w):
        echo '<option value="'.$p.'">'.$w.'</option>';
    endforeach;
?>
</select>

<button id="btnAdd">Start</button>
<button id="btnRestart">Restart</button>
<button id="btnCancel">Cancel</button>
<button id="btnHist">History</button>
 <input type="submit" name="submit" class="button" id="submit_btn" value="Send" />
</form>
</div>
<br>
<br>

<script>
    $(document).ready(function () {
     $('#container').append('<button class="btn-styled" type="button">Press me</button>');
     $('#btnTest1').click(function () {
       $("#btnTest1").attr("disabled", true);
       $.ajax({
         type: "POST",
         url: 'ajax.php',
         data:{action:'call_this'},
         success:function(html) {
           alert(html);
           $("#btnTest1").attr("disabled",false);
           }
        });
     })
    $( "form" ).on( "submit", function(e) {
 
    var dataString = $(this).serialize();
     
    // alert(dataString); return false;
 
  });
});

</script>

<div id="container"></div>

<form class="form" action="" method="post">
    <input type="text" name="name" id="name" >
    <textarea name="text" id="message" placeholder="Write something to us"> </textarea>
    <input type="button" onclick="return formSubmit();" value="Send">
</form>

<script>
    function formSubmit(){
        var name = document.getElementById("name").value;
        var message = document.getElementById("message").value;
        var dataString = 'name='+ name + '&message=' + message;
        jQuery.ajax({
            url: "submit.php",
            data: dataString,
            type: "POST",
            success: function(data){
                $("#myForm").html(data);
            },
            error: function (){}
        });
    return true;
    }
</script>

