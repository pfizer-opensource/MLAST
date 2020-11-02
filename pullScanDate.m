% pullScanDate()
% Mary Kate Montgomery
% November 2018
%
% Function to pull scan date from the CT scan log in either the input folder
% or the current directory. Directory should be recon directory for SkyScan
% CT data.
function scanDate = pullScanDate(fileName)

% Read text file
fid = fopen(fileName,'r');
formatSpec = '%s';
rawTxt = fscanf(fid,formatSpec);
fclose(fid);

% Parse date and time of scan
parsedTxt = strsplit(rawTxt,'=');
TimePlus = parsedTxt{52};
scanDate = replace(TimePlus,'Scanduration','');
scanDate = insertAfter(scanDate,2,'-');
scanDate = insertAfter(scanDate,6,'-');
scanDate = insertAfter(scanDate,11,' ');
scanDate(15) = '';
scanDate(18) = '';
scanDate(end) = '';

end