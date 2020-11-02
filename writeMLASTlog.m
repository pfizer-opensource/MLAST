% writeMLASTlog()
% Mary Kate Montgomery
% July 2019
%
% Function to record log of input parameters and results any time MLAST is
% run. Saves as text file in Study Directory. If text file already exists,
% appends information with new run.

function writeMLASTlog(inputVars,additionalVars,versionNum)
% Parse inputs
fileName = fullfile(inputVars.loadPath,'MLAST Log.txt');
loadPath = inputVars.loadPath;
tagNames = cat(2,inputVars.tagNames{:});
tagColors = cat(2,num2str(cat(2,inputVars.tagColors{:})));
if inputVars.saveROIlabels
    saveROIlabels = 'Yes';
else
    saveROIlabels = 'No';
end
if inputVars.exportDataTable
    exportDataTable = 'Yes';
else
    exportDataTable = 'No';
end
if inputVars.saveData
    saveData = 'Yes';
else
    saveData = 'No';
end
segmentationMethod = inputVars.segMethod;
saveFileName = inputVars.saveFileName;
if ~contains(saveFileName,'.xlsx') || ~contains(saveFileName,'.xls') || ~contains(saveFileName,'.csv')
    saveFileName = [saveFileName '.xlsx'];
end
metricOptions ={'Tissue Counts','Tissue Percent of Total','Tissue Density',...
    'Normalized Tissue Density','Total Thoracic Count','Diaphragm Count',...
    'Total Image Size','Bone Threshold','Bone Count'};
metrics = metricOptions(inputVars.whichMetrics);
whichMetrics = cat(2,metrics{:});

% Get other info
D = datetime('now','TimeZone','local');
if additionalVars.wasData
    dataFound = 'Yes';
else
    dataFound = 'No';
end
analysisTime = num2str(round(additionalVars.analysisTime/60,2));
compName = getenv('computername');
userName = getenv('username');
numScans = num2str(additionalVars.numScans);
numMice = num2str(numel(inputVars.tagNames));

% Open file
fid = fopen(fileName,'a');

% Write header to separate from previous runs
fprintf(fid,'\r\n'); fprintf(fid,'\r\n'); fprintf(fid,'\r\n');
fprintf(fid,'%c','---------------------------------------'); fprintf(fid,'\r\n');
fprintf(fid,'%c',['Analysis run on ' datestr(D)]); fprintf(fid,'\r\n');
fprintf(fid,'%c','---------------------------------------'); fprintf(fid,'\r\n');
fprintf(fid,'%c','Analysis Parameters:'); fprintf(fid,'\r\n');

% Write info
fprintf(fid,'%c',['MLAST Version = ' num2str(versionNum)]); fprintf(fid,'\r\n');
fprintf(fid,'%c',['Study Directory = ' loadPath]); fprintf(fid,'\r\n');
fprintf(fid,'%c',['Data Found = ' dataFound]);fprintf(fid,'\r\n');
fprintf(fid,'%c',['User = ' userName]); fprintf(fid,'\r\n');
fprintf(fid,'%c',['Computer = ' compName]); fprintf(fid,'\r\n');
fprintf(fid,'%c',['TimeZone = ' D.TimeZone]); fprintf(fid,'\r\n');
fprintf(fid,'%c',['Number of Subjects = ' numMice]); fprintf(fid,'\r\n');
fprintf(fid,'%c',['Number of Scans = ' numScans]); fprintf(fid,'\r\n');
fprintf(fid,'%c',['Time to Analyze = ' analysisTime ' minutes']); fprintf(fid,'\r\n');
fprintf(fid,'%c',['Save File Name = ' saveFileName]); fprintf(fid,'\r\n');
fprintf(fid,'%c',['Metrics = ' whichMetrics]); fprintf(fid,'\r\n');
fprintf(fid,'%c',['Save Labels = ' saveROIlabels]); fprintf(fid,'\r\n');
fprintf(fid,'%c',['Export Results = ' exportDataTable]); fprintf(fid,'\r\n');
fprintf(fid,'%c',['Save QC Data = ' saveData]); fprintf(fid,'\r\n');
fprintf(fid,'%c',['Thresholding = ' segmentationMethod]); fprintf(fid,'\r\n');
fprintf(fid,'%c',['Tag Names = ' tagNames]); fprintf(fid,'\r\n');
fprintf(fid,'%c',['Tag Colors = ' tagColors]);

% Save and close text file
fclose(fid);

% Update user
disp('Analysis parameters written to MLAST Log.txt');

end