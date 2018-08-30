% List of open inputs
% Slice Timing: TA - cfg_entry
nrun = X; % enter the number of runs here
jobfile = {'/Users/CNDM/Documents/SHOP/fMRI Preprocessing/timeslice_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(1, nrun);
for crun = 1:nrun
    inputs{1, crun} = MATLAB_CODE_TO_FILL_INPUT; % Slice Timing: TA - cfg_entry
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
