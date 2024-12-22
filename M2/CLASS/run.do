vlib work
vdel -all
vlib work

vlog  design.sv
vlog  Interface.sv
vlog  top_module.sv
vlog  async_fifo_test.sv

vsim  work.async_fifo_top
add wave -r *
run -all

