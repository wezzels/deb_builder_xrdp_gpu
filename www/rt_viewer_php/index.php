<!doctype html>
<html>
<head>
<meta charset="UTF-8">
<title>Read Log File</title>

</head>

<body>
<div>
    <ul id="log">

    </ul>
</div>
<script src="./jquery-3.6.0.min.js"></script> 
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
</body>
</html>
