function focalPlanes = computeFocalStack(lfImage, numOfPerspect, numOfFocalPlanes, maxShift)

maxU = (numOfPerspect -1)/2;
maxV =  (numOfPerspect -1)/2;

focalPlanes = zeros(size(lfImage, 1), size(lfImage, 2), 3, numOfFocalPlanes);

for shift = -maxShift : maxShift
    %temp_im = zeros(size(lfImage,1), size(lfImage,2), size(lfImage,5));
    interp_im = zeros(size(lfImage,1), size(lfImage,2), size(lfImage,5));
    sum_im = zeros(size(lfImage,1), size(lfImage,2), size(lfImage,5));
   
    %rshift = shift*0.5 + 3;
    rshift = shift*0.4 + 2;
    for ky = 1 : numOfPerspect
        for kx = 1 : numOfPerspect
            u = (kx-1-maxU); v = (ky-1-maxV);
            shift_u = (u/maxU) * rshift;
            shift_v = (v/maxV) * rshift;
 
            temp_im = squeeze(lfImage(:,:,ky,kx,:));
            interp_im(:,:,1) = interp2([1:size(lfImage,2)], ...
               [1:size(lfImage,1)]', temp_im(:,:,1), shift_u+...
               [1:size(lfImage,2)],(shift_v+[1:size(lfImage,1)])','linear');
 
            interp_im(:,:,2) = interp2([1:size(lfImage,2)], ...
               [1:size(lfImage,1)]', temp_im(:,:,2), shift_u+...
               [1:size(lfImage,2)],(shift_v+[1:size(lfImage,1)])','linear');
 
            interp_im(:,:,3) = interp2([1:size(lfImage,2)], ...
               [1:size(lfImage,1)]', temp_im(:,:,3), shift_u+...
               [1:size(lfImage,2)],(shift_v+[1:size(lfImage,1)])','linear');
 
            sum_im = sum_im + interp_im;
        end
    end
 
focalPlanes(:,:,:, shift + maxShift + 1) = sum_im / max(sum_im(:));

end
