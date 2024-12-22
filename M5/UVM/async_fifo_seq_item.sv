import uvm_pkg::*;
`include "uvm_macros.svh"

class transaction_write extends uvm_sequence_item;
	`uvm_object_utils(transaction_write)
	

	rand bit [8:0] data_write;
	rand bit write_enable;
	bit wfull,wHalf_full;

	function new(string name = "transaction_write");
		super.new(name);
	endfunction
endclass

class transaction_read extends uvm_sequence_item;
	`uvm_object_utils(transaction_read)

	rand bit read_enable;
	logic [8:0] data_read;
	bit rempty,wHalf_empty;

	function new(string name = "transaction_read");
		super.new(name);
	endfunction
endclass
