interface intf(input logic wclk, rclk, wrst_n, rrst_n);
    logic [8:0] data_write;
    logic write_enable;
    logic read_enable;

    logic [8:0] data_read;
    logic rempty,wHalf_empty;
    logic wfull,wHalf_full;

    clocking monw_cs @(posedge wclk);
        default input #1;
        input write_enable, wrst_n, data_write, wfull,wHalf_full;
    endclocking

    clocking monr_cs @(posedge rclk);
        default input #0;
        input read_enable, rrst_n, data_read, rempty,wHalf_empty;
    endclocking

endinterface
