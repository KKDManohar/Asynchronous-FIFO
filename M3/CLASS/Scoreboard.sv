class scoreboard;

	parameter DEPTH = 512;
	longint tran_num;
	logic [7:0] fifo_mem [DEPTH-1 : 0];
	bit [7:0] wr_ptr;
	bit [7:0] rd_ptr;
	mailbox mon2scb;
	  
	function new(mailbox mon2scb);
		this.mon2scb = mon2scb;
		
		foreach(fifo_mem[i])
			fifo_mem[i] = 12'h0;
		
	endfunction 
	 
	virtual task main();
	begin   
		transaction tx3;
		mon2scb.get(tx3);
		 
			if(tx3.write_enable)
				begin
					fifo_mem[wr_ptr] = tx3.data_write;
					wr_ptr = wr_ptr + 1;
				end
			

		    if(tx3.read_enable)
				begin
					if(tx3.data_read == fifo_mem[rd_ptr])
						begin
							$display("design works correctly at address %0h - tx3.Data = %0h - Saved Data = %0h",rd_ptr, tx3.data_read,fifo_mem[rd_ptr]);
							rd_ptr = rd_ptr + 1;
						end 
					else 
						begin
							$display("design has error at address %0h - tx3.Data = %0h - Saved Data = %0h",rd_ptr,tx3.data_read,fifo_mem[rd_ptr]);
						end
				end

		 
		   if(tx3.wfull)
				$display("FIFO is full");
				
		  if(tx3.rempty)
				$display("FIFO is empty");
			
			
		  tran_num++;

	end
	endtask


endclass
