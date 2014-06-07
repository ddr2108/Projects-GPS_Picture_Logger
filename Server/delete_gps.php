<?php

//Get data
$userName = $_GET['userName'];
$deviceName = $_GET['deviceName'];

//Open connection with db
$con=mysqli_connect("localhost","deep","siddhartha","GPS_Logger");
if (mysqli_connect_errno()) {
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
}

//Delete db
mysqli_query($con,"DELETE FROM GPS_Data WHERE userName='$userName' AND deviceName='$deviceName'");


//Close connection
mysqli_close($con);

?>

//http://deepdattaroy.com/other/projects/GPS%20Logger/delete_gps.php?userName=deep&deviceName=iPhone