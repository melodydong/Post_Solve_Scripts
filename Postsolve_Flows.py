# --- VTK-PYTHON SCRIPT FOR READING VTP, INTEGRATING VARIABLES OF INTEREST USING TRAPEZOIDAL RULE
# --- CALCULATES FLOW AT OUTLETS OF THE MODEL
# --- NOTE: TO BE RUN FROM DIRECTORY CONTAINING all_results.vtp FILE AND mesh-complete/ DIRECTORY
# --- NOTE: THIS SCRIPT ASSUMES A TRIANGULAR SURFACE MESH
# --- BASED ON A SCRIPT BY JUSTIN TRAN
# --- UPDATED 8/4/17 BY CASEY FLEETER


#---------------------------------------------------------------------#
#   RUN THIS SCRIPT FROM THE SAME DIRECTORY AS all_results.vtp        #
#   SCRIPT GENERATES all_results_flows.dat                            #
#---------------------------------------------------------------------#

import sys
import os
import vtk
import numpy as np


#------------------------------------------------------------#
#   CHANGE THE START AND END TIMES AND TIME STEP INCREMENT   #
#------------------------------------------------------------#
# SPECIFIY TIME POINTS TO DETERMINE FLOW, ALONG WITH INCREMENT IN RESTART FILES
START_TIME = 0
END_TIME = 1000
INCREMENT = 20


#---------------------------------------------------------------------#
#   CHANGE THE NAMES OF THE CAP FILES FROM THE MESH-COMPLETE FOLDER   #
#---------------------------------------------------------------------#
# NAMES OF CAP GEOMETRY FILES OF MODEL, WITHOUT CAP_ PREFIX
input_filenames = ['celiac_trunk', 'celiac_branch', 'superior_mesentaric', \
                   'renal_right', 'renal_left', 'right_internal_iliac', \
                   'left_internal_iliac', 'right_iliac', 'aorta_2']


# PATH OF OUTPUT FILE FOR RESULTS
output_filename = 'all_results_flows.dat'
output_collection = []

if __name__ == "__main__":

  for file in input_filenames:

    # Load in the mesh file for the outlet you want flows at. This can be found in the mesh-surfaces folder
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
    
    # Compute the normals to each mesh cell
    normalGenerator = vtk.vtkPolyDataNormals()          # Create vtk instance
    normalGenerator.SetInputData(outlet_model)          # Open file
    normalGenerator.ComputePointNormalsOff()
    normalGenerator.ComputeCellNormalsOn()              # normals to each mesh cell
    normalGenerator.Update()
    normals_test = normalGenerator.GetOutput()          # Read file into new variable for manipulation
    outlet_normal = normals_test.GetCellData().GetArray("Normals").GetTuple3(1) # one normal for the entire cap, assumed flat
    


    # Load in the velocity information from the vtp file
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
    # iterate through nodes in outlet
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
    
    # Create a Python list to hold the velocity arrays from the all_results.vtp
    velocity_vectors = []
    # keep track of how many timesteps in solution
    timestep_count = 0
    for i_array in xrange(START_TIME, END_TIME+INCREMENT, INCREMENT):
      velocity_vectors.append(vtk.vtkDoubleArray())
      
      if i_array < 10:
        velocity_vectors[timestep_count] = all_results_model.GetPointData().GetArray('velocity_' + '0000' + str(i_array))
      elif i_array < 100:
        velocity_vectors[timestep_count] = all_results_model.GetPointData().GetArray('velocity_' + '000' + str(i_array))
      elif i_array < 1000:
        velocity_vectors[timestep_count] = all_results_model.GetPointData().GetArray('velocity_' + '00' + str(i_array))
      elif i_array < 10000:
        velocity_vectors[timestep_count] = all_results_model.GetPointData().GetArray('velocity_' + '0' + str(i_array))
      else:
        velocity_vectors[timestep_count] = all_results_model.GetPointData().GetArray('velocity_' + str(i_array))
      
      timestep_count = timestep_count + 1    
    


    # Create a matrix to hold all the normal velocities for every node at every time on the outlet face
    normal_velocities = np.zeros((numPts, timestep_count))
    
    # Fill out the normal_velocities matrix by first looping over the nodes in the outlet,
    # computing the normal velocity, then storing it for each time point
    for i_node in xrange(0, len(outlet_nodes)):
      
      node_ind = outlet_nodes[i_node]
      for i_time in xrange(0, timestep_count):
          
        nodal_velocities = velocity_vectors[i_time]
        x_vel = nodal_velocities.GetTuple3(node_ind)[0]
        y_vel = nodal_velocities.GetTuple3(node_ind)[1]
        z_vel = nodal_velocities.GetTuple3(node_ind)[2]
          
        norm_vel_temp = outlet_normal[0]*x_vel + \
                        outlet_normal[1]*y_vel + \
                        outlet_normal[2]*z_vel
                          
        normal_velocities[i_node][i_time] = norm_vel_temp
        


    # Now that we know the normal velocities at every node and time, integrate
    # them over the surface of the outlet face to get the flow on this face at every time
    temp_flow = np.zeros(timestep_count)

    for i_time in xrange(0, timestep_count):
    
      # Compute the integral using trapezoidal rule
      total_area = 0.0
      # store velocity information for the entire outlet face at this time step
      curr_flow = 0.0 

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
        local_area = vtk.vtkTriangle().TriangleArea(p0, p1, p2)
        total_area = total_area + local_area
        
        local_temp_flow = 0.0
        # add contributions from each vertex of cell
        for ipt in xrange(0, pts_cell.GetNumberOfIds()):
          
          iid = pts_cell.GetId(ipt)                       # get node number of this point
          norm_vel_temp = normal_velocities[iid][i_time]  # get normal velocity of this node
          # add normal velocity contribution of this point to the cell velocity
          local_temp_flow = local_temp_flow + norm_vel_temp 
          
        # Complete the trapezoidal rule integration for this cell by multiplying the sum of velocites
        # by the local area and dividing by the number of vertices
        # Add the contribution of this cell to the curr_flow for the entire outlet face
        curr_flow = curr_flow + local_temp_flow*local_area/3.0
      
      # save flow information at the outlet face for the current timestep  
      temp_flow[i_time] = curr_flow

    # save flow information for all timesteps for the current outlet face
    output_collection.append(temp_flow)



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



