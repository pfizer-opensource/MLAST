% segmentRibcage()
% Mary Kate Montgomery
% February 2019
%
% Function to threshold bone, find largest 3D bone structure, and compute
% maximum projection over nSlice slices.

function outputIm = segmentRibcage(inputIm,thresh,nSlice)

% Threshold image
boneIm = ones(size(inputIm),'single');
boneIm(inputIm<thresh) = 0;

% Remove unwanted pixels (and/or dilate) image to improve connectivity
% between bones
for z = 1:size(inputIm,3)
    boneIm(:,:,z) = bwareaopen(boneIm(:,:,z),10);
end

%Find largest connected bone structure (rib cage, vertebrae, sternum)
CC = bwconncomp(boneIm);
numPixels = cellfun(@numel,CC.PixelIdxList);
[~,idx] = max(numPixels);
for reg = 1:numel(CC.PixelIdxList)
    if reg ~= idx
        boneIm(CC.PixelIdxList{reg}) = 0;
    end
end

%Some additional processing of image to improve image quality for future
%use
se = strel('diamond',4);
se2 = strel('diamond',2);
boneIm = imfill(boneIm, 'holes');
boneIm = imdilate(boneIm,se);
boneIm = imerode(boneIm,se2);

%Add up few slices at a time for better definition of the boundaries of the
%thoracic cavity.
maxProject = zeros(size(inputIm),'single');
zMax = size(inputIm,3);
for z = 1:zMax
    if z <= floor(nSlice/2)
        maxProject(:,:,z) = max(boneIm(:,:,1:z+ceil(nSlice/2)),[],3);
    elseif z >= zMax - ceil(nSlice/2)
        maxProject(:,:,z) = max(boneIm(:,:,z-floor(nSlice/2):zMax),[],3);
    else
        maxProject(:,:,z) = max(boneIm(:,:,z-floor(nSlice/2):z+ceil(nSlice/2)),[],3);
    end
end
outputIm = maxProject;
end