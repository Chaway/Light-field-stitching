function  imsave(img,name)
    fig = figure;
    imshow(img);
    print(fig,name,'-dpdf');
end
