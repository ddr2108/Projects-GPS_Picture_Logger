import javax.swing.*;

// User Name Panel for GUI
@SuppressWarnings("serial")
public class userName extends JPanel{

	//Parts of the panel
	private JLabel userNameLabel;
	private JTextField userNameTextField;
	
	private String name; 	//holds name

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
	public userName(){
		//Label stating this is name text field
		userNameLabel = new JLabel("User Name:");
		//Text Field
		userNameTextField = new JTextField(25);
			
		
		//Add to panel
		this.add(userNameLabel);
		this.add(userNameTextField);
	}
	
	/*
	* getName()
	*
	* parameters: 
	* 	none
	* returns: 
	* 	String - name of user
	* 
	* returns the name
	*/
	public String getName(){
		//return the name
		return name;
	}
	
}
