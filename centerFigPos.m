% centerFigPos()
% Mary Kate Montgomery
% August 2019
%
% Function to get screen size and return position coordinates for centered
% window of input width/height.

function figPos = centerFigPos(w,h)

% Get screen size
scrSz = get(0,'ScreenSize');
scrH = scrSz(4); scrW = scrSz(3); clear scrSz;

% Set top-left corner position
figStH = round(scrH/2-h/2);
figStW = round(scrW/2-w/2);

% Set all figure position coordinates
figPos = [figStW,figStH,w,h];
end