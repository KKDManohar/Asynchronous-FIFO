import uvm_pkg::*;
`include "uvm_macros.svh"
`include "async_fifo_interface.sv"
`include "async_fifo_test1.sv"

module tb_top;

    bit rclk, wclk, rrst_n, wrst_n;
    always #21ns wclk = ~wclk;
    always #30ns rclk = ~rclk;

    intf intf (wclk, rclk, wrst_n, rrst_n);

    ASYNC_FIFO DUT (
        .data_write(intf.data_write),
        .wfull(intf.wfull),
        .rempty(intf.rempty),
        .write_enable(intf.write_enable),
        .read_enable(intf.read_enable),
        .wclk(intf.wclk),
        .rclk(intf.rclk),
        .rrst_n(intf.rrst_n),
        .wrst_n(intf.wrst_n),
        .data_read(intf.data_read)
    );

    initial begin
        uvm_config_db#(virtual intf)::set(null, "*", "vif", intf);
        `uvm_info("tb_top", "uvm_config_db set for uvm_tb_top", UVM_LOW);
    end

    initial begin
        run_test("fifo_base_test");
        // run_test("fifo_full_test");
        // run_test("fifo_random_test");
    end

    initial begin
        wclk = 0;
        rclk = 0;
        wrst_n = 0;
        rrst_n = 0;
        intf.read_enable = 0;
        intf.write_enable = 0;
        #1;
        rrst_n = 1;
        wrst_n = 1;
    end

endmodule
