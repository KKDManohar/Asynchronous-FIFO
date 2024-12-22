`include "async_fifo_test.sv"
`include "Interface.sv"

module async_fifo_top;
  
	bit rclk,wclk,rrst_n,wrst_n;
	logic [7:0] data_write;
	logic [7:0] data_read;
	  
	always #21ns wclk = ~wclk;
	always #30ns rclk = ~rclk;
	  
	initial 
		begin
			wclk =0;
			rclk=0;
			wrst_n =0;
			rrst_n=0;
			#50;
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
			
covergroup async_fifo_cover;
  option.per_instance = 1;

  DATA_WRITE : coverpoint in.data_write{
		option.comment = "write data ";
	        bins low_range  = {[1:511]};
	        bins mid_range  = {[512:1023]};
	        bins high_range = {[1023:2048]};	
	}

	WRITE_FULL : coverpoint in.wfull {
		option.comment = "FULL_FLAG";
		bins full_c   = ( 0 => 1 );
		bins full_c1  = ( 1 => 0 );
	}

	READ_EMPTY: coverpoint in.rempty {
		option.comment = "WHEN RESET IS OFF check EMPTY";
		bins empty_c  = (0 => 1);
		bins empty_c1 = (1 => 0);
	}

  DATA_READ : coverpoint in.data_read{
		option.comment = "read data ";
	        bins low_range  = {[1:511]};
	        bins mid_range  = {[512:1023]};
	        bins high_range = {[1023:2048]};	
	}


  W_INC : coverpoint in.write_enable{
  bins incr_s = (0 => 1);
  bins incr_s1 = (1 => 0);
  }

  R_INC : coverpoint in.read_enable{
  bins incr_sr = (0 => 1);
  bins incr_s1r = (1 => 0);
  }


  W_RESET: coverpoint in.wrst_n {
    option.comment = "write reset signal";
    bins reset_low_to_high = (0 =>1);
    bins reset_high_to_low = (1 =>0);

  }

  R_RESET: coverpoint in.rrst_n {
    option.comment = "read reset signal";
    bins reset_low_to_high = (0 =>1);
    bins reset_high_to_low = (1 =>0);
  }


W_CLK: coverpoint in.wclk {
  option.comment = "write clock signal";
  bins clk_low_to_high = (0 => 1);
  bins clk_high_to_low = (1 => 0);
}

R_CLK: coverpoint in.rclk {
  option.comment = "read clock signal";
  bins clk_low_to_high = (0 => 1);
  bins clk_high_to_low = (1 => 0);
}

WRITExADDxDATA : cross W_CLK,W_INC,DATA_WRITE;
READxADDxDATA  : cross R_CLK, R_INC, DATA_READ;
READxWRITE     : cross DATA_WRITE,DATA_READ;
RESETxWRITE    : cross W_RESET, DATA_WRITE;
RESETxREAD     : cross R_RESET , DATA_READ;

endgroup


  async_fifo_cover async_fifo_cov_inst;
  initial begin 
    async_fifo_cov_inst = new();
    forever begin @(posedge wclk or posedge rclk)
      async_fifo_cov_inst.sample();
    end
  end

  
  
endmodule




