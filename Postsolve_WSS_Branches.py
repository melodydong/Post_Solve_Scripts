# --- VTK-PYTHON SCRIPT FOR READING VTP, INTEGRATING VARIABLES OF INTEREST USING TRAPEZOIDAL RULE
# --- CALCULATES MAX/MIN/MEAN WSS AT ALL TIMES AT EACH INDIVIDUAL MODEL BRANCH
# --- ALSO CALCULATES AREA OF LOW WSS AT ALL TIMES AT EACH INDIVIDUAL MODEL BRANCH
# --- NOTE: TO BE RUN FROM DIRECTORY CONTAINING all_results.vtp FILE AND mesh-complete/ DIRECTORY
# --- NOTE: THIS SCRIPT ASSUMES A TRIANGULAR SURFACE MESH
# --- BASED ON A SCRIPT BY AEKAANSH VERMA
# --- UPDATED 8/4/17 BY CASEY FLEETER

#---------------------------------------------------------------------#
#   RUN THIS SCRIPT FROM THE SAME DIRECTORY AS all_results.vtp        #
#   SCRIPT GENERATES all_results_wss_branches.dat                     #
#---------------------------------------------------------------------#

import sys
import os
import vtk
import numpy as np


#------------------------------------------------------------#
#   CHANGE THE START AND END TIMES AND TIME STEP INCREMENT   #
#------------------------------------------------------------#
# SPECIFIY TIME POINTS TO DETERMINE WSS, ALONG WITH INCREMENT IN RESTART FILES
START_TIME = 160
END_TIME = 240
INCREMENT = 10

#---------------------------------------------------------------------#
#   CHANGE THE NAMES OF THE WALL FILES FROM THE MESH-COMPLETE FOLDER  #
#---------------------------------------------------------------------#
# NAMES OF WALL GEOMETRY FILES OF MODEL, WIHTOUT WALL_ PREFIX
input_filenames = ['celiac_trunk', 'celiac_branch', 'superior_mesentaric', \
                   'renal_right', 'renal_left', 'right_internal_iliac', \
                   'left_internal_iliac', 'right_iliac', 'aorta']


#---------------------------------------------------------------------#
#   CHANGE THE THRESHHOLD VALUES FOR AREAS OF LOW WSS.                #
#   CAN HAVE >= 0 THRESHHOLD VALUES                                   #
#---------------------------------------------------------------------#
# LOW WSS THRESHHOLD VALUES
thresholds = [0.001, 0.01, 0.1, 0.5, 1.0, 10.0]


#---------------------------------------------------------------------#
#   CHANGE THE ZERO THRESHHOLD TO AVOID MIN WSS = 0.0                 #
#---------------------------------------------------------------------#
# THRESHOLD FOR WSS (to avoid min = 0.0 for all)
zero_wss_th = 0.0001


# PATH OF OUTPUT FILE FOR RESULTS
output_filename = 'all_results_wss_branches.dat'
output_collection = []

