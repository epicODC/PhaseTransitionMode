#!/bin/bash
#
#

julia_start_time=$(date +%s)
julia percolate_maze.jl
julia_end_time=$(date +%s)
julia_spd_used_time=$(echo $julia_end_time $julia_start_time | awk '{ print ($1 - $2)}')

echo "Total maze Algorithem CPU Time: ${julia_spd_used_time}"

julia_start_time=$(date +%s)
julia percolate_recursion.jl
julia_end_time=$(date +%s)
julia_rec_used_time=$(echo $julia_end_time $julia_start_time | awk '{ print ($1 - $2)}')

echo "Total Recursion Algorithem CPU Time: ${julia_rec_used_time}"

echo $(date) >> TEST.result
echo "Recursion Algorithem CPU Time(s)  :  ${julia_rec_used_time}" >> TEST.result 
echo "    Maze Algorithem CPU Time(s)  :  ${julia_spd_used_time}" >> TEST.result
echo "" >> TEST.result