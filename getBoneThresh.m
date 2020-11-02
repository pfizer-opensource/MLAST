% getBoneThresh()
% Mary Kate Montgomery
% Function to calculate lower limit of bone threshold using a histogram

function thresh_bone_lower = getBoneThresh(justThoracic)
% Get histogram
thorTemp = reshape(justThoracic,[size(justThoracic,1)*size(justThoracic,2)*size(justThoracic,3),1]);
thorTemp(thorTemp==1)=0;
[b, e] = histcounts(thorTemp(thorTemp~=0),200); 
% Find threshold
loc = find(b>prctile(b,55),1,'last');
thresh_bone_lower = e(loc+1);
end