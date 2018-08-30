function SnPM_with_Mask_Part1(s,mask)

scriptdir = pwd;
%Load contrast info from 1st subject
sNum = num2str(s(1));
output_header = sprintf('/Users/CNDM/Dropbox/SaTCPrivacyGrant/SaTC3/fMRIAnalyses/SnPM/Masked/Masked_with_%s/',mask)
%-----------------------
%   Dropbox Directory
datadir='/Users/CNDM/Dropbox/SaTCPrivacyGrant/SaTC3/fMRIAnalyses/';
%------------------------

%   Name model directory
modeldir = sprintf('%sfMRI_Data/ReconScans/%s_3D/Decision1/AI_Decision_Model/',datadir, sNum);

%    Mask Directory
maskdir = sprintf('%sfMRI_Data/ReconScans/Masks/',datadir);
switch mask
    case 'Benefit'
        maskdir = sprintf('%sBenefit/',maskdir);
    case 'Question'
        maskdir = sprintf('%sQuestion/',maskdir);
end

modeldir = sprintf('%sfMRI_Data/ReconScans/%s_3D/Decision1/AI_Decision_Model/',datadir, sNum);

%Load first subject's contrast
conspm=[modeldir 'SPM.mat'];
cmd = ['load ' [modeldir 'SPM.mat']];
eval(cmd);

%How many contrasts?
cons=length(SPM.xCon); %Only building the first, Positive contrast

threshold = {'01','005','001'};
PosNeg = {'PosMask','NegMask'};
for thresh = 1:3
    for c = 1:cons
        for maskType = 1:2
            conname=[sprintf('%s',SPM.xCon(c).name)];
            condir=[output_header conname '/' PosNeg{maskType} threshold{thresh}];
            if maskType == 1
                head = 'pos';
            elseif maskType ==2
                head = 'neg';
            end   
                if exist(condir)~=1 % exist requires string format
                    mkdir(condir)
                end
                concell{1}=condir; %SPM requires directory in cell format.
                scans=cell(length(s),1);
                for sub=1:length(s)
                    modeldir = sprintf('%sfMRI_Data/ReconScans/%s_3D/Decision1/AI_Decision_Model/',datadir, num2str(s(sub)));
                    if cons<10
                        scans(sub)={[modeldir 'con_000' num2str(c) '.nii,1']};
                    else
                        scans(s)={[modeldir 'con_00' num2str(c) '.nii,1']};
                    end
                end %subj loop
                
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
                
                matlabbatch{1}.spm.tools.snpm.des.OneSampT.masking.em = {sprintf('%s%s%sMask.nii',maskdir,head,threshold{thresh})};
                
                matlabbatch{1}.spm.tools.snpm.des.OneSampT.globalc.g_omit = 1;
                matlabbatch{1}.spm.tools.snpm.des.OneSampT.globalm.gmsca.gmsca_no = 1;
                matlabbatch{1}.spm.tools.snpm.des.OneSampT.globalm.glonorm = 1;
                matlabbatch{2}.spm.tools.snpm.cp.snpmcfg(1) = cfg_dep('MultiSub: One Sample T test on diffs/contrasts: SnPMcfg.mat configuration file', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','SnPMcfg'));
                save(fullfile(condir,[conname 'Masked -'  date '.mat']),'matlabbatch');
                spm('defaults', 'FMRI');
                spm_jobman('serial', matlabbatch);
            end
        end
    end
cd(scriptdir)




