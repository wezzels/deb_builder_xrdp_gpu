<?php
    /*
    Project Name: PHPConsole
    Usage: Upload this file to FTP space, and run it from browser.
    Description: PHPConsole is a simple and compact browser-based AJAX PHP console, that
    allows direct acces to the PHP erver-side interpreter, recieving via AJAX all your 
    code output.
    WARNING! ENSURE YOU CHANGE THE DEFAULT PASSWORD BEFORE UPLOADING!
    Version: 1.5
    Author: c0lx1
    Macros: 
    – ls([path]) 
      Outputs the provided dirpath contents (or current dir if no argument is pased).
 
    – cat(filename) 
      Outputs the content of the requested file.
 
    – help()
      List the available macros.
    */
    /*
        This program is free software; you can redistribute it and/or modify
        it under the terms of the GNU General Public License as published by
        the Free Software Foundation; either version 2 of the License, or
        (at your option) any later version.

        This program is distributed in the hope that it will be useful,
        but WITHOUT ANY WARRANTY; without even the implied warranty of
        MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
        GNU General Public License for more details.
    */

    // ************ SET YOUR PASS !!!!
    $p = "admin1234"; 
    
    // ************ Initiation
    if($_SERVER['REQUEST_METHOD'] == "POST"){ 
        header('Content-Encoding: UTF-8');
        header('Content-Type: text/html; charset=UTF-8');
        error_reporting(E_ALL);
        if(!isset($_POST['p']) || $_POST['p'] !== $p){
            echo  "Wrong pass! Unallowed acces attempt.";
            die();
        }
        if(isset($_POST['c'])){ 
            if(get_magic_quotes_gpc()) $_POST['c'] = stripslashes($_POST['c']);
            eval($_POST['c']);
            die(); // prevents returning all following HTML code...
        };
    }
    // ************ some usefull functions
    function help(){
        echo "AVAILBLE MACROS:<br>";
        echo "ls() | cat()";
        return 0;
    }
    function login(){
        echo "1";
        return 0;
    }
    function ls($directory = null){
        $directory = isset($directory) ? $directory : getcwd();
        echo "Listing directory '".$directory."'...";
        echo "</br>-------------------------------------------------------";
        $results = array();
        $handler = opendir($directory);
        while ($file = readdir($handler)){
            if ($file != "." && $file != "..") $results[] = $file;
        }
        closedir($handler);
        foreach($results as $key => $elem) echo "</br>".utf8_encode($elem);
        echo "</br>";
        return 0;
    }
    function cat($file){
        if(!isset($file)) return 1;
        echo "Printing file contents '".$file."'...";
        echo "</br>-------------------------------------------------------";
        echo "<pre>";
        echo utf8_encode(htmlspecialchars(file_get_contents($file)));
        echo "</br>";
        echo "</pre>";
        return 0;
    }
?>
<html> 
<head>
    <meta http-equiv="Content-type" content="text/html; charset=utf-8" />
    <style>
        body {
            overflow: hidden;
            font-family: 'lucida console',arial;
            font-size: 10px;
            color: grey;
        }
        #code {
            resize: vertical;
            padding:10px;
            min-height:100px;
            width:100%
        }
        #code:focus {
            outline-width: 0;
        }
        #center{
            display: table;
            margin-left: auto;
            margin-right: auto;
        }
        #response{
            background-color:#EFEEFF;
            border:1px dashed grey;
            padding:10px;
            margin-top:10px;
            overflow:auto;
        }
    </style>
</head> 
<body> 
    <input id="pass" hidden="true" type="text" name="p" value="">
    <textarea id="code" name="c" placeholder ="...Insert your code, and press CTRL+ENTER to submit  ('-?' or '-help' for help)"></textarea>
    <div id="response" class="response"></div>
