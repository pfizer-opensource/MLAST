% loadScan()
% Mary Kate Montgomery
% October 2018
%
% Function to load all images in a scan

function resultImage = loadScan(fileLoc, fileList, fileType)
dz = numel(fileList);
% Read image stack
if strcmp(fileType,'dcm') % If dicom format
    tempImage = dicomread([fileLoc '\' fileList{1}]);
    [dy, dx] = size(tempImage);
    resultImage = zeros([dy, dx, dz]);
    for z = 1:dz
        resultImage(:,:,z) = dicomread([fileLoc '\' fileList{z}]);
    end
else % If non-dicom format
    tempImage = imread([fileLoc '\' fileList{1}]);
    [dy, dx] = size(tempImage);
    resultImage = zeros([dy, dx, dz]);
    for z = 1:dz
        resultImage(:,:,z) = imread([fileLoc '\' fileList{z}]);
    end
end
end