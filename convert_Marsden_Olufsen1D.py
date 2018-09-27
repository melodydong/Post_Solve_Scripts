### SCRIPT TO CONVERT MARSDEN 1D SOLVER INPUT FILE TO OLUFSEN INPUT FILE ###
# Input: Marsden Lab 1D Solver's input file (.in file) - ***MODIFIED MARSDEN INPUT FILE
# Output: Olufsen Lab 1D Solver's input files
#	- Connectivity.txt (vessel index connectivity)
#	- Dimensions.txt (cm)
#	- Terminal_indx.txt (vessel indices)
#	- Windkessel_Parameters.txt (non-dimensionalized)
#	- Qdat.dat (inlet flow waveform - cc/s)

# Import Header
import os
import sys
import csv
from collections import defaultdict
from os import listdir
from os.path import isfile, join
from os import fdopen, remove
import numpy as np
from glob import glob

# Define Global Variables
nodeInfo = defaultdict(list) 		# { Node # : [X, Y, Z] }
jointNode = {} 						# {Seg # : Node #}
jointSeg = defaultdict(list) 		# {Inlet Seg # : [Outlet Seg #'s]}
segName = defaultdict(list) 		# {Vessel Name : [Seg #'s]'}
segNode = defaultdict(list) 		# {Seg # : [Node In, Node Out]}
segLength = {} 						# {Seg # : Seg Length}
segArea = defaultdict(list) 		# {Seg # : [Area In, Area Out]}
outletBC = defaultdict(list)		# {Outlet Seg #: [Rp C Rd]}
modelMM = False						# Model in cm or mm


def main():
	# USER-DEFINED VARIABLES
	pname = r'C:/Users/melody/Documents/Marsden_Research/OneDSolver_Project/Olufsen_1D/03Vessel_centralSU0201/' # path name to 1D input file	
	marsden_inputFile = pname + '03Vessel_centralSU0201.in' # Marsden input file
	modelMM = False

	# Record marsden input file's segment, connectivity, dimensions, boundary conditions
	segments(marsden_inputFile)
	joints(marsden_inputFile)
	bcs(marsden_inputFile)

	# Non-Dimensionalization Characteristic Parameters
	nonDim = True
	r_c = 1.0;			# Characteristic Radius
	Q_c = r_c*10.0; 	# Characteristic Flow
	rho = 1.06;			# Density (g/cm^3)
	g = 980;			# Gravitational Acceleration (cm/s^2)


	# Write Connectivity.txt
	connectivity_fname = pname + 'Connectivity_test.txt'
	f = open(connectivity_fname, "w")
	p_vessels = list(set(jointSeg))
	p_vessels.sort(key=int)
	for p_vessel in p_vessels:
		connectivity_line = p_vessel
		for d_vessel in jointSeg[p_vessel]:
			connectivity_line = connectivity_line + ' ' + d_vessel
		f.write(connectivity_line + '\n')
	f.close()

	# Write Dimensions.txt
	dimensions_fname = pname + 'Dimensions_test.txt'
	f = open(dimensions_fname, "w")
	vessels = list(set(segLength))
	vessels.sort(key=int)
	for vessel in vessels:
		radIn = np.sqrt(float(segArea[vessel][0])/np.pi)
		radOut = np.sqrt(float(segArea[vessel][1])/np.pi)
		dimensions_line = str(segLength[vessel]) + ' ' + str(radIn) + ' ' + str(radOut)
		f.write(dimensions_line + '\n')
	f.close()

	# Write Terminal_Indx.txt
	terminal_indx_fname = pname + "Terminal_indx_test.txt"
	f = open(terminal_indx_fname, "w")
	outlets = list(set(outletBC))
	terminal_indx_line = ""
	for outlet in outlets:
		if outlet != 'Qin':
			terminal_indx_line = terminal_indx_line + str(outlet) + ' '
	f.write(terminal_indx_line)
	f.close()

	# Write Windkessel_Parameters.txt
	windkessel_fname = pname + 'Windkessel_Parameters_test.txt'
	f = open(windkessel_fname, "w")
	for outlet in outlets:
		if outlet != 'Qin': # only outlet BC's
			# RCR BC
			if len(outletBC[outlet]) > 1:
				Rp = outletBC[outlet][0]
				C = outletBC[outlet][1]
				Rd = outletBC[outlet][2]
				if nonDim: # Non-dimensionalize Windkessel Parameters
					Rp = float(Rp)*Q_c/(rho*g*r_c)
					Rd = float(Rd)*Q_c/(rho*g*r_c)
					C = float(C)*(rho*g*r_c)/Q_c
				bc_line = str(Rp) + ' ' + str(Rd) + ' ' + str(C)
			
			# Resistance BC
			else:
				Rp = outletBC[outlet][0]
				if nonDim:
					Rp = float(Rp)*Q_c/(rho*g*r_c)
				bc_line = str(Rp)

			f.write(bc_line + '\n')

	







