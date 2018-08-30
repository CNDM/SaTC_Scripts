function SnPM_with_Mask_Part2(threshold,mask)

scriptdir = pwd;
output_header = sprintf('/Users/CNDM/Dropbox/SaTCPrivacyGrant/SaTC3/fMRIAnalyses/SnPM/Masked/Masked_With_%s/',mask);
fileList = dir(output_header);
consList = struct2cell(fileList(4:end));
cons = consList(1,:);
thresh = num2str(threshold);
threshStr = thresh(3:end)
PosNeg = {'PosMask','NegMask'};

    for contrast = 1:length(cons)
            contrastName = cons{contrast};
            condir = sprintf('%s%s',output_header,cons{contrast});
            fileList_thresh = dir(condir);
            threshList = struct2cell(fileList_thresh(4:end));
            threshFolders = threshList(1,:);
            for m = 1:length(threshFolders)
                
                threshDir = sprintf('%s/%s/threshold_',condir,threshFolders{m},num2str(threshold));
                if exist(threshDir)~=1 % exist requires string format
                    mkdir(threshDir)
                end
                cd(threshDir)
                sprintf('Contrast: %s   Threshold: %s   Mask: %s', contrastName,num2str(threshold),mask)
                
                matlabbatch{1}.spm.tools.snpm.inference.SnPMmat = {sprintf('%s/%s/SnPM.mat',condir,threshFolders{m})};
                matlabbatch{1}.spm.tools.snpm.inference.Thr.Clus.ClusSize.CFth = threshold;
                matlabbatch{1}.spm.tools.snpm.inference.Thr.Clus.ClusSize.ClusSig.FWEthC = 0.05;
                matlabbatch{1}.spm.tools.snpm.inference.Tsign = 1;
                matlabbatch{1}.spm.tools.snpm.inference.WriteFiltImg.name = sprintf('SnPM_filtered_%s',threshStr);
                matlabbatch{1}.spm.tools.snpm.inference.Report = 'FWEreport';
                save(fullfile(threshDir,['Part2 -' date '.mat']),'matlabbatch');
                spm('defaults', 'FMRI');
                spm_jobman('serial', matlabbatch);
                saveas(gcf,'ClusterThreshold.fig')
            end
    end
    cd(scriptdir)
    