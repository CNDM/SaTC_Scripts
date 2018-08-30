%-----------------------------------------------------------------------
% Job saved on 26-Mar-2018 18:27:53 by cfg_util (rev $Rev: 6460 $)
% spm SPM - SPM12 (6685)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
%Subs completed: 301:307, 311:313



contrasts = {'PosIntr','PosWill','NegWill'};
%subs = [301:307,311:322, 324:326, 328, 329];
%subs = [302:307,311:313];
%subs = [314:322, 324:326, 328:329];
subs = 329;
datadir = '/Users/CNDM/Dropbox/SaTCPrivacyGrant/SaTC3/fMRIAnalyses/fMRI_Data/ReconScans/'
specific = {'Willingness','Attractiveness','Intrusiveness'};

% Loop through the subjects
for s = subs
    s = num2str(s)
    mriSubdir = fullfile(datadir,sprintf('%s_3D',s));
    runs = {'Decision1','Decision2'};
    l = [366];
    DecisionSession = [];
    
    %   Grabbing Scans
    for r=1:length(runs)
        session={};
        cd(fullfile(mriSubdir,runs{r},'Non Moco'));
        funcFiles = struct2cell(dir('swas*.nii'));
        funcHeadidx = strfind(funcFiles{1,1},'_');
        funcHead = funcFiles{1}(1:funcHeadidx);
        for i=7:l(1)
            if i<10
                session{i-6,1}=(fullfile(mriSubdir,runs{r},'Non Moco', [funcHead '00' num2str(i) '.nii,1']));
            elseif i<100
                session{i-6,1}=(fullfile(mriSubdir,runs{r},'Non Moco', [funcHead '0' num2str(i) '.nii,1']));
            else
                session{i-6,1}=(fullfile(mriSubdir,runs{r},'Non Moco', [funcHead num2str(i) '.nii,1']));
            end
        end
        DecisionSession = [DecisionSession;session];
    end
    for c = contrasts % Loop through the 3 contrast folders
        switch c{:};
            case 'PosIntr' %Change to appropriate directory, appropriate VOI names
                cd(sprintf('%s%s_3D/Decision1/AI_Decision_Model/Positive_Intrusiveness_PPI',datadir,s));
                voi = {'LAIns','RAIns','LPPC','PCC','BilatVis','DmPFC','LITG'};
            case 'PosWill'
                cd(sprintf('%s%s_3D/Decision1/AI_Decision_Model/Positive_Willingness_PPI',datadir,s));
                voi = {'LPPC','RVis','Lamyg','LDLPFC','RDLPFC'};
            case 'NegWill'
                cd(sprintf('%s%s_3D/Decision1/AI_Decision_Model/Negative_Willingness_PPI',datadir,s));
                voi = {'RPPC','LVis'};
        end
        contrDir = pwd;
        
        for v = voi    %Loop through the voi's
            voiDir = fullfile(contrDir,v{:})
            for spec = specific %Loop through each voi's contrast (Willingness, attractiveness, intrusiveness)
                specDir = sprintf('%s/%s_%s',voiDir,v{:},spec{:});
                cd(specDir)
                cmd = sprintf('load PPI_%s_%s.mat',v{:},spec{:});
                eval(cmd) %load ppi file
                
                
                matlabbatch{1}.spm.stats.fmri_spec.dir = {specDir};
                matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'scans';
                matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2;
                matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
                matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;
                %%
                matlabbatch{1}.spm.stats.fmri_spec.sess.scans = DecisionSession;
                %%
                matlabbatch{1}.spm.stats.fmri_spec.sess.cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
                matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {''};
                matlabbatch{1}.spm.stats.fmri_spec.sess.regress(1).name = 'PPI - Interaction';
                %%
                matlabbatch{1}.spm.stats.fmri_spec.sess.regress(1).val = PPI.ppi
                %%
                matlabbatch{1}.spm.stats.fmri_spec.sess.regress(2).name = sprintf('%s - BOLD',v{:});
                %%
                matlabbatch{1}.spm.stats.fmri_spec.sess.regress(2).val = PPI.Y
                %%
                matlabbatch{1}.spm.stats.fmri_spec.sess.regress(3).name = spec{:};
                %%
                matlabbatch{1}.spm.stats.fmri_spec.sess.regress(3).val = PPI.P
                %%
                matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {''};
                matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;
                matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
                matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
                matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
                matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
                matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
                matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
                matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
                matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
                matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
                matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
                matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
                matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'PPI Interaction';
                matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1 0 0];
                matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
                matlabbatch{3}.spm.stats.con.delete = 0;
                %% Save batch file and run
                save(fullfile(voiDir,[spec{:} '_job.mat']),'matlabbatch');
                spm('defaults', 'FMRI');
                spm_jobman('serial', matlabbatch);
                %movefile(fullfile(voiDir,[spec{:} '_job.mat'],specDir))
            end 
        end
    end
end

        
    