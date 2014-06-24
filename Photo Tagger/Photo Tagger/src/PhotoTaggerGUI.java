import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;


//Start button panel - starts all other panel
public class PhotoTaggerGUI extends JPanel implements ActionListener{
	
	//Overall GUI
	JFrame guiFrame;
	
	//All the panels used
	Directory directoryPanel;
	UserName userNamePanel;
	DeviceName deviceNamePanel;
	DeltaTime deltaTimePanel;
	TimeDifference timeDifferencePanel;
	
	//Parts of the PhtoTaggerGUI Panel
	JButton startButton;
	JLabel progressLabel;
	JLabel curProgressLabel;
	
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
		
		//Set up GUI
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
		
		//Start button
		startButton = new JButton("Start");
		//Progress Label
		JLabel progressLabel = new JLabel("Progress:");
		//Current Progress Label
		curProgressLabel = new JLabel("");

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
		guiFrame = new JFrame();
		guiFrame.setTitle("Photo Tagger");
		guiFrame.setSize(1200, 200);
		guiFrame.setLocationRelativeTo(null);
		guiFrame.setLayout(new FlowLayout());
		
		//Get all the panels
		directoryPanel = new Directory();
		userNamePanel = new UserName();
		deviceNamePanel = new DeviceName();
		deltaTimePanel = new DeltaTime();
		timeDifferencePanel = new TimeDifference();

		//Set up frame
		guiFrame.add(directoryPanel);
		guiFrame.add(userNamePanel);
		guiFrame.add(deviceNamePanel);
		guiFrame.add(deltaTimePanel);
		guiFrame.add(timeDifferencePanel);
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
	* run the program when start button pressed
	*/
	@Override
	public void actionPerformed(ActionEvent e) {

		//Start Processing
		startProcessing();
		
	}
    
	/*
	* startProcessing()
	*
	* parameters: 
	* 	none
	* returns: 
	* 	none
	* 
	* Start the things necessary for processing
	*/
	public void startProcessing() {

		//Get the parameters
		String userName = userNamePanel.getUserName();
		String deviceName = deviceNamePanel.getDeviceName();
		String deltaTime = deltaTimePanel.getDeltaTime();
		String timeDifference = timeDifferencePanel.getTimeDifference();
		String directory = directoryPanel.getDirectory();

		//Check for correctness
		if (userName.length()==0){
			JOptionPane.showMessageDialog(guiFrame, "Need a User Name");
			curProgressLabel.setText("Parameter Error");
			return;
		}
		if (deviceName.length()==0){
			JOptionPane.showMessageDialog(guiFrame, "Need a Device Name");
			curProgressLabel.setText("Parameter Error");
			return;
		}
		if (isInteger(deltaTime)==false || Integer.parseInt(deltaTime)<0 || Integer.parseInt(deltaTime)>1440){
			JOptionPane.showMessageDialog(guiFrame, "Delta Time needs to be an integer between 0 and 1440");
			curProgressLabel.setText("Parameter Error");
			return;
		}
		if (isInteger(timeDifference)==false){
			JOptionPane.showMessageDialog(guiFrame, "Time Difference needs to be an integer");
			curProgressLabel.setText("Parameter Error");
			return;
		}
		if (directory.length()==0){
			JOptionPane.showMessageDialog(guiFrame, "Need a Directory");
			curProgressLabel.setText("Parameter Error");
			return;
		}

		//Set the parameters
		PhotoTagger photoTagger = new PhotoTagger();
		photoTagger.setParameters(userName, deviceName, deltaTime, timeDifference);
		photoTagger.setProgressLabel(curProgressLabel);
		
		//Start the processing
		photoTagger.startProcessing(directory);		
		
	}
	
	/*
	* isInteger()
	*
	* parameters: 
	* 	String s - string to check
	* returns: 
	* 	boolean - true if it is
	* 
	* Check if string is an integer
	*/
	public static boolean isInteger(String s) {
		
	    //Try to parse the string
		try { 
	        Integer.parseInt(s); 
	    } catch(NumberFormatException e) { 
	        return false; 
	    }

	    return true;
	    
	}
}


