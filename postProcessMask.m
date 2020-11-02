% postProcessMask()
% Mary Kate Montgomery
% March 2019
%
% Function to perform post-processing on 3D mask of thoracic cavity

function maskOut = postProcessMask(maskIn)

dz = size(maskIn,3);

% Erode
Mask = maskIn;

% Filter
Mask = smooth3(Mask,'gaussian',3);
Mask = movmean(Mask,15,3);
Mask(Mask>.5) = 1;
Mask(Mask<=.5) = 0;

% Remove discontinuities
Mask = single(makeContinuous(Mask,26));

% Remove portions of mask where centroid makes massive jump from frame to
% frame
res = zeros([dz,1],'single');
for z = single(2:dz)
    if sum(sum(Mask(:,:,z))) ~= 0
        centLoc = regionprops(Mask(:,:,z),'Centroid');
        res(z) =  max(Mask(single(round(centLoc.Centroid(2))),single(round(centLoc.Centroid(1))),z-1),single(sum(sum(Mask(:,:,z-1)))==0));
    end
end
temp = bwconncomp(res); temp2 = zeros(temp.NumObjects,1);
for i = 1:temp.NumObjects
    temp2(i) = numel(temp.PixelIdxList{i});
end
[~, temp3] = max(temp2);
for i = 1:temp.NumObjects
    if i ~= temp3
        Mask(:,:,temp.PixelIdxList{i}) = 0;
    end
end

% Remove discontinuities again
maskOut = single(makeContinuous(Mask,26));
end