% createLabelIm()
% Mary Kate Montgomery
% March 2019
%
% Function to generate a 3D image containing all major segmentation
% components for export

function [labelIm, labelTags] = createLabelIm(tissues, bones, diaphragm)
    [dy,dx,dz] = size(bones);
    labelIm = zeros([dy, dx, dz],'int8');
    labelIm(bones==1) = 1;
    labelIm(diaphragm==1) = 2;
    labelIm(tissues.lung > 0) = 3;
    labelIm(tissues.intermediate > 0) = 4;
    labelIm(tissues.softTissue > 0) = 5;
    labelTags = {'Bone','Diaphragm','Lung','Intermediate','Soft Tissue'};
end