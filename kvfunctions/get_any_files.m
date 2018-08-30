function yourFiles = get_any_files(targetFile,mainDir)

%Get any files you want from any directory. This script will spider through
%your directories to retrieve the "targetFile". Script compiled by Khoi Vo

cwd = pwd;
switch nargin
    case 1
        mainDir = uigetdir(cwd, 'Select main directory that contains yours files');
end
fileList = get_files(mainDir);

for j = 1:size(fileList,1)
    if strfind(fileList{j},targetFile) > 0
        yourFiles{j,1} = fileList{j};
    end
end
yourFiles(cellfun(@isempty,yourFiles)) = [];

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
