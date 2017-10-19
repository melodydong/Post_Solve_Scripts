# --- VTK-PYTHON SCRIPT FOR READING VTP, INTEGRATING VARIABLES OF INTEREST USING TRAPEZOIDAL RULE
# --- CALCULATES PRESSURE AT OUTLETS OF THE MODEL
# --- NOTE: TO BE RUN FROM DIRECTORY CONTAINING all_results.vtp FILE AND mesh-complete/ DIRECTORY
# --- NOTE: THIS SCRIPT ASSUMES A TRIANGULAR SURFACE MESH
# --- BASED ON A SCRIPT BY JUSTIN TRAN
# --- UPDATED 8/4/17 BY CASEY FLEETER


#---------------------------------------------------------------------#
#   RUN THIS SCRIPT FROM THE SAME DIRECTORY AS all_results.vtp        #
#   SCRIPT GENERATES all_results_pressures.dat                        #
#---------------------------------------------------------------------#

import sys
import os
import vtk
import numpy as np

#------------------------------------------------------------#
#   CHANGE THE START AND END TIMES AND TIME STEP INCREMENT   #
#------------------------------------------------------------#
# SPECIFIY TIME POINTS TO DETERMINE PRESSURE, ALONG WITH INCREMENT IN RESTART FILES
START_TIME = 160
END_TIME = 240
INCREMENT = 10


#---------------------------------------------------------------------#
#   CHANGE THE NAMES OF THE CAP FILES FROM THE MESH-COMPLETE FOLDER   #
#---------------------------------------------------------------------#
# NAMES OF CAP GEOMETRY FILES OF MODEL, WITHOUT CAP_ PREFIX
input_filenames = ['celiac_trunk', 'celiac_branch', 'superior_mesentaric', \
                   'renal_right', 'renal_left', 'right_internal_iliac', \
                   'left_internal_iliac', 'right_iliac', 'aorta_2']

# PATH OF OUTPUT FILE FOR RESULTS
output_filename = 'all_results_pressures.dat'
output_collection = []

