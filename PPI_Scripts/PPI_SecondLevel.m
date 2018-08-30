contrasts = {'Positive_Intrusiveness','Positive_Willingness','Negative_Willingness'};
subs = [301:307,311:322, 324:326, 328, 329];
datadir = '/Users/CNDM/Dropbox/SaTCPrivacyGrant/SaTC3/fMRIAnalyses/fMRI_Data/ReconScans/'
specific = {'Willingness','Attractiveness','Intrusiveness'};



scriptdir = pwd;
%Load contrast info from 1st subject
sNum = num2str(subs(1));

%-----------------------
%   Dropbox Directory
ppidir = '/Users/CNDM/Dropbox/SaTCPrivacyGrant/SaTC3/fMRIAnalyses/PPI_Analysis/';
datadir = '/Users/CNDM/Dropbox/SaTCPrivacyGrant/SaTC3/fMRIAnalyses/fMRI_Data/ReconScans/';
%------------------------
 for c = contrasts %Loop through contrasts
        switch c{:};
            case 'Positive_Intrusiveness' %Change to appropriate directory, appropriate VOI names
                outputcondir=[sprintf('%sPositive_Intrusiveness',ppidir)];
                voi = {'LAIns','RAIns','LPPC','PCC','BilatVis','DmPFC','LITG'};
            case 'Positive_Willingness'
                outputcondir=[sprintf('%sPositive_Willingness',ppidir)];
                voi = {'LPPC','RVis','Lamyg','LDLPFC','RDLPFC'};
            case 'Negative_Willingness'
                outputcondir=[sprintf('%sNegative_Willingness',ppidir)];
                voi = {'RPPC','LVis'};
        end
        for v = voi
            outputvoiDir = fullfile(outputcondir,v{:})
            if exist(outputvoiDir,'dir')==0
                mkdir(outputvoiDir);
            end
            for spec = specific
                outputspecDir = sprintf('%s/%s_%s_SecondLevel/',outputvoiDir,v{:},spec{:})
                if exist(outputspecDir,'dir')==0
                    mkdir(outputspecDir);
                end
                
                %Load first subject's contrast
                conspm=[datadir '301_3D/Decision1/AI_Decision_Model/' c{:} '_PPI/' v{:} '/' v{:} '_' spec{:}  '/SPM.mat'];
                cmd = ['load ' conspm];
                eval(cmd);
                
                %How many contrasts?
                cons=length(SPM.xCon); %Only building the first, Positive contrast
                
                for contrasts=1:cons
                    fprintf('Working on Contrast %d / %d \n', contrasts, cons)
                    %Create condir if necessary
                    conname=[sprintf('%s',SPM.xCon(contrasts).name)];
                    concell{1}=outputspecDir; %SPM requires directory in cell format.
                    scans=cell(length(subs),1);
                    index = 1;
                    for sub = subs
                        condir = sprintf('%s%d_3D/Decision1/AI_Decision_Model/%s_PPI',datadir,sub,c{:});
                        voiDir = fullfile(condir, v{:})
                        specDir = sprintf('%s/%s_%s/',voiDir,v{:},spec{:});
                        if contrasts<10
                            scans(index)={[specDir 'con_000' num2str(contrasts) '.nii,1']};
                        else
                            scans(index)={[specDir 'con_00' num2str(contrasts) '.nii,1']};
                        end
                        index = index+1;
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
                    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
                    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
                    %%
                    matlabbatch{3}.spm.stats.con.spmmat = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
                    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = SPM.xCon(contrasts).name;
                    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = 1;
                    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
                    %matlabbatch{3}.spm.stats.con.delete = 1;
                    
                    save(fullfile(outputspecDir,[conname 'SecondLevel -' date '.mat']),'matlabbatch');
                    spm('defaults', 'FMRI');
                    spm_jobman('serial', matlabbatch);
                    
                    
                end %con loop                
            end
            
        end
        
 end
