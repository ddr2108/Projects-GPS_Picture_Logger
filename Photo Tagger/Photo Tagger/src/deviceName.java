import javax.swing.*;

//Device Name Panel for GUI
@SuppressWarnings("serial")
public class deviceName extends JPanel{

	//Parts of the panel
	JLabel deviceNameLabel;
	JTextField deviceNameTextField;
	
	private String name;	//holds name
	
	/*
	* deviceName()
	* 
	* parameters: 
	* 	none
	* returns: 
	* 	none
	*
	*constructor - sets up gui for this panel
	*/
	public deviceName(){
		//Label stating this is name text field
		deviceNameLabel = new JLabel("Device Name:");
		//Text Field
		deviceNameTextField = new JTextField(25);
					
				
		//Add to panel
		this.add(deviceNameLabel);
		this.add(deviceNameTextField);
	}
	
	/*
	* getDeviceName()
	*
	* parameters: 
	* 	none
	* returns: 
	* 	String - name of device
	* 
	* returns the device name
	*/
	public String getDeviceName(){
		//return the name
		return name;
	}

}
