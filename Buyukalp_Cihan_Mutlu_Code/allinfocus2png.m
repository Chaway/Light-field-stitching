for ii = 1:1:size(allInFocus,4)
        dir = '../fps/';
        img_name = [dir num2str(ii) '.png'];
        imwrite(allInFocus(:,:,:,ii),img_name);
end 