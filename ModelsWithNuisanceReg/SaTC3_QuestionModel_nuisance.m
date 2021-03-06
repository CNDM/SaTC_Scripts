function SaTC3_QuestionModel_nuisance(s)
%Accepts subject number as input. Builds 1st level model, estimates, and
%builds contrasts.

% Composed by Anthony Resnick 6/26/2017

% Directory
scriptdir = pwd;

sNum = num2str(s);

%---------------------------------------------------------------
% ****************************************************************************
% *** Please change these to your data and save directories ***
% ****************************************************************************

    %   Dropbox Directory
mriDataDir = '/Users/CNDM/Dropbox/SaTCPrivacyGrant/SaTC3/fMRIAnalyses/fMRI_Data/ReconScans';
BehaviorDataDir = '/Users/CNDM/Dropbox/SaTCPrivacyGrant/SaTC3/fMRIAnalyses/Regressors';

    %   Anthony Directory
%mriDataDir = '/Users/CNDM/Documents/SaTC3_withPractice/fMRIAnalyses/fMRI_Data/ReconScans';
%BehaviorDataDir = '/Users/CNDM/Documents/SaTC3_withPractice/fMRIAnalyses/Regressors';



mriSubdir = fullfile(mriDataDir,sprintf('%s_3D',sNum));
BehaviorSubdir = fullfile(BehaviorDataDir,sprintf('%s',sNum));
runs = {'Question'};
l = [366];

%   Create Model Directory
if ~exist(fullfile(mriSubdir,'Question','Question_Model_nuisance'))
    mkdir(fullfile(mriSubdir,'Question','Question_Model_nuisance'));
end
modelDir = fullfile(mriSubdir,'Question','Question_Model_nuisance');

%   Grabbing Scans
    session={};
    cd(fullfile(mriSubdir,runs{1},'Non Moco'));
    funcFiles = struct2cell(dir('swas0*.nii'));
    funcHeadidx = strfind(funcFiles{1,1},'_');
    funcHead = funcFiles{1}(1:funcHeadidx);
    for i=7:l(1)
        if i<10
            session{i-6,1}=(fullfile(mriSubdir,runs{1},'Non Moco', [funcHead '00' num2str(i) '.nii,1']));
        elseif i<100
            session{i-6,1}=(fullfile(mriSubdir,runs{1},'Non Moco', [funcHead '0' num2str(i) '.nii,1']));
        else
            session{i-6,1}=(fullfile(mriSubdir,runs{1},'Non Moco', [funcHead num2str(i) '.nii,1']));
        end
    end
    
%   Read in regressors
    cd(BehaviorSubdir)
    Regressors = csvread(fullfile(BehaviorSubdir, sprintf('QuestionRegressor.%s',sNum)));

    modulator = Regressors(:,3) - mean(Regressors(:,3));

%% First Level Specification
matlabbatch{1}.spm.stats.fmri_spec.dir = {modelDir};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;
matlabbatch{1}.spm.stats.fmri_spec.sess.scans = session;
%%
matlabbatch{1}.spm.stats.fmri_spec.sess.cond.name = 'Question';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond.onset = Regressors(:,1)
matlabbatch{1}.spm.stats.fmri_spec.sess.cond.duration = [2];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond.tmod = 0;
%%
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).pmod(1).name = 'Intrusiveness';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).pmod(1).param = Regressors(:,2);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).pmod(1).poly = 1;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).orth = 1;

matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).pmod(2).name = 'ReactionTime';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).pmod(2).param = modulator;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).pmod(2).poly = 1;
%%
matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {''};
matlabbatch{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {''};
matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;
matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'none';

%% Estimation
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

%% Contrasts
matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'Pos';
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [0 1 0];
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'Neg';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [0 -1 0];
matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 0;

%% Save Pre-processing batch file, Run job
save(fullfile(modelDir,['Question' date '.mat']),'matlabbatch');
cd(modelDir)
spm('defaults', 'FMRI');
spm_jobman('serial', matlabbatch);

cd(scriptdir)
end