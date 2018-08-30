function SnPMBatch_script()
%-----------------------------------------------------------------------
%%% This script will run the Matlab toolbox SnPM on your second level
%%% analyses to find cluster thresholds for your analysis. Must have SnPM
%%% installed.

%%% You do not need to make any changes if you do not want to. This file
%%% assumes that you are finding thresholds on second-level analyses and
%%% that the model name is the name of the folder where the first-level
%%% contrasts are (based on the structure of 
%%% SUBJECT -> MODEL -> contrasts.con


%%% You will be prompted to first choose a directory to output to

%%% Next you will be prompted to choose a directory that has your
%%% second-level analyses in it. The script will select all SPM.mat files
%%% in any folder within that directory.

%%% Third you will be asked to select the thresholds you would like to
%%% check at. You may choose more than one. If you want to select different
%%% thresholds, you must write them in the thresholds variable as a cell of
%%% strings

%%% Finally you will choose what models/contrasts you actually want to run.
%%% If you want to run every one just select all,
%-----------------------------------------------------------------------

% Select here or in gui

output_header = []; %Output Folder
secondLevelFolder = {};
thresholds = {};


%-----------------------------------------------------------------------
%-----------------------------------------------------------------------




scriptDir = pwd;
cd('..'); mainDir = pwd;

if isempty(output_header)
    output_header = uigetdir(pwd,'Choose a folder to output all SnPM data');
    if output_header == 0; return; end
end

if isempty(secondLevelFolder)
    secondLevelFolder = uigetdir(pwd,'Choose the Second Level folder that has the SPM.mat file. If you choose a folder that has multiple folders that have SPM.mat files, every one will be selected.');
    if secondLevelFolder == 0; return; end
end

if isempty(thresholds)
    threshold_names = {'0.01','0.005','0.001'};
    threshold_selection = listdlg('ListString',threshold_names,...
        'SelectionMode','multiple',...
        'PromptString','Choose threshold level to analyze.');
    if isempty(threshold_selection)==1; return; end
end
thresholds = threshold_names(threshold_selection);


spmFiles = get_any_files('SPM.mat',secondLevelFolder);

for i = 1:size(spmFiles,1)
    spmFiles_selection{i,1} = spmFiles{i}(length(secondLevelFolder)+2:end-8);
end

%spmFileSelection =
SPM_selection = listdlg('ListString',spmFiles_selection,...
    'SelectionMode','multiple',...
    'PromptString','Choose models/contrasts to analyze.');
if isempty(SPM_selection)==1; return; end

spmFiles = spmFiles(SPM_selection)


for c=1:size(spmFiles,1)
    load(spmFiles{c});
    
    % Grab the contrasts from the SPM file
    for i = 1:size(SPM.xY.VY,1)
        contrasts{i,1} = SPM.xY.VY(i).fname;
    end
    
    %Grab Model name and Directory name.
    % (ASSUMES model name is the name of the folder where the contrasts is)
    splitDir = strsplit(contrasts{1},filesep);
    modelName = ['SnPM_' splitDir{end-1}];
    contrastName = SPM.xCon.name;
    
    
    fprintf('Working on model: %s,  Contrast: %s', modelName, contrastName)
    
    
    %Create condir if necessary
    for thresh_idx = 1:length(thresholds)
        
        condir=[output_header filesep modelName filesep thresholds{thresh_idx} filesep contrastName];
        if exist(condir)~=1 % exist requires string format
            mkdir(condir)
        end
        concell{1}=condir; %SPM requires directory in cell format.
        
        
        matlabbatch{1}.spm.tools.snpm.des.OneSampT.DesignName = 'MultiSub: One Sample T test on diffs/contrasts';
        matlabbatch{1}.spm.tools.snpm.des.OneSampT.DesignFile = 'snpm_bch_ui_OneSampT';
        matlabbatch{1}.spm.tools.snpm.des.OneSampT.dir = concell;
        %%
        matlabbatch{1}.spm.tools.snpm.des.OneSampT.P = contrasts
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
        matlabbatch{3}.spm.tools.snpm.inference.Thr.Clus.ClusSize.CFth = str2num(thresholds{thresh_idx});
        matlabbatch{3}.spm.tools.snpm.inference.Thr.Clus.ClusSize.ClusSig.FWEthC = 0.05;
        matlabbatch{3}.spm.tools.snpm.inference.Tsign = 1;
        matlabbatch{3}.spm.tools.snpm.inference.WriteFiltImg.name = 'SnPM_filtered';
        matlabbatch{3}.spm.tools.snpm.inference.Report = 'MIPtable';
        
        save(fullfile(condir,[contrastName '_SnPM -' date '.mat']),'matlabbatch');
        spm('defaults', 'FMRI');
        spm_jobman('serial', matlabbatch);
        saveas(gcf,'ClusterThreshold.fig')
    end
end
cd(scriptDir)
end


function yourFiles = get_any_files(targetFile,mainDir)

%Get any files you want from any directory. This script will spider through
%your directories to retrieve the "targetFile". Script compiled by Khoi Vo

cwd = pwd;
switch nargin
    case 1
        mainDir = uigetdir(cwd, 'Select main directory that contains yours files');
end
fileList = get_files(mainDir);

index = 1;
for j = 1:size(fileList,1)
    if strfind(fileList{j},targetFile) > 0
        yourFiles{index,1} = fileList{j};
        index = index+1;
    end
end

yourFiles(cellfun(@isempty,yourFiles)) = [];
end


function fileList = get_files(dname)

data = dir(dname);      % current directory
index = [data.isdir];  % directory index
fileList = {data(~index).name}';  % get file list

if ~isempty(fileList)
    fileList = cellfun(@(x) fullfile(dname,x),...  %add full path to data
        fileList,'UniformOutput',false);
end

subdir = {data(index).name};  % get subdirectory list
subindex = ~ismember(subdir,{'.','..'});  % index of subdirectories that are not '.' or '..'

for i = find(subindex)             
    nextdir = fullfile(dname,subdir{i});
    fileList = [fileList; get_files(nextdir)];   %#ok<*AGROW>
end
end