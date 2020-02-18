%Driving FUNCTION 
%Runs get_Isodose_Levels.m and DoseROI.m
%Puts a ROI folder in each corresponding patient folder. 
%copy folder to a preprocess folder that contains ROI of patient of
%interest. 
%NEED folder named 'Patient_Data'!!!!
%Creates folder called 'Preprocess'
% Gets the RTPLAN for all patients 

cd /Users/anthonysong/Desktop/U_of_M_Rad_Onc/Workspace_Extract/Reprocess; 
 %Change to file directory pathway 


file_directory = pwd ;  %Location of Patient Data

patient_files = dir(fullfile('*mm')); %all of the patient files
num_patient = length(patient_files); %number of patient files

%loops through every patient file and extracts all of the .dcm files. 

cd ../ ; 
%change directory back to workplace extract to run function. 

mkdir reprocess_2 % make preprocess folder. 
preprocess_location = strcat(pwd,'/reprocess_2') ; % Pathway of preprocess folder.


for j = 3:num_patient
    
    folder_name = patient_files(j).name ;
    
    
    [DICOMfolder,isodoseLevels] = get_Isodose_Levels(file_directory, folder_name);
    
    [ROIFolder] = DoseROI(isodoseLevels,DICOMfolder);
    
end
  parts = split(folder_name, '_'); % splits name by delimiter
  patient_id = parts{1}; % gets patient id number 
  patient_id = strcat(patient_id,'_','ROIs'); % creates patient ID name

  cd ../../Preprocess % move from patient folder to preprocess folder
  mkdir([patient_id]); %create folder with Patient ID in preprocess folder
  temp_path = strcat('../Patient_Data/' , folder_name);
  cd (temp_path)% goes back to patient folder 
  path = strcat('../../', 'Preprocess', '/', patient_id); %create path to new_ROIfolder
  copyfile('ROIs' , path); % copy file to preprocess ROI folder 
  cd ../../ %back to directory with all functions and folders. 
  
end

