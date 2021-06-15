<?php
    # Not ideal method but quick and easy.
	$masterapi = '123i8913u894894y278323904y238948390423y';
	$api = $_GET['api'];
	$msg = $_GET['msg'];
	$name = $_GET['name'];
	if ($api == $masterapi) {
		include('Net/SSH2.php');
		$ssh = new Net_SSH2('localhost');
		if (!$ssh->login('root', 'password')) {
		    exit('Login Failed');
		    echo "login failed?";
		}
		echo $ssh->exec("screen -S $name -p 0 -X stuff '$msg\n'");
	} else {
		echo "Invalid API";
	}
?>
