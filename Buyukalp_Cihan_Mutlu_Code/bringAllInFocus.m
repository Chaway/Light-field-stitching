function allInFocus = bringAllInFocus(allImages, numOfFocalPlanes)

%maxShift = (numOfFocalPlanes - 1) / 2;
 
allImagesDx = zeros(size(allImages));
allImagesDy = zeros(size(allImages));
allImagesD = zeros(size(allImages));

lytroImSize = [size(allImages,1),size(allImages,2)] ;
% Define the gradient operators
Dx = [-1 1];
DxF = psf2otf(Dx, [lytroImSize(1) lytroImSize(2)]);
DyF = psf2otf(Dx', [lytroImSize(1) lytroImSize(2)]);
 
for ii = 1 : numOfFocalPlanes
    allImagesDx(:,:,1,ii) = ifft2(fft2(allImages(:,:,1,ii)) .* DxF);
    allImagesDx(:,:,2,ii) = ifft2(fft2(allImages(:,:,2,ii)) .* DxF);
    allImagesDx(:,:,3,ii) = ifft2(fft2(allImages(:,:,3,ii)) .* DxF);
    
    allImagesDy(:,:,1,ii) = ifft2(fft2(allImages(:,:,1,ii)) .* DyF);
    allImagesDy(:,:,2,ii) = ifft2(fft2(allImages(:,:,2,ii)) .* DyF);
    allImagesDy(:,:,3,ii) = ifft2(fft2(allImages(:,:,3,ii)) .* DyF); 
    
    allImagesD(:,:,:,ii) = sqrt(allImagesDx(:,:,:,ii).^2 + ...
        allImagesDy(:,:,:,ii).^2);
end
 
allInFocus = zeros(lytroImSize(1), lytroImSize(2),3);
defocusImage = zeros(lytroImSize(1), lytroImSize(2),3);
maxGradient = zeros(lytroImSize(1), lytroImSize(2), 3);
 
for ii = 1 : lytroImSize(1)
    for jj = 1 : lytroImSize(2)
        for kk = 1 : 3
            gradients = squeeze(allImagesD(ii,jj,kk,:));
            [maxG, I] = max(gradients);
            maxGradient(ii,jj,kk) = maxG;
            allInFocus(ii,jj,kk) = allImages(ii,jj,kk,I);
            defocusImage(ii,jj,kk) = I;
        end
    end
end
%crop the resulting image to remove cropping artifacts
%allInFocus = allInFocus(2+maxShift:end-maxShift-1, 2+maxShift:end-maxShift-1, :);

%median filter
% figure()
% subplot(1,2,1)
% imshow(allInFocus);
% hold on
% for ii = 1:1:size(allInFocus,3)  
%    allInFocus(:,:,ii) = medfilt2(allInFocus(:,:,ii), [5 5]);
%    subplot(1,2,2);
% end
% subplot(1,2,2);
% imshow(allInFocus);
% hold off
return;