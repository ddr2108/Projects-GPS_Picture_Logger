<?php

//Get data
$userName = $_GET['userName'];
$deviceName = $_GET['deviceName'];
$date = $_GET['date'];
$time =  $_GET['time'];
$deltaTime = $_GET['deltaTime'];

//Open connection with db
$con=mysqli_connect("localhost","deep","siddhartha","GPS_Logger");
if (mysqli_connect_errno()) {
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
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

//http://deepdattaroy.com/other/projects/GPS%20Logger/get_gps.php?userName=deep&deviceName=Deep-iPhone&date=6-7-2014&time=942&deltaTime=20