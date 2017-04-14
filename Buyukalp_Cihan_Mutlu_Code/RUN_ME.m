clear; clc;

% enter scene number
% sceneNum = 4;

% crop the resulting panorama (or do not)
isCropPanorama = 0;

% save the resulting focal stack
savePanoramicFocalStack = 0;
folderName = strcat('IMG_Panoramic Focal Stack');

% number of perspectives in the lightfield data
numOfPerspect = 15;
%numOfPerspect = 14;
% number of focal planes in the computed focal stack
% enter an ODD number for the parameter
numOfFocalPlanes = 31;
maxShift = (numOfFocalPlanes - 1) /2;

% lytro image size
lytroImSize = [434 626];
%lytroImSize = [376,541];
% find the files with the specified scene number%

directory = '../group5/';
result_dir = '../group5_result/';
listing = dir([directory '*.mat']);
num_of_images = size(listing, 1);

focalPlanes = zeros(lytroImSize(1), lytroImSize(2), 3, numOfFocalPlanes, num_of_images);

parfor ii = 1 : num_of_images
    disp([directory listing(ii).name]);
    lfImage = readLfImage([directory listing(ii).name], numOfPerspect);
    focalPlanes(:,:,:,:,ii) = computeFocalStack(lfImage, numOfPerspect, numOfFocalPlanes, maxShift);    
end
focalPlanes = focalPlanes(1+maxShift:end-maxShift, 1+ maxShift:end-maxShift, :, :, :);

save([result_dir 'focalPlanes_31s.mat'],'focalPlanes');

focalplane2png

%load('focalPlanes_21_0.mat');
%up_ > down_
up_ = 21 ; down_ = 16 ;
allInFocus = zeros(lytroImSize(1) - 2*maxShift, lytroImSize(2) - 2*maxShift, 3, num_of_images);
parfor ii = 1: num_of_images
    allInFocus(:,:,:,ii) = bringAllInFocus(squeeze(focalPlanes(:,:,:,down_:up_,ii)), up_ - down_ + 1);
end

save([result_dir 'allInFocus_31s.mat'],'allInFocus');
% calculate the transform parameters for creating the panorama
allinfocus2png

transforms = calculateStichingParameters(allInFocus);
% create the all-in-focus image
allInFocusPanorama = createPanorama(allInFocus, transforms, isCropPanorama);
save([result_dir,'allInFocusPanorama.mat'],'allInFocusPanorama');
fig = figure;
imshow(allInFocusPanorama)



%print(fig,'allInFocusPanorama','-dpdf');
%clear allInFocusPanorama

%if (PanoramicFocalStack)
    %if exist(folderName, 'dir')
        %rmdir(folderName);
    %end
    %mkdir(folderName);
%end

% compute the panoramic focal stack

[height, width] = getPanoramaSize(allInFocus, transforms, isCropPanorama);
panoramicFocalPlanes = zeros(width, height, 3, numOfFocalPlanes);

for ii = 1 : numOfFocalPlanes
    panoramicFocalPlanes(:,:,:,ii) = createPanorama(squeeze(focalPlanes(:,:,:,ii, :)), transforms, isCropPanorama);
    %figure(); imshow(panoramicFocalPlanes(:,:,:,ii));
% 
end

save('panoramicFocalPlanes.mat','panoramicFocalPlanes');

panoramaLF = FStoNovView(panoramicFocalPlanes, numOfPerspect, numOfPerspect);
clear panoramicFocalPlanes;

% perform gamma correction by 2.2
panoramaLF = panoramaLF.^(1/2.2);

% webcam tracking and perspective update
numOfViews = size(panoramaLF, 3);
headTrackingOn = true;
ourWebcam = webcam();
img = snapshot(ourWebcam);
WebcamImgSize = [size(img,1), size(img,2)];
% vision.CascadeObjectDetector detect objects using the Viola-Jones algorithm
detector = vision.CascadeObjectDetector();
% vision.PointTracker System object tracks points in video using Kanade-Lucas-Tomasi (KLT) algorithm
trackerFeaturePts = vision.PointTracker('MaxBidirectionalError', 3);

videoObject=vision.VideoPlayer('Position',[0 450 size(panoramaLF,2) size(panoramaLF,1)]);
a = timer('ExecutionMode','fixedRate','Period',0.5, 'TimerFcn', @updatePerspective);
set(a, 'TimerFcn', ['headPos = trackHead(ourWebcam, detector,trackerFeaturePts);',...
    '    boxCent = [mean(headPos(:,1)), mean(headPos(:,2))];',...
    '    boxCentRound(1) = round(boxCent(1) / WebcamImgSize(2) * numOfViews);',...
    '    boxCentRound(2) = round(boxCent(2) / WebcamImgSize(1) * numOfViews);',...
    '    if (boxCentRound ~= [0 0] & boxCentRound(1)>=1 & boxCentRound(1)<=numOfViews & boxCentRound(2)>=1 & boxCentRound(2)<=numOfViews)',...
    '       step(videoObject, squeeze(real(panoramaLF(:,:,boxCentRound(1),numOfViews-boxCentRound(2),:))));',...
    '    end;',...
    '    boxCentRound;']);
start(a);
