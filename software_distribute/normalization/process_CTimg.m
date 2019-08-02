function process_CTimg(CTpath)

petpix = 1.005; 
g_smooth = 3.5; 

zika_flag = 0; 

% load CT image

zika_flag = contains(CTpath, 'Zika')

CTpath2=[CTpath,'/A/']; 

lst = dir(CTpath2);
num_slices = length(lst) - 2; 
fname=[CTpath2,'Z100'];
info = dicominfo(fname);
img1=dicomread(info);


ctfov = info.ReconstructionDiameter; ctfov = double(ctfov); 
numpix = info.Width; numpix=double(numpix); 
pixelsize = ctfov/numpix; pixelsize=double(pixelsize)
%pixelsize = 0.625; 
slicethick = info.SliceThickness; slicethick=double(slicethick)
kVp = info.KVP; kVp = double(kVp)

imgstore = zeros(numpix,numpix,num_slices);

ct_dcminfo = info; 

fn = 'Z'; 

%pool = parpool(16,'IdleTimeout',2); 
disp('Reading CT image ...'); 
for i = 1:num_slices
    
    if i<9.5
        fname=[CTpath2,fn,'0',num2str(i)];
    
    else
        fname=[CTpath2,fn,num2str(i)];
    end
    
    if exist(fname)
    
    	info = dicominfo(fname);
    	cc = info.InstanceNumber; 
    
    	imgtemp = dicomread(info); 
    
    	imgtemp = double(imgtemp); 
    
    	if (size(imgtemp,1)==size(imgstore,1) && size(imgtemp,2)==size(imgstore,2)); 

    		imgstore(:,:,cc) = imgtemp; 
    	end
    end
       
end



disp('finished reading image');

imtemp = squeeze(imgstore(round(numpix/2),:,:)); 
figure
imagesc(imtemp)
colormap(gray); 
axis image

disp('Check image, press any key to continue'); 
pause


% new pre-process
%xend = pixelsize*size(imgstore,1);

%yend = pixelsize*size(imgstore,2); 
%zend = slicethick*size(imgstore,3); 

%xx = linspace(0,xend,size(imgstore,1)+1); 
%yy = linspace(0,yend,size(imgstore,2)+1);
%zz = linspace(0,zend,size(imgstore,3)+1);

%xx = xx(1:end-1);
%yy = yy(1:end-1);
%zz = zz(1:end-1); 

%[X,Y,Z] = meshgrid(xx,yy,zz);

% gaussian smooth ct image to match pet resolution
%imgstore = imgaussfilt3(imgstore,[g_smooth/(2.355*pixelsize) g_smooth/(2.355*pixelsize) g_smooth/(2.355*slicethick)]); 

%disp('finished ct image smoothing');  

% downsample smoothed ct image to pet voxel size
xend = pixelsize*size(imgstore,1);
yend = pixelsize*size(imgstore,2); 
zend = slicethick*size(imgstore,3); 

xx = linspace(0,xend,size(imgstore,1)+1); 
yy = linspace(0,yend,size(imgstore,2)+1);
zz = linspace(0,zend,size(imgstore,3)+1);

xx = xx(1:end-1);
yy = yy(1:end-1);
zz = zz(1:end-1); 

[X,Y,Z] = meshgrid(xx,yy,zz);

[Xq,Yq,Zq]=meshgrid(0:petpix:xend,0:petpix:yend,0:petpix:zend);

imgstore2 = interp3(X,Y,Z,imgstore,Xq,Yq,Zq,'linear'); 
imsize = size(imgstore2)

disp('finished interpolation'); 

% rotate image:
imgstore2 = rot90(imgstore2,3);
imgstore2 = flipud(imgstore2); 

%imgstore2(1:50,:,:) = 1000; 

% catch bad values
imgstore2(imgstore2<0)=0; 
imgstore2(isnan(imgstore2))=1000; 
imgstore2(isinf(imgstore2))=1000; 
imgstore2(imgstore2>2500)=2500; 





img_info = struct; 
img_info.imsize = imsize; 
img_info.kVp = kVp; 
img_info.petpix = petpix; 
img_info.g_smooth = g_smooth; 
img_info.ct_dcminfo = ct_dcminfo; 


 


if zika_flag
	box_remove_done = false;
	while ~box_remove_done
		close all
    	imgstore2_nobox = BoxRemove1Click(0.5, 5, imgstore2); 
    	%imgstore22 = imgstore2; 
    	imgstore2 = imgstore2_nobox; 
    	
    	answer = questdlg('Do you want to remove more objects?','','Yes','No','No');
		switch answer
			case 'Yes'
				box_remove_done = false; 
				 				
			case 'No'
				box_remove_done = true; 
				disp('OK, proceeding with image registration...'); 				
    	
    	end
    end
end




fsave1 = [CTpath,'/ct_preregPET.raw'];
fids1 = fopen(fsave1,'w');
fwrite(fids1,imgstore2,'float'); 

fsave2 = [CTpath,'/ct_preregPETinfo.mat'];
save(fsave2,'imsize','kVp','petpix','g_smooth','ct_dcminfo'); 





