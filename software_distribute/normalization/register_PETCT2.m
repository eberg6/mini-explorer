function register_PETCT2(CTpath,PETpath)
% this one is used for cylinder calibration scans
CTpath
PETpath

petpix = 1.005; 
g_smooth = 4; 

numrad = 157; 
numang = 156;
numrings = 111;

num_voxels = 323;
num_voxels2 = 267;
num_slices = 445;
image_size = [num_voxels num_voxels num_slices];
voxel_size = [1.005, 1.005, 1.005];



%%% Load and prep the pet and ct images

% load CT image
fname2 = [CTpath,'/ct_preregPETinfo.mat'];
ctinfo = load(fname2); 
ct_imsize = ctinfo.imsize; 

fname1 = [CTpath,'/ct_preregPET.raw'];
fid1 = fopen(fname1,'rb');
ctimg = fread(fid1,inf,'float'); 
ctimg = reshape(ctimg,ct_imsize); 
ctimg = ctimg./2000; 
ctimg = imgaussfilt3(ctimg,[4/2.35,4/2.35,4/2.35]); 


if ct_imsize(1) > 323
	ctimg = ctimg((round(ct_imsize(1)/2)-161):(round(ct_imsize(1)/2)+161),(round(ct_imsize(2)/2)-161):(round(ct_imsize(2)/2)+161),:); 
end

if ct_imsize(1) < 323
	ctimgnew = zeros(323,323,ct_imsize(3)); 
	ctimgnew(1:ct_imsize(1),1:ct_imsize(2),:) = ctimg; 
end

% load bed CT
fname22 = '/run/media/meduser/data/software_distribute/normalization/CT_PETbed.raw';
fid22 = fopen(fname22,'rb'); 
ctimgb = fread(fid22,inf,'float'); 
nr = length(ctimgb)/323; 
ctimgb = reshape(ctimgb,nr,323); 
ctimgb = flipud(ctimgb); 
ctimgb = permute(ctimgb,[2,1]); 
ctimgb = ctimgb - 0.0125; 

% load PET image
fname3 = [PETpath]; 
fid3 = fopen(fname3,'rb'); 
petimg = fread(fid3,inf,'float'); 
num_voxels2 = sqrt(length(petimg)/num_slices); 
petimg = reshape(petimg,num_voxels2,num_voxels2,num_slices); 

petimg = imgaussfilt3(petimg,g_smooth/2.355); 

petimg(:,:,1:6) = 0; 
petimg(:,:,(end-5):end) = 0; 
petimg(1:6,:,:) = 0; 
petimg((end-5):end,:,:) = 0; 
petimg(:,1:6,:) = 0; 
petimg(:,(end-5):end,:) = 0; 

if (num_voxels2<323)
	
	petimg2 = zeros(num_voxels,num_voxels,num_slices); 
	sizediff = (num_voxels - num_voxels2)/2; 
	petimg2((sizediff+1):(end-sizediff),(sizediff+1):(end-sizediff),:) = petimg; 
	petimg = petimg2; 
end


% find 
petimg2 = zeros(size(petimg)); 
for yyy = 3:442
	petimg2(:,:,yyy) = mean(petimg(:,:,(yyy-2):(yyy+2)),3); 
end
petimg = petimg2; 
clear petimg2; 

