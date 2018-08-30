function SaTC3_AI_DecisionModel(s)
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
RegressorDataDir = '/Users/CNDM/Dropbox/SaTCPrivacyGrant/SaTC3/fMRIAnalyses/Regressors';
BehaviorDataDir = '/Users/CNDM/Dropbox/SaTCPrivacyGrant/SaTC3/Data/';
    %   Anthony Directory
%mriDataDir = '/Users/CNDM/Documents/SaTC3_withPractice/fMRIAnalyses/fMRI_Data/ReconScans';
%BehaviorDataDir = '/Users/CNDM/Documents/SaTC3_withPractice/fMRIAnalyses/Regressors';

[Benefits, Questions] = SaTC3_FindRates(s);   

mriSubdir = fullfile(mriDataDir,sprintf('%s_3D',sNum));
BehaviorSubdir = fullfile(RegressorDataDir,sprintf('%s',sNum));
runs = {'Decision1','Decision2'};
l = [366];

%   Create Model Directory
if ~exist(fullfile(mriSubdir,'Decision1','AI_Decision_Model'))
    mkdir(fullfile(mriSubdir,'Decision1','AI_Decision_Model'));
end
modelDir = fullfile(mriSubdir,'Decision1','AI_Decision_Model');
    DecisionSession = [];
    
%   Grabbing Scans
for r=1:length(runs)
    session={};
    cd(fullfile(mriSubdir,runs{r},'Non Moco'));
    funcFiles = struct2cell(dir('swas*.nii'));
    funcHeadidx = strfind(funcFiles{1,1},'_');
    funcHead = funcFiles{1}(1:funcHeadidx);
    for i=7:l(1)
        if i<10
            session{i-6,1}=(fullfile(mriSubdir,runs{r},'Non Moco', [funcHead '00' num2str(i) '.nii,1']));
        elseif i<100
            session{i-6,1}=(fullfile(mriSubdir,runs{r},'Non Moco', [funcHead '0' num2str(i) '.nii,1']));
        else
            session{i-6,1}=(fullfile(mriSubdir,runs{r},'Non Moco', [funcHead num2str(i) '.nii,1']));
        end
    end
   DecisionSession = [DecisionSession;session]; 
end
    
%   Read in regressors
    cd(BehaviorSubdir)
    Regressors = csvread(fullfile(BehaviorSubdir, sprintf('DecisionRegressor.%s',sNum)));

%   Get rid of missing responses
    Ben_with_onset = [Regressors(:,1), Benefits'];
    BenRegressor = Ben_with_onset(Ben_with_onset(:,2)~=0,:);
    
    Quest_with_onset = [Regressors(:,1), Questions'];
    QuestRegressor = Quest_with_onset(Quest_with_onset(:,2)~=0,:);
    
    DecRegressor = Regressors(Regressors(:,2)~=0,1:2);
    
%   Build Junk Regressor
    MissingResponses = sum([Questions', Benefits', Regressors(:,2)]')==0;

    
%% First Level Specification
matlabbatch{1}.spm.stats.fmri_spec.dir = {modelDir};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;
matlabbatch{1}.spm.stats.fmri_spec.sess.scans = DecisionSession;
%%  Decision Regressor
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).name = 'Decision';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).onset = DecRegressor(:,1);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).duration = [2];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).tmod = 0;
%%  Decision pmod
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).pmod.name = 'Willingness';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).pmod.param = DecRegressor(:,2);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).pmod.poly = 1;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).orth = 1;
%%  Benefit Regressor
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).name = 'Benefit';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).onset = BenRegressor(:,1);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).duration = [2];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).tmod = 0;
%%  Benefit pmod
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).pmod.name = 'Attractiveness';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).pmod.param = BenRegressor(:,2);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).pmod.poly = 1;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).orth = 1;
%%  Question Regressor
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).name = 'Question';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).onset = QuestRegressor(:,1);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).duration = [2];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).tmod = 0;
%%  Question pmod
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).pmod.name = 'Intrusiveness';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).pmod.param = QuestRegressor(:,2);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).pmod.poly = 1;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).orth = 1;
%%  Only included if all three regressors are missing a response
if sum(MissingResponses) ~= 0
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).name = 'Junk';
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).onset = Regressors(MissingResponses',1);
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).duration = [2];
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).orth = 1;
end
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
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'Positive Willingness';
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [0 1 0];
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'Negative Willingness';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [0 -1 0];
matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'Positive Attractiveness';
matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [0 0 0 1];
matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = 'Negative Attractiveness';
matlabbatch{3}.spm.stats.con.consess{4}.tcon.weights = [0 0 0 -1];
matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{5}.tcon.name = 'Positive Intrusiveness';
matlabbatch{3}.spm.stats.con.consess{5}.tcon.weights = [0 0 0 0 0 1];
matlabbatch{3}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{6}.tcon.name = 'Negative Intrusiveness';
matlabbatch{3}.spm.stats.con.consess{6}.tcon.weights = [0 0 0 0 0 -1];
matlabbatch{3}.spm.stats.con.consess{6}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 0;

%% Save Pre-processing batch file, Run job
save(fullfile(modelDir,['AI_Decision' date '.mat']),'matlabbatch');
cd(modelDir)
spm('defaults', 'FMRI');
spm_jobman('serial', matlabbatch);

cd(scriptdir)
end