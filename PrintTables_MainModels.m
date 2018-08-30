

baseDir = '/Users/CNDM/Dropbox/SaTCPrivacyGrant/SaTC3/fMRIAnalyses';
outputDir = [baseDir '/Tables'];
[~,~,data] = xlsread('/Users/CNDM/Documents/ModelThresh.xlsx');
for idx = 2:size(data,1)
    if data{idx,4} ~= 0
        spmfile = {fullfile(baseDir,data{idx,1},data{idx,2},'SPM.mat')};
        cd(fullfile(baseDir,data{idx,1},data{idx,2}));
        
        
        matlabbatch{1}.spm.stats.results.spmmat = spmfile;
        matlabbatch{1}.spm.stats.results.conspec.titlestr = '';
        matlabbatch{1}.spm.stats.results.conspec.contrasts = 1;
        matlabbatch{1}.spm.stats.results.conspec.threshdesc = 'none';
        matlabbatch{1}.spm.stats.results.conspec.thresh = data{idx,3};
        matlabbatch{1}.spm.stats.results.conspec.extent = data{idx,4};
        matlabbatch{1}.spm.stats.results.conspec.conjunction = 1;
        matlabbatch{1}.spm.stats.results.conspec.mask.none = 1;
        matlabbatch{1}.spm.stats.results.units = 1;
        matlabbatch{1}.spm.stats.results.print = 'csv';
        matlabbatch{1}.spm.stats.results.write.none = 1;
        spm('defaults', 'FMRI');
        spm_jobman('serial', matlabbatch);
        pval = num2str(data{idx,3});
        command = sprintf('mv %s/spm_2018May29_001.csv %s/%s/%s%s_table.csv',pwd,outputDir,data{idx,1},data{idx,2},pval(3:end));
        system(command)
    end
end



