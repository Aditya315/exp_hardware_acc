#! /bin/bash

verilator -sv -Irtl --cc tb/tb_exp_rtl.sv --exe sim_main.cpp --build --timing --Wno-fatal --Wno-UNOPTFLAT --Wno-WIDTH --Wno-TIMESCALEMOD --trace

./obj_dir/Vtb_exp_rtl
