function playMovie(data)

no_ims = size(data,3);
for i =1:no_ims
        imagesc(findArtery(data(:,:,i)));%Calls the other function
        F(i) = getframe; 
end

movie(F,1)

%     artery = uint8(data);
%     no_ims = size(artery,3);
% 
%     map = colormap('gray');
%     close all
% 
%     for m = 1:no_ims
% %        frame_jet(m) = im2frame(artery(:,:,m), map);
%         frame_jet(m) = im2frame(artery(:,:,m), map);
%     end
%     
%     figure()
%     movie(frame_jet, 2);

% artery = data;
% no_ims = size(artery,3);
% 
% map = colormap('gray');
% for m = 1:no_ims
%    imagesc(artery(:, :, m));
%    F(m) = getframe;
% end
% 
% movie(F, 2);

end

function out = findArtery(in)
%Input should be a slice of the image

[rows cols] = size(in);         %Finds the size of the image, used in looping later

thresh = mean(mean(in));        %Finds the average of the image
bw = in > thresh;               %White pixels are above the average, black are below at at the average
str = strel('disk', 3);         %Round structuring element
dilIm = imdilate(bw, str);      %Dilates the image
labelim = bwlabel(~dilIm);      %Creates a labeled image

% close all                       %Closes all of the other figures
% figure()
% imshow(labelim, [])
% title('Labeled Image')
% figure()
% imshow(dilIm,[])
% title('Dilated Binary Image');
% figure()
% imshow(bw,[])
% title('Binary Image')

maLen = regionprops(labelim, 'MajorAxisLength');        %Finds the length of the Major Axis of every connected component in the image
miLen = regionprops(labelim, 'MinorAxisLength');        %Finds the length of the Minor Axis of every connected component in the image
Area = regionprops(labelim, 'Area');                    %Finds the area of every connected component of the image

numConnComp = max(max(labelim));                        %Finds the number of connected components
loc = [];                                               %loc stores the connected component number that meet the large circular requirements I have specified below 
roundness = zeros(numConnComp,1);                       %Roundness stores the value of the major axis length/minor axis length, this should ideally be very close to one for circular objects

for m = 1:numConnComp                                   %Goes through all of the connected components
    roundness(m) = maLen(m).MajorAxisLength./miLen(m).MinorAxisLength;      %Finds the roundness
    if Area(m).Area>3000 && roundness(m)<1.5            %Finds objects with large areas that have roundness close to one
        loc = [loc m];                                  %Stores the connected components that meet this requirement
        [Area(m).Area roundness(m)]
    end
end

if length(loc)>1                                        %Error checking
    warning('More than one space fits the criteria');
    oldloc = 1;
    for i=2:length(loc)
        if roundness(i)> roundness(oldloc)
            oldloc = i;
        end
    end
    loc = oldloc;
end

newIm = in;                                             %Sets what hopefully is now the segmented artery to 255 in the frame
for x=1:rows
    for y=1:cols
        if labelim(x,y) == loc
            newIm(x,y) = 255;
        end
    end
end


% figure
% imshow(newIm,[])                                        %Shows the new frame with artery segmentation

out = newIm;
clc
end
