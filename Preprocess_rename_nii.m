
file_directory = pwd; %set pathway. This is the Parent folder!
mkdir Preprocess_nii %create a preprocess for only .nii.gz

cd Preprocess_Converted ;
patient_preprocess = dir(fullfile('*ROIs'));
num_preprocess = length(patient_preprocess); 

preprocess_nii_path = strcat(file_directory,'/','Preprocess_nii');
preprocess_converted_path = strcat(file_directory,'/','Preprocess_Converted');
% at preprocess converted folder


%start for loop
for i=1:num_preprocess

folder_name = patient_preprocess(i).name;
folder_name_nii = folder_name; 
folder_name_nii = split(folder_name_nii,'_');
folder_name_nii = char(folder_name_nii(1,1));

cd(preprocess_nii_path);
mkdir(folder_name_nii); %make folder name for patient. 

cd(preprocess_converted_path);
copy_path_nii = strcat('../Preprocess_nii/', folder_name_nii);
copyfile(folder_name, copy_path_nii); % copy converted folder to nii folder 

cd(preprocess_nii_path );
cd(folder_name_nii);
delete '*.dcm' ; % delete with extension .dcm
delete '*.json' ; % delete with .json

temp_struct = dir('*nii.gz'); % create structure with all files 

%rename volume of interest
temp_var = temp_struct(1);
temp_var = struct2cell(temp_var);
temp_var = split(temp_var(1,1),'_');
temp_var =char(temp_var(1,1));
vol_name = strcat(temp_var,'.nii.gz');
movefile(temp_struct(1).name, vol_name);

% renames all files to .seg.nii.gz
for j=2:length(temp_struct)
  [~, file_name] = fileparts(temp_struct(j).name); %delete extension and turn to cell
  file_parts = split(file_name,'.dcm'); %split by '.'
  new_name = strcat(file_parts(1,1),'.seg.nii.gz'); %string new name
  new_name = char(new_name); %cell to characters 
  movefile(temp_struct(j).name, new_name); %rename to newname 
end

end

  
