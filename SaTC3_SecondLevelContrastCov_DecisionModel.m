function SaTC3_SecondLevelContrastCov_DecisionModel(subj,subs,covfile,directory)
% % List of open inputs
% nrun = X; % enter the number of runs here
% jobfile = {'Z:\Capture.01Data\Analysis\Scripts\DummyTrait_job.m'};
% jobs = repmat(jobfile, 1, nrun);
% inputs = cell(0, nrun);
% for crun = 1:nrun
% end
%Covariate file: column 1 doesn't matter, column 2 is covariate, and
%column 3 is ScanID number

%Read in covariate info; MUST BE SORTED IN SAME ORDER AS SUB!!

cov=read_table([directory.covariates '/' covfile '.txt']);
for a=1:length(cov.col1)
    if str2double(subj{a})==cov.col3(a)
    else
        fprintf('ERROR! SUBJECTS DO NOT MATCH!!\n')
    end
end
%Load contrast info from 1st subject

outputdir=[fullfile(directory.datadir, 'DecisionModelN24/')];
conspm=[directory.datadir '/' num2str(subs(1)) '_3D/Decision1/Decision_Model/SPM.mat'];
cmd = ['load ' [conspm]];
eval(cmd);

%How many contrasts?
cons=length(SPM.xCon);
for c=1:cons
    fprintf('Working on Contrast %d / %d \n', c, cons)
    %Create condir if necessary
    conname=[covfile];%SPM.xCon(c).name;
    if c == 1
        condir=[outputdir 'PosDecision/' conname];
    elseif c == 2
        condir=[outputdir 'NegDecision/' conname];
    end
    if exist(condir)~=1 % exist requires string format
        mkdir(condir)
    end
    concell{1}=condir; %SPM requires directory in cell format.
    scans=cell(length(subj),1);
    for s=1:length(subj)
        if c<10
            scans(s)={[sprintf('%s/%s_3D/Decision1/Decision_Model/con_000%s.nii,1',directory.datadir, num2str(subs(s)),num2str(c))]};
        else
            scans(s)={[sprintf('%s/%s_3D/Decision1/Decision_Model/con_00%s.nii,1',directory.datadir, num2str(subs(s)),num2str(c))]};
        end
    end %subj loop
    matlabbatch{1}.spm.stats.factorial_design.dir = concell;
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.scans = scans;
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov.c = cov.col2;
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov.cname = covfile;
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov.iCC = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.incint = 1;
    matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep;
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tname = 'Select SPM.mat';
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(1).name = 'filter';
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(1).value = 'mat';
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(2).name = 'strtype';
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(2).value = 'e';
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).sname = 'Factorial design specification: SPM.mat File';
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).src_exbranch = substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).src_output = substruct('.','spmmat');
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    matlabbatch{3}.spm.stats.con.spmmat = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'Pos';
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.convec = [0 1];
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'Neg';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.convec = [0 -1];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.delete = 1;
    save(fullfile(condir,[covfile '_' date '.mat']),'matlabbatch');
    spm('defaults', 'FMRI');
    spm_jobman('serial', matlabbatch);
end %con loop
