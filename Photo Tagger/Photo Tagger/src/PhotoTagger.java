import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Calendar;

import javax.swing.JLabel;

import org.apache.commons.imaging.ImageReadException;
import org.apache.commons.imaging.ImageWriteException;
import org.apache.commons.imaging.Imaging;
import org.apache.commons.imaging.formats.jpeg.JpegImageMetadata;
import org.apache.commons.imaging.formats.jpeg.exif.ExifRewriter;
import org.apache.commons.imaging.formats.tiff.TiffField;
import org.apache.commons.imaging.formats.tiff.TiffImageMetadata;
import org.apache.commons.imaging.formats.tiff.constants.TiffTagConstants;
import org.apache.commons.imaging.formats.tiff.write.TiffOutputSet;
import org.apache.commons.imaging.util.IoUtils;


public class PhotoTagger {

	//Label for showing progress
	JLabel curProgressLabel;
	
	//Parameters necessary for getting data from server
	String userName;
	String deviceName;
	String deltaTime;
	
	//Parameters for shifting time
	String timeDifference;
	
	public PhotoTagger(){
		
	}
	
	/*
	* setParameters()
	*
	* parameters: 
	* 	String userName - user name of the user
	*	String deviceName - device name of the device
	*	String time - time of the picture
	*	String date - date of the picture
	*	String deltaTime - delta time for GPS coordinates
	*	String timeDifference - time difference between camera and phone
	* returns: 
	* 	none
	* 
	* saves the parameters needed for tagging photos
	*/
	public void setParameters(String userName, String deviceName, String deltaTime, String timeDifference){
		
		//Save the parameters
		this.userName = userName;
		this.deviceName = deviceName;
		this.deltaTime = deltaTime;
		this.timeDifference = timeDifference;
		
	}
	
	/*
	* setProgressLabel()
	*
	* parameters: 
	* 	JLabel curProgressLabel - label with progress
	* returns: 
	* 	none
	* 
	* saves the progress label infor
	*/
	public void setProgressLabel(JLabel curProgressLabel){
		
		//Save the label
		this.curProgressLabel = curProgressLabel;
		
	}
	
	/*
	* startProcessing()
	*
	* parameters: 
	* 	String directory - directory to process
	* returns: 
	* 	none
	* 
	* begin the processing of pictures
	*/
	public void startProcessing(String directory) {
		
		//Go through all the files in that directory and process those
		File[] files = new File(directory).listFiles();
		processFiles(files);

		//Say processing is done
		curProgressLabel.setText("Done");

	}

	
	/*
	* processFiles()
	*
	* parameters: 
	* 	File[] files - set of files to examine
	* returns: 
	* 	none
	* 
	* go through each file and process that file
	*/
	private void processFiles(File[] files) {
		
		//Go through all files in current directory
	    for (File file : files) {
	    	
	    	//Examine files
	        if (file.isDirectory()) {	//If the file is a directory, rerun on that directory
	        	processFiles(file.listFiles()); 
	        }else {		//if is a file
	        	
	        	//If it is a jpeg
            	if (file.getName().contains("JPG")){
            		
            		//Set progress label
            		curProgressLabel.setText(file.getName());

            		//Try to add gps coordinates
		            try {
			            setExifGPSTag(file);		//Put gps coordinates into new file
			        } catch (ImageReadException | ImageWriteException | IOException e) {
						e.printStackTrace();
					}
		            
            	}
            	
	        }
	        
	    }
	    
	}
	
	/*
	* setExifGPSTag()
	*
	* parameters: 
	* 	final File file - original jpeg
	* returns: 
	* 	none
	* 
	* run the program
	*/
    private void setExifGPSTag(final File file) throws IOException, ImageReadException, ImageWriteException {
    	
    	//Related to writing temp file with new metadata
        File tempFile = null;	
    	OutputStream os = null;

    	//Output metadata
    	TiffOutputSet outputMetadata = null;

    	///////////////////PULL METADATA FROM IMAGE//////////////////////
    	
        //Get metadata from picture
        final JpegImageMetadata jpegMetadata = (JpegImageMetadata) Imaging.getMetadata(file);
        
        //If there is metadata
        if (jpegMetadata != null) {

        	//get the exif data
        	final TiffImageMetadata exifMetadata = jpegMetadata.getExif();
            if (exifMetadata != null) {
                outputMetadata = exifMetadata.getOutputSet();
            }
            
        }

        //if there is no exif metadata, then return
        if (outputMetadata == null) {
        	return;
        }

        ///////////////////GET DATA FROM SERVER/////////////////////
        
        //Get the timestamp
        String[] dateTime = getTime(jpegMetadata);
        //Return if no timestamp
        if (dateTime == null){
        	return;
        }
        
        //Get coordinates
        double[] coordinates = getCoordinates(dateTime);
        //Return if no coordinates
        if (coordinates == null){
        	return;
        }

        //Set coordinates
        outputMetadata.setGPSInDegrees(coordinates[0], coordinates[1]);
        
        /////////////////WRITE TO FILE////////////////////////

        //create new file for use as temp for recording gps
        tempFile = new File(file.getAbsolutePath() + "-2");		

        
        //Create a stream to write to the file
        os = new FileOutputStream(tempFile);
        os = new BufferedOutputStream(os);
        new ExifRewriter().updateExifMetadataLossless(file, os, outputMetadata);
        
        //close the stream
        IoUtils.closeQuietly(true, os);
        
        //Rename file to get original
        String originalPath = file.getAbsolutePath();
        file.delete();
        File tempFileRename = new File(originalPath);	
        tempFile.renameTo(tempFileRename);

	}

