function [height, width] = getPanoramaSize(sceneImageSet, transforms, CropPanorama)

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

if (CropPanorama)
    [xmin, xmax, ymin, ymax] = PanoramaCropParameters(sceneImageSet, transforms, xMin, yMin);
    width = ymax - ymin + 1;
    height = xmax - xmin + 1;
else
    width  = round(xMax - xMin);
    height = round(yMax - yMin);
end

return;