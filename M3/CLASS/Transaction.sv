class transaction;
  	
	bit wrst_n, rrst_n, wclk, rclk;
	rand bit [7:0] data_write;
	rand bit write_enable;
	rand bit read_enable;
	logic [7:0] data_read;
	bit rempty;
	bit wfull;
	

endclass
