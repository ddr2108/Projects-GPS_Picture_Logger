<?php

//Get data
$userName = $_POST['userName'];
$deviceName = $_POST['deviceName'];
$date = $_POST['date'];
$daysHistory = $_POST['daysHistory'];

//Open connection with db
$con=mysqli_connect("localhost","deep","siddhartha","GPS_Logger");
if (mysqli_connect_errno()) {
    die('Connect Error: ' . $mysqli->connect_errno);
}

//If want all history
if ($daysHistory==-1){

	//Get all for this user and device
	$result = mysqli_query($con,"SELECT * FROM GPS_Data WHERE userName='$userName' AND deviceName='$deviceName'");

	//Count number of results and return
	$numResults = mysqli_num_rows($result);
	echo $numResults;

//Want recent history
}else{

	//Break date into pieces
	$datePieces = explode("-", $date);

	//Go through all the days of history required
	for ($i=0; $i<$daysHistory;$i++){

		//Create date
        $day = $datePieces[1]-$i;
        $modifiedDate =  $dateTokens[1] . '-'  . $dateTokens[0] . '-'  . $dateTokens[2];
        $numDaysBack = -1*$i .' day';
        $dateString = date('n-j-Y', strtotime($modifiedDate . $numDaysBack));
		
		//Get all for this user and device
		$result = mysqli_query($con,"SELECT * FROM GPS_Data WHERE userName='$userName' AND deviceName='$deviceName' AND date='$dateString'");
		while($row = mysqli_fetch_array($result)) {

			//Calcualte timestamp
			$hour = floor($row['time']/60);
			$min = $row['time']%60;
			//Calculate AM or PM
			if ($hour>=12){	
				$timeString = sprintf('%d:%02dPM', $hour%12, $min);
			}else{
				$timeString = sprintf('%d:%02dAM', $hour%12, $min);
			}

			echo $row['longitude'] . " ";
			echo $row['latitude'] . " ";
            echo $dateString . " ";
			echo $timeString . " ";

		}

	}

}

?>

