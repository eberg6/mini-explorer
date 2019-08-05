function register_PETCT(CTpath,PETpath)


petpix = 1.005; 
g_smooth = 3.5; 

zika_flag = 0; 

zika_flag = contains(CTpath, 'Zika'); 
if zika_flag
	disp('Image registration with Zika box'); 
end 

numrad = 157; 
numang = 156;
numrings = 111;

num_voxels = 323;
num_voxels2 = 267;
num_slices = 445;
image_size = [num_voxels num_voxels num_slices];
voxel_size = [1.005, 1.005, 1.005];

log_pet = true;


%%% Load and prep the pet and ct images

% load CT image
fname2 = [CTpath,'/ct_preregPETinfo.mat'];
ctinfo = load(fname2); 
ct_imsize = ctinfo.imsize; 
ct_dcminfo = ctinfo.ct_dcminfo; 
 

fname1 = [CTpath,'/ct_preregPET.raw'];
fid1 = fopen(fname1,'rb');
ctimg = fread(fid1,inf,'float'); 
ctimg = reshape(ctimg,ct_imsize); 
ctimg = ctimg./2000; 

if ct_imsize(1) > 323
	ctimg = ctimg((round(ct_imsize(1)/2)-161):(round(ct_imsize(1)/2)+161),(round(ct_imsize(2)/2)-161):(round(ct_imsize(2)/2)+161),:); 
end

if ct_imsize(1) < 323
	ctimgnew = zeros(323,323,ct_imsize(3)); 
	ctimgnew(1:ct_imsize(1),1:ct_imsize(2),:) = ctimg; 
	ctimg = ctimgnew; 
	clear ctimgnew;
end

% load bed CT
fname22 = '../normalization/CT_PETbed.raw';
fid22 = fopen(fname22,'rb'); 
if ~fid22
	disp('open file fail - register pet ct, paused'); 
	pause
end

ctimgb = fread(fid22,inf,'float'); 
nr = length(ctimgb)/323; 
ctimgb = reshape(ctimgb,nr,323); 
ctimgb = flipud(ctimgb); 
ctimgb = permute(ctimgb,[2,1]); 


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

%if (num_voxels2<323)
	
	%petimg2 = zeros(num_voxels,num_voxels,num_slices); 
	%sizediff = (num_voxels - num_voxels2)/2; 
	%petimg2((sizediff+1):(end-sizediff),(sizediff+1):(end-sizediff),:) = petimg; 
	%petimg = petimg2; 
%end

% 

% first correct for angle of ct image relative to pet
bed_npix_d = 16; 
bed_npix_h = 16; 
bed_hu = 0.17;

%ff = [0.12,0.17,0.21,0.18,0.12]';
ff = [0.13,0.19,0.24,0.2,0.13]'; 
%ff = [0.09,0.13,0.25,0.22,0.14]'; 

ctsag = (ctimg((round(size(ctimg,1)/2)-1):(round(size(ctimg,1)/2)+1),:,:)); 
ctsag = mean(ctsag,1);
ctsag = squeeze(ctsag); 
ctsag = imgaussfilt(ctsag,3/2.355); 


figure
imagesc(ctsag)
colormap(gray); 
pause(1)


pos_store = zeros((425-225),1);
ccc = 1;  
for axpos = 225:425
%axpos1 = 175; 
%axpos2 = 350; 

lp1 = ctsag(:,axpos); 
%lp2 = ctsag(:,axpos2); 



dmin = 100; 
dtemp = 0; 
pos = 1; 

for yind = 3:(length(lp1)-bed_npix_d-20)
	
	%dtemp = sum(abs(lp1((yind-2):(yind+2))-ff)) + sum(abs(lp1((yind+bed_npix_d-2):(yind+bed_npix_d+2))-ff)) + sum(abs(lp1((yind+8):(yind+11))-0.092.*ones(4,1))) + sum(abs(lp1((yind+bed_npix_d+13):(yind+bed_npix_d+16))-(0.5.*ones(4,1))));
	
	dtemp = sum(abs(lp1((yind-2):(yind+2))-ff)) + sum(abs(lp1((yind+bed_npix_d-2):(yind+bed_npix_d+2))-ff)) + sum(abs(lp1((yind+8):(yind+11))-0.092.*ones(4,1)));
	 
	if dtemp < dmin
		dmin = dtemp;
		pos = yind; 
	end
