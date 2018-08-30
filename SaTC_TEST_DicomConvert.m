function [] = SaTC_TEST_DicomConvert()

%Adapted from the Shop task (Sangsuk), with was adapted from USPS project.
%Looks like originally written by Khoi Vo around 2015.
%Adapted by C.Reeck May 2017 for SaTC 3 project. This script is used ONLY
%for reconstructing the scans testing the different EPI sequences. 
%Assumes 6 disdaqs. 
%NOTE: Must be run with spm and mricron installed. 

cwd = pwd;

%mainDir = '~/Dropbox/Experiments/SaTCPrivacyGrant/SaTC3/fMRIAnalyses/TEST/Scans/'; %Crystal's laptop set up. 
mainDir = '/Users/CNDM/Documents/SaTC3_withPractice/Raw_Scans'; %CNDM
%Laptop Setup. 
%outputdir = '~/Dropbox/Experiments/SaTCPrivacyGrant/SaTC3/fMRIAnalyses/TEST/ReconScans/'; %Where should images be output? Setup for Crystal's laptop
outputdir = '/Users/CNDM/Documents/SaTC3_withPractice/ReconScans'; %Where should images be output? Setup for Crystal's laptop

%Can instead use GUI:
%mainDir = uigetdir(pwd,'Choose source directory for all subjects in batch named "Raw Dicoms"    ');
%outputdir = uigetdir(pwd,'Choose output directory named "Preprocessed"');

%Removes .DS_Store files, which are hidden and sometimes accidentally added
try
    dstore = get_any_files('.DS_Store',mainDir);
    for i = 1:length(dstore)
        delete(dstore{i});
    end
catch
end

matlabmainpath = userpath; %Where matlab is stored on analysis machine. 
%Patch to MRICron on analysis machine
%If MRICron path is not recognized, Matlab will request user input
%Crystal laptop:
%mricrondname='"/Volumes/Macintosh HD/Applications/mricron2015"'; %Parentheses needed due to space. 
%CNDM set up
mricrondname = ('/Users/CNDM/Documents/MATLAB/CNDMToolbox/MRICron');

%Get list of all folders containing dicoms (one per subject)
dirData = dir(mainDir);     
dirIndex = [dirData.isdir];  
subDirs = {dirData(dirIndex).name};  
validIndex = ~ismember(subDirs,{'.','..'});
batchList = {dirData(validIndex).name};

%Creating selection List
for index = 1:length(batchList)
    selectionOptions(index,1) = {batchList{index}};
end

subject_selection = listdlg('ListString',selectionOptions,...
    'SelectionMode','multiple',...
    'PromptString','Choose subjects to preprocess');

temp = batchList; clear batchList
batchList = temp(subject_selection);

%ALWAYS RUN WITH CONVERSION ONLY!!!
preprocChoice = questdlg('What do you want to do?',...
    'Preprocessing option',...
    'Convert DICOM ONLY','Preprocess ONLY','Convert & Preprocess','Convert & Preprocess');

for i = 1:size(batchList,2)
    subjectID = batchList{i};
    sourcename = fullfile(mainDir,batchList{i});
    try
        switch preprocChoice
            case 'Convert DICOM ONLY'
                display(sprintf('Converting DICOM for subject: %s',subjectID));
                
                dicom_convert(sourcename, subjectID,outputdir,mricrondname);
            case 'Preprocess ONLY'
                display(sprintf('Preprocessing for subject: %s',subjectID));
                
                SHOP_Preprocessing(fullfile(outputdir,strcat(subjectID,'_3D'),strcat(subjectID,'_inputs.mat'))); 
            otherwise
                display(sprintf('Converting DICOM & Preprocessing for subject: %s',subjectID));
                
                dicom_convert(sourcename, subjectID,outputdir,mricrondname);
                SHOP_Preprocessing(fullfile(outputdir,strcat(subjectID,'_3D'),strcat(subjectID,'_inputs.mat'))); 
        end                
        display(sprintf('Procedure successful for: %s',subjectID));
    catch ME %#ok<*NASGU>
        display(sprintf('Procedure failed for: %s',subjectID));
    end
end


function [] = dicom_convert(sourcename, subjectID,outputdir,mricrondname)

%-------------------------------------------------------------------------%
%   creates user input dialog for key parameters
%-------------------------------------------------------------------------%    
inputs.subjectID = subjectID;

inputs.cfgfile = 1; % change to 2 for 4D images
    if inputs.cfgfile == 2
        cfgfile = '4D.ini';
    else cfgfile = '3D.ini';
    end
    
subjectID = strcat(subjectID,'_',cfgfile(1:end-4));
inputs.dicomdir = sourcename;
inputs.niftidir = fullfile(outputdir,subjectID);

