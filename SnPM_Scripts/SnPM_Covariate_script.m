%-----------------------------------------------------------------------
% Job saved on 07-Nov-2017 10:48:19 by cfg_util (rev $Rev: 6460 $)
% spm SPM - SPM12 (6685)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
scriptdir = pwd;
%Load contrast info from 1st subject
sNum = num2str(s(1));
output_header = '/Users/CNDM/Dropbox/SaTCPrivacyGrant/SaTC3/fMRIAnalyses/fMRI_Data/SnPM_attempt/SnPM_AIDecision_Covariates'
%-----------------------
%   Dropbox Directory
    datadir='/Users/CNDM/Dropbox/SaTCPrivacyGrant/SaTC3/fMRIAnalyses/fMRI_Data/ReconScans/';
%------------------------

% Name Output directory
if length(s) < 10
    outputdir=[sprintf('%sAIDecisionModelN0%d_withRes/',datadir,length(s))];
else
    outputdir=[sprintf('%sAIDecisionModelN%d_withRes/',datadir,length(s))];
end

%   Name model directory
modeldir = sprintf('%s%s_3D/Decision1/AI_Decision_Model/',datadir, sNum);

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
        modeldir = sprintf('%s%s_3D/Decision1/AI_Decision_Model/',datadir, num2str(s(sub)));
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
matlabbatch{1}.spm.tools.snpm.des.Corr.CovInt = [-0.2196875 0.3222175 0.3558585 0.0229985 0.0009445 -0.1236895 0.1205265 -0.3875585 -0.0064125 0.2697975 0.1085755 0.1153685 -0.1954085 -0.4612955 0.2083865 0.1852175 -0.1591565 0.0647465 0.1896525 0.2278965 -0.2616645 -0.0947495 -0.1201255 -0.1624385];
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
matlabbatch{3}.spm.tools.snpm.inference.SnPMmat(1) = cfg_dep('Compute: SnPM.mat results file', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','SnPM'));
matlabbatch{3}.spm.tools.snpm.inference.Thr.Clus.ClusSize.CFth = 0.0001;
matlabbatch{3}.spm.tools.snpm.inference.Thr.Clus.ClusSize.ClusSig.FWEthC = 0.05;
matlabbatch{3}.spm.tools.snpm.inference.Tsign = 1;
matlabbatch{3}.spm.tools.snpm.inference.WriteFiltImg.name = 'SnPM_filtered';
matlabbatch{3}.spm.tools.snpm.inference.Report = 'MIPtable';

save(fullfile(condir,[conname 'SecondLevel -' date '.mat']),'matlabbatch');
spm('defaults', 'FMRI');
spm_jobman('serial', matlabbatch);
end
