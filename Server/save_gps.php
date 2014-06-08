<?php

//Get data
$userName = $_GET['userName'];
$deviceName = $_GET['deviceName'];
$date = $_GET['date'];
$time = $_GET['time'];
$longitude = $_GET['longitude'];
$latitude = $_GET["latitude"];

//Open connection with db
$con=mysqli_connect("localhost","deep","siddhartha","GPS_Logger");
if (mysqli_connect_errno()) {
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
}

//Insert into db
mysqli_query($con,"INSERT INTO GPS_Data (userName, deviceName, date, time, longitude, latitude) VALUES ('$userName', '$deviceName', '$date', '$time', '$longitude', '$latitude')");


//Close connection
mysqli_close($con);

?>