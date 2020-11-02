% uCT_autoSegment
% Mary Kate Montgomery
% February 2019
%
% Function to load, mask, and segment thoracic mCT scan. Calls all
% necessary functions to perform single-scan segmentation.

function dataOut = uCT_autoSegment(dirName, segmentationMethod, allScanDirs)

% Preallocate output variables
dataOut = preallocateData();

% Load Scan
if exist('allScanDirs','var')
    [fileList, data.mouseNum, data.scanDate, fileType] = scanInfo(dirName,allScanDirs);
else
    [fileList, data.mouseNum, data.scanDate, fileType] = scanInfo(dirName);
end

if ~ numel(fileList) > 0
    disp('No images found');
    return;
end
rawIm = loadScan(dirName, fileList, fileType);

% Normalize on 0-1 scale
normFactor = prctile(rawIm(:),99.5); % Normalize by 99th percentile, not max
normIm = rawIm./normFactor;
normIm(normIm>1) = 1;
% clear rawIm

% Get mask using ribcage
boneThresh = getBoneThresh(normIm);
normIm = single(normIm);
boneMask = segmentRibcage(normIm,boneThresh,3);

thoracicMask = createLungMask(boneMask);
maskedIm = normIm.*thoracicMask;
% clear normIm

% Break into regions
if strcmp(segmentationMethod,'Kmeans')
    [tissues,C] = separateTissues(double(maskedIm),boneThresh);
elseif strcmp(segmentationMethod,'Otsu')
    % Use otsu thresholding (fast)
    [tissues] = separateTissuesFast(double(maskedIm),boneThresh);
end

% Find and remove diaphragm
[diaphragmMask] = idDiaphragm(maskedIm,tissues);
tissues = cropTissues(tissues,diaphragmMask);

% Find trachea and use as cutoff point
[cutoff, tracheaMask] = idTrachea(tissues.lung,thoracicMask,maskedIm);
tissues = cropTissues(tissues,tracheaMask);

clear tracheaMask thoracicMask

% Find and remove any discontinuities in mask
allPix = (diaphragmMask+tissues.softTissue+tissues.lung+tissues.intermediate)>0;
allPixCont = single(makeContinuous(allPix,6)); clear allPix
tissues = cropTissues(tissues,~allPixCont); clear allPixCont

% Calculate and save results
[data.Results, data.ResultsTags] = pullMetrics(tissues,diaphragmMask,boneThresh,boneMask,maskedIm.*normFactor);

% Create 8-bit label image
[data.LabelIm, data.LabelImTags] = createLabelIm(tissues,boneMask,diaphragmMask);

% Output
dataOut= data;
end