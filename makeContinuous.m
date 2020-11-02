% makeContinuous()
% Mary Kate Montgomery
% February 2019
%
% Function to adjust bw image so that it contains only 1 region. If input
% contains more than 1 region, output uses largest region
function bwOut = makeContinuous(bwIn,conn)
% Separate regions
CC = bwconncomp(bwIn,conn);
if CC.NumObjects > 0
    % Calculate number of pixels in each region
    numPix = zeros(numel(CC),1);
    for i = 1:CC.NumObjects
        numPix(i) = numel(CC.PixelIdxList{i});
    end
    % Take largest region
    [~, maxInd] = max(numPix);
    bwOut = bwIn;
    for i = 1:CC.NumObjects
        if i ~= maxInd
            bwOut(CC.PixelIdxList{i}) = 0;
        end
    end
else
    bwOut = zeros(size(bwIn));
end
end