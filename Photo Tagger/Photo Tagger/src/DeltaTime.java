import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;

import javax.swing.*;

// Delta Time Panel for GUI
@SuppressWarnings("serial")
public class DeltaTime extends JPanel{

	//Parts of the panel
	JLabel deltaTimeLabel;
	JTextField deltaTimeTextField;
	JLabel deltaTimeUnitLabel;
		
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
	public DeltaTime(){
		
		//Label stating this is name text field
		deltaTimeLabel = new JLabel("Delta Time:");
		//Text Field
		deltaTimeTextField = new JTextField(5);
		//Label stating min
		deltaTimeUnitLabel = new JLabel("min");

		//Add to panel
		this.add(deltaTimeLabel);
		this.add(deltaTimeTextField);
		this.add(deltaTimeUnitLabel);

		
	}
	
	/*
	* getDeltaTime()
	*
	* parameters: 
	* 	none
	* returns: 
	* 	String - delta time to use
	* 
	* returns the delta time 
	*/
	public String getDeltaTime(){
		
		//return the delta time
		return deltaTimeTextField.getText();
		
	}
	
}
