Driver.m%Gets isodose levels at 12 different isodose percentages of a given
%prescription dose. Also outputs folder pathway. 
% Anthony Song - August 5th, 2019. 

function [DICOMfolder,isodoseLevels] = get_Isodose_Levels(file_directory,folder_name)
% need file_directory to all patient files 
% need fold_name = specific patient folder 
%(e.g. below)
%file_directory = '/Users/anthonysong/Desktop/U_of_M_Rad_Onc/Workspace_Extract/Patient_Data/' ;
%folder_name = '078_3.0_4.0_600_0mm' ;

    DICOMfolder = [file_directory,'/', folder_name]; % adhere to Kellen's code (DoseROI)

    %get all filenames
    dir_data=dir(fullfile(file_directory,folder_name, '*dcm'));
    num_dicoms=length(dir_data);

    for i = 1:num_dicoms
        temp_folder = dir_data(i).folder;
        temp_name   = dir_data(i).name; 
        all_filenames{i}=fullfile(temp_folder, temp_name);
    end
    all_filenames = all_filenames'; % all file names 

    % ONLY Get RTPLAN and save RTPLAN DICOM structure
    num_files = length(all_filenames); % Number of files in Patient Data
    num_RTPLAN=0;
    for i=1:num_files %for all files in patient file
        dcm_plan = dicominfo(all_filenames{i}); 
        if strcmp(dcm_plan.Modality, 'RTPLAN')
            num_RTPLAN=num_RTPLAN+1;
            RTPLAN_files{num_RTPLAN}=all_filenames{i};
            RTPLAN_structs{num_RTPLAN}=dcm_plan;
            fprintf('Modality:%s \n',dcm_plan.Modality);
        end
    end
    RTPLAN_files = RTPLAN_files' ; % transpose
    
    % get dose from RTPLAN file names
   % DOSE_from_name = split(RTPLAN_files,"_"); % split file name by delimiter
   % DOSE_from_name = DOSE_from_name(:,end-1); % get second to last delimiter column 
    %which is always the dose value with the current naming convention 
    
  
    
    %Turns all the cells arrays into structure so dose functions can work.
    %you allready  call dicominf before, just use the part on section, and
    %save struct. 
    % OK to call here, just make this function short.
    
    %num_PLANS = length(RTPLAN_files); % number of all plans
    %for k = 1:num_PLANS
    %    dcm_plan = RTPLAN_files(k,1);
    %    [PLAN_struct] = cellfun(@dicominfo,dcm_plan) ; 
    %    %applies dicominfo to cell array to get structure. 
    %    all_struct{k} = PLAN_struct ; % string together all structures
    %end  
    %all_struct = all_struct' ;

%Get average dose value for all plans     
% 
    num_PLANS = length(RTPLAN_files); % number of all plans
    all_DOSE={};
    
    for k = 1:num_PLANS 
       
  %      dcm_plan = all_struct{k,1} ;
        dcm_plan=RTPLAN_structs{k};
        dose_pt_data = dcm_plan.DoseReferenceSequence;
        field_names = fieldnames(dose_pt_data); 
        num_rx_points  = length(field_names); % Number of items in Dose Reference Sequence
        for i=1:num_rx_points
            %For Tandem and Ring plans, the order of the points is: B, A, T, Taper,
            %VSD
            dose_value(i,1)   = dose_pt_data.(field_names{i}).TargetPrescriptionDose;
        end

        %Format of dose_pt_data is for each row is: (x,y,z,dose value)

        Avg_dose_value = mean(dose_value); %Output average dose value
        Avg_dose_value = Avg_dose_value .* 100; %Avg dose value in Centi-Gy. 

        % not use "/" to spli here as the data maybe from Windows computer
        % and use "\" in the file path
        
        
        %Filename = dcm_plan.Filename ;
        %Filename = split(Filename,"/");
        %Filename = Filename(9,1);
        
        [tmp_path, tmp_filename, ext]=fileparts(dcm_plan.Filename);
        Filename=strcat(tmp_filename, ext);
        
        tmp_array = split(Filename,"_");
        DOSE_from_name = tmp_array(end-1);
        
    
        % Dose = [Filename, Avg_dose_value];
        Dose = [Filename, string(Avg_dose_value), string(DOSE_from_name)];
        all_DOSE{k,1} = Dose; % all dose files 
    end
    
  
    all_DOSE = vertcat(all_DOSE{:}); % unpack data
    
   
    for k = 1:num_PLANS
        % val = round(all_DOSE{k,2}) - eval(all_DOSE{k,3});
         
        % add this col right away
        all_DOSE(k,4)= round(str2num(all_DOSE(k,2))) - str2num(all_DOSE(k,3));
         % rounded avg. dose value - dose value from name 
         %  difference{k} = val ; % should be equal to zero.
         
         % add this column right away
     
    end
    
  %  difference = difference' ; %transpose to single column 
  %  all_DOSE = [all_DOSE, difference]; %KEY for all_DOSE below 
%col 1 = file name , col 2 = avg. dose from pt. col. 3 =  dose from name 
%col 4 = difference between rounded avg. dose and dose from name.

    
    %Test to see if the difference of all the values is zero. 
    test = all_DOSE(:,4)% isolate column four of all_DOSE
          % take the absolute value. 
    test = cell2mat(test); % change to matrix format
    sum_test = sum(str2num(test)); % sum of all matrix elements 

    %if test = 0 then display the dose value from the name of the file
    % otherwise, set to be 0
    
    if sum_test == 0 
        DOSE_single = str2num(all_DOSE(1,2));
    %if test =/= 0 then need to check where the error is. 
    else
        % DOSE_single = ['all_DOSE error'];
         DOSE_single=0;   
    end
  
% isodose level cell array 1x12

    DOSE_single = round(DOSE_single); % Round the dose to integer. 
    iso_400=4.00;
    iso_300=3.00;
    iso_200=2.00;
    iso_150=1.50;
    iso_120=1.20;
    iso_110=1.10;
    iso_105=1.05;
    iso_100=1.00;
    iso_90=0.90;
    iso_85=0.85;
    iso_80=0.80;
    iso_50=0.50;
    isodoseLevels_factors=[iso_400, iso_300, iso_200, iso_150, iso_120, iso_110, iso_105, iso_100, iso_90, iso_85, iso_80, iso_50];
    isodoseLevels= DOSE_single * isodoseLevels_factors;
 
end







   
   
   

