vlib work
vlog async_fifo.sv
vlog async_fifo_package.sv
vlog async_fifo_top.sv
vlog async_fifo_test1.sv
#vlog async_fifo_test2.sv
#vlog async_fifo_test3.sv
vlog async_fifo_driver.sv
vlog async_fifo_env.sv
vlog async_fifo_interface.sv
vlog async_fifo_read_agent.sv
vlog async_fifo_scoreboard.sv
vlog async_fifo_seq_item.sv
vlog async_fifo_seq_test1.sv
vlog async_fifo_seq_test2.sv
vlog async_fifo_seq_test3.sv
vlog async_fifo_sequencer.sv
vlog async_fifo_write_agent.sv
vlog async_fifo_read_monitor.sv
vlog async_fifo_write_monitor.sv

#vlog +define+BUG_ON -sv async_fifo.sv
#vlog +define+PTR_BUG -sv async_fifo.sv



vsim -coverage tb_top -voptargs="+cover=bcesf"
vlog -cover bcst async_fifo.sv
#vsim -coverage tb_top -do "run -all; exit"
vsim -coverage tb_top -do "run -all"

coverage report -code bcesf
coverage report -assert -binrhs -details -cvg
coverage report -codeAll

