`include "async_fifo_test.sv"
`include "Interface.sv"

module async_fifo_top;
  
	bit rclk,wclk,rrst_n,wrst_n;
	  
	always #5 wclk = ~wclk;
	always #5 rclk = ~rclk;
	  
	initial 
		begin
			wclk =0;
			rclk=0;
			wrst_n =0;
			rrst_n=0;
			#10
			rrst_n =1;
			wrst_n=1;
		end
  

intf in (wclk,rclk,wrst_n,rrst_n);
test t1 (in);

asynchronous_fifo DUT (.wclk(in.wclk),
			.wrst_n(in.wrst_n),
			.rclk(in.rclk),
			.rrst_n(in.rrst_n),
			.write_enable(in.write_enable),
            .read_enable(in.read_enable),
			.data_read(in.data_read),
			.data_write(in.data_write),
            .wfull(in.wfull),
            .rempty(in.rempty),
			.half_full(in.half_full),
			.half_rempty(in.half_rempty));
  
  
endmodule




