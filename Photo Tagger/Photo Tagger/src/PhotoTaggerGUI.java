import javax.net.ssl.HttpsURLConnection;
import javax.swing.*;

import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;

import org.apache.commons.imaging.ImageReadException;
import org.apache.commons.imaging.ImageWriteException;
import org.apache.commons.imaging.Imaging;
import org.apache.commons.imaging.common.IImageMetadata;
import org.apache.commons.imaging.common.RationalNumber;
import org.apache.commons.imaging.formats.jpeg.JpegImageMetadata;
import org.apache.commons.imaging.formats.jpeg.exif.ExifRewriter;
import org.apache.commons.imaging.formats.tiff.TiffField;
import org.apache.commons.imaging.formats.tiff.TiffImageMetadata;
import org.apache.commons.imaging.formats.tiff.constants.ExifTagConstants;
import org.apache.commons.imaging.formats.tiff.constants.TiffTagConstants;
import org.apache.commons.imaging.formats.tiff.write.TiffOutputDirectory;
import org.apache.commons.imaging.formats.tiff.write.TiffOutputSet;
import org.apache.commons.imaging.util.IoUtils;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.HttpClients;
import org.omg.CORBA.NameValuePair;

//Start button panel - starts all other panel
public class PhotoTaggerGUI extends JPanel implements ActionListener{
	
	//All the panels used
	Directory directoryPanel;
	UserName userNamePanel;
	DeviceName deviceNamePanel;
	TimeInterval timerIntervalPanel;
	
	/*
	* main()
	* 
	* parameters: 
	* 	String[] args - default args
	* returns: 
	* 	none
	*
	* beginning of program
	*/
	public static void main(String[] args) {    
        new PhotoTaggerGUI();
    }

	/*
	* photoTaggerGUI()
	* 
	* parameters: 
	* 	none
	* returns: 
	* 	none
	*
	*constructor - sets up gui for this panel
	*/
	public PhotoTaggerGUI() {
		//Set up start button
		JButton startButton = new JButton("Start");
		//Create Progress Label
		JLabel progressLabel = new JLabel("Progress:");
		//Create Label with Progress
		JLabel curProgressLabel = new JLabel("");

		//Set up action listener
		startButton.addActionListener(this);
		
		//Add to panel
		this.add(startButton);
		this.add(progressLabel);
		this.add(curProgressLabel);
		
		//Set up rest of gui
		setUpFrame();
	}
	
	/*
	* setUpFrame()
	* 
	* parameters: 
	* 	none
	* returns: 
	* 	none
	*
	* sets up the outer frame
	*/
	public void setUpFrame(){
		//Set up frame
		JFrame guiFrame = new JFrame();
		guiFrame.setTitle("Photo Tagger");
		guiFrame.setSize(1200, 200);
		guiFrame.setLocationRelativeTo(null);
		guiFrame.setLayout(new FlowLayout());

		//Get all the panels
		directoryPanel = new Directory();
		userNamePanel = new UserName();
		deviceNamePanel = new DeviceName();
		timerIntervalPanel = new TimeInterval();

		//Set up frame
		guiFrame.add(directoryPanel);
		guiFrame.add(userNamePanel);
		guiFrame.add(deviceNamePanel);
		guiFrame.add(timerIntervalPanel);
		guiFrame.add(this);
		
		//make sure the JFrame is visible
        guiFrame.setVisible(true);
	}
	    
    /*
	* actionPerformed()
	*
	* parameters: 
	* 	ActionEvent arg0 - default args
	* returns: 
	* 	none
	* 
	* run the program
	*/
	@Override
	public void actionPerformed(ActionEvent e) {
		//Get the directory name
		String directoryName = directoryPanel.getName();
		
		//Go through all the files in that directory
		File[] files = new File(directoryName).listFiles();
    	showFiles(files);
	}

