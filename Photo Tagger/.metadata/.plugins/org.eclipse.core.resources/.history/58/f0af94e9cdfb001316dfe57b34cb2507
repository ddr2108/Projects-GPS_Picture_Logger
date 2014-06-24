import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;

import javax.swing.*;

// Time Difference Panel for GUI
@SuppressWarnings("serial")
public class TimeDifference extends JPanel{

	//Parts of the panel
	JLabel timeDifferenceLabel;
	JTextField timeDifferenceTextField;
	JLabel timeDifferenceUnitLabel;
		
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
		
		//Label stating this is name text field
		timeDifferenceLabel = new JLabel("Time Difference:");
		//Text Field
		timeDifferenceTextField = new JTextField(5);
		//Label stating hour
		timeDifferenceUnitLabel = new JLabel("hours");

		
		//Add to panel
		this.add(timeDifferenceLabel);
		this.add(timeDifferenceTextField);
		this.add(timeDifferenceUnitLabel);
		
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
		
		//return the time difference
		return timeDifferenceTextField.getText();
		
	}
	
}
