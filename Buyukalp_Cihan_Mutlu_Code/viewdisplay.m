close all;
clear
numOfPerspect = 14;
sceneNum = 4;
listing = dir('IMG*');
for ii = 1:length(listing)
    lfImage = readLfImage(listing(ii).name, numOfPerspect);
    %figure
    %imshow(squeeze(lfImage(:,:,numOfPerspect/2,numOfPerspect/2,:)));
end


for ii = 1:size(focalPlanes,4)
   figure()
   imshow(focalPlanes(:,:,:,ii,2));
end


load('allInFocus.mat');

for ii = 1: size(allInFocus,4)
    figure()
    imshow(allInFocus(:,:,:,ii));
end

load('allInFocusPanorama.mat');
figure
imshow(allInFocusPanorama);

load('focalPlanes.mat');

for ii = 1:size(focalPlanes,5)
    for jj = 1:size(focalPlanes,4)
        figure()
        imshow(focalPlanes(:,:,:,jj,ii));        
    end
end

load('panoramicFocalPlanes.mat');
for ii = size(panoramicFocalPlanes,4):-1:1
    figure
    imshow(panoramicFocalPlanes(:,:,:,ii));
end