</body>
    <script> 
        // some vars definitions
        var pass        = document.getElementById("pass");
        var code        = document.getElementById("code");
        var response    = document.getElementById("response");
        // GUI events and other definitions
        if (typeof String.prototype.trim != 'function'){            // detect native str.trim implementation, if not defined, implement it
            String.prototype.trim = function () { return this.replace(/^s+/, '').replace(/s+$/, '')};
        }
        responsiveGUI();                                            // adapt GUI to screen dimensions                                           
        window.onresize      = function(){responsiveGUI()};         // ...and on resize window
        document.onmousemove = function(){responsiveGUI()};         // and on code textarea resize (code.onresize not really working)
        code.onkeydown = function(event){                           // CTRL+ENTER for subiting code, event definition
            if (event.keyCode == 13 && event.ctrlKey){ 
                response.innerHTML = "<div id='center'>Loding...</div>";
                send(function(str){
                    console.log(str);
                    response.innerHTML = str;
                });
            }else{checkTab(event)};
        };
        // Request user Login... 
        code.value           = "login();";                          // prepare login function for login request
        pass.value           = window.prompt("Insert password");    // promt for password acced
        send(function(resp){                                        // chek login request answer and disable GUI if unsuccesfull
                code.value                    = "";
                response.innerHTML            = resp;
                if(resp != '1') code.disabled = true;
                else{
                    tmpHTML   = "<div id='center'>";
                    tmpHTML  += "<br>";
                    tmpHTML  += "PHP in-Browser Ajax Console v0.5 (2012 - by colxi.info)<br>";
                    tmpHTML  += "-------------------------------------------------------------<br>";
                    tmpHTML  += "With this tiny web application you will be able to test your<br>";
                    tmpHTML  += "code snippets, directlly from the browser window, manage and <br>";
                    tmpHTML  += "explore your remote server file system, or anything else you <br>";
                    tmpHTML  += "could normally do with PHP.<br>";
                    tmpHTML  += "<br>";
                    tmpHTML  += "-------------------------------------------------------------<br>";
                    tmpHTML  += "WARNING: This applicatins offers an unlimited control scenario<br>";
                    tmpHTML  += "over your server, so be shure to change the DEFAULT PASSWORD.<br>";
                    tmpHTML  += "before moving it online.<br>";
                    tmpHTML  += "-------------------------------------------------------------<br>";
                    tmpHTML  += "<br>";
                    tmpHTML  += "BEHAVIOUR NOTES:<br>";
                    tmpHTML  += "<br>";
                    tmpHTML  += "- Your code will be executed in a non persistent way. That means<br>";
                    tmpHTML  += "it's going to be evaled after each new submission.<br>";
                    tmpHTML  += "- The output is done inside a PRE Html Tag.<br>";
                    tmpHTML  += "- UTF-8 whould be de default codification charset (but can fail).<br>";
                    tmpHTML  += "</div>";
                    response.innerHTML  = tmpHTML;
                }
            })
        // ready for action!
        code.focus();
        
        // ---------- FUNCTIONS ------------
        
        // adjust size of boxes on widows/textarea redimension
        function responsiveGUI(){
            var height            = (typeof window.innerHeight != 'undefined' ? window.innerHeight : document.body.offsetHeight);
            code.style.maxHeight  = (height - 175) + "px";
            response.style.height = (height - code.offsetHeight - 55) + "px";
        };
        
        // Ajax browser-to-server communication function
        function send(callback){
            if (window.XMLHttpRequest) var xmlhttp=new XMLHttpRequest();
                else var xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
            var file = sPage = window.location.pathname.substring(window.location.pathname.lastIndexOf('/') + 1);
            xmlhttp.open("POST", file ,true); 
            xmlhttp.setRequestHeader("Content-type","application/x-www-form-urlencoded;charset=UTF-8");
            codeSubmit = code.value.trim();
            if(codeSubmit == "-?" || codeSubmit == "-help" ) codeSubmit=  "help();"; 
            xmlhttp.send("c=" + codeSubmit + "&p=" + pass.value);
            // AJAX CALLBACK FUNCTION 
            xmlhttp.onreadystatechange = function(){
                if (xmlhttp.readyState == 4 && xmlhttp.status == 200) callback(xmlhttp.responseText);
            };
        };
        
        // TAB Key handler for textArea
        function checkTab(evt) {
            var tab = "    ";
            var t = evt.target;
            var ss = t.selectionStart;
            var se = t.selectionEnd;
            // Tab key - insert tab expansion
            if (evt.keyCode == 9) {
                evt.preventDefault();
                // Special case of multi line selection
                if (ss != se && t.value.slice(ss,se).indexOf("n") != -1) {
                    // In case selection was not of entire lines (e.g. selection begins in the middle of a line)
                    // we ought to tab at the beginning as well as at the start of every following line.
                    var pre = t.value.slice(0,ss);
                    var sel = t.value.slice(ss,se).replace(/n/g,"n"+tab);
                    var post = t.value.slice(se,t.value.length);
                    t.value = pre.concat(tab).concat(sel).concat(post);
                           
                    t.selectionStart = ss + tab.length;
                    t.selectionEnd = se + tab.length;
                }
                // "Normal" case (no selection or selection on one line only)
                else {
                    t.value = t.value.slice(0,ss).concat(tab).concat(t.value.slice(ss,t.value.length));
                    if (ss == se) {
                        t.selectionStart = t.selectionEnd = ss + tab.length;
                    }
                    else {
                        t.selectionStart = ss + tab.length;
                        t.selectionEnd = se + tab.length;
                    };
                };
            };
        };
        
    </script> 
</html>
