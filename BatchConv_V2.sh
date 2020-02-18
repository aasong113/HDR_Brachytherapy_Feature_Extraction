#!/bin/bash

#8/6/19 Kellen Mulford
#This is a script to batch convert dicoms to .nii.
#To run this script, change the patient ID list to whatever you need and the directory variable to where your patient data files are stored. 
#EX /path/to/data/FolderwithDoseVolumeAndROIS
#Will work no matter how many ROIs files are in the patients folder.


#shopt -s nullglob

patientID='086_ROIs 088_ROIs 090_ROIs'
directoryPath='/Users/anthonysong/Desktop/U_of_M_Rad_Onc/Workspace_Extract/reprocess_1'

## Only loop pateintIDs in DirectoryPath


echo "Processing DCM files in $directoryPath\n"

for name in $patientID
do

  echo "Running PatientID: ${directoryPath}/${name}------\n"
  c=0  
  for dcms in ${directoryPath}/${name}/*.dcm
  do

    c=$((c+1))
    echo ""
    echo "$c:$dcms---\n"
    dcm2niix -s "y" -z "y" -f "%b" $dcms
    echo ""
   
  done
  echo "Number of dcm files:$c ------\n"

done

echo "All done"