	/*
	* getCoordinates()
	*
	* parameters: 
	* 	String timestamp - timestamp of image
	* returns: 
	* 	double[] - longitude and latitude
	* 
	* get coordinates from server
	*/
    private double[] getCoordinates(String[] dateTime){
    	
    	//hold coordinates to return
    	double[] coordinates = new double[2];
    	 
    	//Pull out time and date
    	String time = dateTime[0];
    	String date = dateTime[1];
    	
    	//Generate URL
    	String baseURL = "http://deepdattaroy.com/other/projects/Services/GPS%20Logger/getGPS.php";
    	String post = "userName=" + userName + "&deviceName=" + deviceName + "&date=" + date + "&time=" + time + "&deltaTime=" + deltaTime;

    	//Talk to server
    	String response = "";
		try {
			
	    	//Create connection to server
			URL url = new URL(baseURL);
	    	HttpURLConnection request = (HttpURLConnection) url.openConnection();

			//add request header
	    	request.setRequestMethod("POST");
	    	request.setRequestProperty("User-Agent", "Mozilla/5.0");
	    	request.setRequestProperty("Accept-Language", "en-US,en;q=0.5");
	 
			// Send post request
	    	request.setDoOutput(true);
			DataOutputStream wr = new DataOutputStream(request.getOutputStream());
			wr.writeBytes(post);
			wr.flush();
			wr.close();

			//Read Reponse
	    	BufferedReader responseReader = new BufferedReader(new InputStreamReader(request.getInputStream()));
	    	response = responseReader.readLine();
	    	responseReader.close();
	    	
		} catch (IOException e) {
			return null;
		}  	
    	
		//Get pieces of reponse
        String[] coordinatesTokens = response.split("[ ]+");
      
        //No data found
    	if (coordinatesTokens.length==0){
    		return null;
    	}
    	
    	//Pull the coordinates
    	coordinates[0] = Double.parseDouble(coordinatesTokens[0]);
    	coordinates[1] = Double.parseDouble(coordinatesTokens[1]);
    	
    	//Return data
    	return coordinates;
    }
    
	/*
	* getTime()
	*
	* parameters: 
	* 	final JpegImageMetadata jpegMetadata - jpeg metadata
	* returns: 
	* 	String[] - time/data info
	* 
	* get the time and date in pic
	*/
    private String[] getTime(final JpegImageMetadata jpegMetadata){
    	
    	Calendar shiftedTime = shiftTime(jpegMetadata);
    	
        //Return data if available; otherwise return null
        if (shiftedTime == null){
        	return null;
        }
        
        //Generate date and time
        int time = shiftedTime.get(Calendar.HOUR_OF_DAY)*60 + shiftedTime.get(Calendar.MINUTE);
        String date = (shiftedTime.get(Calendar.MONTH) + 1) + "-" + shiftedTime.get(Calendar.DAY_OF_MONTH) + "-" + shiftedTime.get(Calendar.YEAR);

        //Date Time info array
        String dateTime[] = {Integer.toString(time), date};
        
        //Return data
        return dateTime;
        
    }
    
    /*
	* shiftTime()
	*
	* parameters: 
	* 	final JpegImageMetadata jpegMetadata - jpeg metadata
	* returns: 
	* 	Calendar - calander of time
	* 
	* Shift the time in pic based on what was logged
	*/
    private Calendar shiftTime(final JpegImageMetadata jpegMetadata){
    	
    	//Get that field of metadata
        final TiffField field = jpegMetadata.findEXIFValueWithExactMatch(TiffTagConstants.TIFF_TAG_DATE_TIME);
        
        //Return data if available; otherwise return null
        if (field == null){
        	return null;
        }
        
        //Get timestamp and break into pieces
        String timestamp = field.getValueDescription();
        String[] timestampTokens = timestamp.split("[ :']+");
        
        //Generate date and time of picture
        Calendar picTime = Calendar.getInstance();
        picTime.set(Calendar.HOUR_OF_DAY, Integer.parseInt(timestampTokens[4]));
        picTime.set(Calendar.MINUTE, Integer.parseInt(timestampTokens[5]));
        picTime.set(Calendar.SECOND, Integer.parseInt(timestampTokens[6]));
        picTime.set(Calendar.DAY_OF_MONTH, Integer.parseInt(timestampTokens[3]));
        picTime.set(Calendar.MONTH, Integer.parseInt(timestampTokens[2])-1);
        picTime.set(Calendar.YEAR, Integer.parseInt(timestampTokens[1]));
        
        //Generate new time
        picTime.add( Calendar.HOUR, Integer.parseInt(timeDifference));
        
        //return calander
        return picTime;
    }

}