tic;
try
    %-------------------------------------------------------------------------%
    %   anon & converting dicoms --> nifti
    %-------------------------------------------------------------------------%
    
    display('Anonymizing & converting DICOM files');
    
    %Create output folder
    if exist(fullfile(outputdir,subjectID),'dir')==0
        mkdir(fullfile(outputdir,subjectID));
    end
    
    %Calling dcm2nii (works on both PC and unix-based systems)
    if ispc
        anoncmd = ['"' mricrondname '\dcm2nii" -a y -b "' mricrondname '\' cfgfile '" -o "' ...
            fullfile(outputdir,['/' subjectID '"']) ' "' sourcename '"'];
        system(anoncmd);
    else
        anoncmd = [mricrondname '/dcm2nii -a y -b ' mricrondname '/' cfgfile ' -o ''' fullfile(outputdir,subjectID) ''' ''' sourcename ''''];
        unix(anoncmd);
    end
    
    %-------------------------------------------------------------------------%
    %   Read a number of dicom headers to obtain information on series and
    %   series name for folder creation purposes
    %-------------------------------------------------------------------------%
    display('Moving anonymized & converted NIFTI files');
    
    dicomList = get_dicoms(sourcename);
    
    % Is there a DICOMDIR that was imported as well?
    temp = dicomList{1,1};
    if strcmp(temp(size(temp,2)-7:end),'DICOMDIR')
        dicomList = dicomList(2:end,1);
    end
    
    index = 1:3:size(dicomList,1); %sample every 3rd dicom for header information
    
    %key step in this process - if the headers are incomplete, then this
    %step will fail
    images = char(dicomList(index,1));
    try
        for i = 1:size(images,1)
            hdrs{1,i} = dicominfo(images(i,:)); %this function is included in image processing toolbox for Matlab
        end
    catch
        hdrs = spm_dicom_headers(images);
    end
    
    for i = 1:size(hdrs,2)
        seriesNum(i,1) = hdrs{1,i}.SeriesNumber;
        seriesName{i,1} = hdrs{1,i}.SeriesDescription;
        if seriesNum(i,1) < 10
            num_name{i,1} = lower(strcat('0',num2str(seriesNum(i,1)),'_',seriesName{i,1}));
        else
            num_name{i,1} = lower(strcat(num2str(seriesNum(i,1)),'_',seriesName{i,1}));
        end
    end
    
    folders = unique(num_name);
    
    inputs.series = folders;
    inputs.moco_index = zeros(size(folders,1),1);
    inputs.nonmoco_index = zeros(size(folders,1),1);
    
    for i = 1:size(folders,1)
        if strfind(folders{i,1},'t1')
            if exist(fullfile(outputdir,subjectID,'T1'),'dir')==0
                mkdir(fullfile(outputdir,subjectID,'T1'));
            end
            movefile(fullfile(outputdir,subjectID,sprintf('s0%s*.nii',folders{i}(1:2))),...
                fullfile(outputdir,subjectID,'t1'));
            T1 = dir(fullfile(outputdir,subjectID,'T1','*.nii'));
            inputs.T1 = char(fullfile(outputdir,subjectID,'T1',{T1.name}));
        end
        if strfind(folders{i,1},'t2')
            if exist(fullfile(outputdir,subjectID,'T2'),'dir')==0
                mkdir(fullfile(outputdir,subjectID,'T2'));
            end
            movefile(fullfile(outputdir,subjectID,sprintf('s0%s*.nii',folders{i}(1:2))),...
                fullfile(outputdir,subjectID,'t2'));
            T2 = dir(fullfile(outputdir,subjectID,'T2','*.nii'));
            inputs.T2 = char(fullfile(outputdir,subjectID,'T2',{T2.name}));
        end
        if strfind(folders{i,1},'localizer')
            if exist(fullfile(outputdir,subjectID,'Localizer'),'dir')==0
                mkdir(fullfile(outputdir,subjectID,'Localizer'));
            end
            movefile(fullfile(outputdir,subjectID,sprintf('s0%s*.nii',folders{i}(1:2))),...
                fullfile(outputdir,subjectID,'localizer'));
            localizer = dir(fullfile(outputdir,subjectID,'Localizer','*.nii'));
            inputs.localizer = char(fullfile(outputdir,subjectID,'Localizer',{localizer.name}));
        end
        if strfind(folders{i,1},'gre')
            if exist(fullfile(outputdir,subjectID,'GRE'),'dir')==0
                mkdir(fullfile(outputdir,subjectID,'GRE'));
            end
            movefile(fullfile(outputdir,subjectID,sprintf('s0%s*.nii',folders{i}(1:2))),...
                fullfile(outputdir,subjectID,'gre'));
            GRE = dir(fullfile(outputdir,subjectID,'GRE','*.nii'));
            inputs.GRE = char(fullfile(outputdir,subjectID,'GRE',{GRE.name}));
        end
        if strfind(folders{i,1},'b_te30')
            try
                inputs.nonmoco_index(i,1) = str2num(folders{i,1}(1:2));
            catch
                inputs.nonmoco_index(i,1) = str2num(folders{i,1}(1));
            end
        end
        if strfind(folders{i,1},'b_te25')
            try
                inputs.nonmoco_index(i,1) = str2num(folders{i,1}(1:2));
            catch
                inputs.nonmoco_index(i,1) = str2num(folders{i,1}(1));
            end
        end
        if strfind(folders{i,1},'b_te20')
            try
                inputs.nonmoco_index(i,1) = str2num(folders{i,1}(1:2));
            catch
                inputs.nonmoco_index(i,1) = str2num(folders{i,1}(1));
            end
        end
        if strfind(folders{i,1},'moco')
            try
                inputs.moco_index(i,1) = str2num(folders{i,1}(1:2));
            catch
                inputs.moco_index(i,1) = str2num(folders{i,1}(1));
            end
        end
    end
    
    if sum(inputs.moco_index)>0
        inputs.moco_index = sort(inputs.moco_index(inputs.moco_index ~=0,1));
    end
    inputs.nonmoco_index = sort(inputs.nonmoco_index(inputs.nonmoco_index ~=0,1)); 
    
    runNames = {'Benefit_TE20','Benefit_TE25','Benefit_TE30'};
    
    %Move functionals
    for i = 1:size(inputs.nonmoco_index,1)
        if exist(fullfile(outputdir,subjectID,runNames{i}),'dir')==0
            mkdir(fullfile(outputdir,subjectID,runNames{i}));
        end
        
        %Creating sub-folders for each run
        if exist(fullfile(outputdir,subjectID,runNames{i},'Non MoCo'),'dir')==0
            mkdir(fullfile(outputdir,subjectID,runNames{i},'Non MoCo'));
        end
        if sum(inputs.moco_index) > 0
            if exist(fullfile(outputdir,subjectID,runNames{i},'MoCo'),'dir')==0
                mkdir(fullfile(outputdir,subjectID,runNames{i},'MoCo'));
            end
        end
            
        %Non-MoCo files
        movefile(fullfile(outputdir,subjectID,sprintf('s0%02d*.nii',inputs.nonmoco_index(i))),...
            fullfile(outputdir,subjectID,runNames{i},'Non MoCo'));
        
        %MoCo files
        if sum(inputs.moco_index) > 0
            movefile(fullfile(outputdir,subjectID, sprintf('s0%02d*.nii',inputs.moco_index(i))),...
                fullfile(outputdir,subjectID,runNames{i},'MoCo'));
            
            rmdir(fullfile(outputdir,subjectID,runNames{i},'MoCo'),'s');
        end
        
        images = dir(fullfile(outputdir,subjectID,runNames{i},'Non MoCo','s0**.nii')); %change accordingly based on file name
        inputs.functionals{i,1} = char(fullfile(outputdir,subjectID,runNames{i},'Non MoCo',{images.name})); %#ok<*AGROW>
    end
    
    % Throwing away the first six TRs (if 3D images)
    if inputs.cfgfile == 1
        for i = 1:size(inputs.functionals,1)
            inputs.functionals{i,1} = inputs.functionals{i,1}(7:end,:); % excluded 1 TR
        end
    end
    %-------------------------------------------------------------------------%
    %   finalizing analyses
    %-------------------------------------------------------------------------%
    
    images = dir(fullfile(outputdir,subjectID,'Benefit_TE20','Non MoCo','*001.nii')); %change accordingly based on file name
    volinfo = spm_vol(fullfile(outputdir,subjectID,'Benefit_TE20','Non MoCo',char(images(1,1).name)));
    inputs.nslices = volinfo(1,1).dim(3); % get information of the number of slices from one selected file
    inputs.nruns = size(inputs.nonmoco_index,1);
        
    save(fullfile(outputdir,subjectID,strcat(inputs.subjectID,'_inputs.mat')),'inputs');
catch ME %#ok<*NASGU>
    display('Error converting DICOMS to NIFTI. Please check your files.');
    display(['Error from: ' sourcename]);
end
toc;

function fileList = get_dicoms(dname)

switch nargin
    case 0
        dname = uigetdir('Choose directory of dicoms');
end

data = dir(dname);      % current directory
index = [data.isdir];  % directory index
fileList = {data(~index).name}';  % get file list

if ~isempty(fileList)
    fileList = cellfun(@(x) fullfile(dname,x),...  %add full path to data
        fileList,'UniformOutput',false);
end

subdir = {data(index).name};  % get subdirectory list
subindex = ~ismember(subdir,{'.','..'});  % index of subdirectories that are not '.' or '..'

for i = find(subindex)             
    nextdir = fullfile(dname,subdir{i});
    fileList = [fileList; get_dicoms(nextdir)];   %#ok<*AGROW>
end


