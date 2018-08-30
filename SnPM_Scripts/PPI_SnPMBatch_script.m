function PPI_SnPMBatch_script(s)
%-----------------------------------------------------------------------
% Job saved on 03-Nov-2017 09:59:40 by cfg_util (rev $Rev: 6460 $)
% spm SPM - SPM12 (6685)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
scriptdir = pwd;
%Load contrast info from 1st subject
sNum = num2str(s(1));
output_header = '/Users/CNDM/Dropbox/SaTCPrivacyGrant/SaTC3/fMRIAnalyses/PPI/SnPM'
%-----------------------
%   Dropbox Directory
    datadir='/Users/CNDM/Dropbox/SaTCPrivacyGrant/SaTC3/fMRIAnalyses/fMRI_Data/ReconScans/';
%------------------------


contrasts = {'Positive_Intrusiveness_PPI','Positive_Willingness_PPI','Negative_Willingness_PPI'};
specific = {'Willingness','Attractiveness','Intrusiveness'};
p_val = {'0.005','0.01','0.001'};

%   Name model directory

for p = p_val
    for c = contrasts
        modeldir = sprintf('%s%s_3D/Decision1/AI_Decision_Model',datadir, sNum);
        switch c{:};
            case 'Positive_Intrusiveness_PPI' %Change to appropriate directory, appropriate VOI names
                cd(sprintf('%s/Positive_Intrusiveness_PPI',modeldir));
                voi = {'LAIns','RAIns','LPPC','PCC','BilatVis','DmPFC','LITG'};
            case 'Positive_Willingness_PPI'
                cd(sprintf('%s/Positive_Willingness_PPI',modeldir));
                voi = {'LPPC','RVis','Lamyg','LDLPFC','RDLPFC'};
            case 'Negative_Willingness_PPI'
                cd(sprintf('%s/Negative_Willingness_PPI',modeldir));
                voi = {'RPPC','LVis'};
        end
        contrDir = pwd;
        
        for v = voi
            voiDir = fullfile(contrDir,v{:});
            for spec = specific
                specDir = sprintf('%s/%s_%s/',voiDir,v{:},spec{:});
                cd(specDir)
                
                
                
                
                
                %Load first subject's contrast
                conspm=[specDir 'SPM.mat'];
                cmd = ['load ' [specDir 'SPM.mat']];
                eval(cmd);
                
                %How many contrasts?
                cons=length(SPM.xCon); %Only building the first, Positive contrast
                
                for contrast=1:cons
                    fprintf('Working on Contrast %d / %d \n', contrast, cons)
                    %Create condir if necessary
                    conname=[sprintf('%s',SPM.xCon(contrast).name)];
                    condir=fullfile(output_header,['p_' p{1}(3:end)],c{:},v{:},spec{:}, conname);
                    if exist(condir)~=1 % exist requires string format
                        mkdir(condir)
                    end
                    concell{1}=condir; %SPM requires directory in cell format.
                    scans=cell(length(s),1);
                    for sub=1:length(s)
                        modeldir = sprintf('%s%s_3D/Decision1/AI_Decision_Model/%s/%s/%s_%s',datadir, num2str(s(sub)),c{:},v{:},v{:},spec{:});
                        if contrast<10
                            scans(sub)={[modeldir '/con_000' num2str(contrast) '.nii,1']};
                        else
                            scans(s)={[modeldir '/con_00' num2str(contrast) '.nii,1']};
                        end
                    end %subj loop
                    sprintf('Contrast: %s  VOI: %s   SPEC: %s    Threshold: %s', c{:},v{:},spec{:},p_val{:});
                    matlabbatch{1}.spm.tools.snpm.des.OneSampT.DesignName = 'MultiSub: One Sample T test on diffs/contrasts';
                    matlabbatch{1}.spm.tools.snpm.des.OneSampT.DesignFile = 'snpm_bch_ui_OneSampT';
                    matlabbatch{1}.spm.tools.snpm.des.OneSampT.dir = concell;
                    %%
                    matlabbatch{1}.spm.tools.snpm.des.OneSampT.P = scans
                    %%
                    matlabbatch{1}.spm.tools.snpm.des.OneSampT.cov = struct('c', {}, 'cname', {});
                    matlabbatch{1}.spm.tools.snpm.des.OneSampT.nPerm = 5000;
                    matlabbatch{1}.spm.tools.snpm.des.OneSampT.vFWHM = [0];
                    matlabbatch{1}.spm.tools.snpm.des.OneSampT.bVolm = 1;
                    matlabbatch{1}.spm.tools.snpm.des.OneSampT.ST.ST_later = -1;
                    matlabbatch{1}.spm.tools.snpm.des.OneSampT.masking.tm.tm_none = 1;
                    matlabbatch{1}.spm.tools.snpm.des.OneSampT.masking.im = 1;
                    matlabbatch{1}.spm.tools.snpm.des.OneSampT.masking.em = {''};
                    matlabbatch{1}.spm.tools.snpm.des.OneSampT.globalc.g_omit = 1;
                    matlabbatch{1}.spm.tools.snpm.des.OneSampT.globalm.gmsca.gmsca_no = 1;
                    matlabbatch{1}.spm.tools.snpm.des.OneSampT.globalm.glonorm = 1;
                    matlabbatch{2}.spm.tools.snpm.cp.snpmcfg(1) = cfg_dep('MultiSub: One Sample T test on diffs/contrasts: SnPMcfg.mat configuration file', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','SnPMcfg'));
                    matlabbatch{3}.spm.tools.snpm.inference.SnPMmat(1) = cfg_dep('Compute: SnPM.mat results file', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','SnPM'));
                    matlabbatch{3}.spm.tools.snpm.inference.Thr.Clus.ClusSize.CFth = str2num(p{:});
                    matlabbatch{3}.spm.tools.snpm.inference.Thr.Clus.ClusSize.ClusSig.FWEthC = 0.05;
                    matlabbatch{3}.spm.tools.snpm.inference.Tsign = 1;
                    matlabbatch{3}.spm.tools.snpm.inference.WriteFiltImg.name = 'SnPM_filtered';
                    matlabbatch{3}.spm.tools.snpm.inference.Report = 'MIPtable';
                    
                    save(fullfile(condir,[conname 'SecondLevel -' date '.mat']),'matlabbatch');
                    spm('defaults', 'FMRI');
                    spm_jobman('serial', matlabbatch);
                    saveas(gcf,'ClusterThreshold.fig');
                end
            end
        end
    end
end
end