if __name__ == "__main__":

  for file in input_filenames:

    # Load in the mesh file for the outlet you want pressures at. This can be found in the mesh-surfaces folder
    command_string = 'cd mesh-complete/mesh-surfaces'
    print(command_string)
    os.chdir('mesh-complete/mesh-surfaces')

    # Read geometry (mesh) information from this cap
    outlet_reader = vtk.vtkXMLPolyDataReader()          # Create vtk instance
    outlet_reader.SetFileName('cap_' + file + '.vtp')   # Open file
    outlet_reader.Update()
    outlet_model = vtk.vtkPolyData()
    outlet_model = outlet_reader.GetOutput()            # Read file into new variable for manipulation
    numPts = outlet_model.GetNumberOfPoints()           # Determine number of points in the mesh at this outlet
    outlet_IDs = outlet_model.GetPointData().GetArray("GlobalNodeID")  # Extract node IDs to match with full model solution
    


    # Load in the pressure information from the vtp file
    command_string = 'cd ../..'
    print(command_string)
    os.chdir('../..')

    # First, read in the .vtp file containing your quantities of interest
    all_results_reader = vtk.vtkXMLPolyDataReader()             # Create vtk instance
    all_results_reader.SetFileName('all_results.vtp')           # Open file
    all_results_reader.Update()
    all_results_model = vtk.vtkPolyData() 
    all_results_model = all_results_reader.GetOutput()          # Read file into new variable for manipulation
    all_results_numPts = all_results_model.GetNumberOfPoints()  # Determine number of points in the mesh of the entire model
    all_results_IDs = all_results_model.GetPointData().GetArray('GlobalNodeID')   # Extract node IDs of full model solution
    


    # Find the nodes on all_results that correspond to the outlet of interest
    outlet_nodes = []
    for i_node in xrange(0, numPts):
      this_ID = outlet_IDs.GetTuple1(i_node)
      
      # iterate through all nodes in model
      for i_full in xrange(0, all_results_numPts):
        full_ID = all_results_IDs.GetTuple1(i_full)

        if(full_ID == this_ID):
          outlet_nodes.append(i_full)
          break
          
    # Just to make sure we found all the outlet nodes in all_results
    assert(len(outlet_nodes) == numPts)
    
    # Create a Python list to hold the pressure arrays from the all_results.vtp
    pressure_vectors = []
    # keep track of how many timesteps in solution
    timestep_count = 0
    for i_array in xrange(START_TIME, END_TIME+INCREMENT, INCREMENT):
      pressure_vectors.append(vtk.vtkDoubleArray())

      if i_array < 10:
        pressure_vectors[timestep_count] = all_results_model.GetPointData().GetArray('pressure_' + '0000' + str(i_array))
      elif i_array < 100:
        pressure_vectors[timestep_count] = all_results_model.GetPointData().GetArray('pressure_' + '000' + str(i_array))
      elif i_array < 1000:
        pressure_vectors[timestep_count] = all_results_model.GetPointData().GetArray('pressure_' + '00' + str(i_array))
      elif i_array < 10000:
        pressure_vectors[timestep_count] = all_results_model.GetPointData().GetArray('pressure_' + '0' + str(i_array))
      else:
        pressure_vectors[timestep_count] = all_results_model.GetPointData().GetArray('pressure_' + str(i_array))
      
      timestep_count = timestep_count + 1
    
    
        
    # Integrate pressures over the surface of the outlet face to get the pressure on this face at each time
    temp_press = np.zeros(timestep_count)

    for i_time in xrange(0, timestep_count):
    
      # Compute the integral using trapezoidal rule
      total_area = 0.0
      # store pressure information for the entire outlet face at this time step
      curr_press = 0.0

      # iterate over all mesh cells on outlet face
      for i_cell in xrange(0, outlet_model.GetNumberOfCells()):
      
        # extract information about cell vertices
        temp_cell = outlet_model.GetCell(i_cell)
        pts_cell = temp_cell.GetPointIds()
        cell_pts = temp_cell.GetPoints()
        p0 = cell_pts.GetPoint(0)
        p1 = cell_pts.GetPoint(1)
        p2 = cell_pts.GetPoint(2)
          
        # compute area of mesh cell (triangular mesh assumed)  
        local_area = temp_cell.TriangleArea(p0, p1, p2)
        total_area = total_area + local_area
        
        local_temp_press = 0.0
        # add contributions from each vertex of cell
        for ipt in xrange(0, pts_cell.GetNumberOfIds()):
          
          iid = pts_cell.GetId(ipt)   # get node number of this point
          temp_press_vec = float(pressure_vectors[i_time].GetTuple(iid)[0]) # get pressure at this point
          # add pressure contribution of this point to the total cell pressure
          local_temp_press = local_temp_press + temp_press_vec
          
        # Complete the trapezoidal rule integration for this cell by multiplying the sum of
        # the pressures by the local area and dividing by the number of vertices
        # Add the contribution of this cell to the curr_press for the entire outlet face
        curr_press = curr_press + local_temp_press*local_area/3.0
      
      # save pressure information at the outlet face (with pressure normalized by the total area 
      # of the outlet face) for the current timestep   
      temp_press[i_time] = curr_press/ total_area

    # save pressure information for all timesteps for the current outlet face
    output_collection.append(temp_press)



  # Now that we have looped over all our .vtp files of interest and integrated
  # the variables, it is time to save them to the output file.
  outfile = open(output_filename, 'w')
  
  # First print a header that tells what each integrated quantity of interest is
  out_string = 'Time Step '
  for iq in xrange(0, len(input_filenames)):
    out_string = out_string + input_filenames[iq] + ' '
  out_string = out_string + '\n'
  outfile.write(out_string)

  # Now print the data for each quantity of interest at each time step
  for i_time in xrange(0, timestep_count):

      # Print time step
      out_string = str(i_time)
      
      # Print each quantity of interest at that timestep
      for i_file in xrange(0,len(input_filenames)):  
        out_string = out_string + ' ' + str(output_collection[i_file][i_time])
          
      out_string = out_string + '\n'
      outfile.write(out_string)

  outfile.close()
  