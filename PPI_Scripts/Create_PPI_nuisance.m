%-----------------------------------------------------------------------
% Job saved on 26-Mar-2018 18:18:15 by cfg_util (rev $Rev: 6460 $)
% spm SPM - SPM12 (6685)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
cwd = pwd;

%Overwrite previously written PPI's?
OVERWRITE = 0;
%Subs completed: 301:307, 311:313

contrasts = {'PosIntr','PosWill','NegWill'};
%subs = [301:307,311:322, 324:326, 328, 329];
subs = [311:322, 324:326, 328, 329];

datadir = '/Users/CNDM/Dropbox/SaTCPrivacyGrant/SaTC3/fMRIAnalyses/fMRI_Data/ReconScans'
ppi_contrasts = {[1,2,1],[2,2,1],[3,2,1]};


for s = subs
    subDir = sprintf('%s/%d_3D/Decision1/AI_Decision_Model_nuisance',datadir,s);
    %Define spm file from model for spm
    spmFile = {sprintf('%s/SPM.mat',subDir)}
    for c = contrasts %Loop through contrasts
        switch c{:};
            case 'PosIntr' %Change to appropriate directory, appropriate VOI names
                conDir = sprintf('%s/Positive_Intrusiveness_PPI',subDir);
                voi = {'LAIns','RAIns','LPPC','DMPFC','PCC','LVis','RPFC','LPFC'};
            case 'PosWill'
                conDir = sprintf('%s/Positive_Willingness_PPI',subDir);
                voi = {'LPPC','Rcere','Lamyg','LDLPFC'};
            case 'NegWill'
                conDir = sprintf('%s/Negative_Willingness_PPI',subDir);
                voi = {'RPPC','LVis'};
        end
        for v = voi %Loop through each VOI
            
            voiDir = fullfile(conDir,v{:}) %Create VOI directory
            if exist(voiDir,'dir')==0
                mkdir(voiDir);
            end

            dir.sub = subDir;
            dir.voi = voiDir;
            
            if ~exist(sprintf('%s/VOI_%s_1.mat',voiDir,v{:}))
                make_VOI_nuisance(c{:},v{:},spmFile,dir)
            end
            cd(voiDir)
            
            % Define VOI file for spm
            ppi_voi = {sprintf('%s/VOI_%s_1.mat',voiDir,v{:})};
            for pc = ppi_contrasts %Loop through contrasts in model
                if pc{:} == [1,2,1]
                    ppi_name = sprintf('%s_Willingness',v{:});
                elseif pc{:} ==  [2,2,1]
                    ppi_name = sprintf('%s_Attractiveness',v{:});
                elseif pc{:} ==  [3,2,1]
                    ppi_name = sprintf('%s_Intrusiveness',v{:});
                end
                
                ppi_dir = fullfile(voiDir,ppi_name);
                if exist(ppi_dir,'dir')==0
                    mkdir(ppi_dir);
                end
                if ~exist(sprintf('%s/PPI_%s.mat',ppi_dir,ppi_name))
                    matlabbatch{1}.spm.stats.ppi.spmmat = spmFile;
                    matlabbatch{1}.spm.stats.ppi.type.ppi.voi = ppi_voi;
                    matlabbatch{1}.spm.stats.ppi.type.ppi.u = pc{:};
                    matlabbatch{1}.spm.stats.ppi.name = ppi_name;
                    matlabbatch{1}.spm.stats.ppi.disp = 0;
                    %% Save batch file and run
                    save(fullfile(voiDir,[ppi_name '_job.mat']),'matlabbatch');
                    spm('defaults', 'FMRI');
                    spm_jobman('serial', matlabbatch);
                    movefile(sprintf('%s/PPI_%s.mat',subDir,ppi_name),ppi_dir);
                end
                
            end
            cd(cwd)
        end
        
    end
end
