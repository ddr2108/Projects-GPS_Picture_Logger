<?php

//Get data
$userName = $_POST['userName'];
$deviceName = $_POST['deviceName'];
$date = $_POST['date'];
$deleteID = $_POST['deleteID'];

//Open connection with db
$con=mysqli_connect("localhost","deep","siddhartha","GPS_Logger");
if (mysqli_connect_errno()) {
    die('Connect Error: ' . $mysqli->connect_errno);
}

//Delete db
if ($deleteID==-1){
	mysqli_query($con,"DELETE FROM GPS_Data WHERE userName='$userName' AND deviceName='$deviceName' AND date='$date'");
}

//Close connection
mysqli_close($con);

//Tell it was deleted
echo "Deleted";

?>
