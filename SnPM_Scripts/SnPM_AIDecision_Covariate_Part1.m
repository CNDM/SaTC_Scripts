function SnPM_AIDecision_Covariate_Part1(s,covariate)

scriptdir = pwd;
%Load contrast info from 1st subject
sNum = num2str(s(1));
output_header = sprintf('/Users/CNDM/Dropbox/SaTCPrivacyGrant/SaTC3/fMRIAnalyses/SnPM/Covariates/AIDecision_Covariates/%s/',covariate)
%-----------------------
%   Dropbox Directory
    datadir='/Users/CNDM/Dropbox/SaTCPrivacyGrant/SaTC3/fMRIAnalyses/';
%------------------------

%   Name model directory
modeldir = sprintf('%sfMRI_Data/ReconScans/%s_3D/Decision1/AI_Decision_Model/',datadir, sNum);


covariateFile = read_table_DM1(sprintf('%sCovariates/%s.txt',datadir,covariate));
covariateData = covariateFile.col2;
%Load first subject's contrast
conspm=[modeldir 'SPM.mat'];
cmd = ['load ' [modeldir 'SPM.mat']];
eval(cmd);

%How many contrasts?
cons=length(SPM.xCon); %Only building the first, Positive contrast

for c=1:cons
    fprintf('Working on Contrast %d / %d \n', c, cons)
    %Create condir if necessary
    conname=[sprintf('%s',SPM.xCon(c).name)];
    condir=[output_header conname];
    if exist(condir)~=1 % exist requires string format
        mkdir(condir)
    end
    concell{1}=condir; %SPM requires directory in cell format.
    scans=cell(length(s),1);
    for sub=1:length(s)
        modeldir = sprintf('%sfMRI_Data/ReconScans/%s_3D/Decision1/AI_Decision_Model/',datadir, num2str(s(sub)));
        if c<10
            scans(sub)={[modeldir 'con_000' num2str(c) '.nii,1']};
        else
            scans(s)={[modeldir 'con_00' num2str(c) '.nii,1']};
        end
    end %subj loop
    
    
matlabbatch{1}.spm.tools.snpm.des.Corr.DesignName = 'MultiSub: Simple Regression; 1 covariate of interest';
matlabbatch{1}.spm.tools.snpm.des.Corr.DesignFile = 'snpm_bch_ui_Corr';
matlabbatch{1}.spm.tools.snpm.des.Corr.dir = concell;
matlabbatch{1}.spm.tools.snpm.des.Corr.P = scans;
matlabbatch{1}.spm.tools.snpm.des.Corr.CovInt = covariateData;
matlabbatch{1}.spm.tools.snpm.des.Corr.cov = struct('c', {}, 'cname', {});
matlabbatch{1}.spm.tools.snpm.des.Corr.nPerm = 5000;
matlabbatch{1}.spm.tools.snpm.des.Corr.vFWHM = [0 0 0];
matlabbatch{1}.spm.tools.snpm.des.Corr.bVolm = 1;
matlabbatch{1}.spm.tools.snpm.des.Corr.ST.ST_later = -1;
matlabbatch{1}.spm.tools.snpm.des.Corr.masking.tm.tm_none = 1;
matlabbatch{1}.spm.tools.snpm.des.Corr.masking.im = 1;
matlabbatch{1}.spm.tools.snpm.des.Corr.masking.em = {''};
matlabbatch{1}.spm.tools.snpm.des.Corr.globalc.g_omit = 1;
matlabbatch{1}.spm.tools.snpm.des.Corr.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.tools.snpm.des.Corr.globalm.glonorm = 1;
matlabbatch{2}.spm.tools.snpm.cp.snpmcfg(1) = cfg_dep('MultiSub: Simple Regression; 1 covariate of interest: SnPMcfg.mat configuration file', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','SnPMcfg'));

save(fullfile(condir,[conname 'Part1 -' date '.mat']),'matlabbatch');
spm('defaults', 'FMRI');
spm_jobman('serial', matlabbatch);
end
cd(scriptdir)