vlib work
vdel -all
vlog  design.sv
vlog  Interface.sv
vlog  top_module.sv
vlog  async_fifo_test.sv


vsim  async_fifo_top
vsim -coverage async_fifo_top -voptargs="+cover=bcesf"
vlog -cover bcst design.sv
vsim -coverage async_fifo_top -do "run -all; exit"
run -all
coverage report -code bcesf
coverage report -assert -binrhs -details -cvg
vcover report -html coverage_results
coverage report -codeAll

