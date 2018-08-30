function SaTC3_NormSmooth(s)
%Accepts subject number as input. Conducts Normalization/Smoothing

% Composed by Anthony Resnick 6/14/2017

scriptdir = pwd;

% Directory
sNum = num2str(s)


%---------------------------------------------------------------
% ****************************************************************************
% *** Please change these to your data and save directories ***
% ****************************************************************************


    %   Dropbox Directory
datadir = '/Users/CNDM/Dropbox/SaTCPrivacyGrant/SaTC3/fMRIAnalyses/fMRI_Data/ReconScans';

    %   Anthony Directory
%datadir = '/Users/CNDM/Documents/SaTC3_withPractice/fMRIAnalyses/fMRI_Data/ReconScans';
subdir = fullfile(datadir,sprintf('%s_3D',sNum));

% ****************************************************************************
% ****************************************************************************


% Grab anatomical field
cd(fullfile(subdir,'T1'));
anatomicalField = dir('y_s*.nii');
anatomicalFieldPath = {fullfile(subdir,'T1',anatomicalField.name)};

% Order of sessions is correct
if ismember(mod(str2num(sNum),4),[0,1])
    runs={'Question' 'Benefit' 'Decision1' 'Decision2'};
    l=[366 126 366 366];
else
    runs={'Benefit' 'Question' 'Decision1' 'Decision2'};
    l=[126 366 366 366];
end

    session={};
%% Grabbing Scans
for r=1:length(runs)
    cd(fullfile(subdir,runs{r},'Non Moco'));
    funcFiles = struct2cell(dir('as0*007.nii'));
    funcHeadidx = strfind(funcFiles{1,1},'_');
    funcHead = funcFiles{1}(1:funcHeadidx);
    for i=7:l(r)%Discard first 6
        if i<10
            tempsession{i-6,1}=(fullfile(subdir,runs{r},'Non Moco', [funcHead '00' num2str(i) '.nii,1']));
        elseif i<100
            tempsession{i-6,1}=(fullfile(subdir,runs{r},'Non Moco', [funcHead '0' num2str(i) '.nii,1']));
        else
            tempsession{i-6,1}=(fullfile(subdir,runs{r},'Non Moco', [funcHead num2str(i) '.nii,1']));
        end
    end
    session = [session;tempsession];
end

% --------------------
%% Create Job
% --------------------

matlabbatch{1}.spm.spatial.normalise.write.subj.def = anatomicalFieldPath;
%%
matlabbatch{1}.spm.spatial.normalise.write.subj.resample = session;
%%
matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-90 -126 -72
                                                          90 90 108];
matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [3 3 3];
matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;

matlabbatch{2}.spm.spatial.smooth.data(1) = cfg_dep('Normalise: Write: Normalised Images (Subj 1)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
matlabbatch{2}.spm.spatial.smooth.fwhm = [8 8 8];
matlabbatch{2}.spm.spatial.smooth.dtype = 0;
matlabbatch{2}.spm.spatial.smooth.im = 0;
matlabbatch{2}.spm.spatial.smooth.prefix = 's';
matlabbatch{3}.cfg_basicio.file_dir.file_ops.file_move.files(1) = cfg_dep('Normalise: Write: Normalised Images (Subj 1)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
matlabbatch{3}.cfg_basicio.file_dir.file_ops.file_move.action.delete = false;

%% Save Segment batch file, Run job
save(fullfile(subdir,['FuncPreProc-NormSmooth-' date '.mat']),'matlabbatch');
cd(subdir)
spm('defaults', 'FMRI');
spm_jobman('serial', matlabbatch);

cd(scriptdir)
end


