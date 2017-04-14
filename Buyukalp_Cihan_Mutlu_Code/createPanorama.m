% this function takes the images to be stitched and the computed
% 2D spatial transforms to generate a warped panoramic image
function panorama = createPanorama(sceneImageSet, transforms, CropPanorama)
imageSize = [size(sceneImageSet, 1) size(sceneImageSet, 2)];

for ii = 1:length(transforms)           
    [xlim(ii,:), ylim(ii,:)] = outputLimits(transforms(ii), ...
        [1 imageSize(2)], [1 imageSize(1)]);
end

% Find the minimum and maximum output limits 
xMin = min([1; xlim(:)]);
xMax = max([imageSize(2); xlim(:)]);

yMin = min([1; ylim(:)]);
yMax = max([imageSize(1); ylim(:)]);

% Width and height of panorama.
width  = round(xMax - xMin);
height = round(yMax - yMin);

% Initialize the "empty" panorama.
panorama = zeros([height width 3], 'like', sceneImageSet(:,:,:,1));

% create an alpha blender to blend the images together
blender = vision.AlphaBlender('Operation', 'Binary mask', ...
    'MaskSource', 'Input port');  

% Create a 2-D spatial reference object defining the size of the panorama
xLimits = [xMin xMax];
yLimits = [yMin yMax];
panoramaView = imref2d([height width], xLimits, yLimits);

sceneImageSet = compensateGain(sceneImageSet, transforms, xLimits, yLimits, xMin, yMin, height, width);

% Create the panorama
for ii = 1:length(transforms)
    I = sceneImageSet(:,:,:,ii);
   
    % Transform I into the panorama.
    warpedImage = imwarp(I, transforms(ii), 'OutputView', panoramaView);
                  
    % Overlay the warpedImage onto the panorama.
    panorama = step(blender, panorama, warpedImage, warpedImage(:,:,1));
end

if (CropPanorama)
    [xmin, xmax, ymin, ymax] = PanoramaCropParameters(sceneImageSet, transforms, xMin, yMin);
    panorama = panorama(ymin:ymax, xmin:xmax, :);
end
    
return;