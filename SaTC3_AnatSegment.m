function SaTC3_AnatSegment(s)
%Accepts subject number as input. Conducts Segmentation, produces warp
%fields.

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


% Grab anatomical
cd(fullfile(subdir,'T1'));
anatomical = dir('s*.nii');
anatomicalScan = {fullfile(subdir,'T1',anatomical.name)};

% SPM Directory
spm_dir = which('spm');
spm_dir = spm_dir(1:end-5);


matlabbatch{1}.spm.spatial.preproc.channel.vols = anatomicalScan;
matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001;
matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
matlabbatch{1}.spm.spatial.preproc.channel.write = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {[spm_dir 'tpm/TPM.nii,1']};
matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {[spm_dir 'tpm/TPM.nii,2']};
matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {[spm_dir 'tpm/TPM.nii,3']};
matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {[spm_dir 'tpm/TPM.nii,4']};
matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {[spm_dir 'tpm/TPM.nii,5']};
matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {[spm_dir 'tpm/TPM.nii,6']};
matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
matlabbatch{1}.spm.spatial.preproc.warp.write = [1 1];

%% Save Segment batch file, Run job
save(fullfile(subdir,['FuncPreProc-anat_segment-' date '.mat']),'matlabbatch');
cd(subdir)
spm('defaults', 'FMRI');
spm_jobman('serial', matlabbatch);

cd(scriptdir)
end


