% cropTissues()
% Mary Kate Montgomery
% March 2019
% 
% Function to remove pixels from tissue counts based on input mask

function tissOut = cropTissues(tissIn, mask)

if isstruct(tissIn)
    % Apply mask to each tissue field
    tissOut = struct;
    fieldNames = fieldnames(tissIn);
    for f = 1:numel(fieldNames)
        tissue = getfield(tissIn,fieldNames{f});
        tissue(mask==1) = 0;
        tissOut = setfield(tissOut,fieldNames{f},tissue);
    end
else
    % Apply mask
    tissOut = tissIn;
    tissOut(mask==1) = 0;
end
end