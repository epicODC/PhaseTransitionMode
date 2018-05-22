#!/bin/bash
#
#

julia_start_time=$(date +%s%N)
julia percolate_recursion.jl
julia_end_time=$(date +%s%N)
julia_rec_used_time=$(echo $julia_end_time $julia_start_time | awk '{ print ($1 - $2) / 1000000000}')

julia_start_time=$(date +%s%N)
julia percolate_speed.jl
julia_end_time=$(date +%s%N)
julia_spd_used_time=$(echo $julia_end_time $julia_start_time | awk '{ print ($1 - $2) / 1000000000}')

echo $(date) >> TEST.result
echo "Recursion Algorithem CPU Time(s)  :  ${julia_rec_used_time}" >> TEST.result 
echo "    Speed Algorithem CPU Time(s)  :  ${julia_spd_used_time}" >> TEST.result
echo "" >> TEST.result