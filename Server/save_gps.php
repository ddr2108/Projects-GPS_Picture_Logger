?php

//Get data
$userName = $_GET['userName'];
$deviceName = $_GET['deviceName'];
$date = $_GET['date'];
$hour = $_GET['hour'];
$minute =  $_GET['minute'];
$longitude = $_GET['longitude'];
$latitude = $_GET["latitude"];

//Print data for confirmation
echo $userName;
echo $deviceName;
echo $date;
echo $hour;
echo $minute;
echo $longitude;
echo $latitude;

//Open connection with db
$con=mysqli_connect("localhost","deep","siddhartha","GPS_Logger");
if (mysqli_connect_errno()) {
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
}

//Insert into db
mysqli_query($con,"INSERT INTO GPS_Data (userName, deviceName, date, hour, minute, longitude, latitude) VALUES ('$userName', '$deviceName', '$date', '$hour', '$minute', '$longitude', '$latitude')");


//Close connection
mysqli_close($con);

?>

//http://deepdattaroy.com/other/projects/GPS%20Logger/save_gps.php?userName=deep&deviceName=iPhone&date=6-6-2014&hour=3&minute=3&longitude=5&latitude=9