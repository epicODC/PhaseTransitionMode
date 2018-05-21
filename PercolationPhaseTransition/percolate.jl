# Author: liyang
#
# Date: 2018.5.21
#
# Descripution:
#   Calculate the percollation phase transition 


###############################
#         Sub Function        #
###############################
########
function welcomeinterface()
  println(" ") 
  println(" ") 
  println(" ") 
  for pattern_row_index = 1:12
    print("                   ")
    for pattern_column_index = 1:40
      if rand() < 0.618
        print(" ")
      else
        print("#")
      end
    end
    print("\n")
  end 
  println(" ")
  println("                        Percollation Phase Transition ")
  println("                             Simulation Program")
  println(" ")  
  println("                       LiYang (liyang6pi5@icloud.com)")
  println("                         Last Update Date: 2018.5.21")
  println("                               Version: 1.0.0")
  println("                              Copyleft liyang")
  println(" ")
  println("                         Julia 0.6.2 Supported ONLY!")
  println(" ")
  println(" ")
  println(">>> Calculation Process <<<")
end

########
function getpercolrationpattern!(material_field::Array{Int8,2}, 
                                  void_possible::Float16)
  material_size = size(material_field)
  material_matrix_row_num = material_size[1]
  material_matrix_column_num = material_size[2]

  for column_index = 2:material_matrix_column_num-1
    for row_index = 2:material_matrix_row_num-1
      if rand() < void_possible
        material_field[row_index,column_index] = 0  # 0 for holl
      else
        material_field[row_index,column_index] = 1  # 1 for rock
      end
    end
  end
end

########
#=
function takeonestepaway!(material_field::Array{Int8,2},
                  preposition_row_index,
               preposition_column_index)
  material_field[preposition_row_index,preposition_column_index] = 2
                                                    # 2 for path walk through
  # If at the bottom
  if preposition_row_index == size(material_field)[1]-1
    return true
  end
  # go left
  if material_field[preposition_row_index,preposition_column_index-1] == 0
    if takeonestepaway!(material_field,
                        preposition_row_index,
                        preposition_column_index-1)
      return true
    end
  end
  # go down
  if material_field[preposition_row_index+1,preposition_column_index] == 0
    if takeonestepaway!(material_field,
                        preposition_row_index+1,
                        preposition_column_index)
    return true
    end
  end
  # go right
  if material_field[preposition_row_index,preposition_column_index+1] == 0
    if takeonestepaway!(material_field,
                        preposition_row_index,
                        preposition_column_index+1)
    return true
    end
  end
  # go up
  if material_field[preposition_row_index-1,preposition_column_index] == 0
    if takeonestepaway!(material_field,
                        preposition_row_index-1,
                        preposition_column_index)
    return true
    end
  end
  # dead end ...
  return false
end

########
function patternispermeable(material_field::Array{Int8,2})::Bool
  for column_index = 2:size(material_field)[2]-1
    if material_field[2,column_index] == 0 && 
       takeonestepaway!(material_field,2,column_index)
      return true
    end
  end

  return false
end
=#

########
function enlargethefield(material_field::Array{Int8,2})
  material_matrix_row_num = size(material_field)[1]
  material_matrix_column_num = size(material_field)[2]
  
  enlarge_material_field = Array{Int8}(2*material_matrix_row_num,
                                       2*material_matrix_column_num)
  enlarge_material_field = ones(enlarge_material_field)

  for column_index = 1:material_matrix_column_num
    for row_index = 1:material_matrix_row_num
      enlarge_material_field[2*row_index-1,2*column_index-1] = 
        material_field[row_index,column_index]
      enlarge_material_field[2*row_index,2*column_index-1] = 
        material_field[row_index,column_index] 
      enlarge_material_field[2*row_index-1,2*column_index] = 
        material_field[row_index,column_index] 
      enlarge_material_field[2*row_index,2*column_index] = 
        material_field[row_index,column_index] 
    end
  end

  return enlarge_material_field
end

