% collectMetaData
% Mary Kate Montgomery
% May 2019
%
% Function to parse scans using folder structure. Takes list of all folders
% used in MLAST analysis and parses out group, subject name, and time point
% information to later be used for sorting.

function Mdat = collectMetaData(allSubfolders,parentDir)

for ind = 1:numel(allSubfolders)
    % Get list of all content in subfolder
    contentList = dir(allSubfolders{ind}); cL = cell(numel(contentList),1);
    for i = 1:numel(contentList); cL{i} = contentList(i).name; end
    % Parse metadata for scans that were analyzed using MLAST
    if max(contains(cL,'rec0'))
        nameparts = parseDirName(parentDir,allSubfolders{ind});
        Mdat(ind,1:numel(nameparts)) = nameparts; 
    end
end
% Remove empty metadata rows
Mcol1 = Mdat(:,1);
Mdat = Mdat(~cellfun('isempty',Mcol1),:);
end