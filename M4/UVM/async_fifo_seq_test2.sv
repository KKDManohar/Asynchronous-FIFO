 import uvm_pkg::*;
`include "uvm_macros.svh"
 import fifo_pkg::*;

class write_sequence_full extends uvm_sequence#(transaction_write);
	`uvm_object_utils(write_sequence_full)

	int tx_count_write=256;
	transaction_write txw;
		
	function new(string name = "write_sequence_full");
	    super.new(name);
		`uvm_info("WRITE_SEQUENCE_CLASS", "Inside constructor",UVM_LOW)
	endfunction

	task body();
		`uvm_info("WRITE_SEQUENCE_CLASS", "Inside body task",UVM_LOW)
		for (int i = 0; i < tx_count_write; i++) 
		begin
			txw = transaction_write::type_id::create("txw");
			start_item(txw);
			if (!(txw.randomize() with {txw.write_enable == 1;}));
				finish_item(txw);
		end

	endtask
endclass


class read_sequence_full extends uvm_sequence#(transaction_read);
	`uvm_object_utils(read_sequence_full)

	int tx_count_read=256;
	transaction_read txr;
		
	function new(string name = "read_sequence_full");
		super.new(name);
		`uvm_info("READ_SEQUENCE_CLASS", "Inside constructor",UVM_LOW)
	endfunction

	task body();
		`uvm_info("READ_SEQUENCE_CLASS", "Inside body task",UVM_LOW)
		for (int i = 0; i < tx_count_read; i++) 
		begin
		txr = transaction_read::type_id::create("txr");
		start_item(txr);
		if(!(txr.randomize() with {txr.read_enable == 0;}));	
			finish_item(txr);
		end
		
	endtask
endclass
