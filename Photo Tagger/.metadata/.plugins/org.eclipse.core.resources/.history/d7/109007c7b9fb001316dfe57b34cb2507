import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;

import javax.swing.*;

// Name Panel for GUI
@SuppressWarnings("serial")
public class TimeDifference extends JPanel{

	//Parts of the panel
	JLabel timeDifferenceLabel;
	JTextField timeDifferenceTextField;
		
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
	public TimeDifference(){
		//Create layout
		this.setLayout(new GridBagLayout());
		GridBagConstraints c = new GridBagConstraints();
		c.fill = GridBagConstraints.HORIZONTAL;

		//Label stating this is name text field
		timeDifferenceLabel = new JLabel("Time Difference:");
		//Text Field
		timeDifferenceTextField = new JTextField(5);
		
		//Add to panel
		this.add(timeDifferenceLabel);
		this.add(timeDifferenceTextField);
	}
	
	/*
	* getTimeDifference()
	*
	* parameters: 
	* 	none
	* returns: 
	* 	String - time difference to use
	* 
	* returns the time difference
	*/
	public String getTimeDifference(){
		//return the name
		return timeDifferenceTextField.getText();
	}
	
}
