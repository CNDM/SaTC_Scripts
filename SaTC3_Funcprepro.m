function SaTC3_Funcprepro(s)
%Accepts subject number as input. Conducts slice timing, realignment, and
%coregistration for SaTC.3 functionals

% Adapted from ETS Scripts written by Crystal Reeck
% Composed by Anthony Resnick 6/08/2017

% Test Data: Epi tests, and sub990 scans
% Subject Data: Our subjects to be used for final analysis

% Directory
scriptdir = pwd;

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


% Grab anatomical
cd(fullfile(subdir,'T1'));
anatomical = dir('s*.nii');
anatomicalScan = {fullfile(subdir,'T1',anatomical.name)};

% Order of sessions is correct
if ismember(mod(str2num(sNum),4),[0,1])
    runs={'Question' 'Benefit' 'Decision1' 'Decision2'};
    l=[366 126 366 366];
else
    runs={'Benefit' 'Question' 'Decision1' 'Decision2'};
    l=[126 366 366 366];
end

% Grabbing Scans
for r=1:length(runs)
    session={};
    cd(fullfile(subdir,runs{r},'Non Moco'));
    funcFiles = struct2cell(dir('s0*001.nii'));
    funcHeadidx = strfind(funcFiles{1,1},'_');
    funcHead = funcFiles{1}(1:funcHeadidx);
    for i=7:l(r)%Discard first 6
        if i<10
            session{i-6,1}=(fullfile(subdir,runs{r},'Non Moco', [funcHead '00' num2str(i) '.nii,1']));
        elseif i<100
            session{i-6,1}=(fullfile(subdir,runs{r},'Non Moco', [funcHead '0' num2str(i) '.nii,1']));
        else
            session{i-6,1}=(fullfile(subdir,runs{r},'Non Moco', [funcHead num2str(i) '.nii,1']));
        end
    end
    matlabbatch{1}.spm.temporal.st.scans{r} = session;
end

%% Slice-Timing Correction
matlabbatch{1}.spm.temporal.st.nslices = 42;
matlabbatch{1}.spm.temporal.st.tr = 2;
matlabbatch{1}.spm.temporal.st.ta = 1.95238095238095;
matlabbatch{1}.spm.temporal.st.so = [2:2:42,1:2:42]; %42 slices ascending
matlabbatch{1}.spm.temporal.st.refslice = 1;
matlabbatch{1}.spm.temporal.st.prefix = 'a';

%% Realignment
matlabbatch{2}.spm.spatial.realign.estwrite.data{1}(1) = cfg_dep('Slice Timing: Slice Timing Corr. Images (Sess 1)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
matlabbatch{2}.spm.spatial.realign.estwrite.data{1}(2) = cfg_dep('Slice Timing: Slice Timing Corr. Images (Sess 2)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{2}, '.','files'));
matlabbatch{2}.spm.spatial.realign.estwrite.data{1}(3) = cfg_dep('Slice Timing: Slice Timing Corr. Images (Sess 3)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{3}, '.','files'));
matlabbatch{2}.spm.spatial.realign.estwrite.data{1}(4) = cfg_dep('Slice Timing: Slice Timing Corr. Images (Sess 4)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{4}, '.','files'));
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.sep = 4;
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.interp = 4;
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.weight = {''};
matlabbatch{2}.spm.spatial.realign.estwrite.roptions.which = [0 1];
matlabbatch{2}.spm.spatial.realign.estwrite.roptions.interp = 4;
matlabbatch{2}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
matlabbatch{2}.spm.spatial.realign.estwrite.roptions.mask = 1;
matlabbatch{2}.spm.spatial.realign.estwrite.roptions.prefix = 'r';

%% Coregistration
matlabbatch{3}.spm.spatial.coreg.estimate.ref(1) = cfg_dep('Realign: Estimate & Reslice: Mean Image', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rmean'));
matlabbatch{3}.spm.spatial.coreg.estimate.source = anatomicalScan;
matlabbatch{3}.spm.spatial.coreg.estimate.other = {''};
matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];

%% Save Pre-processing batch file, Run job
save(fullfile(subdir,['FuncPreProc-st_realign_coreg-' date '.mat']),'matlabbatch');
cd(subdir)
spm('defaults', 'FMRI');
spm_jobman('serial', matlabbatch);

cd(scriptdir)
end
