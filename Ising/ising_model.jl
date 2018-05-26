# Author : Liyang
# Data   : 2018.5.18 
# Descripution : 
#   This program code is desgined for 2D ising model calculation 
#

###############################
#         Sub Function        #
###############################
function welcomeinterface()
  println(" ") 
  println(" ") 
  println(" ") 
  println("          ooooo  .oooooo..o ooooo ooooo      ooooo    oooooooooo   ")
  println("          '888' d8P'    'Y8 '888'  888'88.    888   d88'     '88b  ")
  println("           888  Y88bo.       888   888  888   888  d88             ")
  println("           888   ':Y8888o.   888   888   888  888  888    o888888b ")
  println("           888       ':Y88b  888   888    888 888  q88      88  8o ")
  println("           888  oo     .d8P  888   888     888'88   q88.    88  8o ")
  println("          o888o 8::88888P'  o888o o888o      o888o    o888888o  oo ")
  println(" ")
  println("                        Two Dimensional Ising Model ")
  println("                             Simulation Program")
  println(" ")  
  println("                       LiYang (liyang6pi5@icloud.com)")
  println("                         Last Update Date: 2018.5.26")
  println("                               Version: 1.2.0")
  println("                              Copyleft liyang")
  println(" ")
  println("                         Julia 0.6.2 Supported ONLY!")
  println(" ")
  println(" ")
  println(">>> Calculation Processing <<<")
end

function periodicfieldassignment!(material_field::Array{Int8,2}) 
  material_size = size(material_field)
  material_matrix_row_num = material_size[1]
  material_matrix_column_num = material_size[2]

  material_field[1,:] = material_field[material_matrix_row_num-1,:]
  material_field[material_matrix_row_num,:] = material_field[2,:]
  material_field[:,1] = material_field[:,material_matrix_column_num-1]
  material_field[:,material_matrix_column_num] = material_field[:,2]
  #return material_field
end

function acceptspinrevers(material_field::Array{Int8,2},
                               row_index::Int64,
                            column_index::Int64,
                             temperature::Float16,
                 external_magnetic_field::Float16)
                             
  delta_energy = ((-2) * (-1) * material_field[row_index,column_index] * 
                               (material_field[row_index-1,column_index] +
                                material_field[row_index+1,column_index] + 
                                material_field[row_index,column_index-1] +
                                material_field[row_index,column_index+1])) +
                 ((-2) * (-1) * material_field[row_index,column_index] *
                                external_magnetic_field)
  if delta_energy > 0
    reverse_possibility = exp(-delta_energy / temperature)
    random_pickup_point = rand()
    if random_pickup_point < reverse_possibility
      return true
    else
      return false
    end
  else
    return true
  end
end

function getmagneticmoment(material_field::Array{Int8,2})::Int64
  magnetic_moment :: Int64 = 0

  material_size = size(material_field)
  material_matrix_row_num = material_size[1]
  material_matrix_column_num = material_size[2]

  for column_index = 2:material_matrix_column_num-1
    for row_index = 2:material_matrix_row_num-1
      magnetic_moment += material_field[row_index,column_index]
    end
  end

  return magnetic_moment
end

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

function datawritetofile(external_magnetic_field,
                         temperature,
                         magnetic_moment,
                         data_file_name)
  data_file = open(data_file_name,"a")
  output_char = "$(external_magnetic_field) \t $(temperature) \t $(magnetic_moment)\n"
  write(data_file,output_char)
  close(data_file)
end

function plot_script_output(temperature_list, 
                            external_magnetic_field_list, 
                            data_save_matrix,
                            command_file_name)
  println("> Julia Plot Script <")
  println("============================================")
  println("")
  println("using Plots")
  println("using Rsvg")
  println("Plots.plotlyjs()")
  println("X = ",temperature_list)
  println("Y = ",external_magnetic_field_list)
  println("Z = ",data_save_matrix)
  println("fig_handle = Plots.surface(Y,X,Z)")
  println("#Plots.savefig(fig_handle,\"ising.data.png\")")
  println("")
  println("println(\"Plot Complete!\")")
  println("")
  println("============================================")

  command_file = open(command_file_name,"w")
  write(command_file,"> Julia Plot Script <\n")
  write(command_file,"============================================\n")
  write(command_file,"\n")
  write(command_file,"using Plots\n")
  write(command_file,"using Rsvg\n")
  write(command_file,"Plots.plotlyjs()\n")
  write(command_file,"X = $(temperature_list)\n")
  write(command_file,"Y = $(external_magnetic_field_list)\n")
  write(command_file,"Z = $(data_save_matrix)\n")
  write(command_file,"fig_handle = Plots.surface(Y,X,Z)\n")
  write(command_file,"#Plots.savefig(fig_handle,\"ising.data.png\")\n")
  write(command_file,"\n")
  write(command_file,"println(\"Plot Complete!\")\n")
  write(command_file,"\n")
  write(command_file,"============================================\n")
  close(command_file)
