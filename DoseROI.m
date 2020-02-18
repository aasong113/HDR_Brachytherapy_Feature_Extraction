%This is a function to calculate ROI based on isodose levels for RTDose
%files created during brachytherapy treatment planning

%Kellen Mulford | July 2019 | University of Minnesota


function ROIFolder = DoseROI(isodoseLevels,DICOMfolder)

DICOMFiles = dir([DICOMfolder '/*.dcm*']); %Finds all DICOM files directory
FolderLength = length(DICOMFiles); %Calculates length of folder for for loop
count = 1;
Doses = []; 

%This first for loop creates a structure Doses, which is all the dose
%volumes found in the DICOM folder. This also saves the info from the
%header for use in writing the ROI dicoms
for k = 1 : FolderLength
    baseFileName = DICOMFiles(k).name; %Picks the k-th file from folder
    fullFileName = fullfile(DICOMfolder, baseFileName); %adds path name
    info = dicominfo(fullFileName);
    if strncmpi(info.Modality, 'RTDOSE',8) %Only finds RTDOSE files
        Dose = dicomread(fullFileName);
        Dose = squeeze(Dose); %Removes extra color dimension
        if size(Dose,1) > 0 %If RTDose file is empty, don't add to Doses
            Doses(:,:,:,count) = Dose; 
            DoseFileNames(count) = string(baseFileName);
            count = count + 1;
        end

    end
end

%If no non-zero RTdose files are found, count will remain at 1
if count == 1
    fprintf('\nNo RTDose files in this folder\n')
    ROIFolder = strcat(DICOMfolder,'/ROIs');
    return
end

%The next part of the script checks if Doses are 0-volumes or duplicates

NumDoses = [1:count-1];
fprintf('%d Dose files found\n',count-1)
fprintf('\nNow checking for 0-plans and merging equivalent plans\n')

if size(NumDoses,2) > 1
    [Doses,DoseFileNames] = CheckAndDeleteDuplicates(Doses,DoseFileNames);
end


%The next set of loops deletes RTDOSE files that are 0-matrices

place = [];
for xx = 1:size(Doses,4)
    if mean(mean(mean(Doses(:,:,:,xx)))) == 0
        place = [place xx];
    end
end
for ii = 1:size(place,1)
    fprintf('Dose Plan number %d is a Zero-volume -- Deleting\n\n',place)
    Doses(:,:,:,ii) = [];
    DoseFileNames(ii) = [];
end


%Finally with the cleaned up ROI dose and name information we create a new
%directory to move our ROIs and Dose volumes into

ROIFolder = strcat(DICOMfolder,'/ROIs');
mkdir(ROIFolder);

%Copy in our dose volumes
for zz=1:size(Doses,4)
    copyfile(strcat(DICOMfolder,'/',DoseFileNames(zz)),ROIFolder);
end

%Write our Dose ROIs into new DICOMs which have the same headers as the
%dose volumes

cd(ROIFolder);
DoseROIs = zeros(size(Doses));
for x=1:size(Doses,4)
    info = dicominfo(DoseFileNames(x));
    Name = DoseFileNames(x);
    for yy=1:size(isodoseLevels,2) %dim may need to be 2        
        DoseROIs(:,:,:,x) = Doses(:,:,:,x) > isodoseLevels(1,yy);
        X = DoseROIs(:,:,:,x);
        X = reshape(X,[size(X,1) size(X,2) 1 size(X,3)]);
        IDL = sprintf('%d',isodoseLevels(1,yy));
        dicomwrite(X,strcat(IDL,'_ROI_',Name),info, 'CreateMode','Copy');
    end
end

cd ../

end
