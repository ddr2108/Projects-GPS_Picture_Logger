import javax.swing.*;
import java.awt.*;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;

import org.apache.commons.imaging.ImageReadException;
import org.apache.commons.imaging.ImageWriteException;
import org.apache.commons.imaging.Imaging;
import org.apache.commons.imaging.common.IImageMetadata;
import org.apache.commons.imaging.common.RationalNumber;
import org.apache.commons.imaging.formats.jpeg.JpegImageMetadata;
import org.apache.commons.imaging.formats.jpeg.exif.ExifRewriter;
import org.apache.commons.imaging.formats.tiff.TiffImageMetadata;
import org.apache.commons.imaging.formats.tiff.constants.ExifTagConstants;
import org.apache.commons.imaging.formats.tiff.write.TiffOutputDirectory;
import org.apache.commons.imaging.formats.tiff.write.TiffOutputSet;
import org.apache.commons.imaging.util.IoUtils;

public class PhotoTaggerGUI {
	
	public static void main(String[] args) {    
        new PhotoTaggerGUI();
    }

	public PhotoTaggerGUI() {
        
		//Set up frame
		final JFrame guiFrame = new JFrame();
		guiFrame.setTitle("Photo Tagger");
		guiFrame.setSize(800, 800);
		guiFrame.setLocationRelativeTo(null);
		guiFrame.setLayout(new FlowLayout());
		
		//Set up disk location
		JPanel diskPanel = new JPanel();
		JLabel diskLabel = new JLabel("Disk Location:");
		JButton dirButton = new JButton("Directory");
		final JLabel dirLabel = new JLabel(new java.io.File(".").getAbsolutePath());
		//Set up action listeners
		dirButton.addActionListener(new ActionListener(){
            @Override
            public void actionPerformed(ActionEvent event){
            	//Create a file Chooser
            	JFileChooser dirChooser = new JFileChooser();
            	dirChooser.setCurrentDirectory(new java.io.File(dirLabel.getText()));
            	dirChooser.setDialogTitle("Choose Directory");
            	dirChooser.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
            	dirChooser.setAcceptAllFileFilterUsed(false);
            	dirChooser.showOpenDialog(guiFrame);
            	//Get the direcotry and save it
            	dirLabel.setText(dirChooser.getSelectedFile().getAbsolutePath());
            	
            }
        });
		//Add to panel
		diskPanel.add(diskLabel);
		diskPanel.add(dirButton);
		diskPanel.add(dirLabel);
		
		//Set up  name
		JPanel namePanel = new JPanel();
		JLabel nameLabel = new JLabel("Name:");
		//Add to panel
		namePanel.add(nameLabel);

		//Set up device name
		JPanel deviceNamePanel = new JPanel();
		JLabel deviceNameLabel = new JLabel("Device Name:");
		//Add to panel
		deviceNamePanel.add(deviceNameLabel);

		//Set up time interval
		JPanel timePanel = new JPanel();
		JLabel timeLabel = new JLabel("Time Interval:");
		//Add to panel
		timePanel.add(timeLabel);

		//Set up start button
		JPanel startPanel = new JPanel();
		JButton startButton = new JButton("Start");
		//Set up action listener
		startButton.addActionListener(new ActionListener(){
            @Override
            public void actionPerformed(ActionEvent event){
            	File[] files = new File(dirLabel.getText()).listFiles();
            	showFiles(files);
            }
        });
		//Add to panel
		startPanel.add(startButton);

		//Set up frame
		guiFrame.add(diskPanel);
		guiFrame.add(namePanel);
		guiFrame.add(deviceNamePanel);
		guiFrame.add(timePanel);
		guiFrame.add(startPanel);
		
		//make sure the JFrame is visible
        guiFrame.setVisible(true);
	
	}
	
	public static void showFiles(File[] files) {
	    for (File file : files) {
	        if (file.isDirectory()) {
	            showFiles(file.listFiles()); // Calls same method again.
	        } else {
            	if (file.getName().contains("JPG")){
		            try {
		            	String originalPath = file.getAbsolutePath() ;
		            	File dst = new File(file.getAbsolutePath() + "copy");
			            	setExifGPSTag(file, dst);
			            	file.delete();
			            	File dstRename = new File(originalPath);

			            	dst.renameTo(dstRename);
			        } catch (ImageReadException | ImageWriteException | IOException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
            	}
	        }
	    }
	}
	
    public static void setExifGPSTag(final File jpegImageFile, final File dst) throws IOException, ImageReadException, ImageWriteException {
    	OutputStream os = null;
        boolean canThrow = false;
        try {
            TiffOutputSet outputSet = null;

            // note that metadata might be null if no metadata is found.
            final IImageMetadata metadata = Imaging.getMetadata(jpegImageFile);
            final JpegImageMetadata jpegMetadata = (JpegImageMetadata) metadata;
            if (null != jpegMetadata) {
                // note that exif might be null if no Exif metadata is found.
                final TiffImageMetadata exif = jpegMetadata.getExif();

                if (null != exif) {
                    // TiffImageMetadata class is immutable (read-only).
                    // TiffOutputSet class represents the Exif data to write.
                    //
                    // Usually, we want to update existing Exif metadata by
                    // changing
                    // the values of a few fields, or adding a field.
                    // In these cases, it is easiest to use getOutputSet() to
                    // start with a "copy" of the fields read from the image.
                    outputSet = exif.getOutputSet();
                }
            }

            // if file does not contain any exif metadata, we create an empty
            // set of exif metadata. Otherwise, we keep all of the other
            // existing tags.
            if (null == outputSet) {
                outputSet = new TiffOutputSet();
            }

            {
                // Example of how to add/update GPS info to output set.

                // New York City
                final double longitude = -74.0; // 74 degrees W (in Degrees East)
                final double latitude = 40 + 43 / 60.0; // 40 degrees N (in Degrees
                // North)

                outputSet.setGPSInDegrees(longitude, latitude);
            }

            os = new FileOutputStream(dst);
            os = new BufferedOutputStream(os);

            new ExifRewriter().updateExifMetadataLossless(jpegImageFile, os,
                    outputSet);
            canThrow = true;
        } finally {
            IoUtils.closeQuietly(canThrow, os);
        }
    	
	}

}
