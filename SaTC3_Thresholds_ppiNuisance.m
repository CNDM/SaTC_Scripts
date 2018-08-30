function getThresholds_ppiNuisance()
scriptDir = pwd;
%xlwriteDir = ['/Users/CNDM/Dropbox/SaTCPrivacyGrant/SaTC3/fMRIAnalyses/Scripts/xlwrite'];
%analysisDir = ['/Users/CNDM/Dropbox/SaTCPrivacyGrant/SaTC3/fMRIAnalyses/SnPM/PPI_nuisance_models'];
%outputDir = ['/Users/CNDM/Dropbox/SaTCPrivacyGrant/SaTC3/fMRIAnalyses/Thresholds'];

xlwriteDir = ['C:\Users\Blaine Patrick\Dropbox\SaTCPrivacyGrant\SaTC3\fMRIAnalyses\Scripts'];
analysisDir = ['C:\Users\Blaine Patrick\Dropbox\SaTCPrivacyGrant\SaTC3\fMRIAnalyses\SnPM\IndDiff_Nuisance\DecisionModel_nuisance']
outputDir = ['C:\Users\Blaine Patrick\Dropbox\SaTCPrivacyGrant\SaTC3\fMRIAnalyses\Thresholds']


cd(xlwriteDir)
javaaddpath('poi_library/poi-3.8-20120326.jar');
javaaddpath('poi_library/poi-ooxml-3.8-20120326.jar');
javaaddpath('poi_library/poi-ooxml-schemas-3.8-20120326.jar');
javaaddpath('poi_library/xmlbeans-2.3.0.jar');
javaaddpath('poi_library/dom4j-1.6.1.jar');
javaaddpath('poi_library/stax-api-1.0.1.jar');
cd(scriptDir)

cd(analysisDir)
%modelDir = getDirs(dir);
bigData = [];

figs = get_any_files('ClusterThreshold.fig',analysisDir);


for f = 1:length(figs)
    figureFile = figs{f};
    figureFileSplit = strsplit(figureFile,filesep);
    
    open(figureFile)
    fig = gcf;
    h = findobj(fig,'-method','Text')
    x = array2table(h)
    if size(x,1) == 2
        threshold = x.h(1,1).String{1};
    elseif size(x,1) == 3
        threshold = x.h(2,1).String{1};
    elseif size(x,1) == 4
        threshold = fig.Children(1).XLabel.String;
    elseif size(x,1) == 5
        threshold = ['NOTSIG ' fig.Children(1).XLabel.String];
    elseif size(x,1) > 5
        threshold = x.h(7,1).String
    end
    
    
    bigData = [bigData;figureFileSplit(10),figureFileSplit(11),figureFileSplit(12),figureFileSplit(13),{threshold}]
    close
    %thresharray{1,cDir} = threshold;
    %data.model(mDir).threshold(tDir).contrast(cDir).thresholds = threshold
    %cd('..')
end
xlwrite([outputDir '/IndDiff_nuisanceThresholds'],bigData);
%xlwrite([analysisDir '/nuisanceThresholds'],threshDir',modelDir{mDir},'B1');
%data.model(mDir).threshold(tDir).contrast(cDir).thresholds = thresharray;
end




function outputDir = getDirs(x)
x = x(3:end) %Getting rid of previous dirs
index = [x.isdir];
idx = 1;
for i = 1:length(index)
    if index(i) == 1
        outputDir{idx,1} = x(i).name;
        idx = idx+1;
    end
end
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