end

###############################
#       Main Function         #
###############################
function main()
  # Parameter List
  const kMaterialColumnNum         :: Int32   =  100
  const kMaterialRowNum            :: Int32   =  100
  const kPreheatingStepNum         :: Int32   =  100000000
  const kSampleIntervalSteps       :: Int32   =  100
  const kSampleNum                 :: Int32   =  10000000
  const kMaxTemperature            :: Float16 =  6.0
  const kMinTemperature            :: Float16 =  1.0
  const kTemperatureStep           :: Float16 =  0.1
  const kMaxExternalMagneticField  :: Float16 =  3.0
  const kMinExternalMagneticField  :: Float16 =  -3.0
  const kExternalMagneticFieldStep :: Float16 =  0.1
  const kDataFileName              :: String  =  "DATA_ising.txt"
  const kCommandFileName           :: String  =  "PLOT_ising_julia_command.txt"

  magnetic_moment_save_array = Array{Int64}(kSampleNum)
  magnetic_moment_save_array = zeros(magnetic_moment_save_array)
  material_field = Array{Int8}(kMaterialRowNum+2,kMaterialColumnNum+2)
  material_field = ones(material_field)

  temperature_list = kMinTemperature:kTemperatureStep:kMaxTemperature
  external_magnetic_field_list = kMinExternalMagneticField:kExternalMagneticFieldStep:kMaxExternalMagneticField

  data_save_matrix = Array{Float16,2}(length(temperature_list),
                                      length(external_magnetic_field_list))

  init_data_file = open(kDataFileName,"w")
  close(init_data_file)

  srand()  # random number seed set 

  welcomeinterface()

  # Init the field 
  for column_index = 2:kMaterialColumnNum+1
    for row_index = 2:kMaterialRowNum+1
      material_field[row_index,column_index]=rand(-1:2:1)
    end
  end
  periodicfieldassignment!(material_field)

  # Main simulation start
  data_save_matrix_column_index = 1
  for external_magnetic_field = external_magnetic_field_list
    data_save_matrix_row_index = 1
    for current_temperature = temperature_list
      println("")
      println("External Magnetic Field   :  ", external_magnetic_field, 
              " \t (",kMinExternalMagneticField," : ",kExternalMagneticFieldStep," : ", kMaxExternalMagneticField,")")
      println("Temperature               :  ", current_temperature, 
              " \t (",kMaxTemperature," : ",-kTemperatureStep,
              " : ",kMinTemperature,")")
      # Initial the data save array 
      magnetic_moment_save_array = zeros(magnetic_moment_save_array)
      # Preheat
      for preheat_loop = 1:kPreheatingStepNum 
        random_row_index = rand(2:kMaterialRowNum+1)
        random_column_index = rand(2:kMaterialColumnNum+1)
        # If the reverse can be accecpt
        if acceptspinrevers(material_field,
                            random_row_index,
                            random_column_index,
                            current_temperature,
                            external_magnetic_field)
          # filp the spin
          material_field[random_row_index,random_column_index] = 
          material_field[random_row_index,random_column_index] * (-1) 
        end
        periodicfieldassignment!(material_field)
      end
      
      # Start sampling 
      for sample_loop_index = 1:kSampleNum
        for step_skip_loop = 1:kSampleIntervalSteps
          random_row_index = rand(2:kMaterialRowNum+1)
          random_column_index = rand(2:kMaterialColumnNum+1)
          
          # If the reverse can be accecpt
          if acceptspinrevers(material_field,
                              random_row_index,
                              random_column_index,
                              current_temperature,
                              external_magnetic_field)
            # filp the spin
            material_field[random_row_index,random_column_index] = 
            material_field[random_row_index,random_column_index] * (-1) 
          end
          periodicfieldassignment!(material_field)
        end
        magnetic_moment_save_array[sample_loop_index] = 
                    getmagneticmoment(material_field)
        printprocessbar(sample_loop_index,kSampleNum)
      end
      magnetic_moment = mean(magnetic_moment_save_array)

      datawritetofile(external_magnetic_field,
                      current_temperature,
                      magnetic_moment,
                      kDataFileName)

      data_save_matrix[data_save_matrix_row_index,data_save_matrix_column_index]= magnetic_moment

      println("")
      println("Magnetic Moment           :  ", magnetic_moment)

      data_save_matrix_row_index += 1
    end
    data_save_matrix_column_index += 1
  end

  println("")
  println("> The calculation result has been saved in file: '",
          kDataFileName,"'")
  println("")

  plot_script_output(temperature_list, 
                     external_magnetic_field_list, 
                     data_save_matrix,
                     kCommandFileName)
  println("> The julia plot command has been saved in file: '$(kCommandFileName)'")

  println("")
  println(">>> Program Complete! <<<")
  println("")
end

###############################
#       Main Execution        #
###############################

main()
