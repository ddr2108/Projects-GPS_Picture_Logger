import javax.swing.*;

// Name Panel for GUI
@SuppressWarnings("serial")
public class timeInterval extends JPanel{

	//Parts of the panel
	JLabel timeIntervalLabel;
	JTextField timeIntervalTextField;
	
	private int name; 	//holds name
	
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
	public timeInterval(){
		//Label stating this is name text field
		timeIntervalLabel = new JLabel("Time Interval:");
		//Text Field
		timeIntervalTextField = new JTextField(5);
		
		//Add to panel
		this.add(timeIntervalLabel);
		this.add(timeIntervalTextField);
	}
	
	/*
	* getTime()
	*
	* parameters: 
	* 	none
	* returns: 
	* 	int - time interval to use
	* 
	* returns the time interval
	*/
	public int getTimeInterval(){
		//return the name
		return name;
	}
	
}
