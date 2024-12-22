module ASYNC_FIFO #(parameter DATA_WIDTH = 9, parameter PTR_WIDTH = 9 ) (
    input  logic write_enable, wclk, wrst_n,
    input  logic read_enable, rclk, rrst_n,
    input  logic [DATA_WIDTH-1:0] data_write,
    output logic [DATA_WIDTH-1:0] data_read,
    output logic wfull,
    output logic rempty
);

    logic [PTR_WIDTH-1:0] waddr, raddr;   
    logic [PTR_WIDTH:0] wptr, rptr;      
    logic [PTR_WIDTH:0] wptr_s, rptr_s;  

    synchronizer_r2w #(PTR_WIDTH) r2w_DUT (
        .rptr_s(rptr_s),
        .rptr(rptr),
        .wclk(wclk),
        .wrst_n(wrst_n)
    );

    synchronizer_w2r #(PTR_WIDTH) w2r_DUT (
        .wptr_s(wptr_s),
        .wptr(wptr),
        .rclk(rclk),
        .rrst_n(rrst_n)
    );

    fifo_mem #(DATA_WIDTH, PTR_WIDTH) fifo_mem_DUT (
        .data_read(data_read),
        .data_write(data_write),
        .waddr(waddr),
        .raddr(raddr),
        .wclk(wclk),
        .wfull(wfull),
        .write_enable(write_enable),
        .rclk(rclk),
        .read_enable(read_enable),
        .rempty(rempty)
    );

    rptr_handler #(PTR_WIDTH) rptr_DUT (
        .raddr(raddr),
        .rempty(rempty),
        .rptr(rptr),
        .read_enable(read_enable),
        .rclk(rclk),
        .rrst_n(rrst_n),
        .wptr_s(wptr_s)
    );

    wptr_handler #(PTR_WIDTH) wptr_DUT (
        .waddr(waddr),
        .wfull(wfull),
        .wptr(wptr),
        .write_enable(write_enable),
        .wclk(wclk),
        .wrst_n(wrst_n),
        .rptr_s(rptr_s)
    );

endmodule : ASYNC_FIFO

module fifo_mem#(parameter DATA_WIDTH = 12, parameter PTR_WIDTH = 12) (
    input  logic write_enable, wfull, wclk,
    input  logic read_enable, rempty, rclk,
    input  logic [PTR_WIDTH-1:0] waddr, raddr,
    input  logic [DATA_WIDTH-1:0] data_write,
    output logic [DATA_WIDTH-1:0] data_read
);

    localparam DEPTH = 1 << PTR_WIDTH;
    logic [DATA_WIDTH-1:0] fifo_mem1 [0:DEPTH-1];

    always @(posedge rclk) begin
        if (read_enable && !rempty)
            data_read = fifo_mem1[raddr];
    end

    always @(posedge wclk) begin
        if (write_enable && !wfull)
            fifo_mem1[waddr] <= data_write;
    end

endmodule : fifo_mem

module synchronizer_r2w #(parameter PTR_WIDTH = 12) (
    input  logic wclk, wrst_n,
    input  logic [PTR_WIDTH:0] rptr,
    output logic [PTR_WIDTH:0] rptr_s
);

    logic [PTR_WIDTH:0] wq1_rptr;

    always_ff @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n)
            {rptr_s, wq1_rptr} <= 0;
        else
            {rptr_s, wq1_rptr} <= {wq1_rptr, rptr};
    end

endmodule : synchronizer_r2w


module synchronizer_w2r #(parameter PTR_WIDTH = 12) (
    input  logic rclk, rrst_n,
    input  logic [PTR_WIDTH:0] wptr,
    output logic [PTR_WIDTH:0] wptr_s
);

    logic [PTR_WIDTH:0] rq1_wptr;

    always_ff @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n)
            {wptr_s, rq1_wptr} <= 0;
        else
            {wptr_s, rq1_wptr} <= {rq1_wptr, wptr};
    end

endmodule : synchronizer_w2r

module rptr_handler #(parameter PTR_WIDTH = 12) (
    input  logic read_enable, rclk, rrst_n,
    input  logic [PTR_WIDTH :0] wptr_s,
    output logic rempty,
    output logic [PTR_WIDTH-1:0] raddr,
    output logic [PTR_WIDTH :0] rptr
);

    logic [PTR_WIDTH:0] rbin;
    logic [PTR_WIDTH:0] rgraynext, rbinnext;

    always_ff @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n)
            {rbin, rptr} <= '0;
        else
            {rbin, rptr} <= {rbin + (read_enable & ~rempty), rgraynext};
    end

    assign raddr = rbin[PTR_WIDTH-1:0];
    assign rbinnext = rbin + (read_enable & ~rempty);
    assign rgraynext = (rbinnext >> 1) ^ rbinnext;

    // FIFO Empty Logic generation 
    assign rEmpty_val = (rgraynext == wptr_s);

    always_ff @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n)
            rempty <= 1'b1;
        else
            rempty <= rEmpty_val;
    end

endmodule : rptr_handler


module wptr_handler #(parameter PTR_WIDTH = 12) (
    input  logic write_enable, wclk, wrst_n,
    input  logic [PTR_WIDTH :0] rptr_s,
    output logic wfull,
    output logic [PTR_WIDTH-1:0] waddr,
    output logic [PTR_WIDTH :0] wptr
);

    logic [PTR_WIDTH:0] wbin;
    logic [PTR_WIDTH:0] wgraynext, wbinnext;

    always_ff @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n)
            {wbin, wptr} <= '0;
        else
            {wbin, wptr} <= {wbin + (write_enable & ~wfull), wgraynext};
    end


    assign waddr = wbin[PTR_WIDTH-1:0];
    

    assign wbinnext = wbin + (write_enable & ~wfull);


    assign wgraynext = (wbinnext >> 1) ^ wbinnext;

    assign wFull_val = (wgraynext == {~rptr_s[PTR_WIDTH:PTR_WIDTH-1], rptr_s[PTR_WIDTH-2:0]});  
  
    always_ff @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n)
            wfull <= 1'b0;
        else
            wfull <= wFull_val; 
    end

endmodule : wptr_handler
