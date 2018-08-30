function fileList = get_dicoms(dname)

switch nargin
    case 0
        dname = uigetdir('Choose directory of dicoms');
end

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
    fileList = [fileList; get_dicoms(nextdir)];   %#ok<*AGROW>
end
