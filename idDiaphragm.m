% idDiaphragm()
% Mary Kate Montgomery
% January 2019
%
% Function to find diaphram in segmented mCT lung scan

function [Dmask,Dtop,maskFullSizeInd] = idDiaphragm(maskedIm, tissues)
% Sort input variables
[dy, dx, dz] = size(maskedIm);
softTissue = tissues.softTissue;
lung = tissues.lung;
intermediate = tissues.intermediate;
clear tissues

% Establish variables to work with
st_trace = squeeze(sum(sum((softTissue > 0),1),2)); clear softTissue
ibw_trace = squeeze(sum(sum((intermediate > 0),1),2));
tc_trace = squeeze(sum(sum((maskedIm > 0),1),2));
percentST = (st_trace+ibw_trace)./tc_trace; %Use both ST &IBW
buf = 1;

% Find where mask reaches full size (ribcage fully apparent)
crosssectSizeTrace = squeeze(sum(sum(maskedIm>0,1),2));
[maxSize,~] = max(crosssectSizeTrace);
maskFullSizeInd = find(crosssectSizeTrace==maxSize,1,'first');

% Find top of whole diaphragm
[~, pkInds, ~, proms] = findpeaks(-percentST(maskFullSizeInd+1:end));
Dtop = pkInds(find(isoutlier(proms),1,'first')) + maskFullSizeInd; % use first prominent peak
if isempty(Dtop) && ~isempty(pkInds)
    Dtop = pkInds(1)+maskFullSizeInd;
end

% Find where diaphragm disappears using inflection point of each pixel
Dmask = zeros([dy, dx, dz],'single');
for row = 1:dy
    for col = 1:dx
        Ztrace = squeeze(maskedIm(row,col,1:Dtop)); % value of pixel row, col along z axis
        
        if sum(Ztrace) ~= 0
            Dbottom = find(Ztrace,1,'first');
            Dend = find(Ztrace,1,'last');
            Ztrace = Ztrace(Dbottom+buf:Dend-buf);
            Ztrace(Ztrace==0) = NaN;
            if length(Ztrace) >= 4
                Ztrace_diff = -(diff(double(Ztrace))); % differential of ztrace
                [diffMax,diffMaxInd] = max(Ztrace_diff); % get max peak for reference
                Dnot = diffMaxInd - 1;
            else
                Dnot = length(Ztrace)-1;
            end
            % Create mask
                Dmask(row,col,Dbottom:Dnot+Dbottom+buf) = 1;
        end
    end
end
clear maskedIm
% ------------------------------------------------------------------------
%                         Post Processing
% ------------------------------------------------------------------------
% Remove lung from diaphragm mask
Dmask = Dmask.*(single(~lung));
clear lung

% Perform slice-by-slice post-processing steps
for z = 1:dz
    Dmask(:,:,z) = postProcessDiaphragm(Dmask(:,:,z),intermediate(:,:,z));
end
clear intermediate
    
% Once pixel is not diaphragm, cannot be diaphragm again
for row = 1:dy
    for col = 1:dx
        Dtrace = squeeze(Dmask(row,col,:));
        Dstart = find(Dtrace>0,1,'first');
        Dtrace(Dstart+find(Dtrace(Dstart+1:end)==0,1,'first'):end) = 0;
        Dmask(row,col,:) = Dtrace;
    end
end

% Force diaphragm to be continuous in every slice (x3)
for z = 1:dz; Dmask(:,:,z) = single(makeContinuous(Dmask(:,:,z),4)); end

end