function SecondLevelContrastManagerCov(con)
% % List of open inputs
% nrun = X; % enter the number of runs here
% jobfile = {'Z:\Capture.01Data\Analysis\Scripts\SecondLevelContrastManager_job.m'};
% jobs = repmat(jobfile, 1, nrun);
% inputs = cell(0, nrun);
% for crun = 1:nrun
% end
% job_id = cfg_util('initjob', jobs);
% sts    = cfg_util('filljob', job_id, inputs{:});
% if sts
%     cfg_util('run', job_id);
% end
% cfg_util('deljob', job_id);
matlabbatch{1}.spm.stats.con.spmmat = {['C:\Users\clc42\Desktop\fMRI\ETS01\Analysis\ReallyBasicModelGenSwitchDiffRT\Contrast' num2str(con) '\SPM.mat']};
matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'Pos';
matlabbatch{1}.spm.stats.con.consess{1}.tcon.convec = [0 1];
matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = 'Neg';
matlabbatch{1}.spm.stats.con.consess{2}.tcon.convec = [0 -1];
matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
matlabbatch{1}.spm.stats.con.delete = 1;
spm('defaults', 'FMRI');
spm_jobman('serial', matlabbatch);