function grayImageMasked = BoxRemove1Click(tolerance, radius, grayImage) 

 if ~exist('tolerance','var') 
    tolerance = 0.50;
 end 

 if ~exist('radius','var') 
    radius = 5;
 end

%tolerance = 0.50;
%radius = 5;

% Load and read file 
%fname = 'ct_preregPET.raw'; 
%fid = fopen(fname,'r');
%dtemp = fread(fid,inf,'float');
%fname2 = 'ct_preregPETinfo.mat';
%dinfo = load(fname2);
%grayImage = reshape(dtemp,dinfo.imsize);

[rows, columns, slices] = size(grayImage);




figure
imagesc(grayImage(:,:,floor(size(grayImage,3)/2)));

uiwait(msgbox(sprintf('Click a point on the box to remove')));

coordinates = [];

% Select box and circles
%hold on
%for i = 1:1
%  w = waitforbuttonpress;
%    points = get(gca,'CurrentPoint');
%     x = abs(round(points(1,2)));
%     y = abs(round(points(1,1)));
%     coordinates(i,:) = [x, y];
%end
%hold off

 
[x,y] = ginput(1); 
coordinates(1,:) = [round(y),round(x)];

%runningSelectionMsgbox = msgbox(sprintf('Program is running, please wait...'), 'Running', 'replace');
disp('Program is running, please wait...'); 

n = length(coordinates(:,1));

binaryImageS = false(rows, columns, slices, n);
outputImageS = zeros(rows, columns, slices, n);
slice = floor(slices/2);

% Segment based on each click
for k=1:n
    row = coordinates(k,1);
    column = coordinates(k,2);
    
    % Correct if click misses actual pixel of ROI
    rowLow = row - radius;
    rowHigh = row + radius;
    columnLow = column - radius;
    columnHigh = column + radius;
    maxValue = max(max(grayImage(rowLow:rowHigh, columnLow:columnHigh, slice)));
    [newRow,newColumn] = find(grayImage(rowLow:rowHigh, columnLow:columnHigh, slice) == maxValue);
    maxRow = row + newRow - radius - 1;
    maxColumn = column + newColumn - radius - 1;
        
    grayLevel = grayImage(maxRow, maxColumn, slice);
    lowGL = grayLevel - tolerance*grayLevel;
    highGL = grayLevel + tolerance*grayLevel;

    binaryImagek = grayImage >= min(lowGL) & grayImage <= max(highGL) ;
    binaryImageS(:,:,:,k) = binaryImagek;
    binaryMarkerImage = false(rows, columns, slices);
    binaryMarkerImage(maxRow, maxColumn, slice) = true;
    outputImageS(:,:,:,k) = imreconstruct(binaryMarkerImage, binaryImageS(:,:,:,k),26);
end 

binaryImage = zeros(rows, columns, slices);
outputImage = zeros(rows, columns, slices);

% Combine 3 segmented images together
for i=1:n
    binaryImage = binaryImage | binaryImageS(:,:,:,i);
    outputImage = outputImage | outputImageS(:,:,:,i);
end

outputFilled = imfill(outputImage,'holes');

%% Original Gray Image
 figure
    imshow3Dfull2(grayImage, []);
    
%% Binary Image Above Threshold
 figure
    imshow3Dfull2(binaryImage);
    caption = sprintf('Binary Image within \n %d Gray Levels below %d and \n %d Gray Levels above %d', tolerance, min(grayLevel), tolerance, max(grayLevel));
    title(caption);

%% Binary Image Constructed from Seed Point  
 figure
    imshow3Dfull2(outputImage, []);
    title('Reconstructed Binary Image from Seed Points');

%% Binary Image from Filling Any Holes in outputImage     
 figure
    imshow3Dfull2(outputFilled);
    title('Reconstructed Binary Image from Seed Points w/ Holes Filled');
    
%% Original Image with Only Box   
 figure
    maskedImage = zeros(rows, columns, slices);
    maskedImage(outputFilled) = grayImage(outputFilled);
    imshow3Dfull2(maskedImage);
    title('Grayscale Image from Seed Points');  
    
%% Original Gray Image with Box Masked Out 
 figure
    grayImageMasked = grayImage;
    blackMask = zeros(size(outputFilled));
    grayImageMasked(outputFilled) = blackMask(outputFilled);
    imshow3Dfull2(grayImageMasked, []);

%% Finish    
if exist('runningSelectionMsgbox', 'var')
	delete(runningSelectionMsgbox);
	clear('runningSelectionMsgbox');
end


uiwait(msgbox(sprintf('Paused to check images, press ok when ready')));

