function playMovie(frames)

no_ims = size(frames,3);
colormap jet

for i =1:no_ims
    imagesc(findArtery(frames(:,:,i)));%find artery within frame
    F(i) = getframe;
end

close all
movie(F,1)

end