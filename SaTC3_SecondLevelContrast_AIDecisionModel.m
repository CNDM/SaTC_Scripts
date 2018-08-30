function SaTC3_SecondLevelContrast_AIDecisionModel(s)

%%% s = matrix of participant numbers you would like to build the second
%%% level model for the SaTC3 project.
%%% task = 'Benefit', 'Question', or 'Decision'
%%% Will create a directory for your new second level model and contrasts


scriptdir = pwd;
%Load contrast info from 1st subject
sNum = num2str(s(1));

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
    condir=[outputdir conname];
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
    matlabbatch{1}.spm.stats.factorial_design.dir = concell;
    matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = scans;
    matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
    %%
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 1;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    %%
    matlabbatch{3}.spm.stats.con.spmmat = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = SPM.xCon(c).name;
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = 1;
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.delete = 1;
    
save(fullfile(condir,[conname 'SecondLevel -' date '.mat']),'matlabbatch');
spm('defaults', 'FMRI');
spm_jobman('serial', matlabbatch);


end %con loop
cd(scriptdir)
end