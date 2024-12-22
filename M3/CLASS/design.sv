module asynchronous_fifo (wclk,wrst_n,rclk,rrst_n,write_enable,read_enable,data_read,data_write,wfull,rempty,half_full,half_rempty);

	parameter DEPTH=512, DATA_WIDTH=8;
	parameter PTR_WIDTH = $clog2(DEPTH);

	input wclk, wrst_n;
	input rclk, rrst_n;
	input write_enable, read_enable;
	input logic [DATA_WIDTH-1:0] data_read;
	output logic [DATA_WIDTH-1:0] data_write;
	output reg wfull, rempty,half_full,half_rempty;

	reg [PTR_WIDTH:0] sync_rq2_wptr, sync_wq2_rptr;
	reg [PTR_WIDTH:0] wptr, rptr;
	reg [PTR_WIDTH:0] rq2_wptr, wq2_rptr;

	wire [PTR_WIDTH-1:0] waddr, raddr;

	synchronizer #(PTR_WIDTH) sync_wptr (rclk, rrst_n, rq2_wptr, sync_rq2_wptr); 
	synchronizer #(PTR_WIDTH) sync_rptr (wclk, wrst_n, wq2_rptr, sync_wq2_rptr);  

	write_ptr #(PTR_WIDTH) wptr_h(wclk, wrst_n, write_enable,sync_wq2_rptr,wptr,rq2_wptr,wfull,half_full);
	read_ptr #(PTR_WIDTH) rptr_h(rclk, rrst_n, read_enable,sync_rq2_wptr,rptr,wq2_rptr,rempty,half_rempty);
	fifo_mem fifom(wclk, write_enable, rclk, read_enable,wptr, rptr, data_read,wfull,rempty, data_write);

endmodule

module synchronizer (clk,rst_n,D_in,D_out);

	parameter WIDTH=8;
	
	input clk, rst_n;
	input [WIDTH:0] D_in;
	output reg [WIDTH:0] D_out;
	
	reg [WIDTH:0] q;
	
	always@(posedge clk) 
		begin
			if(!rst_n) 
			begin
				q <= 0;
				D_out <= 0;
			end
			else 
			begin
				q <= D_in;
				D_out <= q;
			end
		end
endmodule

module write_ptr (wclk,wrst_n,write_enable,wq2_rptr,wptr,rq2_wptr,wfull,half_full);

	parameter PTR_DEPTH=9;
	
	input wclk, wrst_n, write_enable;
	input [PTR_DEPTH:0] wq2_rptr;
	output reg [PTR_DEPTH:0] wptr, rq2_wptr;
	output reg wfull;
	output reg half_full;

	reg [PTR_DEPTH:0] inc_wptr;
	reg [PTR_DEPTH:0] g_inc_wptr;

	wire full;

	assign inc_wptr = wptr+(write_enable & !wfull);
	assign g_inc_wptr = (inc_wptr >>1)^inc_wptr;
	
	assign half_full = (wptr >= (1<<(PTR_DEPTH-1)));

	always@(posedge wclk or negedge wrst_n) 
		begin
			if(!wrst_n) 
			begin
				wptr <= 0;
				rq2_wptr <= 0;
			end
			else 
			begin
				wptr <= inc_wptr; 
				rq2_wptr <= g_inc_wptr;
			end
		end

	always@(posedge wclk or negedge wrst_n) 
		begin
			if(!wrst_n) 
				wfull <= 0;
			else        
				wfull <= full;
		end

	
	assign full = (g_inc_wptr == {~wq2_rptr[PTR_DEPTH:PTR_DEPTH-1], wq2_rptr[PTR_DEPTH-2:0]});

endmodule

module read_ptr (rclk,rrst_n,read_enable,rq2_wptr,rptr,wq2_rptr,rempty,half_wempty);

	parameter PTR_DEPTH = 9;
	
	input rclk, rrst_n, read_enable;
	input [PTR_DEPTH:0] rq2_wptr;
	output reg [PTR_DEPTH:0] rptr, wq2_rptr;
	output reg rempty,half_wempty;

	reg [PTR_DEPTH:0] inc_rptr;
	reg [PTR_DEPTH:0] g_inc_rptr;

	assign inc_rptr = rptr+(read_enable & !rempty);
	assign g_inc_rptr = (inc_rptr >>1)^inc_rptr;
	assign empty = (rq2_wptr == g_inc_rptr);
	
	assign half_wempty = (rptr <= (1 << (PTR_DEPTH - 1)));
  
	always@(posedge rclk or negedge rrst_n) 
		begin
			if(!rrst_n) begin
				rptr <= 0;
				wq2_rptr <= 0;
			end
			else begin
				rptr <= inc_rptr;
				wq2_rptr <= g_inc_rptr;
			end
		end
  
	always@(posedge rclk or negedge rrst_n) 
		begin
			if(!rrst_n) 
				rempty <= 1;
			else        
				rempty <= empty;
		end
		
		
endmodule

module fifo_mem (wclk,write_enable,rclk,read_enable,wptr,rptr,data_write,wfull,rempty,data_read);

	parameter DEPTH=512, DATA_WIDTH=8, PTR_WIDTH=9;
	
	input wclk, write_enable, rclk, read_enable;
	input [PTR_WIDTH:0] wptr, rptr;
	input logic [DATA_WIDTH-1:0] data_write;
	input wfull, rempty;
	output reg [DATA_WIDTH-1:0] data_read;
	
	reg [DATA_WIDTH-1:0] fifo[0:DEPTH-1];
	
	//assign data_read = fifo[rptr[PTR_WIDTH-1:0]];
  
	always@(posedge wclk) 
		begin
			if(write_enable & !wfull) 
			begin
			  fifo[wptr[PTR_WIDTH-1:0]] <= data_write;
			end
			else
			  fifo[wptr[PTR_WIDTH-1:0]] <= fifo[wptr[PTR_WIDTH-1:0]];
			  
			  
		end
		
	always@(posedge rclk)
	begin
		if(read_enable && !rempty) 
			data_read <= fifo[rptr[PTR_WIDTH-1:0]];
		else
			fifo[wptr[PTR_WIDTH-1:0]] <= fifo[wptr[PTR_WIDTH-1:0]]; 
	end 
	
	
endmodule