`include "Environment.sv"

program test(intf in);
  environment env;
 
	initial 
		begin
	  
			$display("test environment started");
			env = new(in);
			env.gen.tx_count =10;
			env.tran_num=100;
			env.run();
			$display("TEST FINISHED SUCCESSFULLY");
			$finish;
	    end
		
endprogram