end

pos_store(ccc) = pos;
ctrow1 = pos;
ctcol1 = axpos;
ccc=ccc+1; 
end


mean_pos = mean(pos_store); 
pos_store((abs(pos_store-mean_pos)/mean_pos)>0.4) = mean_pos; 

%figure
%plot(1:ccc-1,pos_store); 


bedfit = polyfit((225:425)',pos_store,1);

ctrow2 = bedfit(1)*425 + bedfit(2); 
ctrow1 = bedfit(1)*225 + bedfit(2); 
ctcol2 = 425; 
ctcol1 = 225; 


%dmin = 10; 
%dtemp = 0; 
%pos = 1;
%for yind = 3:(length(lp2)-bed_npix_d-20)
	%dtemp = sum(abs(lp2((yind-2):(yind+2))-ff)) + sum(abs(lp2((yind+bed_npix_d-2):(yind+bed_npix_d+2))-ff)) + sum(abs(lp2((yind+bed_npix_d+13):(yind+bed_npix_d+16))-(0.5.*ones(4,1)))); 
	%if dtemp < dmin
	%	dmin = dtemp;
	%	pos = yind; 
	%end
%end

%ctrow2 = pos;
%ctcol2 = axpos2;

theta = atan((ctrow2-ctrow1)/(ctcol2-ctcol1)); 
theta = theta*(180/pi); 

if ~(theta > -20 && theta < 10)
	theta = -3; 
end

pause(1); 






ctsag = (ctimg((round(size(ctimg,1)/2)-1):(round(size(ctimg,1)/2)+1),:,:)); 
ctsag = mean(ctsag,1);
ctsag = squeeze(ctsag); 
ctsag = imgaussfilt(ctsag,3/2.355);





if zika_flag
	figure(3)
	imagesc(ctsag)
	title('Click on GE PET/CT bed'); 
	colormap(gray);
	[ctcol3,ctrow3] = ginput(1);
	
	ctrow3 = ctrow3 + 35;
	 

else

	ctimgnew = ctimg; 
	for n=1:size(ctimg,1) 
		imtemp1 = squeeze(ctimg(n,:,:));
		imtemp = imrotate(imtemp1,theta,'bilinear','crop');
		ctimgnew(n,:,:) = permute(imtemp,[3,1,2]); 
	end
	ctimg = ctimgnew; 
	clear ctimgnew; 


	pos_store = zeros((325-225),1);
	ccc = 1;  

	for axpos = 225:325
 
		axpos3 = axpos;  

		lp1 = ctsag(:,axpos3); 

		% find bed in rotated image
		dmin = 100; 
		dtemp = 0; 
		pos = 1;
		for yind = 3:(length(lp1)-bed_npix_h-20)
			%dtemp = sum(abs(lp3((yind-2):(yind+2))-ff)) + sum(abs(lp3((yind+bed_npix_d-2):(yind+bed_npix_d+2))-ff)) + sum(abs(lp3((yind+bed_npix_d+13):(yind+bed_npix_d+16))-(0.5.*ones(4,1)))); 
			dtemp = sum(abs(lp1((yind-2):(yind+2))-ff)) + sum(abs(lp1((yind+bed_npix_d-2):(yind+bed_npix_d+2))-ff)) + sum(abs(lp1((yind+7):(yind+10))-0.092.*ones(4,1)));
			if dtemp < dmin
				dmin = dtemp;
				pos = yind; 
			end
		end
		pos_store(ccc) = pos;
		ctrow3 = pos;
		ctcol3 = axpos3;
		ccc = ccc+1; 

	end

	ctrow3 = round(mean(pos_store)); 

end
 
pause(1);



% remove GE petct bed
vv2 = round(ctrow3) - 7;
ctimg(:,1:vv2,:) = 0;  
ctimg2 = ctimg; 



% add in base PET bed
if size(ctimg2,1)<323
	ctimgb = ctimgb((162-floor(size(ctimg2,1)/2)):(162+floor(size(ctimg2,1)/2)),:); 
	ctimgb = ctimgb(1:size(ctimg2),:); 
end
if size(ctimg2,1)>323
	ctimgb2 = zeros(size(ctimg2,1),nr); 
	ctimgb2((round(size(ctimg2,1)/2)-161):(round(size(ctimg2,1)/2)+161),:) = ctimgb; 
	ctimgb = ctimgb2; 
	clear ctimgb2; 
end


for yy = 1:size(ctimg2,3)
	iitemp = ctimg2(:,:,yy); 
	iitemp(:,(vv2+36-nr):(vv2+35)) = iitemp(:,(vv2+36-nr):(vv2+35)) + ctimgb; 
	ctimg2(:,:,yy)= iitemp; 
end

%figure
%imagesc(ctimg2(:,:,round(size(ctimg2,3)/2)-25))
%colormap(gray)
%axis image
%pause

vertct1 = round(ctrow3) + bed_npix_h - 2; 
%ctimg2(:,1:vertct1,:) = ctimg(:,1:vertct1,:); 
ctimg(:,1:vertct1,:) = 0; 

for ii = 1:size(ctimg,3)
	for jj = 1:size(ctimg,1)
		imtemp = ctimg(jj,:,ii);
		%ctimg2(jj,:,ii) = imtemp; 
		%ind = find(imtemp>0.17,1,'first');
		ind = vertct1; 
		if ~isempty(ind) && ~isnan(ind)
			if abs(jj-size(ctimg,1)/2)>30
				ind  = ind + 15;
				if abs(jj-size(ctimg,1)/2)>60
					ind = ind + 9;
					if abs(jj-size(ctimg,1)/2)>90
						ind = ind + 9;
					end
				end
					
			
				
			else
				ind = ind+8; 
			end
			if ind>=length(imtemp)
				ind = length(imtemp);
			end
			imtemp(1:ind) = 0; 
			ctimg(jj,:,ii)=imtemp;
		end
		
	end
end


figure
imagesc(ctimg(:,:,round(size(ctimg,3)/2)-50))
colormap(gray)
axis image

%figure
%imagesc(petimg(:,:,200))
%colormap(flipud(gray))
%axis image

pause(1); 


%ctsag = squeeze(ctimg(round(size(ctimg,1)/2),:,:));
%figure(3)
%imagesc(ctsag)
%colormap(gray); 
%pause(1)

ctimgsmall = ctimg(round((size(ctimg,1)/2) - 50):(round(size(ctimg,1)/2) + 50),(round(size(ctimg,2)/2) - 50):(round(size(ctimg,2)/2) + 50),:); 


axsum = squeeze(sum(sum(ctimgsmall,1),2)); 

ctaxthr = 700; 
slicestartct = find(axsum>ctaxthr,1,'first'); 

ctimgtemp = ctimg(:,:,slicestartct); 
ctimgtemp(:,1) = 0;
ctimgtemp(:,end) = 0; 
ctimgtemp(1,:) = 0; 
ctimgtemp(end,:) = 0; 


ctimgtemp(ctimgtemp<0.5) = 0; 
ctimgtemp(ctimgtemp>0.1) = 1;

 
xg = sum(ctimgtemp,1); 
yg = sum(ctimgtemp,2); 
yg = yg'; 


xgx = 1:length(xg);
ygy = 1:length(yg); 
xbar = round((1/sum(xg))*sum(xgx.*xg)); 
ybar = round((1/sum(yg))*sum(ygy.*yg)); 

 
vertct = xbar; 
horzct = ybar; 

%ctsag = squeeze(ctimg(round(size(ctimg,1)/2),:,:)); 
ctsag = squeeze(sum(ctimg,1)); 
figure(1)
imagesc(ctsag);
title('click on crown of head'); 
colormap(gray); 
[ctcol,ctrow]=ginput(1);
slicestartct = round(ctcol); 
vertct = round(ctrow);

%pause


mipsag = squeeze(max(petimg,[],1));
figure(2)
imagesc(mipsag);
title('click on crown of head'); 
caxis([min(mipsag(:)) 2.5.*mean(mipsag(:))]);
colormap(flipud(gray)); 
[petcol,petrow]=ginput(1);
slicestartpet = round(petcol); 
vertpet1 = round(petrow); 



% adjust axial offset
if (slicestartpet > slicestartct) 
	sd = slicestartpet - slicestartct; 
	ctimg(:,:,sd+1:end) = ctimg(:,:,1:(end-sd)); 
	ctimg(:,:,1:sd) = 0.0; 
	ctimg2(:,:,sd+1:end) = ctimg2(:,:,1:(end-sd)); 
	ctimg2(:,:,1:sd) = 0.0; 
end

if (slicestartct > slicestartpet)
	sd = slicestartct - slicestartpet;
	ctimg(:,:,1:(end-sd)) = ctimg(:,:,sd+1:end); 
	ctimg(:,:,end-sd:end) = 0.0;
	ctimg2(:,:,1:(end-sd)) = ctimg2(:,:,sd+1:end); 
	ctimg2(:,:,end-sd:end) = 0.0;
end

if (size(ctimg,3) > size(petimg,3)+25)
	ctimg = ctimg(:,:,1:(size(petimg,3)+25));
	ctimg2 = ctimg2(:,:,1:(size(petimg,3)+25)); 
end

%ctsag = squeeze(ctimg(round(size(ctimg,1)/2),:,:)); 
ctsag = squeeze(sum(ctimg,1)); 
figure(1)
imagesc(ctsag);
title('click on back');
colormap(gray); 
[ctcol,ctrow]=ginput(1);
%slicestartct = round(ctcol)
vertct = round(ctrow);

%pause


mipsag = squeeze(max(petimg,[],1));
figure(2)
imagesc(mipsag);
title('click on back');
caxis([min(mipsag(:)) 2.5.*mean(mipsag(:))]);
colormap(flipud(gray)); 
[petcol,petrow]=ginput(1);
%slicestartpet = round(petcol)
vertpet = round(petrow); 


% adjust vertical offset

if (vertpet > vertct) 
	sd = vertpet - vertct; 
	ctimg(:,sd+1:end,:) = ctimg(:,1:(end-sd),:); 
	ctimg(:,1:sd,:) = 0.0;
	ctimg2(:,sd+1:end,:) = ctimg2(:,1:(end-sd),:); 
	ctimg2(:,1:sd,:) = 0.0; 
end

if (vertct > vertpet)
	sd = vertct - vertpet;
	ctimg(:,1:(end-sd),:) = ctimg(:,sd+1:end,:); 
	ctimg(:,end-sd:end,:) = 0.0;
	ctimg2(:,1:(end-sd),:) = ctimg2(:,sd+1:end,:); 
	ctimg2(:,end-sd:end,:) = 0.0;
end

%ctsag = squeeze(ctimg(round(size(ctimg,1)/2),:,:));
%figure
%imagesc(ctsag)
%colormap(gray); 


%mipsag = squeeze(max(petimg,[],1));
%figure
%title('click on crown of head'); 
%imagesc(mipsag) 
%caxis([min(mipsag(:)) 2.5.*mean(mipsag(:))]);
%colormap(flipud(gray)); 

%pause


% now adjust in coronal plane
ctcor = squeeze(ctimg(:,vertpet1,:)); 
figure(1)
imagesc(ctcor)
title('click on heart'); 
colormap(gray); 
[ctcol2,ctrow2]=ginput(1);
%slicestartct = round(ctcol)
horzct = round(ctrow2); 


mipcor = squeeze(max(petimg,[],2));
figure(2) 
imagesc(mipcor) 
title('click on heart'); 
caxis([min(mipcor(:)) 4.5.*mean(mipcor(:))]);
colormap(flipud(gray)); 
[petcol2,petrow2]=ginput(1);
%slicestartpet = round(petcol)
horzpet = round(petrow2); 

%pause

% adjust horzontal offset

if (horzpet > horzct) 
	sd = horzpet - horzct; 
	ctimg(sd+1:end,:,:) = ctimg(1:(end-sd),:,:); 
	ctimg(1:sd,:,:) = 0.0;
	ctimg2(sd+1:end,:,:) = ctimg2(1:(end-sd),:,:); 
	ctimg2(1:sd,:,:) = 0.0; 
end

if (horzct > horzpet)
	sd = horzct - horzpet;
	ctimg(1:(end-sd),:,:) = ctimg(sd+1:end,:,:); 
	ctimg(end-sd:end,:,:) = 0.0;
	ctimg2(1:(end-sd),:,:) = ctimg2(sd+1:end,:,:); 
	ctimg2(end-sd:end,:,:) = 0.0;
end



% mipcor = squeeze(max(petimg,[],2));

%ctcor = squeeze(ctimg(:,vertpet1,:)); 
%figure
%title('click on crown of head'); 
%imagesc(ctcor)
%colormap(gray); 



%mipcor = squeeze(max(petimg,[],2));
%figure
%title('click on crown of head'); 
%imagesc(mipcor) 
%caxis([min(mipcor(:)) 4.5.*mean(mipcor(:))]);
%colormap(flipud(gray)); 

%pause


%ctsag = squeeze(ctimg(horzpet,:,:));
%figure
%imagesc(ctsag)
%colormap(gray); 


%mipsag = squeeze(max(petimg,[],1));
%figure
%title('click on crown of head'); 
%imagesc(mipsag) 
%caxis([min(mipsag(:)) 2.5.*mean(mipsag(:))]);
%colormap(flipud(gray)); 

%pause


%%% do registration

regtype = 1; 

if (regtype == 1) 

[optimizer,metric] = imregconfig('multimodal'); 

optimizer.InitialRadius = 0.00005; %0.00005
optimizer.Epsilon = 5e-8; %1e-6
optimizer.GrowthFactor = 1.005; %1.01
optimizer.MaximumIterations = 700; %500 

metric.NumberOfSpatialSamples = 3000000; 
metric.NumberOfHistogramBins = 400; 
metric.UseAllPixels = 0; 

else
[optimizer,metric] = imregconfig('monomodal'); 
optimizer.GradientMagnitudeTolerance = 1e-5; 
optimizer.MinimumStepLength = 1e-6; 
optimizer.MaximumStepLength = 1e-3; 
optimizer.MaximumIterations = 500; 
optimizer.RelaxationFactor = 1e-1; 
end

if log_pet
	petimg = log(petimg+1); 
end

Rfixed = imref3d(size(petimg),petpix,petpix,petpix); 
Rmoving = imref3d(size(ctimg),petpix,petpix,petpix); 
%ctimgreg = ctimg2; 
%ctimgreg = imregister(ctimg,Rmoving,petimg,Rfixed,'rigid',optimizer,metric,'PyramidLevels',4); 

ctimg = imgaussfilt3(ctimg,[g_smooth/(2.355*petpix) g_smooth/(2.355*petpix) g_smooth/(2.355*petpix)]); 
tform = imregtform(ctimg,Rmoving,petimg,Rfixed,'rigid',optimizer,metric,'PyramidLevels',4); 
ctimgreg = imwarp(ctimg2,tform,'OutputView',Rfixed); 
ctimgreg_nobed = imwarp(ctimg,tform,'OutputView',Rfixed); 

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
ctimgreg_nobed = ctimgreg_nobed.*2000; 


% write registered CT image as DICOM
uid = dicomuid; 
uid2 = dicomuid; 

ct_dcminfo.SeriesInstanceUID = uid; 
ct_dcminfo.StudyInstanceUID = uid2; 
ct_dcminfo.ImagesInAcquisition = 445; 
%ct_dcminfo.Modality = 'CT';
ct_dcminfo.Width = 323; 
ct_dcminfo.NumberOfSlices = size(ctimgreg,3); 
ct_dcminfo.ReconstructionDiameter = 323*1.005; 
ct_dcminfo.Rows = 323; 
ct_dcminfo.Columns = 323;
ct_dcminfo.PixelSpacing = [1.005;1.005];
ct_dcminfo.SliceThickness = 1.005; 
ct_dcminfo.SpacingBetweenSlices = 1.005; 
ct_dcminfo.InstitutionName = 'UC Davis';
ct_dcminfo.SeriesDescription = 'CT whole-body'; 
ct_dcminfo = rmfield(ct_dcminfo,'ImagePositionPatient');
ct_dcminfo = rmfield(ct_dcminfo,'ImageOrientationPatient');
ct_dcminfo = rmfield(ct_dcminfo,'PositionReferenceIndicator');

fdir_dcm = [CTpath,'/CTREG/']; 
mkdir(fdir_dcm); 
fdir_dcm2 = [CTpath,'/CTREG_Gen/']; 
mkdir(fdir_dcm2); 

ctimgnew2 = ctimgreg;
for ii=1:size(ctimgreg,3)
    ctimgnew2(:,:,ii) = ctimgreg(:,:,ii); 
    cttemp = ctimgnew2(:,:,ii);
    cttemp = rot90(cttemp);
    cttemp = fliplr(cttemp); 
     
    
    
    ct_dcminfo.InstanceNumber = ii; 
    ct_dcminfo.SliceLocation = (223-ii)*1.005;
    if ii==1
    	%ct_dcminfo
    	
    end
    fname_dcm = [fdir_dcm,'/Z',num2str(ii),'.dcm']; 
    dicomwrite(int16(cttemp),fname_dcm,ct_dcminfo,'CreateMode','Copy'); 
    
    cttemp = rot90(cttemp,2); % rotate image for Genentech 
    fname_dcm2 = [fdir_dcm2,'/Z',num2str(ii),'.dcm']; 
    dicomwrite(int16(cttemp),fname_dcm2,ct_dcminfo,'CreateMode','Copy'); 
    
     
    ctimgnew2(:,:,ii) = cttemp;

    
end
ctimgreg2 = ctimgnew2;
ctimgreg2 = int16(ctimgreg2); 
clear ctimgnew2;
ct_dcminfo.InstanceNumber = 1; 
ct_dcminfo.ImageIndex = 1; 
ct_dcminfo.SliceLocation = (223-1)*1.005; 
fname_dcm = [CTpath,'/CTREG.dcm']; 

dicomwrite(reshape(ctimgreg2,[num_voxels,num_voxels,1,size(ctimgreg2,3)]),fname_dcm,ct_dcminfo,'CreateMode','Copy','MultiFrameSingleFile',true); 

t=dicominfo(fname_dcm); 

ctpathreg1 = [CTpath, '/ct_reg_highres.raw']; 
fid13 = fopen(ctpathreg1,'w'); 
fwrite(fid13,ctimgreg,'float'); 
fclose(fid13); 

ctimgreg = imgaussfilt3(ctimgreg,[g_smooth/(2.355*petpix) g_smooth/(2.355*petpix) g_smooth/(2.355*petpix)]); 

ctpathreg = [CTpath,'/ct_reg.raw']; 
fid3 = fopen(ctpathreg,'w'); 
fwrite(fid3,ctimgreg,'float'); 
fclose(fid3); 

petpathreg = [CTpath,'/pet_reg.raw'];
fid4 = fopen(petpathreg,'w'); 
fwrite(fid4,petimg,'float'); 
fclose(fid4); 

ctpathreg_nobed = [CTpath,'/ct_reg_nobed.raw']; 
fid5 = fopen(ctpathreg_nobed,'w'); 
fwrite(fid5,ctimgreg_nobed,'float'); 
fclose(fid5); 




