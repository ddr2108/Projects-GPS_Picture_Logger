import java.awt.Dimension;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.*;

// Directory Panel for GUI
@SuppressWarnings("serial")
public class Directory extends JPanel implements ActionListener{

	//Parts of the panel
	JLabel dirLabel;
	JTextField chosenDirLabel;
	JButton dirButton;
		
	/*
	* name()
	* 
	* parameters: 
	* 	none
	* returns: 
	* 	none
	*
	* constructor - sets up gui for this panel
	*/
	public Directory(){

		//Set up the panel
		setUpPanel();

	}
	
	/*
	* setUpPanel()
	* 
	* parameters: 
	* 	none
	* returns: 
	* 	none
	*
	* sets up the outer panel
	*/
	public void setUpPanel(){
		
		//Label asking for dir location
		dirLabel = new JLabel("Directory Location:");
		//Label for chosen directory
		chosenDirLabel = new JTextField(40);
		chosenDirLabel.setText(new java.io.File(".").getAbsolutePath());
		//Choose directory button
		dirButton = new JButton("Directory");
				
		//Set up action listeners for when direcoty button pressed
		dirButton.addActionListener(this);
	
		//Set layout
		this.setLayout(new GridBagLayout());

		//Set up layout
		GridBagConstraints c = new GridBagConstraints();
		c.fill = GridBagConstraints.HORIZONTAL;

		//Add to panel
		c.gridx = 0;
		c.gridy = 1;
		c.gridwidth = 1;
		this.add(dirButton, c);
		c.gridx++;
		this.add(Box.createRigidArea(new Dimension(10,0)), c);
		c.gridx++;
		this.add(dirLabel, c);
		c.gridx++;
		this.add(Box.createRigidArea(new Dimension(5,0)), c);
		c.gridx++;
		this.add(chosenDirLabel, c);
		
	}

	
	/*
	* getDirectory()
	*
	* parameters: 
	* 	none
	* returns: 
	* 	String - name of directory
	* 
	* returns the directory
	*/
	public String getDirectory(){
		
		//return the directory
		return chosenDirLabel.getText();
		
	}

	
	/*
	* actionPerformed()
	*
	* parameters: 
	* 	ActionEvent arg0 - default args
	* returns: 
	* 	none
	* 
	* creates and saves the chosen directory info
	*/
	@Override
	public void actionPerformed(ActionEvent arg0) {
    	
		//Create a file chooser
    	JFileChooser dirChooser = new JFileChooser();
    	
    	//Set up file chooser
    	dirChooser.setCurrentDirectory(new java.io.File(getDirectory()));
    	dirChooser.setDialogTitle("Choose Directory");
    	dirChooser.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
    	dirChooser.setAcceptAllFileFilterUsed(false);
    	
    	//Show the dialog box
    	dirChooser.showOpenDialog(this);
    	
    	//Get the directory and save it
    	chosenDirLabel.setText(dirChooser.getSelectedFile().getAbsolutePath());
    	
	}
	
}
