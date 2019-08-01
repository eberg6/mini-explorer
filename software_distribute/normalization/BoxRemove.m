function BoxRemove(tolerance, radius) 

 if ~exist('tolerance','var') 
    tolerance = 0.50;
 end 

 if ~exist('radius','var') 
    radius = 5;
 end

fname = 'ct_preregPET.raw'; 
fid = fopen(fname,'r');
dtemp = fread(fid,inf,'float');
fname2 = 'ct_preregPETinfo.mat';
dinfo = load(fname2);
grayImage = reshape(dtemp,dinfo.imsize);

[rows, columns, slices] = size(grayImage);

searchMax = max(max(grayImage(:,:,floor(slices/2))));
k = columns - 1;

for n = 0:k
    if grayImage(rows-n,floor(columns/2),floor(slices)/2) > 0.25*searchMax
       x = rows-n;
       y = floor(columns/2);
       break
    end
end

figure
imagesc(grayImage(:,:,floor(size(grayImage,3)/2)));

row = x;
column = y;
slice = floor(slices/2);
    
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

binaryImage = grayImage >= min(lowGL) ;
binaryMarkerImage = false(rows, columns, slices);
binaryMarkerImage(maxRow, maxColumn, slice) = true;
outputImage(:,:,:) = imreconstruct(binaryMarkerImage, binaryImage(:,:,:),26);

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