% pullMetrics()
% Mary Kate Montgomery
% September 2018
%
% Function to pull results metrics and store in a 1x14 data matrix called
% "output"

function [output, tags] = pullMetrics(tissues,diaphragmMask,boneThresh,boneMask,ImgArray)

% Sort input variables
softTissue = tissues.softTissue;
lung = tissues.lung;
intermediate = tissues.intermediate;
clear tissues

% Pixel counts
st_ct = sum(sum(sum(softTissue>0)))/1000; %scale to mm^3
las_ct = sum(sum(sum(lung>0)))/1000;
ibw_ct = sum(sum(sum(intermediate>0)))/1000;
comb_ct = st_ct + ibw_ct;
tc_ct = st_ct + las_ct + ibw_ct;
d_ct = sum(sum(sum(diaphragmMask>0)))/1000;
pixCounts = [st_ct, las_ct, ibw_ct, comb_ct];

% Percentages of total
st_POT= st_ct/tc_ct*100;
las_POT = las_ct/tc_ct*100;
ibw_POT = ibw_ct/tc_ct*100;
comb_POT = comb_ct/tc_ct*100;
POTs = [st_POT, las_POT, ibw_POT, comb_POT];

% Mean Densities
st_meanDens = mean(ImgArray(softTissue>0));
las_meanDens = mean(ImgArray(lung>0));
ibw_meanDens = mean(ImgArray(intermediate>0));
comb_meanDens = (st_meanDens+ibw_meanDens)/2;
meanDensVals = [st_meanDens, las_meanDens, ibw_meanDens, comb_meanDens];

% Normalized Mean Densities
st_meanDens = mean(softTissue(softTissue>0));
las_meanDens = mean(lung(lung>0));
ibw_meanDens = mean(intermediate(intermediate>0));
comb_meanDens = (st_meanDens+ibw_meanDens)/2;
normMeanDensVals = [st_meanDens, las_meanDens, ibw_meanDens, comb_meanDens];

% Other
imgSize = size(softTissue,1)*size(softTissue,2)*size(softTissue,3);
bone_ct = sum(sum(sum(boneMask>0)));
other = [tc_ct, d_ct, imgSize, boneThresh, bone_ct];

% Export
output = [pixCounts, POTs, meanDensVals, normMeanDensVals, other];
tags = {'Tissue Volume','Tissue Percent of Total','Tissue Density','Normalized Tissue Density','Total Thoracic Count','Diaphragm Count','Total Image Size','Bone Threshold','Bone Count'};
end