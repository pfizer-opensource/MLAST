% postProcessDiaphragm()
% Mary Kate Montgomery
% March 2019
%
% Function to perform slice-by-slice post-processing on diaphragm mask

function DsliceOut = postProcessDiaphragm(DsliceIn,intermediateSlice)
% Temporarily remove intermediate from diaphragm
Dmask_noInt = DsliceIn;
Dmask_noInt(intermediateSlice>0) = 0; % Dmask(intermediate>0) = 0;
% Force diaphragm to be continuous
Dmask_cont = single(makeContinuous(Dmask_noInt,4));
% Re-include intermediate in diaphragm
Dmask_wInt = Dmask_cont;
Dmask_wInt(DsliceIn.*single(intermediateSlice>0)==1) = 1;
% Force diaphragm to be continuous (x2)
Dmask_cont2 = single(makeContinuous(Dmask_wInt,4));
% Fill in holes
Dmask_filled = imfill(Dmask_cont2,'holes');
% Use watershed transform to remove peninsulas
DsliceOut = reshapeMaskWatershed(Dmask_filled);
end