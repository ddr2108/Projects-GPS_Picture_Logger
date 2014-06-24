import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.*;

// Name Panel for GUI
@SuppressWarnings("serial")
public class Directory extends JPanel implements ActionListener{

	//Parts of the panel
	JLabel dirLabel;
	JLabel chosenDirLabel;
	JButton dirButton;
	
	private String name;	//holds directory 
	
	/*
	* name()
	* 
	* parameters: 
	* 	none
	* returns: 
	* 	none
	*
	*constructor - sets up gui for this panel
	*/
	public Directory(){
		//Create layout
		this.setLayout(new GridBagLayout());
		GridBagConstraints c = new GridBagConstraints();
		c.fill = GridBagConstraints.HORIZONTAL;

		//Initialize name
		name = new java.io.File(".").getAbsolutePath();
		
		//Label asking for dir location
		dirLabel = new JLabel("Directory Location:");
		chosenDirLabel = new JLabel(name);
		dirButton = new JButton("Directory");
		
		//Set up parts
		chosenDirLabel.setSize(500, 20);
		
		//Set up action listeners
		dirButton.addActionListener(this);
		
		//Add to panel
		c.gridx = 1;
		c.gridy = 0;
		this.add(dirLabel, c);
		c.gridx = 2;
		c.gridy = 0;
		c.gridwidth = 2;
		this.add(chosenDirLabel, c);
		c.gridx = 0;
		c.gridy = 0;
		c.gridwidth = 1;
		this.add(dirButton, c);
	}
	
	/*
	* getName()
	*
	* parameters: 
	* 	none
	* returns: 
	* 	String - name of directory
	* 
	* returns the name
	*/
	public String getName(){
		//return the name
		return name;
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
    	dirChooser.setCurrentDirectory(new java.io.File(name));
    	dirChooser.setDialogTitle("Choose Directory");
    	dirChooser.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
    	dirChooser.setAcceptAllFileFilterUsed(false);
    	
    	//Show the dialog box
    	dirChooser.showOpenDialog(this);
    	
    	//Get the directory and save it
    	name = dirChooser.getSelectedFile().getAbsolutePath();
    	chosenDirLabel.setText(name);
	}
	
}