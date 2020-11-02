% reshapeMaskWatershed()
% Mary Kate Montgomery
% March 2019
%
% Function to reshape a mask by removing the peninsulas using a watershed
% algorithm

function sliceOutput = reshapeMaskWatershed(sliceInput)
[dy, dx] = size(sliceInput);
if sum(sum(sliceInput)) > 0
    % Take inverse of distance transform
    distMap = -bwdist(uint16(~sliceInput));
    distMap(~sliceInput) = Inf;
    % Flatten bottom
    maxDepth = 1*median(distMap(distMap~=Inf));
    distMap(distMap<maxDepth) = maxDepth;
    % Compute watershed
    watershedMap = watershed(distMap);
    watershedMap(~sliceInput) = 0;
    % Take largest region
    allRegions = regionprops(watershedMap);
    allAreas = zeros(numel(allRegions),1,'single');
    for i = 1:numel(allRegions); allAreas(i) = allRegions(i).Area; end
    [~,maxAreaInd] = max(allAreas);
    % Save to output
    sliceOutput = zeros([dy,dx],'single');
    sliceOutput(watershedMap==maxAreaInd) = 1;
else
    sliceOutput = sliceInput;
end
end