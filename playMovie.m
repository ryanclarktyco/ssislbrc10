function playMovie(data)

no_ims = size(data,3);
colormap gray
Area = zeros(no_ims,1);
minLen =zeros(no_ims,1);
majLen = zeros(no_ims,1);

for i =1:no_ims
        [out fIm min max a] = findArtery(data(:,:,i));
        imagesc(out);%Calls the other function
        F(i) = getframe; 
        imagesc(fIm);
        F2(i) = getframe;
        Area(i) = a;
        minLen(i) = min;
        majLen(i) = max;
end
close all
movie(F,1)
movie(F2,1)


% figure()
subplot(2,1,1);
plot(Area)
title('Area')

subplot(2,1,2);
plot(1:48, minLen, 1:48, majLen)
legend('Minor Axis Length', 'Major Axis Length');

end