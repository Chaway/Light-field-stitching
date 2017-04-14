% this function compensates the gains of the images by using the 
% overlap regions between them, so that the resulting panoramic image
% does not have sharp gain boundaries
function sceneImageSet = compensateGain(sceneImageSet, transforms, ...
    xLimits, yLimits, xMin, yMin, height, width)

imageSize = [size(sceneImageSet, 1) size(sceneImageSet, 2)];
panoramaView = imref2d([height width], xLimits, yLimits);

% compute the coordinates of the four corners of each image in the
% TRANSORMED coordinates
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

for ii = 2 : length(transforms)
    % find the x and y intervals for which there is an overlapping area
    % between the two consecutive images. This does not mean that there is
    % a full overlap in this interval.
    xMinPrevious = min(Low_right_xy(ii-1,2), Up_right_xy(ii-1,2));
    xMaxCurrent = max(Low_left_xy(ii,2), Up_left_xy(ii,2));
    
    yMaxT = min(Up_right_xy(ii-1,1), Up_left_xy(ii,1));
    yMinT = max(Low_right_xy(ii-1,1), Low_left_xy(ii,1));
    
    % since there is no full overlap, we divide the resulting minimum and
    % maximum coordinates by 2 to make sure our reference area has a
    % full overlap between the two images
    xWidth = round(abs(xMinPrevious - xMaxCurrent) / 2);
    yWidth = round(abs(yMaxT - yMinT) / 2);
    
    % define the center of the overlap region
    xCenter = round((xMinPrevious + xMaxCurrent) / 2);
    yCenter = round((yMaxT + yMinT) / 2);
    
    x = [xCenter - round(xWidth/2) : 1 : xCenter + round(xWidth/2)];
    y = [yCenter - round(yWidth/2) : 1 : yCenter + round(yWidth/2)];
    
    % transform the two images according to the transformation that has
    % been computed before
    warpedImageP = imwarp(sceneImageSet(:,:,:,ii-1), transforms(ii-1), 'OutputView', panoramaView);
    warpedImage  = imwarp(sceneImageSet(:,:,:,ii), transforms(ii), 'OutputView', panoramaView);
    
    % calculate the mean value of all pixels in the overlap region for the
    % current and previous images
    meanP = 0; meanC = 0;
    
    for mm = 1 : length(x)
        for nn = 1 : length(y)
            warpedImageP(y(nn), x(mm),:);
            meanP = meanP  + warpedImageP(y(nn), x(mm),:) / (length(x)*length(y));
            meanC = meanC + warpedImage(y(nn), x(mm),:) / (length(x)*length(y));
             %warpedImageP(y(nn), x(mm),:) = [255,0,0];
             %warpedImage(y(nn), x(mm),:) = [255,0,0];
        end
    end
    
    % compare the resulting means to estimate the gain
    gain = mean(meanC ./ meanP);
    
    % correct for the gain differences
    sceneImageSet(:,:,:,ii) = sceneImageSet(:,:,:,ii) / gain;
    
end

return;