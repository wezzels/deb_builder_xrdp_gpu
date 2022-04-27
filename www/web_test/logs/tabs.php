<!DOCTYPE html>
<html>
<head>
<link rel="stylesheet" href="tabs.css">
<link rel="stylesheet" href="bedim.css">
</head>
<body>
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

</style>
<div class="tabs">
  <div role="tablist" aria-label="Entertainment">
    <button role="tab"
            aria-selected="true"
            aria-controls="ext-tab"
            id="nils">
      External IPs
    </button>
    <button role="tab"
            aria-selected="false"
            aria-controls="int-tab"
            id="agnes"
            tabindex="-1">
      Internal IPs
    </button>
    <button role="tab"
            aria-selected="false"
            aria-controls="serv-tab"
            id="complex"
            tabindex="-1"
            data-deletable="">
      Services 
    </button>
  </div>
  <div tabindex="0"
       role="tabpanel"
       id="ext-tab"
       aria-labelledby="External IPs">
    <h4>External IPs</h4>
    <p>
    List of ips.
    </p>
    <div>
       <h3>External list.</h3>
       <ul id="extlog">
       </ul>
    </div>
  </div>
  <div tabindex="0"
       role="tabpanel"
       id="int-tab"
       aria-labelledby="Internal IPs"
       hidden="">
    <h4>Internal IPs</h4>	  
    <p>
    List of IPs.
    </p>
    <div>
    <h3>Internal list.</h3>
        <ul id="intlog">
            </ul>
            </div>

  </div>
  <div tabindex="0"
       role="tabpanel"
       id="serv-tab"
       aria-labelledby="Services"
       hidden="">
    <h4>Services.</h4>	  
    <p>
      external connections.
    </p>
    <p>
      Internal services.
    </p>
  </div>
</div>
<script src="./tabs.js"></script>
<script
  src="https://code.jquery.com/jquery-3.6.0.min.js"
  integrity="sha256-/xUj+3OJU5yExlq6GSYGSHk7tPXikynS7ogEvDej/m4="
  crossorigin="anonymous"></script>
<script>
  $(function(){
    setInterval(function(){
      $.getJSON( "forms/extLog.php", function( data ) {
        var $log = $('#extlog');
        $log.empty();
        $.each( data, function( key, val ) {
           $log.prepend( "<li>" + val + "</li>" );
        });
      });
    },5000);
  });
  $(function(){
    setInterval(function(){
      $.getJSON( "forms/intLog.php", function( data ) {
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
</html>