if __name__ == "__main__":

  for file in input_filenames:

    # Load in the mesh file for the branch you want WSS at. This can be found in the mesh-surfaces folder
    command_string = 'cd mesh-complete/mesh-surfaces'
    print(command_string)
    os.chdir('mesh-complete/mesh-surfaces')

    # Read geometry (mesh) information from this wall
    branch_reader = vtk.vtkXMLPolyDataReader()          # Create vtk instance
    branch_reader.SetFileName('wall_' + file + '.vtp')   # Open file
    branch_reader.Update()
    branch_model = vtk.vtkPolyData()
    branch_model = branch_reader.GetOutput()            # Read file into new variable for manipulation
    numPts = branch_model.GetNumberOfPoints()           # Determine number of points in the mesh at this outlet
    branch_IDs = branch_model.GetPointData().GetArray("GlobalNodeID")  # Extract node IDs to match with full model solution
    
    

    # Load in the WSS information from the vtp file
    command_string = 'cd ../../'
    print(command_string)
    os.chdir('../../')
    
    # First, read in the .vtp file containing your quantities of interest
    all_results_reader = vtk.vtkXMLPolyDataReader()             # Create vtk instance
    all_results_reader.SetFileName('all_results.vtp')           # Open file
    all_results_reader.Update()
    all_results_model = vtk.vtkPolyData() 
    all_results_model = all_results_reader.GetOutput()          # Read file into new variable for manipulation
    all_results_numPts = all_results_model.GetNumberOfPoints()  # Determine number of points in the mesh of the entire model
    all_results_IDs = all_results_model.GetPointData().GetArray('GlobalNodeID')   # Extract node IDs of full model solution
    all_results_numCells = all_results_model.GetNumberOfCells()
    


    # Find the nodes on all_results that correspond to the branch of interest
    branch_nodes = []
    # iterate through nodes in outlet
    for i_node in xrange(0, numPts):
      this_ID = branch_IDs.GetTuple1(i_node)

      # iterate through all nodes in model
      for i_full in xrange(0, all_results_numPts):
        full_ID = all_results_IDs.GetTuple1(i_full)

        if(full_ID == this_ID):
          branch_nodes.append(i_full)
          break
          
    # Just to make sure we found all the outlet nodes in all_results
    assert(len(branch_nodes) == numPts)

    # Create a Python list to hold the WSS arrays from the all_results.vtp
    wss_vectors = []
    # keep track of how many timesteps in solution
    timestep_count = 0
    for i_array in xrange(START_TIME, END_TIME+INCREMENT, INCREMENT):
      wss_vectors.append(vtk.vtkDoubleArray())

      if i_array < 10:
        wss_vectors[timestep_count] = all_results_model.GetPointData().GetArray('vWSS_' + '0000' + str(i_array))
      elif i_array < 100:
        wss_vectors[timestep_count] = all_results_model.GetPointData().GetArray('vWSS_' + '000' + str(i_array))
      elif i_array < 1000:
        wss_vectors[timestep_count] = all_results_model.GetPointData().GetArray('vWSS_' + '00' + str(i_array))
      elif i_array < 10000:
        wss_vectors[timestep_count] = all_results_model.GetPointData().GetArray('vWSS_' + '0' + str(i_array))
      else:
        wss_vectors[timestep_count] = all_results_model.GetPointData().GetArray('vWSS_' + str(i_array))
      
      timestep_count = timestep_count + 1


    # Integrate WSS over the surface of the branch to get the mean WSS on this branch at each timestep
    temp_wss = np.zeros((timestep_count,1))

    # Also keep track of max and min WSS on the branch at each timestep
    temp_max_wss = np.empty(timestep_count)
    temp_max_wss.fill(-sys.maxint)
    temp_min_wss = np.empty(timestep_count)
    temp_min_wss.fill(sys.maxint)

    # Also keep track of areas of regions of low WSS on the branch at each timestep
    temp_low_wss_area = np.zeros((timestep_count,len(thresholds)))

    for i_time in xrange(0,timestep_count):

        # Compute the integral using trapezoidal rule
        total_area = 0.0
        # store WSS information for the entire branch at this time step
        curr_wss = 0.0
        
        # iterate over all mesh cells on branch wall
        for i_cell in xrange(0,branch_model.GetNumberOfCells()):
          
          # extract information about cell vertices
          temp_cell = all_results_model.GetCell(i_cell)
          pts_cell = temp_cell.GetPointIds()
          cell_pts = temp_cell.GetPoints()
          p0 = cell_pts.GetPoint(0)
          p1 = cell_pts.GetPoint(1)
          p2 = cell_pts.GetPoint(2)

          # compute area of mesh cell (triangular mesh assumed)
          local_area = vtk.vtkTriangle().TriangleArea(p0,p1,p2)
          total_area = total_area + local_area
          
          local_temp_wss = 0.0
          flag_wss = np.zeros(len(thresholds))

          # add contributions from each vertex of cell
          for ipt in xrange(0, pts_cell.GetNumberOfIds()):
            
            iid = pts_cell.GetId(ipt)   # get node number of this point
            # get WSS magnitude at this point
            temp_wss_vec = wss_vectors[i_time]
            x_wss = temp_wss_vec.GetTuple3(iid)[0]
            y_wss = temp_wss_vec.GetTuple3(iid)[1]
            z_wss = temp_wss_vec.GetTuple3(iid)[2]
            temp_wss_mag = np.sqrt(x_wss**2 + y_wss**2 + z_wss**2)

            # check for region of low WSS
            flag_wss = flag_wss + [temp_wss_mag > th for th in thresholds]
            
            # add WSS contribution of this point to the total cell WSS
            local_temp_wss = local_temp_wss + temp_wss_mag
              
          # To complete the trapezoidal rule integration, multiply each summed quantity
          # by the area of the cell, then divide by the number of vertices
          # Complete the trapezoidal rule integration for this cell by multiplying the sum of
          # the WSS by the local area and dividing by the number of vertices
          # Add the contribution of this cell to the curr_wss for the entire branch wall
          curr_wss = curr_wss + local_temp_wss*local_area/3.0

          # update min_wss and max_wss values for this branch at this timestep
          if local_temp_wss < temp_min_wss[i_time]:
            if local_temp_wss > zero_wss_th:
              temp_min_wss[i_time] = local_temp_wss
          if local_temp_wss > temp_max_wss[i_time]:
            temp_max_wss[i_time] = local_temp_wss

          # update area of low WSS regions for this branch at this timestep
          for i_th in xrange(0,len(thresholds)):
            if flag_wss[i_th] == 0:
              temp_low_wss_area[i_time][i_th] = temp_low_wss_area[i_time][i_th] + local_area
        
        # save WSS information at the branch wall (with WSS normalized by the total area 
        # of the branch wall) for the current timestep
        temp_wss[i_time] = float(curr_wss / total_area)

        # precentage of area of low WSS for the current timestep
        temp_low_wss_area[i_time] = [th / total_area for th in temp_low_wss_area[i_time]]

    # save WSS information for all timesteps for the current outlet face
    output_collection.append([temp_wss, temp_min_wss, temp_max_wss, temp_low_wss_area])


  
  # Now that we have looped over all our .vtp files of interest and integrated
  # the variables, it is time to save them to the output file. 
  outfile = open(output_filename, 'w')

  # First print a header that tells what each integrated quantity of interest is
  out_string = 'Time Step '
  for i_file in xrange(0, len(input_filenames)):
    out_string = out_string + input_filenames[i_file] + '_meanWSS ' + \
                 input_filenames[i_file] + '_minWSS ' + \
                 input_filenames[i_file] + '_maxWSS '
    for i_th in xrange(0,len(thresholds)):
      out_string = out_string + input_filenames[i_file] + '_lowWSS_th=' + str(thresholds[i_th]) + ' '
  out_string = out_string + '\n'
  outfile.write(out_string)

  # Now print the data for each quantity of interest at each time step
  for i_time in xrange(0, timestep_count):

    # Print time step
    out_string = str(i_time)

    # Print each quantity of interest at that timestep
    for i_file in xrange(0,len(input_filenames)):
      out_string = out_string + ' ' + str(output_collection[i_file][0][i_time][0]) \
                   + ' ' + str(output_collection[i_file][1][i_time]) \
                   + ' ' + str(output_collection[i_file][2][i_time])
      for i_th in xrange(0,len(thresholds)):
        out_string = out_string + ' ' + str(output_collection[i_file][3][i_time][i_th])
    out_string = out_string + '\n'
    outfile.write(out_string)

  outfile.close()
