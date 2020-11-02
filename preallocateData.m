% preallocateData
% Mary Kate Montgomery
% March 2019
%
% Function to create empty version of output data w/ all required fields

function dataOut = preallocateData()
% Create data
data = struct; 
data.mouseNum = ''; data.scanDate = '';
data.Results = []; data.LabelIm = [];
data.ResultsTags = []; data.LabelImTags = [];
% Output has mouse #, scan date, and data
dataOut = data;
end