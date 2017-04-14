function lfbuffer = readLfImage(fileName, numOfPerspect)
% 
% lfImage = im2double(imread(fileName));
% imsize = size(lfImage(:,:,1)) / numOfPerspect;
%  
% % create a buffer and fill in with different perspectives
% lfbuffer = zeros(imsize(1), imsize(2), numOfPerspect, numOfPerspect, 3);
%  
% for ky = 1 : numOfPerspect
%     for kx = 1 : numOfPerspect
%         lfbuffer(1 : imsize(1), 1 : imsize(2), ky,kx,:) = ...
%             lfImage(ky:numOfPerspect:end, kx:numOfPerspect:end, :);
%     end
% end

load(fileName);
lfbuffer = im2double(permute(LF(:,:,:,:,1:3),[3 4 1 2 5]));

return