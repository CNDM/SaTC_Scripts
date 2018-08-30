function NegAtt_Redo(covariate,threshold)

scriptdir = pwd;
output_header = sprintf('/Users/CNDM/Dropbox/SaTCPrivacyGrant/SaTC3/fMRIAnalyses/SnPM/Covariates/AIDecision_Covariates/%s/',covariate);
fileList = dir(output_header);
consList = struct2cell(fileList(4:end));
cons = consList(1,:);
thresh = num2str(threshold);
threshStr = thresh(3:end)

    contrast = 'Negative Attractiveness';
    condir = sprintf('%s%s/threshold_%s',output_header,contrast,num2str(threshold));
    if exist(condir)==1 % exist requires string format
        return
    else
       mkdir(condir) 
    end
    cd(condir)
    sprintf('Contrast: %s   Threshold: %s   Covariate: %s', contrast,num2str(threshold),covariate)
    
    matlabbatch{1}.spm.tools.snpm.inference.SnPMmat = {sprintf('%s%s/SnPM.mat',output_header,contrast)};
    matlabbatch{1}.spm.tools.snpm.inference.Thr.Clus.ClusSize.CFth = threshold;
    matlabbatch{1}.spm.tools.snpm.inference.Thr.Clus.ClusSize.ClusSig.FWEthC = 0.05;
    matlabbatch{1}.spm.tools.snpm.inference.Tsign = 1;
    matlabbatch{1}.spm.tools.snpm.inference.WriteFiltImg.name = sprintf('SnPM_filtered_%s',threshStr);
    matlabbatch{1}.spm.tools.snpm.inference.Report = 'FWEreport';
    save(fullfile(condir,['Part2 -' date '.mat']),'matlabbatch');
    spm('defaults', 'FMRI');
    spm_jobman('serial', matlabbatch);
    saveas(gcf,'ClusterThreshold.png')
  cd(scriptdir)  