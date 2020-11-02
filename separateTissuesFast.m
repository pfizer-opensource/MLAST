% separateTissuesFast()
% Mary Kate Montgomery
% March 2019
%
% Function to cluster pixels into 4 groups: mask, lung, soft-tissue, and 
% in-between using a simple otsu thresholding algorithm. To be used in
% testing or when using large datasets.

function [tissues] = separateTissuesFast(maskedIm,boneThresh)
% Prepare data
[dy, dx, dz] = size(maskedIm);
maskedIm(maskedIm>=boneThresh) = 0;
imTemp = reshape(maskedIm,[dx*dy*dz,1]);
% Compute threshold
T = multithresh(imTemp(imTemp~=0),2);
% Threshold data and save variables
tissues = struct;
tissues.lung = single(maskedIm.*(maskedIm<T(1)));
tissues.softTissue = single(maskedIm.*(maskedIm>T(2)));
tissues.intermediate = single(maskedIm.*(min(maskedIm>T(1),maskedIm<T(2))));
end