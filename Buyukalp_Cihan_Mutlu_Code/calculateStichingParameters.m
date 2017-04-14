% this function takes the all-in-focus input images and finds the 
% transformations for the panoramic stitching of the individual images
function transforms  = calculateStichingParameters(sceneImageSet)
%sceneImageSet is a 4D array of stacked all-in-focus images
%stacking is done as [x y color image_number]
num_of_images = size(sceneImageSet, 4);
imageSize = [size(sceneImageSet, 1) size(sceneImageSet, 2)];

% register the images starting from the first image
I = sceneImageSet(:,:,:,1);
grayImage = rgb2gray(I);

% using detectSURFFeatures from MATLAB computer vision toolbox to detect
% SURF features
points = detectSURFFeatures(grayImage);
% extract feature descriptors
[features, points] = extractFeatures(grayImage, points);

% in the remaining part, we want to calculate the transforms that map
% image n to image n-1 such that we know the required transforms to 
% create a panoramic image

% first, create an identity matrix to store the transforms
transforms(num_of_images) = projective2d(eye(3));

% iteration over the remaining images
for ii = 2 : num_of_images    
    % Store points and features for I(n-1).
    pointsPrevious = points;
    featuresPrevious = features;
      
    I = sceneImageSet(:,:,:,ii);
    
    % Detect and extract SURF features for the current image
    grayImage = rgb2gray(I);    
    %points = detectSURFFeatures(grayImage,'MetricThreshold',1000);    
    points = detectSURFFeatures(grayImage); 
    [features, points] = extractFeatures(grayImage, points);
    
    % find matching features between the current and previous images
     matches = matchFeatures(features, featuresPrevious, 'Unique', true,'MatchThreshold',0.5);
     %matches = matchFeatures(features, featuresPrevious, 'Unique', true);
    % extract the matching points in the images
    matchedPoints = points(matches(:,1), :);
    matchedPointsPrev = pointsPrevious(matches(:,2), :);     
    size(matchedPoints)
    
    %show matched points in a pair of  images
    fig = figure; 
    ax = axes;
    showMatchedFeatures(sceneImageSet(:,:,:,ii - 1),I,matchedPointsPrev,matchedPoints,'montage','Parent',ax);
    legend('matched points 1','matched points 2');
    print(fig,['m' int2str(ii - 1)],'-dpdf');
    % IMPORTANT!
    % the transform between the previous image and the current image is
    % calculated here
    transforms(ii) = estimateGeometricTransform(matchedPoints, ...
        matchedPointsPrev, 'projective', 'Confidence', 99.99, ...
        'MaxNumTrials', 100000,'MaxDistance',1.5);
    
    % compute the transform of the current image with respect to the
    % FIRST image instead of the previous one
    transforms(ii).T = transforms(ii-1).T * transforms(ii).T; 
end

% in order to obtain a more pleasing view, we try to detect the particular
% image that sits approximately at the center of the resulting panorama
% First, compute the output limits  for each transform
for ii = 1:length(transforms)           
    [xlim(ii,:), ylim(ii,:)] = outputLimits(transforms(ii), ...
        [1 imageSize(2)], [1 imageSize(1)]);    
end

% compute the center image of the panorama image in the x-direction
avgXLim = mean(xlim, 2);
[~, idx] = sort(avgXLim);
centerIdx = floor((length(transforms)+1)/2);
centerImageIdx = idx(centerIdx);

% apply inverse transform to all images so that all transforms are 
% defined with respect to the center image
inverse_transform = invert(transforms(centerImageIdx));

for ii = 1:numel(transforms)    
    transforms(ii).T = inverse_transform.T * transforms(ii).T;
end

return;
