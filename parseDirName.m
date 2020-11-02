% parseDirName
% Mary Kate Montgomery
% May 2019
%
% Function to parse metadata for a CT scan from the directory name

function nameparts = parseDirName(parentDir, dirName)
dirNameRelevant = replace(dirName,'/','\'); % just in case
dirNameRelevant = erase(dirName,[parentDir '\']); % only want part after parent

nameparts = strsplit(dirNameRelevant,'\'); % break up by slashes
% Remove recon folder - not important
recFolderInd = find(contains(nameparts,'_Rec'));
nameparts(recFolderInd) = [];
end