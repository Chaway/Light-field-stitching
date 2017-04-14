% this function calculates the cropping parameters for the panorama.
% because of the projective transformation, some regions are zeros in
% the resulting panorama.
function [xmin, xmax, ymin, ymax] = PanoramaCropParameters(sceneImageSet, ...
    transforms, xMin, yMin)

imageSize = [size(sceneImageSet, 1) size(sceneImageSet, 2)];
numOfImages = length(transforms);

for ii = 1:length(transforms)           
    [u, v] = transformPointsForward(transforms(ii),1,1);
    Low_left_xy(ii, :) = [v-yMin+1 u-xMin+1];
    
    [u, v] = transformPointsForward(transforms(ii),1,imageSize(1));
    Up_left_xy(ii, :) = [v-yMin+1 u-xMin+1];
    
    [u, v] = transformPointsForward(transforms(ii), imageSize(2), 1);
    Low_right_xy(ii, :) = [v-yMin+1 u-xMin+1];
    
    [u, v] = transformPointsForward(transforms(ii), imageSize(2), imageSize(1));
    Up_right_xy(ii, :) = [v-yMin+1 u-xMin+1];
end

xmin = ceil(max(max(Low_left_xy(1, 2)), max(Up_left_xy(1, 2))));
xmax = floor(min(min(Low_right_xy(numOfImages, 2)), min(Up_right_xy(numOfImages, 2))));

ymin = ceil(max(max(Low_left_xy(:, 1)), max(Low_right_xy(:, 1))));
ymax = floor(min(min(Up_left_xy(:, 1)), min(Up_right_xy(:, 1))));

return;