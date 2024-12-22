`include "Transaction.sv"
`include "Generator.sv"
`include "Driver.sv"
`include "Monitor.sv"
`include "Scoreboard.sv"


class environment;
    

	generator gen;
	driver driv;
	monitor mon;
	scoreboard scb;
	  

	mailbox gen2driv;
	mailbox mon2scb;
  
	event driv2gen;
	  
	virtual intf vif;

	int tran_num;

	function new(virtual intf vif);

			this.vif = vif;
			gen2driv = new();
			mon2scb	 = new();
			gen		 = new(gen2driv, driv2gen);
			driv 	 = new (vif,gen2driv);
			mon 	 = new (vif, mon2scb);
			scb	 = new (mon2scb);
	endfunction
	  
 
	task pre_env();
		driv.reset();
	endtask
    

	task test();

		
		$display("------Bursts requested %0d-------",gen.tx_count);
			
		$display("------------------------------------------");
		
		gen.main();
		driv.main();
		mon.main();
		scb.main();

	endtask

  
	task post_env();
		$display("IN POST TEST");
			wait(driv2gen.triggered);
				$display("1 DONE");
			wait(gen.tx_count == driv.no_trans);
				$display("2 DONE");
			wait (gen.tx_count == scb.tran_num);
				$display("3 DONE");
	endtask
		

	task run();
		pre_env();
			for (int i = 0; i < tran_num; i++) 
				test();
			
		$finish;

	endtask
 
 
endclass
