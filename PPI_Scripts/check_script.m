%contrasts = {'PosIntr','PosWill','NegWill'};
contrasts = {'NegWill'};
subs = [301:307,311:322, 324:326, 328, 329];
%subs = [302:307,311:313];
%subs = [326, 328:329];
datadir = '/Users/CNDM/Dropbox/SaTCPrivacyGrant/SaTC3/fMRIAnalyses/fMRI_Data/ReconScans/'
ppi_contrasts = {[1,2,1],[2,2,1],[3,2,1]};

idx = 1;
for s = subs
    %Define spm file from model for spm
    for c = contrasts %Loop through contrasts
        switch c{:};
            case 'PosIntr' %Change to appropriate directory, appropriate VOI names
                cd(sprintf('%s%d_3D/Decision1/AI_Decision_Model/Positive_Intrusiveness_PPI',datadir,s));
                voi = {'LAIns','RAIns','LPPC','PCC','BilatVis','DmPFC','LITG'};
            case 'PosWill'
                cd(sprintf('%s%d_3D/Decision1/AI_Decision_Model/Positive_Willingness_PPI',datadir,s));
                voi = {'LPPC','RVis','Lamyg','LDLPFC','RDLPFC'};
            case 'NegWill'
                cd(sprintf('%s%d_3D/Decision1/AI_Decision_Model/Negative_Willingness_PPI',datadir,s));
                %voi = {'RPPC','LVis'};
                voi = {'LVis'};
        end
        contrDir = pwd; %Define directory for contrasts
        for v = voi %Loop through each VOI
            voiDir = fullfile(contrDir,v{:}) %Create VOI directory
            cd(voiDir)
            load([voiDir '/VOI_' v{:} '_1.mat'])
            data(idx).XYZmm = xY.XYZmm;
            data(idx).X0 = xY.X0;
            data(idx).y = xY.y;
            data(idx).u = xY.u;
            data(idx).v = xY.v;
            data(idx).s = xY.s;
            idx = idx+1;
        end
    end
end
            