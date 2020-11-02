% getTagHeaders
% Mary Kate Montgomery
% May 2019
%
% Function to identify potential header names for the Subject IDs within
% the content of the study's imaging log. Returns list of possibilities for
% user to select from

function [headerChoice, headerInds] = getTagHeaders(allCellCont)
% Create list of possible header names to look for
possHeaderNames = {'Mouse ID','MouseID',' ID ','Tag','Mouse Number',...
    'Mouse #','Subject ID'}; ct = 1;
% Scan log file for possible header names
for row = 1:size(allCellCont,1)
    for col = 1:size(allCellCont,2)
        thisCell = allCellCont{row,col};
        if isa(thisCell,'char') && contains(thisCell,possHeaderNames,'IgnoreCase',1)
            headerInds(ct,:) = [row, col];
            headerOpt{ct} = thisCell;
            ct = ct+1;
        end
    end
end
% Take unique instances of headers and record their location
if ct > 1
    headerChoice = unique(headerOpt,'stable');
    headerInds = unique(headerInds,'rows');
else
    headerChoice = {};
end
end