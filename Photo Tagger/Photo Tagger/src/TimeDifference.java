import java.awt.Dimension;
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
	* constructor - sets up gui for this panel
	*/
	public TimeDifference(){
		
		//Label stating this is name text field
		timeDifferenceLabel = new JLabel("Time Difference:");
		//Text Field
		timeDifferenceTextField = new JTextField(5);
		//Label stating hour
		timeDifferenceUnitLabel = new JLabel("hours");

		//Set layout
		this.setLayout(new GridBagLayout());

		//Set up layout
		GridBagConstraints c = new GridBagConstraints();
		c.fill = GridBagConstraints.HORIZONTAL;

		//Add to panel
		c.gridx = 0;
		c.gridy = 0;
		c.gridwidth = 1;
		this.add(timeDifferenceLabel, c);
		c.gridx++;
		this.add(Box.createRigidArea(new Dimension(5,5)), c);
		c.gridx++;
		this.add(timeDifferenceTextField, c);
		c.gridx++;
		this.add(Box.createRigidArea(new Dimension(5,5)), c);
		c.gridx++;
		c.gridwidth = 2;
		this.add(timeDifferenceUnitLabel, c);
		
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
