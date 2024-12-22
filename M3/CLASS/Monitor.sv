class monitor;

	virtual intf moniter_if;
	mailbox mon2scb;
	 
	function new(virtual intf moniter_if,mailbox mon2scb);
		this.moniter_if = moniter_if;
		this.mon2scb = mon2scb;
	endfunction
	 
	virtual task drive();
	begin
		transaction tx2;
		tx2 = new(); 	  
		@(posedge moniter_if.rclk);   
		tx2.read_enable = moniter_if.read_enable;
		tx2.write_enable = moniter_if.write_enable;
		tx2.data_write = moniter_if.data_write;  
		tx2.wfull = moniter_if.wfull;
		tx2.rempty = moniter_if.rempty;
		tx2.data_read = moniter_if.data_read; 
		mon2scb.put(tx2);
	end
	endtask
		
		
	task  main();
	begin
		for (int i = 0; i < 1; i++) 
			drive(); 
	end
	endtask

endclass
  
