package fifo_pkg;

	`include "async_fifo_seq_item.sv"
	

//base test
`include "async_fifo_seq_test1.sv"
//full test
//`include "async_fifo_seq_test2.sv"
//random test
//`include "async_fifo_seq_test3.sv"

	`include "async_fifo_sequencer.sv"
	`include "async_fifo_driver.sv"
	`include "async_fifo_write_monitor.sv"
	`include "async_fifo_read_monitor.sv"
	`include "async_fifo_write_agent.sv"
	`include "async_fifo_read_agent.sv"
	`include "async_fifo_scoreboard.sv"

		
endpackage
