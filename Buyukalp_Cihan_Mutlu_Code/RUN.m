clear; clc;

% enter scene number
% sceneNum = 4;

% crop the resulting panorama (or do not)
isCropPanorama = 1;

% save the resulting focal stack
savePanoramicFocalStack = 0;
folderName = strcat('IMG_Panoramic Focal Stack');

% number of perspectives in the lightfield data
%numOfPerspect = 15;
numOfPerspect = 14;
% number of focal planes in the computed focal stack
% enter an ODD number for the parameter
numOfFocalPlanes = 11;
maxShift = (numOfFocalPlanes - 1) /2;

% lytro image size
%lytroImSize = [434 625];
lytroImSize = [376,541];
% find the files with the specified scene number%
%listing = dir('IMG*');
listing = dir('Scene4_Image*.mat');
num_of_images = size(listing, 1);

focalPlanes = zeros(lytroImSize(1), lytroImSize(2), 3, numOfFocalPlanes, num_of_images);
allInFocus = zeros(lytroImSize(1)-2*maxShift, lytroImSize(2)-2*maxShift, 3, num_of_images);

for ii = 1 : num_of_images
	    lfImage = readLfImage(listing(ii).name, numOfPerspect);
	    focalPlanes(:,:,:,:,ii) = computeFocalStack(lfImage, numOfPerspect, numOfFocalPlanes);
	    allInFocus(:,:,:,ii) = bringAllInFocus(squeeze(focalPlanes(:,:,:,:,ii)), numOfFocalPlanes, lytroImSize);
 end
 save('focalPlanes.mat','focalPlanes');
 save('allInFocus_scene.mat','allInFocus');
