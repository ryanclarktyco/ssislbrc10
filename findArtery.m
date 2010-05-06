function [out fIm minorLength majorLength A] = findArtery(in, iswhite)
%Input should be a slice of the image

[rows cols] = size(in);         %Finds the size of the image, used in looping later

thresh = mean(mean(in));        %Finds the average of the image
if(iswhite)
    bw = in < thresh;
else
    bw = in > thresh;               %White pixels are above the average, black are below at at the average
end
str = strel('disk', 3);         %Round structuring element
imC = imclose(bw, str);      %Dilates the image
erIm = imerode(~imC, str);
labelim = bwlabel(erIm);      %Creates a labeled image

maLen = regionprops(labelim, 'MajorAxisLength');        %Finds the length of the Major Axis of every connected component in the image
miLen = regionprops(labelim, 'MinorAxisLength');        %Finds the length of the Minor Axis of every connected component in the image
Area = regionprops(labelim, 'Area');                    %Finds the area of every connected component of the image

numConnComp = max(max(labelim));                        %Finds the number of connected components
loc = [];                                               %loc stores the connected component number that meet the large circular requirements I have specified below 
roundness = zeros(numConnComp,1);                       %Roundness stores the value of the major axis length/minor axis length, this should ideally be very close to one for circular objects

for m = 1:numConnComp                                   %Goes through all of the connected components
    if Area(m).Area>3000 %&& roundness(m)<1.2            %Finds objects with large areas that have roundness close to one
        loc = [loc m];                                  %Stores the connected components that meet this requirement
        minorLength = miLen(m).MinorAxisLength;
        majorLength = maLen(m).MajorAxisLength;
        roundness(m) = maLen(m).MajorAxisLength./miLen(m).MinorAxisLength;      %Finds the roundness
%         A = Area(m).Area;
    end
end

val = min(roundness(loc) - 1);
loc = find(roundness == val + 1);

A = Area(loc).Area;


if length(loc)>1                                        %Error checking
    warning('More than one space fits the criteria');
    oldloc = 1;
    for i=2:length(loc)
        if roundness(i)< roundness(oldloc)
            oldloc = i;
        end
    end
    loc = oldloc;
elseif length(loc)<1
    disp(' ')
    error('No connected componenet fits the data, the requirements are too restrictive');    
else
    clc
end

 fIms = regionprops(labelim, 'FilledImage');
 bBoxs = regionprops(labelim, 'BoundingBox');
 fIm = fIms(loc).FilledImage;
 bBox = bBoxs(loc).BoundingBox;
 
 out = bw;
%  out(floor(bBox(2)):floor(bBox(2))+bBox(4)-1,
%  floor(bBox(1)):floor(bBox(1))+bBox(3)-1) = fIm;

for x = 1:bBox(4)-1
    for y = 1:bBox(3)-1
        if fIm(x,y) == 1
            out(floor(bBox(2))+x-1, floor(bBox(1))+y -1) = 0;
        end
    end
end

 

% newIm = in;                                             %Sets what hopefully is now the segmented artery to 255 in the frame
% for x=1:rows
%     for y=1:cols
%         if labelim(x,y) == loc
%             newIm(x,y) = 255;
%         end
%     end
% end

% out = newIm;
end