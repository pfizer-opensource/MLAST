% exportAsExcel()
% Mary Kate Montgomery
% March 2019
%
% Function to organize MLAST results and export as data table corresponding
% with a reference log

function exportAsExcel(outputFileName, metaData, tagNames, allData, metricInd, tagColors, saveQClabels)

% Sort allData based on mouseNum, scanDate, and tag names from log file
[sortedData, sortedMetaData, sortedDates]= sortMlastData3(allData, tagNames, metaData);

% QC results
qcItems = flagErrors2(sortedData,sortedMetaData,saveQClabels);

% Select metrics to use
mm = [];
for m = 1:numel(metricInd)
    if metricInd(m) <= 4
        mm = [mm, (metricInd(m)-1)*4+1:(metricInd(m)-1)*4+4];
    else
        mm = [mm, metricInd(m) + 12];
    end
end
metricOptions = {'Soft Tissue Volume','Lung Volume','Intermediate Volume','Combined Tissue Volume',...
    'Soft Tissue % of Total','Lung % of Total','Intermediate % of Total','Combined Tissue % of Total',...
    'Soft Tissue Density','Lung Density','Intermediate Density','Combined Tissue Density',...
    'Norm Soft Tissue Density','Norm Lung Density','Norm Intermediate Density','Norm Combined Tissue Density',...
    'Total Thoracic Count','Diaphragm Count','Total Image Size','Bone Threshold','Bone Count'};
metrics = metricOptions(mm);

% Create header row
headerRow = cat(2,{'MetaData from Folder Structure:'}, cell(1,3), {'IDs from Scan Log'}, sortedDates');

% ------------ Alternative method to write results to file ------------

% Prepare Excel-related variables
alph = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
allRange = cell(size(sortedData,1)+1,numel(headerRow));
for i = 1:size(allRange,1)
    for j = 1:size(allRange,2)
        allRange{i,j} = [alph(j) num2str(i)];
    end
end

% Open Excel workbook
file = outputFileName;
h = actxserver('excel.application');
wb=h.WorkBooks.Add();
ws = wb.WorkSheets;

% Get worksheet names
sheetNames = cell(wb.Worksheets.Count,1);
for s = 1:wb.Worksheets.Count
    sheetNames{s} = wb.Worksheets.Item(s).Name;
end

for m = 1:length(metrics)
    % Create new sheet
    Lastsheet = wb.ActiveSheet;
    Add(ws,[],Lastsheet);
    wb.ActiveSheet.Name = metrics{m};
    
    % Write header
    for i = 1:numel(headerRow)
        ran = h.Activesheet.get('Range',allRange{1,i});
        ran.value = headerRow{i};
        ran.font.bold = true;
        addAllBorders(ran,3);
    end
    ran = h.Activesheet.get('Range',[allRange{1,1} ':' allRange{1,4}]);%
    ran.MergeCells = 1; % 
    
    % Pull results
    expData = cell(size(sortedData));
    % Create cell matrix to write to given sheet
    for row = 1:size(sortedData,1)
        for col = 1:size(sortedData,2)
            data = sortedData{row,col};
            if ~isempty(data) && ~sum(isnan(data.mouseNum))
                expData{row,col} = data.Results(mm(m));
            end
        end
    end
    
    % Compile content
    bufferCell = cell(size(sortedMetaData,1),4-size(sortedMetaData,2));
    sortedMetaData = cat(2,sortedMetaData,bufferCell);
    tagNamesFull = cat(1,tagNames,cell(size(sortedData,1)-size(tagNames,1),1));
    tagColorsFull = cat(1,tagColors,num2cell(repmat(16777215,[size(sortedData,1)-size(tagNames,1),1])));
    cellToWrite = cat(2,sortedMetaData,tagNamesFull,expData);
    cellToWrite = cat(1,headerRow,cellToWrite);
    
    % Write content
    for i = 1:size(cellToWrite,1)
        for j = 1:size(cellToWrite,2)
            ran = h.Activesheet.get('Range',allRange{i,j});
            if ~isempty(cellToWrite{i,j}) && ~max(isnan(cellToWrite{i,j})) && ~strcmp(cellToWrite{i,j},'NaN')
                ran.value = cellToWrite{i,j};
            end
            % Mark items that need QC w/ "Bad" format
            ii = i-1; jj = j-size(sortedMetaData,2)-1;
            if ii > 0 && jj > 0 && qcItems(ii,jj)
                ran.interior.Color = hex2dec('c7ceff');
                ran.font.Color = hex2dec('00069c');
            % Color other cells
            elseif ii > 0 && tagColorsFull{ii}~=16777215
                ran.interior.Color = tagColorsFull{ii};
            end
            addAllBorders(ran);
        end
    end
    % Autofit columns
    h.Activesheet.Cells.Select;
    h.Activesheet.Cells.EntireColumn.AutoFit;
end

% Delete unwanted sheets
if sum(count(sheetNames,'Sheet1'))
    wb.Worksheets.Item('Sheet1').Delete;
end
if sum(count(sheetNames,'Sheet2'))
    wb.Worksheets.Item('Sheet2').Delete;
end
if sum(count(sheetNames,'Sheet3'))
    wb.Worksheets.Item('Sheet3').Delete;
end

% Close out Excel
h.DisplayAlerts = 0; % Overwrite file without prompting user
wb.SaveAs(file);
wb.Close;
h.Quit;
h.delete;
end

function addAllBorders(ran,w)
% Add borders on all 4 sides with weight of w
ran.Borders.Item('xlEdgeLeft').LineStyle = 1;
ran.Borders.Item('xlEdgeRight').LineStyle = 1;
ran.Borders.Item('xlEdgeBottom').LineStyle = 1;
ran.Borders.Item('xlEdgeTop').LineStyle = 1;
if exist('w')
    ran.Borders.Item('xlEdgeLeft').Weight = w;
    ran.Borders.Item('xlEdgeRight').Weight = w;
    ran.Borders.Item('xlEdgeBottom').Weight = w;
    ran.Borders.Item('xlEdgeTop').Weight = w;
end
end