class generator;

	rand transaction tx;
	int tx_count;
	event driv2gen;
	  
	mailbox gen2driv;

	function new(mailbox gen2driv, event driv2gen); 
		this.gen2driv = gen2driv;
		this.driv2gen = driv2gen;
	endfunction

	task main();
		
		repeat (tx_count) 
		begin         
			tx = new(); 
			if(!tx.randomize()) 
			$fatal ("Randomization for the transaction is failed:");
			gen2driv.put(tx);
		end
			->driv2gen;
	endtask

endclass
