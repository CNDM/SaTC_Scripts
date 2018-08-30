function make_VOI_nuisance(contrast,voi,spmFile,dir)

switch contrast
    case 'PosIntr'
        c = 5;
        switch voi
            case 'LAIns'
                pos = [-39, 24, -12];
            case 'RAIns'
                pos = [33, 24, -21];
            case 'LPPC'
                pos = [-45, -51, 27];
            case 'DMPFC'
                pos = [-3, 45, 36];
            case 'PCC'
                pos = [-9, -54, 30];
            case 'LVis'
                pos = [-18, -90, -3];
            case 'RPFC'
                pos = [48, 21, 18];
            case 'LPFC'
                pos = [-30, 24, 45];
        end
    case 'PosWill'
        c = 1;
        switch voi
            case 'LPPC'
                pos = [-36, -24, 60];
            case 'Rcere'
                pos = [12, -54, -18];
            case 'Lamyg'
                pos = [-27, -9, -6];
            case 'LDLPFC'
                pos = [-18, 27, 39];
        end
    case 'NegWill'
        c = 2;
        switch voi
            case 'RPPC'
                pos = [36, -21, 51];
            case 'LVis'
                pos = [-9, -78, -3];
        end
end

matlabbatch{1}.spm.util.voi.spmmat = spmFile;
matlabbatch{1}.spm.util.voi.adjust = 0;
matlabbatch{1}.spm.util.voi.session = 1;
matlabbatch{1}.spm.util.voi.name = voi;
matlabbatch{1}.spm.util.voi.roi{1}.spm.spmmat = {''};
matlabbatch{1}.spm.util.voi.roi{1}.spm.contrast = c;
matlabbatch{1}.spm.util.voi.roi{1}.spm.conjunction = 1;
matlabbatch{1}.spm.util.voi.roi{1}.spm.threshdesc = 'none';
matlabbatch{1}.spm.util.voi.roi{1}.spm.thresh = 0.999;
matlabbatch{1}.spm.util.voi.roi{1}.spm.extent = 0;
matlabbatch{1}.spm.util.voi.roi{1}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});
matlabbatch{1}.spm.util.voi.roi{2}.sphere.centre = pos;
matlabbatch{1}.spm.util.voi.roi{2}.sphere.radius = 6;
matlabbatch{1}.spm.util.voi.roi{2}.sphere.move.fixed = 1;
matlabbatch{1}.spm.util.voi.expression = 'i1 & i2';
save(fullfile(dir.voi,[voi '_job.mat']),'matlabbatch');
spm('defaults', 'FMRI');
spm_jobman('serial', matlabbatch);

delete(sprintf('%s/VOI_%s_eigen.nii',dir.sub,voi))
delete(sprintf('%s/VOI_%s_mask.nii',dir.sub,voi))
movefile(sprintf('%s/VOI_%s_1.mat',dir.sub,voi),dir.voi)

end