# Define Joint INFO
def joints(in_file):

	with open(in_file,'r') as inFile:
		for line in inFile:
			if line.find("JOINT ")>=0 and not(line.find("# ")>=0):
				temp_line1 = line.split() #Node info for joint
				line2 = next(inFile)
				temp_line2 = line2.split() #Inlet segment for joint
				line3 = next(inFile)
				temp_line3 = line3.split() #Outlet segments for joint

				jointNode[temp_line2[3]] = temp_line1[2] # {Seg # : Joint Node}
				jointSeg[temp_line2[3]] = temp_line3[3:len(temp_line3)+1] # {Inlet Seg # : Outlet Seg #}

	return jointNode, jointSeg


# Define Segment INFO
def segments(in_file):

	with open(in_file,'r') as inFile:
		for line in inFile:
			if line.find("SEGMENT ")>=0 and not(line.find("# ")>=0):
				temp_line = line.split() # segment info

				name = temp_line[1]
				name = name.split('_')
				ves_name = name[0]
				for n in name[1:-1]:
					ves_name = ves_name + "_" + n

				segName[ves_name].append(temp_line[2]) # {Seg Name : Seg #}
				segNode[temp_line[2]] = temp_line[5:7] # {Seg # : [Node In, Node Out]}
				segLength[temp_line[2]] = temp_line[3] # {Seg # : Seg Length}
				segArea[temp_line[2]] = temp_line[7:9] # {Seg # : [Area In, Area Out]}

				if modelMM:
					segNode[temp_line[2]] = temp_line[5:7] # {Seg # : [Node In, Node Out]}
					segLength[temp_line[2]] = str(float(temp_line[3])/10.) # {Seg # : Seg Length}
					segArea[temp_line[2]] = [str(float(temp_line[7])/100.), str(float(temp_line[8])/100.)] # {Seg # : [Area In, Area Out]}

	return segName, segNode, segLength, segArea


# Define inlet and outlet boundary conditions INFO
def bcs(in_file):
	bc_tables = []

	with open(in_file,'r') as inFile:
		for line in inFile:
			if line.find("SEGMENT ")>=0 and not(line.find("# ")>=0):
				temp_line = line.split() # segment info

				if temp_line[-1] != 'NONE':
					bc_tables.append([temp_line[2], temp_line[-1], temp_line[-2]])

			if line.find("SOLVEROPTIONS ")>=0 and not(line.find("# ")>=0):
				temp_line = line.split() # solver options info
				bc_tables.append(["Qin", temp_line[5], 'FLOW'])

	datatables = []
	with open(in_file,'r') as inFile:
		for line in inFile:
			if line.find("DATATABLE ")>=0 and not(line.find("# ")>=0):
				temp_line = line.split()
				datatables.append([temp_line[1]])

				temp_nxtline = next(inFile)
				while not("ENDDATATABLE" in temp_nxtline):
					temp_nxtline = temp_nxtline.split()
					datatables[-1].append(temp_nxtline)
					temp_nxtline = next(inFile)

	for j in bc_tables:
		for table in datatables:
			if table[0] in j[1]:
				# print(table)
				# print(j)
				if j[2] == 'RCR':
					outletBC[j[0]] = [float(table[1][1]), float(table[2][1]), float(table[2][1])]
				elif j[2] == 'RESISTANCE':
					outletBC[j[0]] = [float(table[1][1])]
				elif j[2] == 'FLOW':
					outletBC[j[0]] = [table[1:]]

	return




main()