########
function mazewaytocheck(enlarge_material_field::Array{Int8,2},
                          current_column_index::Int64)::Bool
  current_row_index = 3
  test_direction_order = [[0,-1],  # go left
                          [1,0],   # go down
                          [0,1],   # go right
                          [-1,0]]  # go up
  while true
    if enlarge_material_field[current_row_index+test_direction_order[1][1],
                      current_column_index+test_direction_order[1][2]] == 0
      current_row_index += test_direction_order[1][1]
      current_column_index += test_direction_order[1][2]

      temp_array = test_direction_order[4]
      test_direction_order[4] = test_direction_order[3]
      test_direction_order[3] = temp_array
      temp_array = test_direction_order[3]
      test_direction_order[3] = test_direction_order[2]
      test_direction_order[2] = temp_array
      temp_array = test_direction_order[2]
      test_direction_order[2] = test_direction_order[1]
      test_direction_order[1] = temp_array
    end

    if enlarge_material_field[current_row_index+test_direction_order[2][1],
                      current_column_index+test_direction_order[2][2]] == 0
      current_row_index += test_direction_order[2][1]
      current_column_index += test_direction_order[2][2]
    end

    if enlarge_material_field[current_row_index+test_direction_order[3][1],
                      current_column_index+test_direction_order[3][2]] == 0
      current_row_index += test_direction_order[3][1]
      current_column_index += test_direction_order[3][2]

      temp_array = test_direction_order[1]
      test_direction_order[1] = test_direction_order[2]
      test_direction_order[2] = temp_array
      temp_array = test_direction_order[2]
      test_direction_order[2] = test_direction_order[3]
      test_direction_order[3] = temp_array
      temp_array = test_direction_order[3]
      test_direction_order[3] = test_direction_order[4]
      test_direction_order[4] = temp_array
    end

    if current_row_index == 3
      break
    elseif current_row_index == size(enlarge_material_field)[1]-3
      return true
    end 
  end

  return false
end

########
function patternispermeable(material_field::Array{Int8,2})::Bool
  enlarge_material_field = enlargethefield(material_field)

  for column_index = 3:2:size(enlarge_material_field)[2]-3
    if mazewaytocheck(enlarge_material_field, column_index)
      return true
    end
  end

  return false
end

########
function printprocessbar(finished_task, total_task)
  const kProcessChangeInterval  =  0.1
                          # Process bar change kPCI% per time
  const kTotalSymbolNum         =  60

  process_degree = 1.0 * finished_task / total_task
  task_num_print_interval = 
    round(Int, total_task * kProcessChangeInterval / 100)
  symbol_num_process = round(Int, process_degree * kTotalSymbolNum)

  if (finished_task % task_num_print_interval) == 0
    processing_char = string("[", repeat("#",symbol_num_process),
                             repeat(" ",kTotalSymbolNum-symbol_num_process),
                             "]", round(process_degree*100,2),"%",
                             " <-- ",finished_task,"/",total_task)

    print("\u1b[1G")   # go to first column
    print(processing_char)
    print("\u1b[K")    # clear the rest of the line
  end
end

########
function datawritetofile(data1, data2, data_file_name)
  data_file = open(data_file_name,"a")
  output_char = "$(data1)  \t  $(data2)\n"
  write(data_file,output_char)
  close(data_file)
end


###############################
#       Main Function         #
###############################

function main()
  # Parameter List
  const kMaterialFieldRowNum          ::  Int32    =  100
  const kMaterialFieldColumnNum       ::  Int32    =  100
  const kHollowMinPossibility         ::  Float16  =  0.0
  const kHollowMaxPossibility         ::  Float16  =  1.0
  const kHollowPossibilityChangeRate  ::  Float16  =  0.01
  const kSamplingNum                  ::  Int64    =  100000
  const kDataSaveFileName             ::  String   =  "percolate.data"
  
  material_field = Array{Int8}(kMaterialFieldRowNum+2,kMaterialFieldColumnNum+2)

  srand()  # Seed for random number 

  welcomeinterface()

  # Initial the Matrix
  material_field = ones(material_field)

  # main simulation 
  for hollow_possibility = 
        kHollowMinPossibility:kHollowPossibilityChangeRate:kHollowMaxPossibility
    println(" ")
    println("Hollow Possibility      :  $(hollow_possibility) \t ($(kHollowMinPossibility) : $(kHollowPossibilityChangeRate) : $(kHollowMaxPossibility))")
    # Init the permeation possibility value
    permeation_counter = 0
    for simulation_sampling_loop = 1:kSamplingNum
      getpercolrationpattern!(material_field,hollow_possibility)
      # count the permeable pattern
      if patternispermeable(material_field)
        permeation_counter += 1
      end 
      printprocessbar(simulation_sampling_loop, kSamplingNum)
    end
    permeation_possibility = 1.0 * permeation_counter / kSamplingNum
    datawritetofile(hollow_possibility, 
                    permeation_possibility,
                    kDataSaveFileName)
    println(" ")
    println("Permeation Possibility  :  $(permeation_possibility)")
  end

  println("")
  println(">>> Program Complete! <<<")
  println("> The calculation result has been saved in file: '",
          kDataSaveFileName,"'")
  println("")
end


###############################
#       Main Execution        #
###############################

main()
