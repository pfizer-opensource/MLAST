% splineMask()
% Mary Kate Montgomery
% March 2019
%
% Function to take slice of ribcage and center of mass and create mask of
% slice using spline function. Reorders certain percent of interior points
% from rib region boundaries counter-clockwise around COM and interpolates
% between them using a spline function to generate a mask.

function maskSlice = splineMask(ribSlice,COM,includePercent)

COM_x = COM(1); COM_y = COM(2);
[dy, dx] = size(ribSlice);

% Compute region boundaries
boundaries = bwboundaries(ribSlice);
cent = regionprops(ribSlice,'centroid');
numReg = numel(cent);

% Find the points in each object that are closest to the rib cage COM
X_interior = [];
Y_interior = [];
for r = 1:numReg
    X_thisRegion = boundaries{r,1}(:,2);
    Y_thisRegion = boundaries{r,1}(:,1);
    shortidx = shortdist(X_thisRegion,Y_thisRegion,COM_x,COM_y);
    nidx = int16(includePercent*numel(shortidx)); 
    X_interior = [X_interior; X_thisRegion(shortidx(1:nidx))];
    Y_interior = [Y_interior; Y_thisRegion(shortidx(1:nidx))];
end

% Find the counter clockwise angle between each point and a fixed
% vector (100,0) relative to the rib cage COM
thetaAll = zeros([1,numel(X_interior)],'single');
vFixed = [100 0];
for point = 1:numel(X_interior)
    vPoint = [X_interior(point)-COM_x, Y_interior(point)-COM_y];
    thetaAll(point) = mod(-atan2(vFixed(1)*vPoint(2)-vFixed(2)*vPoint(1), vFixed*vPoint'), 2*pi) * 180/pi;
end

%Sort the points based on increasing angle relative to COM
[~,thetaSortInd] = sort(thetaAll);
Xsorted = X_interior(thetaSortInd);
Ysorted = Y_interior(thetaSortInd);

% Interpolate between the points using a spline function
piecewiseX = spline(1:numel(Xsorted),Xsorted);
valueX = ppval(piecewiseX,1:numel(Xsorted));
piecewiseY = spline(1:numel(Ysorted),Ysorted);
valueY = ppval(piecewiseY,1:numel(Ysorted));

% Generate mask
maskSlice = poly2mask(valueX,valueY,dy,dx);
maskSlice(ribSlice==1) = 0;

% Erosion and dilation to smooth out jagged edges
SE = strel('disk', 8);
maskSlice = imerode(maskSlice,SE);
maskSlice = imdilate(maskSlice,SE);
end


function index = shortdist(X,Y,centerX,centerY)
% Find the point, from a set of points, that is closest to a fixed point.
dist = sqrt((X(:)-centerX).^2 + (Y(:)-centerY).^2);
[~,index] = sort(dist);
end
