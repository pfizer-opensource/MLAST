% flagErrors2
% Mary Kate Montgomery
% April 2019
%
% Function to find potentially erroneous segmentations. Errors could be
% caused by artifacts or algorithm deficiencies.

function findFlagsFinal = flagErrors2(dataIn,metaData,saveLabels)

% Preallocate
dCt = NaN(size(dataIn));
tcCt = NaN(size(dataIn));
stPer = NaN(size(dataIn));
boneCt = NaN(size(dataIn));
boneT = NaN(size(dataIn));

% Parse out results
for i = 1:size(dataIn,1)
    for j = 1:size(dataIn,2)
        data = dataIn{i,j};
        
        if isempty(data)
            continue;
        end
        
        % Pull variables
        tcCt(i,j) = data.Results(end-4)*1000;
        dCt(i,j) = data.Results(end-3)*1000;
        boneCt(i,j) = data.Results(end);
        boneT(i,j) = data.Results(end-1);
        stPer(i,j) = data.Results(5);
        
    end
end

% Diaphragm Count
testMetric = ones(size(tcCt))./dCt; 
tM = testMetric(~isnan(testMetric));
cutoff = 2*prctile(tM,75);
findFlags2 = testMetric>=cutoff;

% Bone Count
testMetric = boneCt;
tM = testMetric(~isnan(testMetric));
findFlags = isoutlier(tM,'ThresholdFactor',10);
findFlags(tM<mean(tM)) = 0;
if sum(sum(findFlags)) > 0
    cutoff = min(tM(findFlags));
    findFlags3 = testMetric>=cutoff;
else
    findFlags3 = zeros(size(testMetric));
end

% Thoracic Cavity Count
testMetric = tcCt;
tM = testMetric(~isnan(testMetric));
findFlags = isoutlier(tM,'ThresholdFactor',3);
findFlags(tM>mean(tM)) = 0;
if sum(sum(findFlags)) > 0
    cutoff = max(tM(findFlags));
    findFlags4 = testMetric<=cutoff;
else
    findFlags4 = zeros(size(testMetric));
end

% Soft Tissue Percent
findFlags5 = max(double(cat(3,stPer<20,stPer>75)),[],3);

findFlagsFinal = max(double(cat(3,findFlags2,findFlags3,findFlags4,findFlags5)),[],3);

% Save snapshot of QC'd scans
if saveLabels
    saveQcLabelImgs(findFlagsFinal,dataIn);
end
end