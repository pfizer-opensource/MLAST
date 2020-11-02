% MLAST_main_for_GUI()
% Mary Kate Montgomery
% March 2019
%
% MLAST main function. Allows user to select study directory and reference
% log, then uses a parfor loop to iterate through all study folders and
% runs auto-segmentation on each scan.

function [wasData, numScans] = MLAST_main_for_GUI(inputVars)

% Parse inputs
loadPath = inputVars.loadPath;
tagNames = inputVars.tagNames;
tagColors = inputVars.tagColors;
saveROIlabels = inputVars.saveROIlabels;
saveQClabels = inputVars.saveQClabels;
exportDataTable = inputVars.exportDataTable;
saveData = inputVars.saveData;
segMethod = inputVars.segMethod;
saveFileName = inputVars.saveFileName;
metricInd = inputVars.whichMetrics;

% Segment all scans in folder structure
allSubfolders = strsplit(genpath(loadPath),';')';
allSubfolders = allSubfolders(~cellfun('isempty',allSubfolders));

% How many scans to analyze
numScans = 0; allScanDirs = {};
for parInd = 1:numel(allSubfolders)
    if ~isempty(dir([allSubfolders{parInd} '\*rec0*.tif']))
        numScans = numScans + 1;
        allScanDirs{numScans} = allSubfolders{parInd};
    end
end
if numScans == 0
    wasData = 0;
    return;
end

% Update user
disp('Progress:')

% Analyze
parfor parInd = 1:numel(allSubfolders)
    if ~isempty(dir([allSubfolders{parInd} '\*rec0*.tif']))
        allData{parInd} = uCT_autoSegment(allSubfolders{parInd},segMethod,allScanDirs);
    end
end

% Update user
disp('Segmentation Complete'); pause(.5);
disp('Sorting...')

% Collect metadata
metaData = collectMetaData(allSubfolders, loadPath);

% Save individual ROI fields
if saveROIlabels
    for ind = 1:numel(allData)
        fileName = 'MLAST_Results';
        filePath = allSubfolders{ind};
        data = allData{ind};
        if isempty(data)
            continue;
        end
        labelIm = data.LabelIm;
        writeImgStack(labelIm,fileName,filePath,'.tif');
    end
end

% Export data to Excel sheet
if exportDataTable
    outputFileName = fullfile(loadPath,saveFileName);
    exportAsExcel(outputFileName, metaData,tagNames,allData,metricInd,tagColors,saveQClabels);
end

% Save copy of data
if saveData
    save(fullfile(loadPath,'allData.mat'),'allData');
end
wasData = 1;
end