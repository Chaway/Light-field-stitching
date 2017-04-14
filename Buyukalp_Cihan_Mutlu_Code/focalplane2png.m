% save focalPlanes on different depth to png
for ii = 1:1:size(focalPlanes,4)
    for jj = 1:1:size(focalPlanes,5) 
        dir = '../fps/';
        img_name = [dir num2str(jj) '_d' num2str(ii) '.png'];
        imwrite(focalPlanes(:,:,:,ii,jj),img_name);
    end
end 