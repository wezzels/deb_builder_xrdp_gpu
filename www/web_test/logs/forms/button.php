<?php
    if (isset($_POST['button_on']))
	        {
			         exec('sudo /home/pi/mark_project/bridge_on.sh >/tmp/turn_me_on.txt && ip a > /tmp/status.txt');
				     }
    if (isset($_POST['button_off']))
            {
                     exec('sudo /home/pi/mark_project/bridge_off.sh >/tmp/turn_me_off.txt && ip a > /tmp/status.txt');
                     }

?>
<html>
<style>
.button {
  background-color: #4CAF50; /* Green */
  border: none;
  color: white;
  padding: 15px 32px;
  text-align: center;
  text-decoration: none;
  display: inline-block;
  font-size: 16px;
  margin: 4px 2px;
  cursor: pointer;
}
.button_on { width: 25%; }
.button_off { width: 25%; background-color: red; }

</style>
<body>
    <form method="post">
    <p>
        <button class="button button_on" name="button_on">On</button>
        <button class="button button_off" name="button_off">Off</button>
    </p>
    </form>
    <?php
         $output = shell_exec('/home/pi/mark_project/is_active.sh');
         echo "<h1><pre>$output</pre></h1>";
    ?>
<div>
<h3>Service logs.</h3>
    <ul id="slog">
    </ul>
</div>
<div>
<h3>External list.</h3> 
    <ul id="extlog">
    </ul>
</div>

<div>
<h3>Internal list.</h3>
    <ul id="intlog">
    </ul>
</div>

<h3>Full list.</h3>
    <ul id="fulllog">
    </ul>
</div>

<script
  src="https://code.jquery.com/jquery-3.6.0.min.js"
  integrity="sha256-/xUj+3OJU5yExlq6GSYGSHk7tPXikynS7ogEvDej/m4="
  crossorigin="anonymous"></script>

<script>

    $(function(){

        setInterval(function(){
            $.getJSON( "./getLog.php", function( data ) {
              var $log = $('#log');
              $.each( data, function( key, val ) {
                $log.prepend( "<li>" + val + "</li>" );
              });
            });

        },5000);

    });

</script>

<script>
    $(function(){
        setInterval(function(){
            $.getJSON( "./extLog.php", function( data ) {
              var $log = $('#extlog');
              $log.empty();
              $.each( data, function( key, val ) {
                $log.prepend( "<li>" + val + "</li>" );
              });
            });
        },5000);
    });
</script>

<script>

    $(function(){

        setInterval(function(){
            $.getJSON( "./intLog.php", function( data ) {
              var $log = $('#intlog');
              $log.empty();
              $.each( data, function( key, val ) {
                $log.prepend( "<li>" + val + "</li>" );
              });
            });

        },5000);

    });

</script>
</body>
