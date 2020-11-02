% getTagNames
% Mary Kate Montgomery
% July 2019
%
% Reads Excel workbook for names and colors of subject identifiers for mCT
% study. Takes file name, relevant sheet name, and subject identifier, or
% the header of the column of interest, as inputs.

function [tagNames, tagColors] = getTagNames2(fileName, sheetName, headerName)
% Open Excel workbook
h = actxserver('excel.application');
if isfile(fileName)
    wb = h.Workbooks.Open(fileName);
else
    wb=h.WorkBooks.Add();
end

% Get worksheet names
sheetNames = cell(wb.Worksheets.Count,1);
for s = 1:wb.Worksheets.Count
    sheetNames{s} = wb.Worksheets.Item(s).Name;
end

% Select Sheet
sheetInd = find(strcmp(sheetName,sheetNames));
wb.Worksheets.Item(sheetInd).Select;

% Prepare data range
alph = {'','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O',...
    'P','Q','R','S','T','U','V','W','X','Y','Z'};
allRange = cell(100,100);
for i = 1:size(allRange,1)
    for j = 1:size(allRange,2)
        if mod(j,26) == 0
            allRange{i,j} = [alph{ceil(j/26)} alph{27} num2str(i)];
        else
            allRange{i,j} = [alph{ceil(j/26)} alph{mod(j,26)+1} num2str(i)];
        end
    end
end
ran = h.ActiveSheet.get('Range',[allRange{1} ':' allRange{end}]);
cellContents = ran.Value;

% Locate tag header
for j = 1:size(cellContents,2)
    tagRow = find(strcmp(headerName,cellContents(:,j)));
    if ~isempty(tagRow)
        tagCol = j;
        break;
    end
end


% Get subject IDs
tagNames = cellContents(tagRow+1:end,tagCol);
% Remove trailing NaNs
for i = size(tagNames,1):-1:1
    if ~isnan(tagNames{i})
        break;
    end
end
tagNames(i+1:end) = [];

% Get subject colors
tagColors = cell(size(tagNames));
for t = 1:numel(tagNames)
    tag = tagNames{t};
    if ~isa(tag,'char') || ~isa(tag,'str')
        if isnumeric(tag)
            tagNames{t} = num2str(tag);
        elseif isnan(tag)
            tagNames = 'NaN';
        end
    end
    % Select cell
    ran = h.ActiveSheet.get('Range',allRange{tagRow+t,tagCol});
    tagColors{t} = ran.interior.color;
end

% Close out Excel
wb.Close;
h.Quit;
h.delete;
end