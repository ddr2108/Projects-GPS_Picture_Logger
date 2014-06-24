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

//if time is right after midnight
//Get data from db - all for that user/device from previous day
if ($time < $deltaTime){
	
	//modify date to previous date
        $dateTokens = explode('-', $date);
        $modifiedDate =  $dateTokens[1] . '-'  . $dateTokens[0] . '-'  . $dateTokens[2];
        $prevDate = date('n-j-Y', strtotime($modifiedDate .'-1 day'));
	
	//Get data from previous date
	$result = mysqli_query($con,"SELECT * FROM GPS_Data WHERE userName='$userName' AND deviceName='$deviceName' AND date='$prevDate'");

	//Go through all matching
	$validRows = array();
	while($row = mysqli_fetch_array($result)) {
		//modify time of new row
		$row['time'] = $row['time'] - 1440;

        	//Check for a timestamp that meets all conditions
        	if (abs($row['time']-$time)<$deltaTime){
                	$validRows[] = $row;
        	}
	}
}


//if time is right before midnight
if ((1440 - $time) < $deltaTime){
	//modify date to previous date
        $dateTokens = explode('-', $date);
        $modifiedDate =  $dateTokens[1] . '-'  . $dateTokens[0] . '-'  . $dateTokens[2];
        $nextDate = date('n-j-Y', strtotime($modifiedDate .'+1 day'));

        //Get data from previous date
        $result = mysqli_query($con,"SELECT * FROM GPS_Data WHERE userName='$userName' AND deviceName='$deviceName' AND date='$nextDate'");

        //Go through all matching
        $validRows = array();
        while($row = mysqli_fetch_array($result)) {
                //modify time of new row
                $row['time'] = $row['time'] + 1440;

                //Check for a timestamp that meets all conditions
                if (abs($row['time']-$time)<$deltaTime){
                        $validRows[] = $row;
                }
        }
}

//Find ones with closes distance
$closestRowsPos = array();
$closestDistancePos = $deltaTime;
$closestRowsNeg = array();
$closestDistanceNeg = $deltaTime*-1;
$zeroRows = array();
foreach($validRows as $validRow){
	//Earlier ones
	if (($validRow['time']-$time)<$closestDistancePos && ($validRow['time']-$time)>0){
		unset($closestRowsPos);
                $closestRowsPos[] = $validRow;
		$closestDistancePos = $validRow['time']-$time;
	}else if (($validRow['time']-$time)==$closestDistancePos && ($validRow['time']-$time)>0 ){
		$closestRowsPos[] = $validRow;
	}
	//Later ones
	if (($validRow['time']-$time)>$closestDistanceNeg && ($validRow['time']-$time)<0){
                unset($closestRowsNeg);
                $closestRowsNeg[] = $validRow;
                $closestDistanceNeg = $validRow['time']-$time;
        }else if (($validRow['time']-$time)==$closestDistanceNeg && ($validRow['time']-$time)<0 ){
                $closestRowsNeg[] = $validRow;
        }
	//Exact Matches
	if (($validRow['time']-$time)==0){
		$zeroRows[] = $validRow;
	}
}

//Defualt values of longitude and latitude
$longitude = 0;
$latitude = 0;

//Average closest rows
$longitudePos = 0;
$latitudePos = 0;
$longitudeNeg = 0;
$latitudeNeg = 0;
//Average rows that occured before, and those that happened after
foreach($closestRowsPos as $closeRow){
	$longitudePos = $longitudePos + $closeRow['longitude'];
	$latitudePos = $latitudePos + $closeRow['latitude'];
}
$longitudePos = $longitudePos/sizeof($closestRowsPos);
$latitudePos = $latitudePos/sizeof($closestRowsPos);
foreach($closestRowsNeg as $closeRow){
        $longitudeNeg = $longitudeNeg + $closeRow['longitude'];
        $latitudeNeg = $latitudeNeg + $closeRow['latitude'];
}
$longitudeNeg = $longitudeNeg/sizeof($closestRowsNeg);
$latitudeNeg = $latitudeNeg/sizeof($closestRowsNeg);
foreach($zeroRows as $closeRow){
        $longitudeZero = $longitudeZero + $closeRow['longitude'];
        $latitudeZero = $latitudeZero + $closeRow['latitude'];
}
$longitudeZero = $longitudeZero/sizeof($zeroRows);
$latitudeZero = $latitudeZero/sizeof($zeroRows);

//Calcualte final coordinates
//Do averaging if coordinates on both sides of time
if (sizeof($zeroRows)>0){
	$longitude = $longitudeZero;
	$latitude = $latitudeZero;
}else if (sizeof($closestRowsNeg)==0){
       	$longitude = $longitudePos;
       	$latitude = $latitudePos;
}else if (sizeof($closestRowsPos)==0){
	$longitude = $longitudeNeg;
        $latitude = $latitudeNeg;
}else{
	$ratio = abs(($closestDistancePos)/($closestDistancePos+$closestDistanceNeg));
	$longitude = $ratio*$longitudeNeg+(1-$ratio)*$longitudePos;
	$latitude = $ratio*$latitudeNeg+(1-$ratio)*$latitudePos;
}

//Return closest rows
echo $longitude . " "  . $latitude . " ";

//Close connection
mysqli_close($con);

?>
