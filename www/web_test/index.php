<?php
// set error reporting level
if (version_compare(phpversion(), "5.3.0", ">=") == 1)
  error_reporting(E_ALL & ~E_NOTICE & ~E_DEPRECATED);
else
	error_reporting(E_ALL & ~E_NOTICE);
include 'get_user_login.php';
//session_start();
$message="";

$oLoginSystem = new LoginSystem();
$sLoginForm = $oLoginSystem->getLoginBox();
echo strtr(file_get_contents('nothingpage.html'), array('{login_form}' => $sLoginForm));
class LoginSystem {
    function getLoginBox() {
        ob_start();
        require_once('login_form.html');
        $sLoginForm = ob_get_clean();
        ob_start();
        require_once('user_dashboard.php');
        $sLogoutForm = ob_get_clean();
        if (isset($_GET['logout'])) {
            if (isset($_COOKIE['member_name']) && isset($_COOKIE['member_pass']))
                $this->simple_logout();
        }
        if ($_POST['username'] && $_POST['password']) {
            if ($this->check_login()) {
		    $this->simple_login($_POST['username'], $_POST['password']);
		    $_SESSION["ACPAGE"] = "main"; 
                return $sLogoutForm . '<h2>Hello ' . $_COOKIE['member_name'] . '!</h2>';
            } else {
                return $sLoginForm . '<h2>Username or Password is incorrect</h2>';
            }
        } else {
            if ($_COOKIE['member_name'] && $_COOKIE['member_pass']) {
                if ($this->check_login($_COOKIE['member_name'], $_COOKIE['member_pass'])) {
                    return $sLogoutForm . '<h2>Hello ' . $_COOKIE['member_name'] . '!</h2>';
                }
            }
            return $sLoginForm;
        }
    }
    function simple_login($sName, $sPass) {
        $this->simple_logout();
        $sMd5Password = MD5($sPass);
        $iCookieTime = time() + 24*60*60*30;
        setcookie("member_name", $sName, $iCookieTime, '/');
        $_COOKIE['member_name'] = $sName;
        setcookie("member_pass", $sMd5Password, $iCookieTime, '/');
        $_COOKIE['member_pass'] = $sMd5Password;
    }
    function simple_logout() {
        setcookie('member_name', '', time() - 96 * 3600, '/');
        setcookie('member_pass', '', time() - 96 * 3600, '/');
        unset($_COOKIE['member_name']);
        unset($_COOKIE['member_pass']);
	$_SESSION['ACPAGE'] = 'public';
    }
    function check_login() {
        if(count($_POST)>0) {
          $row = get_user_ldap($_POST["username"],$_POST["password"]);
          //print_r($row);
          if(is_array($row)) {
            $message = $row[1];
            //echo $row[0];
            $_SESSION["user_id"] = $row[0];
            $_SESSION["user_name"] = $row[1];
            $_SESSION["full_name"] = $row[2];
            $_SESSION["email"] = $row[3];
            return true;
          } else {
            $message = "Invalid Username or Password!";
            print_r(array_values($row[0]));
            echo "Invalid Username or Password!";
            return false;
          }
        }
        return false;
    }
}
switch($_SESSION["ACPAGE"]) {
   case "main":
	require_once('main/index.php');
	break;
   case "logs":
	require_once('logs/index.php');
	break;
   case "pipes":
	require_once('pipe/index.php');
	break;
   case "status":
	require_once('status/index.php');
	break;
   default:
   	require_once('frontpage.html');
   }
?>
