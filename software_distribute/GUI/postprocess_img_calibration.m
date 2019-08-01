function postprocess_img(fdir_bin,lmfname1,imgfname,tf,norm_bin,os,it,frame)


% tf is 1 if it is calibration scan, 0 for normal scan

norm_bin = [norm_bin,'/']; 
Afac_fname = [norm_bin,'Afac']; 

cylroi_rad = 75; 
cylroi_rad_small = 25;
cc_vox = 0.1005 * 0.1005 * 0.1005; 
cyl_vol = 60 * pi*(4.75^2); % calibration cylinder volume in cc
%Afac = 5.9866e4; % to convert from counts/second/voxel --> kBq / cc 

xx = strfind(fdir_bin,'/'); 
xx = xx(end); 
fdir = [fdir_bin(1:xx-1),'/']; 
fdir_bin = [fdir_bin,'/'];  
lmfname1 = [lmfname1,'.lm'];
imgfname = [imgfname,'.os.',num2str(os),'.it.',num2str(it)];


lm_infofname = [fdir_bin,'lm_info_f',num2str(frame)]; 

lmfname = [fdir,lmfname1]; 


lmfname_hdr = [lmfname,'.hdr']
fid = fopen(lmfname_hdr,'r'); 


il = 1;
tline = fgetl(fid); 
A{il} = tline; 
while ischar(tline)
	il = il+1; 
	tline = fgetl(fid); 
	A{il} = tline;
end
fclose(fid); 



str1 = A{305}; 
str_find = 'injection_time'; 
inj_time_str = str1((length(str_find)+5):end)
inj_time = datetime(inj_time_str,'InputFormat','MMMddHH:mm:ssyyyy')
inj_timevec = datevec(inj_time)

str2 = A{152}; 
str_find = 'isotope_half_life'; 
half_life_str = str2((length(str_find)+1):end); 
half_life = str2num(half_life_str)

str3 = A{158}; 
str_find = 'isotope_branching_fraction'; 
branching_ratio_str = str3((length(str_find)+1):end); 
branching_ratio = str2num(branching_ratio_str)

str4 = A{300}; 
str_find = 'dose'; 
dose_str = str4((length(str_find)+1):end);
dose = str2num(dose_str)



logfname = [lmfname,'.*.log']; 
lst = dir(logfname);
ff = lst.name;
ff = erase(ff,lmfname1);
ff = erase(ff,'.');
scan_start_str = erase(ff,'log');
scan_start_str = scan_start_str(4:end)

scan_start = datetime(scan_start_str,'InputFormat','ddMMMyyyy_HHmmss')
scan_startvec = datevec(scan_start);

time_elapse = etime(scan_startvec,inj_timevec)



 
fid1 = fopen(lm_infofname,'r'); 

il = 1;
tline = fgetl(fid1); 
B{il} = tline; 
while ischar(tline)
	il = il+1; 
	tline = fgetl(fid1); 
	B{il} = tline;
end
fclose(fid1);


%ii = fscanf(fid1,'%s',inf); 

strtemp = B{1};
str_find = 'frame_start='; 
frame_start_str = erase(strtemp,str_find); 
frame_start = str2num(frame_start_str)

strtemp = B{2};
str_find = 'frame_length=';
frame_length_str = erase(strtemp,str_find); 
frame_length = str2num(frame_length_str)

%str_find = 'frame_start='; 
%ss = strfind(ii,str_find); 
%strtemp = ii(ss:end)
%frame_start_str = erase(strtemp,str_find);
%frame_start_str = erase(frame_start_str,'='); 
%frame_start = str2num(frame_start_str)

%strtemp = ii(1:ss-1); 
%str_find = 'frame_length='; 
%frame_length_str = erase(strtemp,str_find); 
%frame_length = str2num(frame_length_str)



t1 = time_elapse+frame_start; 
t2 = t1+frame_length; 

