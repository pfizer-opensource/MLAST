% writeImgStack()
% Mary Kate Montgomery
% April 2019
%
% Function to write 3D volume to dicom stack contained within folder
function writeImgStack(im,fileName,savePath,imType)

% Create directory
[~,~,dz] = size(im);
mkdir(savePath,fileName);

% Write images slice by slice
for z = 1:dz
    if strcmp(imType,'.tif')
        imwrite(double(im(:,:,z))/255,fullfile(savePath, fileName,[fileName '_' num2str(z) imType]),'Compression','none');
    else
    imwrite(im(:,:,z),fullfile(savePath, fileName,[fileName '_' num2str(z) imType]),'Mode','lossless');
    end
end

disp('Image Written to File');
end