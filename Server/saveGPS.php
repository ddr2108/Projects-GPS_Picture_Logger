<?php

//Get data
$userName = $_POST['userName'];
$deviceName = $_POST['deviceName'];
$date = $_POST['date'];
$time = $_POST['time'];
$longitude = $_POST['longitude'];
$latitude = $_POST["latitude"];

//Open connection with db
$con=mysqli_connect("localhost","deep","siddhartha","GPS_Logger");
if (mysqli_connect_errno()) {
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
}

//Insert into db
mysqli_query($con,"INSERT INTO GPS_Data (userName, deviceName, date, time, longitude, latitude) VALUES ('$userName', '$deviceName', '$date', '$time', '$longitude', '$latitude')");

//Close connection
mysqli_close($con);

//Message saying it was inserted
echo "Inserted";

?>