decay_factor = (exp(t1*log(2)/half_life) * (log(2)/half_life) * (t2-t1)) / (1-exp(-(log(2)/half_life)*(t2-t1)))
frame_length_factor = 1/frame_length; 
branching_factor = 1/branching_ratio;  

B{3} = ['time_elapse=',num2str(time_elapse)];
B{4} = ['decay_factor=',num2str(decay_factor)];

fid11 = fopen(lm_infofname,'w'); 
 
for tt = 1:numel(B)
	if B{tt+1} == -1
		fprintf(fid11,'%s',B{tt});
		break
	else
		fprintf(fid11,'%s\n',B{tt});
	end
end
fclose(fid11)


fid2 = fopen(imgfname,'r'); 
img = fread(fid2,inf,'float'); 
fclose(fid2);

num_slices = 445; 
num_vox = length(img)/num_slices; 
num_vox = round(sqrt(num_vox));

if (num_vox*num_vox*num_slices ~= length(img))
	disp('image size invalid'); 
end 

img = reshape(img,num_vox,num_vox,num_slices); 

% delete outside rows of image
img(:,:,1:6) = 0; 
img(:,:,(end-5):end) = 0; 
img(1:6,:,:) = 0; 
img((end-5):end,:,:) = 0; 
img(:,1:6,:) = 0; 
img(:,(end-5):end,:) = 0; 


img = img.*decay_factor.*frame_length_factor.*branching_factor;
img(img<0.0) = 0.0; 

if tf>0.5

	imtemp = img(:,:,round(size(img,3)/2)); 
	imtemp = imgaussfilt(imtemp,2); 

	% get average of central pixel values
	ii1 = floor(size(imtemp,1)/2)-2;
	ii2 = ii1+5; 
	imcent = imtemp(ii1:ii2,ii1:ii2); 
	imgmean = mean(imcent(:)); 

	% get average outside
	jj1 = 20; 
	jj2 = 40; 
	imedge = imtemp(jj1:jj2,jj1:jj2);
	imgmean2 = mean(imedge(:)); 

    thr_roi = (imgmean + imgmean2) / 2; 

    % mask pixels
    imtemp_mask = imtemp;
    imtemp_mask(imtemp<thr_roi) = 0; 
    imtemp_mask(imtemp>=thr_roi) = 1; 

    pix_cent = ceil(size(imtemp_mask,1)/2); 
    imean = 0; 
    jmean = 0; 
    pix_count = 1; 
    for i = 1:size(imtemp_mask,1)
        for j = 1:size(imtemp_mask,2)
            dist = (i - pix_cent)^2 + (j - pix_cent)^2; 
            if dist > (cylroi_rad^2)
                imtemp_mask(i,j) = 0; 
            end
            if imtemp_mask(i,j) > 0.5 
                imean = imean + i; 
                jmean = jmean + j;
                pix_count = pix_count + 1; 
            end
        end
    end

    icent = round(imean/pix_count);
    jcent = round(imean/pix_count); 

    % get mean value inside 5 cm cylinder roi for all slices
    roi_mean = 0; 
    pix_count = 1; 
    for k = 50:size(img,3)-50
        imtemp = img(:,:,k);
        for i = 1:size(img,1)
            for j = 1:size(img,2)
                dist = (i - icent)^2 + (j - jcent)^2;
                if dist <= (cylroi_rad_small^2)
                    roi_mean = roi_mean + imtemp(i,j); 
                    pix_count = pix_count + 1; 
                end
            end
        end
    end

    roi_mean = roi_mean / pix_count

    kBq_cc = (dose*37*1000) / cyl_vol; 

    Afac_new = kBq_cc / roi_mean


    fid4 = fopen(Afac_fname,'w'); 
    fwrite(fid4,Afac_new,'float'); 
    fclose(fid4); 

		 
end

fid5 = fopen(Afac_fname,'r');
Afac = fread(fid5,inf,'float')

img = img.*Afac; 

imgfnameout = [imgfname,'.cor.raw']; 
fid3 = fopen(imgfnameout,'w'); 
fwrite(fid3,img,'float'); 

fclose(fid3); 










