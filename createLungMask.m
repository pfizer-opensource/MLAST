% createLungMask()
% Mary Kate Montgomery
% September 2018
%
% Function to create mask out of a binary volume of a ribcage using two
% iterations of spline interpolation between certain points around the
% ribcage.
% First iteration uses all points in the input ribcage and a
% center of mass of the weighted rib centroids. Second iteration uses only
% closest boundary points of the input ribcage and a center of mass of the
% mask created in the first iteration. Benefit is better center of mass
% location second time around, and therefore more accurate masking, even in
% higher slices.
% Adapted from code created by Vidya Premkumar

function Mask = createLungMask(ribcage)

[dy, dx, dz] = size(ribcage);
Mask = zeros([dy, dx, dz],'single');

for z = 1:dz
    % If slice does not contain any bone, move to next slice
    ribSlice = single(bwlabel(ribcage(:,:,z)));
    if sum(sum(ribSlice))==0
        continue;
    end
    
    % Calculate center of ribcage
    cent = regionprops(ribSlice,'centroid');
    numReg = numel(cent);
    centX = zeros([numReg,1],'int16'); centY = zeros([numReg,1],'int16');
    for n1 = 1:numReg
        centX(n1)= int16(cent(n1).Centroid(1));
        centY(n1) = int16(cent(n1).Centroid(2));
    end
    % Use halfway point b/w min and max as center (holds steady when # rib
    % regions unbalanced)
    COM_x = mean([min(centX), max(centX)]);
    COM_y = mean([min(centY), max(centY)]);
    COM = [COM_x, COM_y];
    
    % Compute mask using COM and all boundary points
    maskSlice = splineMask(ribSlice,COM,1);
    
    % Calculate center of mass of mask & use as new COM
    x = sum(maskSlice,1)./(sum(sum(maskSlice)));
    y = sum(maskSlice,2);
    elvecx = 1:dx;
    elvecy = (1:dy)';
    COM_x = sum(x.* elvecx)/sum(x);
    COM_y = sum(y.* elvecy)/sum(y);
    COM = [COM_x, COM_y];
    
    % Compute mask using new COM and interior 30% boundary points
    Mask(:,:,z) = splineMask(ribSlice,COM,.3);
end

% Post processing of final mask 
Mask = postProcessMask(Mask);
end


