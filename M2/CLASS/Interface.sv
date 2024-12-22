interface intf(input logic wclk,rclk,wrst_n,rrst_n);

	logic [7:0] data_write;
	logic write_enable;
	logic read_enable;
	logic [7:0] data_read;
	logic rempty;
	logic wfull;
	logic half_rempty;
	logic half_full;


	clocking driver_cb @(posedge wclk);
		output data_write;                
		output write_enable, read_enable;
		input wfull, rempty,half_rempty,half_full;               
	endclocking

	clocking monitor_cb @(posedge rclk);        
		input write_enable, read_enable;
		input data_read; 
		input wfull, rempty,half_rempty,half_full;               
	endclocking
		  
	modport DRIVER(clocking driver_cb, input wclk,wrst_n);
	modport MONITOR(clocking monitor_cb, input rclk,rrst_n);
    
endinterface: intf
