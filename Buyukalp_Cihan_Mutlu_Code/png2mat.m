clear
close all;
listing = dir('Scene4_*');
numOfPerspect = 14;

for ii = 1:length(listing)
fileName = listing(ii);    
lfImage = imread(fileName.name);
imsize = size(lfImage(:,:,1)) / numOfPerspect;
% create a buffer and fill in with different perspectives
lfbuffer = zeros(imsize(1), imsize(2), numOfPerspect, numOfPerspect, 3);
 
for ky = 1 : numOfPerspect
    for kx = 1 : numOfPerspect
        lfbuffer(1 : imsize(1), 1 : imsize(2), ky,kx,:) = ...
        lfImage(ky:numOfPerspect:end, kx:numOfPerspect:end, :);
        
    end
end
LF = permute(lfbuffer,[3,4,1,2,5]);
save([fileName.name '.mat'],'LF');
end