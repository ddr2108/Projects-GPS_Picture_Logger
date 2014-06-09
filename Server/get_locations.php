<?php

//Get data
$userName = $_GET['userName'];
$deviceName = $_GET['deviceName'];
$date = $_GET['date'];
$daysHistory = $_GET['daysHistory'];

//Open connection with db
$con=mysqli_connect("localhost","deep","siddhartha","GPS_Logger");
if (mysqli_connect_errno()) {
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
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
                $dateString = $datePieces[0] . "-" . $day . "-" .$datePieces[2];
                
                //Get all for this user and device
                $result = mysqli_query($con,"SELECT * FROM GPS_Data WHERE userName='$userName' AND deviceName='$deviceName' AND date='$dateString'");
                while($row = mysqli_fetch_array($result)) {
                        //Calcualte timestamp
                        $hour = floor($row['time']/60);
                        $min = $row['time']%60;
                        $timeString = strval($hour) . ":" . strval($min);

                        echo $row['longitude'] . " ";
                        echo $row['latitude'] . " ";
                        echo $dateString . " ";
                        echo $timeString;
                        echo "<br/>";
                }

        }
          
}        
        
?>