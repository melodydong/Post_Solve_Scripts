# Script to Convert 1D Solver .dat result files to vtk
#	Based off 1D Solver subroutine (c++): 
#	cvOneDBFSolver::postprocess_VTK_XML3D_MULTIPLEFILES
# Melody Dong 9/29/17

# #################
# Import Statements
# #################
import sys
import os
import numpy as np
import math
import csv
import argparse


# ########################################
# READ SINGLE MODEL FILE
# Converted from c++ in main.cpp to python
# Melody Dong 10/18/17
# ########################################
def readModelFile(inputFile):

	# Message
	print("\n");
	print("Reading file: %s ... \n",str(inputFile));

	# Declare input File
	with open(inputFile,'r') as inFile:
		# inFileTxt = csv.reader(inFile);

		lineCount = 1;
		reminder = 0;
		totSegments = 0;

		# Read Data from File
		inFileTxt = inFile.readlines();
		# print(inFileTxt[14]);

		inFile.close();

	# Initialize dictionaries to store Nodal Coordinates, joints, and segment info
	segInfo = {};
	nodeInfo = {};
	jointInfo = {};

	for line in inFileTxt:
		subLine = line.split(' ');
		if subLine[0] == 'NODE':
			# Node info dictionary => <nodeID> : [X, Y, Z]
			nodeInfo[int(subLine[1])] = [float(subLine[2]), float(subLine[3]), float(subLine[4])];

		elif subLine[0] == 'SEGMENT':
			# Seg info dictionary => <segName> : [<segID>, <segLen>, <FE>, <NodeIn>, <NodeOut>, <Ain>, <Aout>]
			segInfo[str(subLine[1])] = [int(subLine[2]), float(subLine[3]), int(subLine[4]), 
				int(subLine[5]), int(subLine[6]), float(subLine[7]), float(subLine[8])];

		elif subLine[0] == 'JOINTINLET':
			jointNum = int(subLine[3])

		elif subLine[0] == 'JOINTOUTLET':
			jointOut = []
			# numOutSeg = int(subLine[2])
			for outSeg in subLine[3:]:
				jointOut.append(int(outSeg))
			jointInfo[jointNum] = jointOut;

	return(segInfo, nodeInfo, jointInfo)
  




## ========================
##      MAIN FUNCTION
## ========================
if __name__ == "__main__":
	
	# get command line arguments
	parser = argparse.ArgumentParser(description = 'Convert Script from 1D .dat to vtk results files')
  	group1 = parser.add_mutually_exclusive_group(required=True)
  	group1.add_argument('-a', '--all', action='store_true', help='converts .dat to a single vtk result file')
  	group1.add_argument('-i', '--indiv', action='store_true', help='converts .dat to multiple vtk result files')
  	group2 = parser.add_mutually_exclusive_group(required=True)
 	group2.add_argument('-d', '--directory', action='store_true', help='provide directory of .dat files' )
  	group2.add_argument('-f', '--files', action='store_true', help='provide individual .dat files')
  	parser.add_argument('data', nargs='+', help='directory of .dat files (with -d) or individual files (with -f)')
  	parser.add_argument('inputFile', help='Input file for results')
  	args = parser.parse_args()  

  	# Collect all .dat results files
  	if args.directory:
  		filePaths = ['inletPath']

  		# check for correct number of arguments
  		if len(args.data) != 1:
  			sys.exit('\nExiting due to error: Only one directory can be provided')

		dirPath = args.data[0]
		# check if argument is a directory
		if not(os.path.isdir(dirPath)):
			sys.exit('\nExiting due to error:Must provide a directory when using -d flag')

		# record all files in directory 
		for filename in os.listdir(dirPath):
			# skip non .dat files 
			if not('.dat' in filename):
				continue

			# check if arguments are files
			filePath = dirPath + '/' + filename
			if not(os.path.isfile(filePath)):
				sys.exit('\nExiting due to error: Must provide a directory of files when using -d flag')

			# Don't include path to file when checking for match with inlet branch filename
			shortFilenames = filename.split('/')
			shortFilename = shortFilenames[-1]

			filePaths.append(filePath)

	# individual files provided
	else:
		filePaths = ['inletPath']

		# record all files
		for filename in args.data:
			# check if arguments are files
			if not(os.path.isfile(filename)):
				sys.exit('\nExiting due to error: Must provide a list of files when using -f flag.\nNote: this error could be caused by not specifying full path to files')

			# Don't include path to file when checking for match with inlet branch filename
			shortFilenames = filename.split('/')
			shortFilename = shortFilenames[-1]

			filePaths.append(filePath)

	# Input File
	# inFile = args.inputFile
	# with open(args.inputFile) as inFile:
	# 	reader = csv.reader(inFile)
	inputFile = args.inputFile
	readModelFile(inputFile);

	# Iterate through all files
	# geometries = []
	# for segmentFileName in filePaths:
	#     # Export to VTK File (if required)
	# 	postproc_VTK_XML3D_MULTIPLEFILES(segmentFilename,inputFile)

