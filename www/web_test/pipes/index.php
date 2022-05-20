   <html>
    <head>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.0.0-beta1/jquery.min.js"></script>   
    </head>
    <body>
    <button id="btnTest1">pipeline 1 Click</button>
    <label for="oses">OS:</label>
    <select name="oses" id="oses">
      <option value="rhel8">RedHat 8</option>
      <option value="alma8">Alma Linux 8</option>
      <option value="cent8">CentOS 8</option>
      <option value="rocky8">RockyLinux 8</option>
      <option value="Ubuntu2204">Ubuntu 22.04</option>
      <option value="Ubuntu2004">Ubuntu 20.04</option>
    </select>
    <label for="type">Run:</label>
    <select name="type" id="tasks">
      <option value="incr">incr</option>
      <option value="full">full</option>
    </select>

    <label for="tasks">task:</label>
    <select name="tasks" id="tasks">
      <option value="mkMedia">Create ISO/UDF</option>
      <option value="mkImage">Create Image</option>
      <option value="mkISO2Img">Run ISO2IMG</option>
      <option value="getOrig">Get Image</option>
    </select>

<br>
    <button id="btnTest2">pipeline 2 Click</button><br>
    <button id="btnTest3">pipeline 3 Click</button><br>
    <button id="btnTest4">pipeline 4 Click</button><br>
    <button id="btnTest5">pipeline 5 Click</button><br>
    <button id="btnTest6">pipeline 6 Click</button><br>
    <button id="btnTest7">pipeline 7 Click</button><br>
    <button id="btnTest8">pipeline 8 Click</button><br>
    <button id="btnTest9">pipeline 9 Click</button><br>
    <button id="btnTest0">pipeline 0 Click</button><br>
    <script>

    $(document).ready(function () {
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
             })});
    $(document).ready(function () {
            $('#btnTest2').click(function () {
                    $("#btnTest2").attr("disabled", true);
                    $.ajax({
                        type: "POST",
                        url: 'ajax.php',
                        data:{action:'call_this'},
                        success:function(html) {
                                alert(html);
                                $("#btnTest2").attr("disabled",false);
                                }
                        });
             })});


    $(document).ready(function () {
	    $('#btnTest3').click(function () {
		    $("#btnTest3").attr("disabled", true);
    		    $.ajax({
       			type: "POST",
       			url: 'ajax.php',
       			data:{action:'call_this'},
       			success:function(html) {
         			alert(html);
				$("#btnTest3").attr("disabled",false);
       				}
     			});
    	     })});    
    $(document).ready(function () {
            $('#btnTest4').click(function () {
                    $("#btnTest4").attr("disabled", true);
                    $.ajax({
                        type: "POST",
                        url: 'ajax.php',
                        data:{action:'call_this'},
                        success:function(html) {
                                alert(html);
                                $("#btnTest4").attr("disabled",false);
                                }
                        });
             })});
    $(document).ready(function () {
            $('#btnTest5').click(function () {
                    $("#btnTest5").attr("disabled", true);
                    $.ajax({
                        type: "POST",
                        url: 'ajax.php',
                        data:{action:'call_this'},
                        success:function(html) {
                                alert(html);
                                $("#btnTest5").attr("disabled",false);
                                }
                        });
             })});


    $(document).ready(function () {
            $('#btnTest6').click(function () {
                    $("#btnTest6").attr("disabled", true);
                    $.ajax({
                        type: "POST",
                        url: 'ajax.php',
                        data:{action:'call_this'},
                        success:function(html) {
                                alert(html);
                                $("#btnTest6").attr("disabled",false);
                                }
                        });
             })});
    $(document).ready(function () {
            $('#btnTest7').click(function () {
                    $("#btnTest7").attr("disabled", true);
                    $.ajax({
                        type: "POST",
                        url: 'ajax.php',
                        data:{action:'call_this'},
                        success:function(html) {
                                alert(html);
                                $("#btnTest7").attr("disabled",false);
                                }
                        });
             })});
    $(document).ready(function () {
            $('#btnTest8').click(function () {
                    $("#btnTest8").attr("disabled", true);
                    $.ajax({
                        type: "POST",
                        url: 'ajax.php',
                        data:{action:'call_this'},
                        success:function(html) {
                                alert(html);
                                $("#btnTest8").attr("disabled",false);
                                }
                        });
             })});


    $(document).ready(function () {
            $('#btnTest9').click(function () {
                    $("#btnTest9").attr("disabled", true);
                    $.ajax({
                        type: "POST",
                        url: 'ajax.php',
                        data:{action:'call_this'},
                        success:function(html) {
                                alert(html);
                                $("#btnTest9").attr("disabled",false);
                                }
                        });
             })});
    $(document).ready(function () {
            $('#btnTest').click(function () {
                    $("#btnTest").attr("disabled", true);
                    $.ajax({
                        type: "POST",
                        url: 'ajax.php',
                        data:{action:'call_this'},
                        success:function(html) {
                                alert(html);
                                $("#btnTest").attr("disabled",false);
                                }
                        });
             })});

   </script>
   </body>
   </html>
