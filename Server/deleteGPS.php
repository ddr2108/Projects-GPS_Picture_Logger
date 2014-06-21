<?php

//Get data
$userName = $_POST['userName'];
$deviceName = $_POST['deviceName'];

//Open connection with db
$con=mysqli_connect("localhost","deep","siddhartha","GPS_Logger");
if (mysqli_connect_errno()) {
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
}

//Delete db
mysqli_query($con,"DELETE FROM GPS_Data WHERE userName='$userName' AND deviceName='$deviceName'");

//Close connection
mysqli_close($con);

//Tell it was deleted
echo "Deleted";

?>
