function [] = dicom_convert(sourcename,subjectID,outputdir)

%-------------------------------------------------------------------------%
%   creates user input dialog for key parameters
%-------------------------------------------------------------------------%
inputs.subjectID = subjectID;
inputs.dicomdir = sourcename;

% download the CNDM Dropbox/CNDM Toolbox/MRICron folder; if not detected in
% path, will prompt for user input
matlabmainpath=userpath;
if exist(fullfile(matlabmainpath(1:end-1),'CNDMToolbox','MRICron','dcm2nii.exe'),'file') == 0 || isunix
    % if using mac/unix, make sure OSX folder is in MRICron
    mricrondname = '/Users/CNDM/Documents/MATLAB/CNDMToolbox/MRICron';
    %mricrondname = uigetdir(pwd,'Choose MRICron directory');
else
    
    mricrondname = fullfile(matlabmainpath(1:end-1),'CNDMToolbox','MRICron');
end

% specifying 3D or 4D nifti output
nii_dim = 3; % default for 3D nifti images, change to 4 for 4D
switch nii_dim
    case 3 % 3D nifti images
        inputs.cfgfile = 1;
        subjectID = [subjectID '_3D'];
        cfgfile = '3D.ini';
    case 4 % 4D nifti images
        inputs.cfgfile = 2;
        cfgfile = '4D.ini';
        subjectID = [subjectID '_4D'];
end

inputs.niftidir = fullfile(outputdir,subjectID);

tic;

