class driver;
	 
	generator gen;
	virtual intf driver_if;
	mailbox gen2driv;
	
	int no_trans;


	//this function allows for communcation with mailbox and creates an interface
	function new(virtual intf driver_if, mailbox gen2driv);
		this.driver_if = driver_if;
		this.gen2driv = gen2driv;
	endfunction

	//reset when write or read reset
	task reset;
		$display("Reset Started");
		wait(driver_if.wrst_n || driver_if.rrst_n);
		driver_if.data_write <= 0;
		driver_if.write_enable <= 0;
		driver_if.read_enable <= 0;
		wait(!driver_if.wrst_n || driver_if.rrst_n);
		$display("Reset Ended:");
	endtask
	  

	virtual task drive();
	begin 
		transaction tx1;
		driver_if.write_enable <= 0;
		driver_if.read_enable <= 0;
		gen2driv.get(tx1);
 
		@(posedge driver_if.wclk);
		if(tx1.write_enable) 
		begin
			driver_if.write_enable <= tx1.write_enable;
			driver_if.data_write <= tx1.data_write;;
			tx1.wfull = driver_if.wfull;
			tx1.rempty = driver_if.rempty;
			$display ("\t write_enable = %0h \t data_write = %0h", tx1.write_enable, tx1.data_write);
		end 
		else 
		begin
			$display ("\t write_enable = %0h \t data_write = %0h", tx1.write_enable, tx1.data_write);
		end
	 
			
		if(tx1.read_enable)
		begin
			driver_if.read_enable <= tx1.read_enable;
			@(posedge driver_if.rclk);
			driver_if.read_enable <=tx1.read_enable;
			@(posedge driver_if.rclk);
			tx1.data_read = driver_if.data_read;
			tx1.wfull = driver_if.wfull;
			tx1.rempty = driver_if.rempty;
			$display ("\t read_enable = %0h", tx1.read_enable);
		end 
		else 
		begin
			$display ("\t read_enable = %0h", tx1.read_enable);
		end
			
	end
	endtask   

	task  main();
	begin
		for (int i = 0; i < 1; i++) 
			drive();
	end
	endtask
         
endclass
