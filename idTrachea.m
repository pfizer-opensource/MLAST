% idTrachea()
% Mary Kate Montgomery
% January 2019
%
% Function to locate the trachea bifurcation in a thoracic mCT scan.
% Inputs: masked lung-air space, mask
% Outputs: z index of bifurcation
% Method: adapted from original findTrachea function, but with additional
% consideration to different potential starting conditions.

function [endidx, tracheaMaskOut] = idTrachea(lung,Mask,Maskedim)

[dy, dx, dz] = size(lung);

% Threshold
thresh = multithresh(lung,2);
l = ones([dy, dx, dz],'single'); 
l(lung<min(thresh)) = 0; l(lung>max(thresh)) = 0;
tracheaMask = zeros([dy, dx, dz],'single');

% -------------------- Find starting slice --------------------------------
z = dz; startingSlice = [];
while isempty(startingSlice) && z>0
    % Find objects in first slice
    thisSlice = l(:,:,z);
    C = bwconncomp(thisSlice);
    cent = regionprops(C,'Centroid');
    % Find indent in mask
    [Xwindow, Ywindow] = getWind(Mask(:,:,z));
    if isempty(Xwindow) || isempty(Ywindow)
        % If no indent, move on to next slice
        z = z-1;
    else    
        switch C.NumObjects % Count # objects in current slice
            case 0 %Move on to next slice
                z = z-1;
           
            case 1 %Call this starting slice
                c = cent(1).Centroid;
                if c(1)>Xwindow(1)&&c(1)<Xwindow(2)&&c(2)>Ywindow(1)&&c(2)<Ywindow(2)
                    startingSlice = z;
                    idx = 1;
                else
                    z = z-1;
                end
           
            otherwise %If multiple objects find # objects near indent
                tracheaCt = 0;
                for i = 1:C.NumObjects 
                    c = cent(i).Centroid;
                    if c(1)>Xwindow(1)&&c(1)<Xwindow(2)&&c(2)>Ywindow(1)&&c(2)<Ywindow(2)
                        tracheaCt = tracheaCt+1;
                        idx = i;
                    end
                end
                switch tracheaCt %Switch # objects near indent
                    case 0 %Move on to next slice
                        z = z-1;
                    case 1 % Call this starting slice
                        startingSlice = z;
                    otherwise % Trachea already bifurcated
                        endidx = z;
                        tracheaMaskOut = zeros([dy,dx,dz],'single');
                        return;
                end
        end
    end
end

if z ==0 % Never found starting slice
    endidx = find(sum(sum(l,1),2)>0,1,'last'); % Assign endidx to last slice w/ lung
    tracheaMaskOut = zeros([dy,dx,dz],'single'); 
    tracheaMaskOut(:,:,endidx:end) = 1;
    return;
end

% -------------------- Track trachea to bifurcation -----------------------

% Remove non-trachea items
for z2 = 1:numel(C.PixelIdxList)
    if z2 ~= idx
        thisSlice(C.PixelIdxList{z2}) = 0;
    end
end
tracheaMask(:,:,startingSlice) = thisSlice;
[ro,col] = find(l(:,:,startingSlice)== 1);
numE = numel(ro);
 
% Follow the Trachea till the bifurcation and mark the slice where the
% number of objects turns from 1 to 2 as the endidx
for z = startingSlice-1:-1:1
    if numE == 0 
        thisSlice = l(:,:,z);
        C = bwconncomp(thisSlice);
        numPixels = cellfun(@numel,C.PixelIdxList);
        [~,idx] = max(numPixels);
        for z2 = 1:numel(C.PixelIdxList)
            if z2 ~= idx
                thisSlice(C.PixelIdxList{z2}) = 0;
            end
        end
        
        [ro,col] = find(thisSlice==1);
        tracheaMask(:,:,z) = thisSlice;
        numE = numel(ro);
        continue;
    end

    nextSlice = zeros(size(l,1),size(l,2));
    for nR = 1:numE
        x = ro(nR); y = col(nR);
        if l(x,y,z) ==1
            nextSlice(x,y) = 1;
        end
        k = 1;
        while l(x+k,y,z)==1
            nextSlice(x+k,y) = 1;
            k = k+1;
        end
        k = 1;
        while l(x-k,y,z)==1
            nextSlice(x-k,y) = 1;
            k = k+1;
        end
        k = 1;
        while l(x,y+k,z)== 1
            nextSlice(x,y+k) = 1;
            k = k+1;
        end
        k = 1;
        while l(x,y-k,z)==1
            nextSlice(x,y-k) = 1;
            k = k+1;
        end
        k = 1;
        while l(x-k,y-k,z)==1
            nextSlice(x-k,y-k) = 1;
            k = k+1;
        end
        k=1;
        while l(x+k,y+k,z)==1
            nextSlice(x+k,y+k) = 1;
            k = k+1;
        end
        k=1;
        while l(x-k,y+k,z)==1
            nextSlice(x-k,y+k) = 1;
            k = k+1;
        end
        k=1;
        while l(x+k,y-k,z)==1
            nextSlice(x+k,y-k) = 1;
            k = k+1;
        end
        
    end
    [ro, col] = find(nextSlice ==1);
    numE = numel(ro);
    tracheaMask(:,:,z) = nextSlice;
    
    % Count regions. If >1, trachea has bifurcated
    C = bwconncomp(nextSlice,4);
    idx = cellfun(@numel,C.PixelIdxList);
    if numel(idx)> 1
        break;
    end
  
end
endidx = z;

% Did we find the trachea properly?
prctLung = sum(sum(lung>0,1),2)./sum(sum(Mask>0,1),2);
zLungSt = find(prctLung>.15,1,'last'); % highest point where lung takes up 15% of thoracic area
%Should find trachea in both top half of thoracic cavity and above point w/ large lung area
zLow = max(zLungSt,.5*dz);
% If endidx too low, don't use
if endidx < zLow
    endidx = dz;
end

tracheaMaskOut = zeros([dy, dx, dz],'single');
tracheaMaskOut(:,:,endidx:end) = 1;
end

function [Xwindow, Ywindow] = getWind(maskSlice)
% Get mask outline in relevant forms
yTrace = sum(maskSlice,2,'omitnan');
[~,maxYind] = max(yTrace);
xTrace = sum(maskSlice(1:maxYind,:),1,'omitnan');
maskOutline = bwboundaries(maskSlice);
try
maskOutline = maskOutline{1};
catch
    Xwindow = []; Ywindow = [];
    return;
end

% Find x-value of indent
[pks, locs] = findpeaks(-xTrace);
[~, maxPkInd] = max(pks);
centerIndentX = locs(maxPkInd);

% Find y-value of indent
maskOutline(find(maskOutline(:,1)>maxYind),:) = [];
centerIndentY = maskOutline(find(maskOutline(:,2) == centerIndentX),1);

% Set x and y window
Xwindow = [centerIndentX - round(.2*(find(xTrace>0,1,'last')-find(xTrace>0,1,'first'))), centerIndentX + round(.2*(find(xTrace>0,1,'last')-find(xTrace>0,1,'first')))];
Ywindow = [centerIndentY - round(.2*(find(yTrace>0,1,'last')-find(yTrace>0,1,'first'))), centerIndentY + round(.2*(find(yTrace>0,1,'last')-find(yTrace>0,1,'first')))];

end

