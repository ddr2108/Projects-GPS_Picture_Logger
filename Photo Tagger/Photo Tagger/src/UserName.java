import java.awt.Dimension;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;

import javax.swing.*;

// User Name Panel for GUI
@SuppressWarnings("serial")
public class UserName extends JPanel{

	//Parts of the panel
	private JLabel userNameLabel;
	private JTextField userNameTextField;
	
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
	public UserName(){
		
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
	private void setUpPanel(){

		//Label stating this is name text field
		userNameLabel = new JLabel("User Name:");
		//Text Field
		userNameTextField = new JTextField(25);
			
		//Set layout
		this.setLayout(new GridBagLayout());

		//Set up layout
		GridBagConstraints c = new GridBagConstraints();
		c.fill = GridBagConstraints.HORIZONTAL;

		//Add to panel
		c.gridx = 0;
		c.gridy = 0;
		c.gridwidth = 1;
		this.add(userNameLabel, c);
		c.gridx++;
		this.add(Box.createRigidArea(new Dimension(5,0)), c);
		c.gridx++;
		this.add(userNameTextField, c);	
		
	}
	
	/*
	* getUserName()
	*
	* parameters: 
	* 	none
	* returns: 
	* 	String - name of user
	* 
	* returns the user name
	*/
	public String getUserName(){
		
		//return the user name
		return userNameTextField.getText();
		
	}
	
}
