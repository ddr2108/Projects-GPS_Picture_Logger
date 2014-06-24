import javax.swing.*;

import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;


//Start button panel - starts all other panel
public class PhotoTaggerGUI extends JPanel {
	
	//Overall GUI
	JFrame guiFrame;
	
	//All the panels used
	Directory directoryPanel;
	UserName userNamePanel;
	DeviceName deviceNamePanel;
	DeltaTime deltaTimePanel;
	TimeDifference timeDifferencePanel;
	Start startPanel;
	
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
		
		//Set up rest of gui
		setUpFrame();
		
		//Set up start panel
		startPanel.setParamters(guiFrame, directoryPanel, userNamePanel, deviceNamePanel, deltaTimePanel, timeDifferencePanel);
		
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

		//Get all the panels
		directoryPanel = new Directory();
		userNamePanel = new UserName();
		deviceNamePanel = new DeviceName();
		deltaTimePanel = new DeltaTime();
		timeDifferencePanel = new TimeDifference();
		startPanel = new Start();
		
		//Set up frame
		guiFrame = new JFrame();
		guiFrame.setTitle("Photo Tagger");
		guiFrame.setSize(800, 160);
		guiFrame.setLocationRelativeTo(null);
		guiFrame.setLayout(new FlowLayout());
		
		//Set layout
		this.setLayout(new GridBagLayout());

		//Set up layout
		GridBagConstraints c = new GridBagConstraints();
		c.fill = GridBagConstraints.HORIZONTAL;
		

		//Add to panel
		c.gridx = 0;
		c.gridy = 0;
		c.gridwidth = 5;
		c.anchor = GridBagConstraints.EAST;
		this.add(directoryPanel, c);
		c.gridy++;
		this.add(Box.createRigidArea(new Dimension(0,10)), c);
		c.gridx = 0;
		c.gridy++;
		c.gridwidth = 2;
		this.add(userNamePanel, c);		
		c.gridx+=2;
		c.gridwidth = 1;
		this.add(Box.createRigidArea(new Dimension(30,0)), c);
		c.gridx = 3;
		c.gridwidth = 2;
		this.add(deviceNamePanel, c);
		c.gridy++;
		this.add(Box.createRigidArea(new Dimension(0,10)), c);
		c.gridx = 0;
		c.gridy++;
		this.add(deltaTimePanel, c);	
		c.gridx+=3;
		this.add(timeDifferencePanel, c);
		c.gridy++;
		this.add(Box.createRigidArea(new Dimension(0,10)), c);
		c.gridx = 0;
		c.gridy++;
		c.gridwidth = 5;
		this.add(startPanel, c);		

		//Set up frame
		guiFrame.add(this);
		
		//make sure the JFrame is visible
        guiFrame.setVisible(true);
	}
	    

}


