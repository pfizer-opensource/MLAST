% sortMlastData3
% Mary Kate Montgomery
% May 2019
%
% Function to sort MLAST results according to subject ID and date. Matches
% subject order from reference log.

function [dataSorted, metaDataSorted, datesSorted] = sortMlastData3(dataIn, tagNames, metadata)

allData = dataIn(~cellfun('isempty',dataIn))';

% Identify scan dates to match to
datesAll = cell(numel(allData),1);
for i = 1:numel(allData)
    date = allData{i}.scanDate;
    % Crop time from date so all scans for given day read the same
    dateCropped = date(1:strfind(date,' '));
    datesAll{i} = dateCropped;
end
datesUnique = unique(datesAll);
[~, sortOrder] = sort(datenum(datesUnique));
datesSorted = datesUnique(sortOrder);
numCols = numel(datesSorted);

% Are there repeating tag names (from scan log)?
[tagNamesUnique, repeatNames] = cellNanUnique(tagNames);
repeatTags = ~(numel(unique(tagNames))==numel(tagNames));


% Preallocate
rowsFound = []; %rowPad = 0;
for tagInd = 1:numel(tagNames)
    idTag = tagNames(tagInd);
    if isempty(getNumTag(idTag{1}))
        relDatAll(tagInd,:) = cell(1,numel(datesSorted));
        metaDataAll(tagInd,:) = cell(1,size(metadata,2));
        continue;
    end
    
    % Find all rows of metadata w/ ID Tag
    idRowAll = []; idColAll = [];
    for col = 1:size(metadata,2)
        metaDataCol = metadata(:,col);
        % Reassign empty cells
        metaDataCol(find(cellfun('isempty',metaDataCol))) = {' '};
        idRow = compareTags(metaDataCol,idTag);
        idRowAll = [idRowAll; idRow];
        idColAll = [idColAll; repmat(col,[length(idRow),1])];
    end
    [idRowAll, sortOrder] = sort(idRowAll);
    idColAll = idColAll(sortOrder);
    thisIdData = allData(idRowAll);
    thisIdMetaData = metadata(idRowAll,:);
    
    % Keep log of rows used
    rowsFound = [rowsFound; idRowAll];
    
    if isempty(thisIdData)
        relDatAll(tagInd,:) = cell(1,numel(datesSorted));
        metaDataAll(tagInd,:) = cell(1,size(metadata,2));
        continue;
    end
    
    
    if ~isempty(compareTags(idTag,repeatNames))
        % Group according to pre-tag columns
        preMetaData = thisIdMetaData;
        for c = 1:numel(idColAll)
            if idColAll(c) < size(preMetaData,2)
                preMetaData(c,idColAll(c)+1:end) = {' '};
            end
        end
        preMetaDataMat = cell(numel(idColAll),1);
        for c = 1:numel(idColAll); preMetaDataMat{c} = cell2mat(preMetaData(c,:)); end
        [preMetaDataMatUnq, uniqueInd] = unique(preMetaDataMat);
        thisDataGrouped = {};
        % Group. Assign correct rows
        for g = 1:length(uniqueInd)
            groupInd = find(contains(preMetaDataMat,preMetaDataMatUnq{g}));
            thisDataGrouped(g,1:length(groupInd)) = thisIdData(groupInd);
            rowAssigns = compareTags(tagNames, idTag);
        end
    else
        thisDataGrouped = thisIdData';
        rowAssigns = tagInd;
    end
    
    for g = 1:size(thisDataGrouped,1)
        % Match each scan w/ a date
        % Get date
        relDat = cell(1,numCols); relDat(1:size(thisDataGrouped,2)) = thisDataGrouped(g,:);
        sortDateInd = [];
        datesRel = cell(numel(relDat),1);
        relDatSorted = cell(1,numCols);
        for j = 1:numel(relDat)
            if ~isempty(relDat{j})
                date = relDat{j}.scanDate;
                dateCropped = date(1:strfind(date,' '));
                % Match date
                dateInd = find(strcmp(dateCropped,datesSorted));
                datesRel{dateInd} = dateCropped;
                relDatSorted{dateInd} = relDat{j};
            end
        end
        % Assign data
        relDatAll(rowAssigns(g),1:numel(relDatSorted)) = relDatSorted;
        
        % Assign metadata
        if ~isempty(compareTags(idTag,repeatNames))
            metaDataAll(rowAssigns(g),1:size(preMetaData,2)) = preMetaData(uniqueInd(g),:);
        else
        preMetaData = thisIdMetaData;
        for c = 1:numel(idColAll)
            if idColAll(c) < size(preMetaData,2)
                preMetaData(c,idColAll(c)+1:end) = {' '};
            end
        end
        % Find most common set of pre-Tag metadata
        preMetaDataMat = cell(numel(idColAll),1); matchCt = [];
        for c = 1:numel(idColAll)
            preMetaDataMat{c} = cell2mat(preMetaData(c,:));
            if c > 1
                numMatches = sum(contains(preMetaDataMat{c,1},preMetaDataMat(1:c-1)));
                if numMatches > 0
                    matchCt(c) = numMatches;
                else
                    matchCt(c) = 0;
                end
            else
                matchCt(c) = 0;
            end
        end
        [~, modeInd] = max(matchCt);
        metaDataAll(rowAssigns(g),1:size(preMetaData,2)) = preMetaData(modeInd,:);
        end
    end
end

dataSorted = relDatAll;
metaDataSorted = metaDataAll;

% Add in unidentified data
dataRemainder = allData;
dataRemainder(rowsFound,:) = [];
dataSorted(end+1:end+numel(dataRemainder),1) = dataRemainder;

metaDataRemainder = metadata;
metaDataRemainder(rowsFound,:) = [];
metaDataSorted = [metaDataSorted; metaDataRemainder];

end


function [outCell, repeatCells] = cellNanUnique(inCell)

outCell = {}; ct = 1; repeatCells = {}; ct2 = 1;
for n = 1:numel(inCell)
    cellContents = inCell{n};
    if strcmp(cellContents,'NaN')
        outCell{ct,1} = cellContents; ct = ct+1;
    else
        % Check for repeats
        isRepeat = sum(contains(outCell,cellContents));
        if ~isRepeat
            outCell{ct,1} = cellContents; ct = ct+1;
        else
            repeatCells{ct2,1} = cellContents; ct2 = ct2+1;
        end
    end
end
end

function sametag = compareTags(tag1,tag2)
% Function to compare only numeric portions of tag IDs
tag1Num = cell(size(tag1)); tag2Num = cell(size(tag2));
for i = 1:numel(tag1)
    tag1Num{i} = getNumTag(tag1{i});
end
for i2 = 1:numel(tag2)
    tag2Num{i2} = getNumTag(tag2{i2});
end
% sametag = find(strcmp(tag1Num,tag2Num));
sametag = find(strcmp(tag1,tag2));
end

function numTag = getNumTag(fullTag)
% Function to compute only numeric portion of input tag ID
numInd = zeros(size(fullTag));
for i = 1:length(fullTag)
    numInd(i) = min(~isnan(str2double(fullTag(i))),isreal(str2double(fullTag(i))));
end
% Find largest continuous numeric portion of tag ID
numInd = bwareafilt(logical(numInd),1);
numTag = fullTag(numInd);
end