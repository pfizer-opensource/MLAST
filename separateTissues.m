% separateTissues.m
% Mary Kate Montgomery
% September 2018
%
% Function to use k-means algorithm to cluster pixels into 4 groups: mask,
% lung, soft-tissue, and in-between. Returns map of all cluster locations,
% as well as values of all cluster centroids. Clusters are sorted
% lowest-to-highest based on centroid value (mean density).

function [tissues, sortedC] = separateTissues(maskedIm, boneThresh)

[dy, dx, dz] = size(maskedIm);

% Perform kmeans
maskedIm(maskedIm>=boneThresh) = 0;
% 4 clusters = Soft Tissue, Lung, Intermediate, and mask
[kmap, C] = kmeans(reshape(maskedIm,[dx*dy*dz,1]),4); 
clear imTemp
kmap = single(reshape(kmap,[dy, dx, dz]));

% Reorder clusters
[sortedC, sortorder] = sort(C); ktemp = kmap;
for clust = 1:4
    ktemp(kmap==sortorder(clust)) = clust;
end
kmap = ktemp; clear ktemp

% Assign separated tissues
lung = maskedIm; lung(kmap~=2) = 0;
softTissue = maskedIm; softTissue(kmap~=4) = 0;
intermediate = maskedIm; intermediate(kmap~=3) = 0; clear maskedIm
tissues.softTissue = softTissue; clear softTissue
tissues.lung = lung; clear lung
tissues.intermediate = intermediate; clear intermediate
end