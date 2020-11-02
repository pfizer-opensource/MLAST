% saveQcLabelImgs()
% Mary Kate Montgomery
% July 2019
%
% Function to create and save label images of MLAST scans which have been
% flagged for QC

function saveQcLabelImgs(qcItems, sortedData)

qcData = sortedData(qcItems==1);

for i = 1:numel(qcData)
    % Pull individual label image
    thisData = qcData{i};
    saveDir = thisData.mouseNum;
    segIm = thisData.LabelIm;
    
    % Save Image
    writeImgStack(segIm,'MLAST_Results',saveDir,'.tif'); 
end
end