count11 = 1;
for yyy = 100:350
	petimgtemp = petimg(:,:,yyy); 

	sum1 = sum(petimgtemp,1); 
	sum2 = sum(petimgtemp,2);
	sum2 = sum2';  
	
	xx1 = find(sum1>0.015,1,'first'); 
	xx2 = find(sum1>0.015,1,'last'); 
	x1 = interp1(sum1((xx1-1):xx1),[(xx1-1),xx1],0.015); 
	x2 = interp1(sum1(xx2:(xx2+1)),[xx2,(xx2+1)],0.015); 
	mu1 = (x2+x1)/2; 
	
	yy1 = find(sum2>0.015,1,'first'); 
	yy2 = find(sum2>0.015,1,'last'); 
	y1 = interp1(sum2((yy1-1):yy1),[(yy1-1),yy1],0.015); 
	y2 = interp1(sum2(yy2:(yy2+1)),[yy2,(yy2+1)],0.015); 
	mu2 = (y1+y2)/2; 

	%mu1 = sum(sum1.*(1:323))/sum(sum1)
	%mu2 = sum(sum2.*(1:323)')/sum(sum2)

	mustore(count11,1) = mu1;
	mustore(count11,2) = mu2; 
	count11 = count11+1; 
end

xxpet = (100:350)'; 

ppet1 = polyfit(xxpet,mustore(:,1),1); 
ppet2 = polyfit(xxpet,mustore(:,2),1);

yfitpet1 = ppet1(1).*xxpet + ppet1(2);
yfitpet2 = ppet2(1).*xxpet + ppet2(2); 

figure
plot(xxpet,mustore(:,1),'b',xxpet,yfitpet1,'r')
figure
plot(xxpet,mustore(:,2),'b',xxpet,yfitpet2,'r')


pause(1)

% cut off ends of cylinder
ctimg = ctimg(:,:,30:(end-29)); 
ctimg = ctimg(:,:,1:455); 



% remove GE petct bed
%vv2 = 102;
%ctimg(:,1:vv2,:) = 0; 
ctimg(:,1:60,:) = 0.0125;
ctimg(ctimg<0.43) = 0.0125; 
ctimg(1:5,:,:) = 0; 
ctimg((end-5):end,:,:) = 0; 
ctimg(:,1:5,:) = 0;
ctimg(:,(end-5):end,:) = 0; 
ctimg(ctimg<0) = 0; 

count22 = 1;
for zzz = 100:350
	ctimgtemp = ctimg(:,:,zzz); 

	sum1 = sum(ctimgtemp,1); 
	sum2 = sum(ctimgtemp,2);
	sum2 = sum2'; 
	sum1(1:60) = 3.6; 
	sum1(250:end) = 3.6; 
	sum2(1:60) = 3.6; 
	sum2(250:end) = 3.6;
	
	
	xx1 = find(sum1>15,1,'first'); 
	xx2 = find(sum1>15,1,'last'); 
	x1 = interp1(sum1((xx1-1):xx1),[(xx1-1),xx1],15); 
	x2 = interp1(sum1(xx2:(xx2+1)),[xx2,(xx2+1)],15); 
	mu1 = (x2+x1)/2; 
	
	yy1 = find(sum2>15,1,'first'); 
	yy2 = find(sum2>15,1,'last'); 
	y1 = interp1(sum2((yy1-1):yy1),[(yy1-1),yy1],15); 
	y2 = interp1(sum2(yy2:(yy2+1)),[yy2,(yy2+1)],15); 
	mu2 = (y1+y2)/2; 
	
	if mu1<140
		figure
		imagesc(ctimgtemp); 
		
		%figure
		%plot(sum1)
		pause
	end

	%mu1 = sum(sum1.*(1:323))/sum(sum1)
	%mu2 = sum(sum2.*(1:323)')/sum(sum2)

	mustorect(count22,1) = mu1;
	mustorect(count22,2) = mu2; 
	count22 = count22+1; 
end

xxct = (100:350)'; 

pct1 = polyfit(xxct,mustorect(:,1),1); 
pct2 = polyfit(xxct,mustorect(:,2),1);

yfitct1 = pct1(1).*xxct + pct1(2);
yfitct2 = pct2(1).*xxct + pct2(2); 

figure
plot(xxct,mustorect(:,1),'b',xxct,yfitct1,'r')
figure
plot(xxct,mustorect(:,2),'b',xxct,yfitct2,'r')

ctimgreg = zeros(size(petimg)); 
for z = 1:445
	x0pet = ppet1(1)*z + ppet1(2); 
	y0pet = ppet2(1)*z + ppet2(2); 
	x0ct = pct1(1)*z + pct1(2); 
	y0ct = pct2(1)*z + pct2(2); 
	
	tx = petpix*(x0pet - x0ct); 
	ty = petpix*(y0pet - y0ct); 
	
	AA = [1,0,0;0,1,0;tx,ty,1]; 
	
	Rfixed = imref2d(size(petimgtemp),petpix,petpix);
	
	tform = affine2d(AA); 
	ctimgtemp = ctimg(:,:,z); 
	ctimgregtemp = imwarp(ctimgtemp,tform,'OutputView',Rfixed); 
	vv2 = round(ppet1(1)*223 + ppet1(2)) - 50; 
	ctimgregtemp(:,(vv2+36-nr):(vv2+35)) = ctimgregtemp(:,(vv2+36-nr):(vv2+35)) + ctimgb;
	
	ctimgreg(:,:,z) = ctimgregtemp; 
end
	


ctimgdisp = ctimgreg./max(ctimgreg(:)); 
petimgdisp = petimg./(2*max(petimg(:))); 

helperVolumeRegistration(ctimgdisp,petimgdisp); 

petsag = squeeze(petimgdisp(round(size(petimgdisp,1)/2),:,:));
ctsag = squeeze(ctimgdisp(round(size(ctimgdisp,1)/2),:,:)); 

figure(1)

imagesc(petsag) 
colormap(flipud(gray)); 
caxis([min(petsag(:)) 3.5.*mean(petsag(:))]);
axis image

figure(2)

imagesc(ctsag)
colormap(gray); 
axis image


disp('check registration accuracy, press any key to continue'); 

pause

ctimgreg = ctimgreg.*2000; 

ctpathreg = [CTpath,'/ct_reg.raw']; 
fid3 = fopen(ctpathreg,'w'); 
fwrite(fid3,ctimgreg,'float'); 
fclose(fid3); 

petpathreg = [CTpath,'/pet_reg.raw'];
fid4 = fopen(petpathreg,'w'); 
fwrite(fid4,petimg,'float'); 
fclose(fid4); 