%-------------------------------------------------------------------------%
%   anon & converting dicoms --> nifti
%-------------------------------------------------------------------------%
try
    display('Anonymizing & converting DICOM files');
    
    %Create output folder
    if exist(fullfile(outputdir,subjectID),'dir')==0
        mkdir(fullfile(outputdir,subjectID));
    end
    
    %Calling dcm2nii
    if ispc
        anoncmd = ['"' mricrondname '\dcm2nii" -a y -b "' mricrondname '\' cfgfile '" -o "' ...
            fullfile(outputdir,['/' subjectID '"']) ' "' sourcename '"'];
        system(anoncmd);
    else
        if nii_dim == 3
            %             anoncmd = [mricrondname '/dcm2nii -4 n -a y -g n -b ' mricrondname '/' cfgfile ' -o ''' fullfile(outputdir,subjectID) ''' ''' sourcename ''''];
            %             anoncmd = [mricrondname '/dcm2nii -4 n -a y -g n -o ''' fullfile(outputdir,subjectID) ''' ''' sourcename ''''];
            %         else
            %             anoncmd = [mricrondname '/dcm2nii -4 y -a y -g n -b ' mricrondname '/' cfgfile ' -o ''' fullfile(outputdir,subjectID) ''' ''' sourcename ''''];
            anoncmd = [mricrondname '/dcm2nii -4 y -a y -g n -o ''' fullfile(outputdir,subjectID) ''' ''' sourcename ''''];
        end
        unix(anoncmd);
    end
catch ME
    display('Error converting DICOMS to NIFTI. Please check your files.');
    display(['Error from: ' sourcename]);
end

%-------------------------------------------------------------------------%
%   Read a number of dicom headers to obtain information on series and
%   series name for folder creation purposes
%-------------------------------------------------------------------------%
try
    display('Moving anonymized & converted NIFTI files');
    
    dicomList = get_dicoms(sourcename);
    
    % Is there a DICOMDIR that was imported as well?
    if strcmp(dicomList{1,1}(size(dicomList{1,1},2)-7:end),'DICOMDIR')
        dicomList = dicomList(2:end,1);
    end
    
    index = 1:3:size(dicomList,1); %sample every 3rd dicom for header information
    
    %key step in this process - if the headers are incomplete, then this
    %step will fail
    images = char(dicomList(index,1));
    try
        for i = 1:size(images,1)
            hdrs{1,i} = dicominfo(strtrim(images(i,:))); %this function is included in image processing toolbox for Matlab
        end
    catch ME % if above dicominfo ran into an error
        hdrs = spm_dicom_headers(images);
    end
    
    for i = 1:size(hdrs,2)
        seriesNum(i,1) = hdrs{1,i}.SeriesNumber;
        seriesName{i,1} = hdrs{1,i}.SeriesDescription;
        num_name{i,1} = lower(sprintf('%02d_%s',seriesNum(i,1),seriesName{i,1}));
    end
    
    folders = unique(num_name);
    
    inputs.series = folders;
    inputs.nonmoco_index = zeros(size(folders,1),1);
    
    % exceptions for strangely ordered imported dicoms
    if strcmp(inputs.subjectID,'JH228') == 1
        series={'localizer' 't1' 't2' 'gre' 'gre' 't1' 'r1' 'r2' 'r3' 'r4' 'r5' 'r6' 'rest'};
    elseif strcmp(inputs.subjectID,'AH245') == 1
        series={'localizer' 't1' 'gre' 'gre' 't2' 'r1' 'r2' 'r3' 'r4' 'r5' 'r6' 'rest'};
    elseif strcmp(inputs.subjectID,'RS218') == 1
        series={'localizer' 't1' 't2' 'r1' 'r2' 'r3' 'r4' 'r5' 'r6' 'rest'};
    else % order of series for the majority of subjects
        series={'localizer' 't1' 't2' 'gre' 'gre' 'r1' 'r2' 'r3' 'r4' 'r5' 'r6' 'rest'};
    end
    for i = 1:size(folders,1)
        if isempty(strfind(folders{i,1},series{i})) == 0
            if exist(fullfile(outputdir,subjectID,series{i}),'dir')==0
                mkdir(fullfile(outputdir,subjectID,series{i}));
            end
            try % to catch movefile error if folder is already created
                [tempfiles,~]=get_any_files(sprintf('s0%sa',folders{i}(1:2)),fullfile(outputdir,subjectID));
                for j=1:length(tempfiles)
                    movefile(tempfiles{j},fullfile(outputdir,subjectID,series{i}));
                end
            catch ME
            end
            if nii_dim == 3
                list=strsplit(sprintf('%s',strtrim(ls(fullfile(outputdir,subjectID,series{i})))));
                for k=1:length(list)
                    vol = spm_vol(fullfile(outputdir,subjectID,series{i},list{k}));
                    img = spm_read_vols(vol);
                    sz = size(img);
                    if size(sz,2) == 4
                        cd(fullfile(outputdir,subjectID,series{i}))
                        abk_4Dto3D(fullfile(outputdir,subjectID,series{i},list{k}))
                        delete(list{k})
                    end
                    clear vol img sz
                end
            end
        end
        if strcmp(inputs.subjectID,'JH228') == 1
            index = {7,8,9,10,11,12,13};
        elseif strcmp(inputs.subjectID,'RS218') == 1
            index = {4,5,6,7,8,9,10};
        else
            index = {6,7,8,9,10,11,12};
        end
        switch i
            case index
            try
                inputs.nonmoco_index(i,1) = str2double(folders{i,1}(1:2));
                functionalruns(i,:) = [{str2double(folders{i,1}(1:2))},series(i)];
            catch
                inputs.nonmoco_index(i,1) = str2double(folders{i,1}(1));
                functionalruns(i,:) = [{str2double(folders{i,1}(1))},series(i)];
            end
        end
        inputs.(series{i}) = char(fullfile(outputdir,subjectID,series{i},strsplit(strtrim(ls(fullfile(outputdir,subjectID,series{i}))))));
    end
%     if strcmp(inputs.subjectID,'JH228') == 1
%         for j=1:size(inputs.t1,1)
%             if isempty(strfind(inputs.t1(j,:),'FOV'))
%         end
    clear tempfiles
    inputs.nonmoco_index = sort(inputs.nonmoco_index(inputs.nonmoco_index ~=0,1));
    if strcmp(inputs.subjectID,'MK249') == 1 % MK scan was aborted after r4
        inputs.functionals = {sort(cellstr(inputs.r1));sort(cellstr(inputs.r2));sort(cellstr(inputs.r3));sort(cellstr(inputs.r4))};
    else
        inputs.functionals = {sort(cellstr(inputs.r1));sort(cellstr(inputs.r2));sort(cellstr(inputs.r3));sort(cellstr(inputs.r4));sort(cellstr(inputs.r5));sort(cellstr(inputs.r6));sort(cellstr(inputs.rest))};
    end
    
    % Throwing away the first 3 TR (if 3D images)
    if inputs.cfgfile == 1
        for i = 1:size(inputs.functionals,1)
            inputs.functionals{i,1} = inputs.functionals{i,1}(4:end,:);
        end
    end
catch ME
    display('Error moving NIFTI files. Please check your files.');
    display(['Error from: ' sourcename]);
end

%-------------------------------------------------------------------------%
%   finalizing analyses
%-------------------------------------------------------------------------%
try
    [tempfiles,~]=get_any_files(sprintf('s0%02da',inputs.nonmoco_index(1)),fullfile(outputdir,subjectID,'r1'));
    volinfo = spm_vol(tempfiles{1});
    inputs.nslices = volinfo(1,1).dim(3);
    inputs.nruns = size(inputs.nonmoco_index,1); % subtract resting
    
    save(fullfile(outputdir,subjectID,strcat(inputs.subjectID,'_inputs.mat')),'inputs');
catch ME
    display('Error saving inputs data. Please check your files.');
    display(['Error from: ' inputs.subjectID]);
end
toc;
end


