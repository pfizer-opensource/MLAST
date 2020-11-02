% scanInfo()
% Mary Kate Montgomery
% February 2019
%
% Function to ID scan information from host directory

function [imageList, mNum, scanDate, fileType] = scanInfo(dirName, allScanDirs)
% Mouse ID
mNum = dirName;

% Update user
if exist('allScanDirs','var')
    thisScanInd = find(strcmp(dirName,allScanDirs));
    disp(['Analyzing scan # ' num2str(thisScanInd) ' of ' num2str(numel(allScanDirs))]);
else
    disp(['Analyzing ' num2str(mNum)]);
end

% Scan Date
allFileStruct = dir(fullfile(dirName));
allFiles = cell(numel(allFileStruct),1);
for i = 1:numel(allFileStruct); allFiles{i} = allFileStruct(i).name; end
logName = allFiles{contains(allFiles,'.log')};
scanDate = pullScanDate(fullfile([dirName '\' logName]));
fileList = allFiles(contains(allFiles,'rec0'));

% Get File Type
fileTypeAll = cell(size(fileList)); for j = 1:numel(fileList); fileTypeAll{j} = fileList{j}(end-3:end); end
fileTypeAll = cell2mat(fileTypeAll);
fileType = mode(fileTypeAll);

% Take only image files
imageList = fileList(contains(fileList,fileType));
end