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
	*constructor - sets up gui for this panel
	*/
	public UserName(){
		//Label stating this is name text field
		userNameLabel = new JLabel("User Name:");
		//Text Field
		userNameTextField = new JTextField(25);
			
		
		//Add to panel
		this.add(userNameLabel);
		this.add(userNameTextField);
	}
	
	/*
	* getUserName()
	*
	* parameters: 
	* 	none
	* returns: 
	* 	String - name of user
	* 
	* returns the name
	*/
	public String getUserName(){
		//return the name
		return userNameTextField.getText();
	}
	
}