	/*
	* showFiles()
	*
	* parameters: 
	* 	File[] files - set of files to examine
	* returns: 
	* 	none
	* 
	* run the program
	*/
	public void showFiles(File[] files) {
		//Go through all files in current directory
	    for (File file : files) {
	    	
	    	//Examine files
	        if (file.isDirectory()) {	//If the file is a directory, rerun on that directory
	            showFiles(file.listFiles()); 
	        }else {		//if is a file
	        	
	        	//If it is a jpeg
            	if (file.getName().contains("JPG")){
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
    public void setExifGPSTag(final File file) throws IOException, ImageReadException, ImageWriteException {
        File tempFile = null;		//new file	
    	OutputStream os = null;		//stream to write to file
        boolean canThrow = false;	//throw exceptions
        TiffOutputSet outputSet = null;

        //Get metadata from picture
        final IImageMetadata metadata = Imaging.getMetadata(file);
        final JpegImageMetadata jpegMetadata = (JpegImageMetadata) metadata;
        
        //If there is metadata
        if (null != jpegMetadata) {

        	//get the exif data
        	final TiffImageMetadata exif = jpegMetadata.getExif();
            if (exif != null) {
                outputSet = exif.getOutputSet();
            }
        }

        //if there is no exif metadata, then return
        if (outputSet == null) {
        	return;
        }

        //Get the timestamp
        String[] dateTime = getTime(jpegMetadata);
        //Return if no timestamp
        if (dateTime == null){
        	return;
        }
        
        //Get coordinates
        double[] coordinates = getCoordinates(dateTime);
        //Return if no coordinates
        if (coordinates[0] == 0 && coordinates[1] == 0){
        	return;
        }

        //Set coordinates
        outputSet.setGPSInDegrees(coordinates[0], coordinates[1]);
        
        //create new file for use as temp for recording gps
        tempFile = new File(file.getAbsolutePath() + "-2");		
        
        //Create a stream to write to the file
        os = new FileOutputStream(tempFile);
        os = new BufferedOutputStream(os);
        new ExifRewriter().updateExifMetadataLossless(file, os, outputSet);

        //enable exceptions
        canThrow = true;
        
        //close the stream
        IoUtils.closeQuietly(canThrow, os);
        
        //Rename file to get original
        String originalPath = file.getAbsolutePath();
        file.delete();
        File tempFileRename = new File(originalPath);	
        tempFile.renameTo(tempFileRename);

	}

	/*
	* getTime()
	*
	* parameters: 
	* 	final JpegImageMetadata jpegMetadata - jpeg metadata
	* returns: 
	* 	String - time/data info
	* 
	* get the time in pic
	*/
    private String[] getTime(final JpegImageMetadata jpegMetadata){
    	
    	//Get that field of metadata
        final TiffField field = jpegMetadata.findEXIFValueWithExactMatch(TiffTagConstants.TIFF_TAG_DATE_TIME);
        
        //Return data if available; otherwise return null
        if (field == null){
        	return null;
        }
        
        //Get timestamp and break into pieces
        String timestamp = field.getValueDescription();
        String[] timestampTokens = timestamp.split("[ :']+");
        
        //Generate date and time
        int time = Integer.parseInt(timestampTokens[4])*60 + Integer.parseInt(timestampTokens[5]);
        String date = Integer.parseInt(timestampTokens[2]) + "-" + Integer.parseInt(timestampTokens[3]) + "-" + Integer.parseInt(timestampTokens[1]);

        //Date Time info array
        String dateTime[] = {Integer.toString(time), date};
        
        //Return data
        return dateTime;
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
    	double[] coordinates = new double[2];	//hold coordinates
    	 
    	//Pull out necessary data
    	String time = dateTime[0];
    	String date = dateTime[1];
    	String userName = userNamePanel.getUserName();
    	String deviceName = deviceNamePanel.getDeviceName();
    	String deltaTime = timerIntervalPanel.getTimeInterval();
    	
    	//Generate URL
    	String baseURL = "http://deepdattaroy.com/other/projects/GPS%20Logger/getGPS.php";
    	String urlParameters = "userName=" + userName + "&deviceName=" + deviceName + "&date=" + date + "&time=" + time + "&deltaTime=" + deltaTime;
    	
    	//Talk to server
    	String response = "";
		try {
	    	//Create connection to server
			URL request = new URL(baseURL);
	    	HttpURLConnection connection = (HttpURLConnection) request.openConnection();

			//add request header
	    	connection.setRequestMethod("POST");
	    	connection.setRequestProperty("User-Agent", "Mozilla/5.0");
	    	connection.setRequestProperty("Accept-Language", "en-US,en;q=0.5");
	 
			// Send post request
	    	connection.setDoOutput(true);
			DataOutputStream wr = new DataOutputStream(connection.getOutputStream());
			wr.writeBytes(urlParameters);
			wr.flush();
			wr.close();

			//Read Reponse
	    	BufferedReader responseReader = new BufferedReader(new InputStreamReader(connection.getInputStream()));
	    	response = responseReader.readLine();
	    	responseReader.close();
		} catch (IOException e) {
			return null;
		}  	
    	
		//Get pieces of reponse
        String[] coordinatesTokens = response.split("[ ]+");
      
        //No data found
    	if (coordinatesTokens.length==0){
    		coordinates[0] = 0;
    		coordinates[1] = 0;
    		return coordinates;
    	}
    	
    	//Get the coordinates
    	coordinates[0] = Double.parseDouble(coordinatesTokens[0]);
    	coordinates[1] = Double.parseDouble(coordinatesTokens[1]);
    	
    	return coordinates;
    }
 
    
    
}