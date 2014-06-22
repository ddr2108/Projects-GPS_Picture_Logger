<?php

//Get data
$userName = $_POST['userName'];
$deviceName = $_POST['deviceName'];
$date = $_POST['date'];
$time =  $_POST['time'];
$deltaTime = $_POST['deltaTime'];

//Open connection with db
$con=mysqli_connect("localhost","deep","siddhartha","GPS_Logger");
if (mysqli_connect_errno()) {
    die('Connect Error: ' . $mysqli->connect_errno);
}

//Get data from db - all for that user/device from specific day
$result = mysqli_query($con,"SELECT * FROM GPS_Data WHERE userName='$userName' AND deviceName='$deviceName' AND date='$date'");

//Go through all matching
$validRows = array();
while($row = mysqli_fetch_array($result)) {
	//Check for a timestamp that meets all conditions
	if (abs($row['time']-$time)<$deltaTime){
		$validRows[] = $row;
	}
}

//echo new
$closestRows = array();
$closestDistance = $deltaTime;
foreach($validRows as $validRow){
	if (abs($validRow['time']-$time)<$closestDistance){
		unset($closestRows);
                $closestRows[] = $validRow;
		$closestDistance = abs($validRow['time']-$time);
	}else if (abs($validRow['time']-$time)==$closestDistance){
		$closestRows[] = $validRow;
	}
}

//Average closest rows
$longitude = 0;
$latitude = 0;
foreach($closestRows as $closeRow){
	$longitude = $longitude + $closeRow['longitude'];
	$latitude = $latitude + $closeRow['latitude'];
}
$longitude = $longitude/sizeof($closestRows);
$latitude = $latitude/sizeof($closestRows);

//Return closest rows
echo $longitude . "= "  . $latitude;

//Close connection
mysqli_close($con);

?>
