#!/bin/bash
# Author : Liyang
# 
# Data : 2018.5.20
#
# Description: 
#   executes the speed test for julia and c code using ising model.

echo "Please make sure you are using:"
echo "> nohup ./IsingCalculationSpeedTest.sh > TEST.record 2>&1 &"
echo "to run this script"

julia_start_time=$(date +%s%N)
julia ising_model.jl >> TEST.record
julia_end_time=$(date +%s%N)
julia_used_time=$(echo $julia_end_time $julia_start_time | awk '{ print ($1 - $2) / 1000000000}')

gcc ising_model.c -lm -o ising_model.c.out
chmod +x ising_model.c.out

c_start_time=$(date +%s%N)
./ising_model.c.out > ising_Tc-M.c.data
c_end_time=$(date +%s%N)
c_used_time=$(echo $c_end_time $c_start_time | awk '{ print ($1 - $2) / 1000000000}')

echo $(date) >> TEST.result
echo "Julia CPU Time(s)  :  ${julia_used_time}" >> TEST.result 
echo "C CPU Time(s)      :  ${c_used_time}" >> TEST.result
echo "" >> TEST.result
