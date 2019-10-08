function postprocess_img(fdir_bin,lmfname1,imgfname,ct_path,tf,norm_bin,os,it,frame)



ss = ['Post-processing image frame ',num2str(frame), '... '];
disp(ss);  

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
lm_infofname2 = [fdir_bin,'LM_INFO/lm_info_f',num2str(frame)]; 

lmfname = [fdir,lmfname1]; 


lmfname_hdr = [lmfname,'.hdr'];
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
inj_time_str = str1((length(str_find)+5):end);
inj_time = datetime(inj_time_str,'InputFormat','MMMddHH:mm:ssyyyy');
inj_timevec = datevec(inj_time);

str2 = A{152}; 
str_find = 'isotope_half_life'; 
half_life_str = str2((length(str_find)+1):end); 
half_life = str2num(half_life_str);

str3 = A{158}; 
str_find = 'isotope_branching_fraction'; 
branching_ratio_str = str3((length(str_find)+1):end); 
branching_ratio = str2num(branching_ratio_str);

str4 = A{300}; 
str_find = 'dose'; 
dose_str = str4((length(str_find)+1):end);
dose = str2num(dose_str);

%dose = dose * 0.4; % REMOVE	

str5 = A{369}; 
str_find = 'subject_weight';
weight_str = str5((length(str_find)+1):end); 
mmu_weight = str2num(weight_str); 
mmu_weight = mmu_weight / 1000; % kg



logfname = [lmfname,'.*.log']; 
lst = dir(logfname);
ff = lst.name;
ff = erase(ff,lmfname1);
ff = erase(ff,'.');
scan_start_str = erase(ff,'log');
scan_start_str = scan_start_str(4:end);

scan_start = datetime(scan_start_str,'InputFormat','ddMMMyyyy_HHmmss');
scan_startvec = datevec(scan_start);

time_elapse = etime(scan_startvec,inj_timevec);



fid1 = fopen(lm_infofname,'r'); 
if fid1 < 0
	
	fid1 = fopen(lm_infofname2,'r'); 
end

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
frame_start = str2num(frame_start_str);

strtemp = B{2};
str_find = 'frame_length=';
frame_length_str = erase(strtemp,str_find); 
frame_length = str2num(frame_length_str);

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

decay_factor = (exp(t1*log(2)/half_life) * (log(2)/half_life) * (t2-t1)) / (1-exp(-(log(2)/half_life)*(t2-t1))); 
frame_length_factor = 1/frame_length; 
branching_factor = 1/branching_ratio; 

B{3} = ['time_elapse=',num2str(time_elapse)];
B{4} = ['decay_factor=',num2str(decay_factor)];



fid11 = fopen(lm_infofname,'w'); 
 
for tt = 1:numel(B)
	%if ~contains(B{tt},'-1.000')
		fprintf(fid11,'%s\n',B{tt});
	%end
	
end
fclose(fid11);

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

    roi_mean = roi_mean / pix_count;

    kBq_cc = (dose*37*1000) / cyl_vol; 

    Afac_new = kBq_cc / roi_mean;


    fid4 = fopen(Afac_fname,'w'); 
    fwrite(fid4,Afac_new,'float'); 
    fclose(fid4); 

		 
end

fid5 = fopen(Afac_fname,'r');
Afac = fread(fid5,inf,'float'); 

img = img.*Afac; 

imgfnameout = [imgfname,'.cor.raw']; 
fid3 = fopen(imgfnameout,'w'); 
fwrite(fid3,img,'float'); 

fclose(fid3); 


%%%% make dicoms
if tf<0.5 && length(ct_path)>2

%fname_template = './dcm_template2.dcm';
%info_template = dicominfo(fname_template);
%info = info_template; 
%info=rmfield(info,'DeidentificationMethod'); 
%info=rmfield(info,'TransverseMash'); 
%info=rmfield(info,'AxialMash'); 
%info=rmfield(info,'PatientGantryRelationshipCodeSequence'); 
%info=rmfield(info,'PatientOrientationModifierCodeSequence');
%info=rmfield(info,'PatientOrientationCodeSequence'); 
%info=rmfield(info,'LossyImageCompression'); 
%info=rmfield(info,'PerformedProcedureStepStartTime'); 
%info=rmfield(info,'PerformedProcedureStepStartDate'); 
%info=rmfield(info,'ImagePositionPatient'); 
%info=rmfield(info,'ImageOrientationPatient'); 
%info=rmfield(info,'PatientIdentityRemoved'); 
%info=rmfield(info,'TriggerTime'); 
%info=rmfield(info,'IntervalsAcquired'); 
%info=rmfield(info,'IntervalsRejected'); 
%info=rmfield(info,'AcquisitionContextSequence'); 
%info=rmfield(info,'DecayFactor'); 
%info=rmfield(info,'DoseCalibrationFactor'); 
%info=rmfield(info,'ScatterFractionFactor'); 
%info=rmfield(info,'DeadTimeFactor'); 
%info=rmfield(info,'SourceApplicationEntityTitle'); 
%info.Manufacturer = 'Cherry Lab UC Davis'; 
%info.InstitutionName = 'UC Davis'; 
%info.ManufacturerModelName = 'mini-EXPLORER'; 

fname_1 = './dcm_info.mat'; 
%save(fname_1,'info'); 
d = load(fname_1); 
info = d.info; 

info; 
pause(1);

%fnamepet = 'G:\monkey\genentech\images\day0\MMU46165\lmrecon_MMU46165_Genentech_Zr89_scan1_60min_T0_60min_v1_267x267x445_frame0.os.20.it.2.cor.raw'; 

fnamect = [ct_path,'/CTREG/Z100']; 
if ~exist(fnamect,'file'); 
	fnamect = [ct_path,'/A/Z100']; 
end
info_ct = dicominfo(fnamect); 

str5 = A{61}; 
str_find = 'study'; 
study_str = str5((length(str_find)+2):end);
str_find2 = ' - '; 
ind5 = strfind(study_str,str_find2); 
studyID_str = study_str(1:ind5-1); 
study_str = study_str(ind5+3:end); 

str6 = A{281}; 
str_find = 'operator'; 
operator_str = str6((length(str_find)+2):end);

str7 = A{289}; 
str_find = 'injected_compound'; 
radiopharm_str = str7((length(str_find)+2):end);

str8 = A{148}; 
str_find = 'isotope'; 
isotope_str = str8((length(str_find)+2):end);

studydatetime = datestr(scan_startvec);
%studydate = studydatetime(1:11) 
a1 = num2str(scan_startvec(1));
a2 = num2str(scan_startvec(2)); 
a3 = num2str(scan_startvec(3)); 
if length(a2) == 1
	a2 = ['0',a2];
end
if length(a3) == 1
	a3 = ['0',a3];
end
studydate = [a1,a2,a3];
studytime = studydatetime(13:end);
studytime = studytime([1,2,4,5,7,8]); 

injdatetime = datestr(inj_timevec); 
%injdate = injdatetime(1:11); 
a1 = num2str(inj_timevec(1));
a2 = num2str(inj_timevec(2)); 
a3 = num2str(inj_timevec(3)); 
if length(a2) == 1
	a2 = ['0',a2];
end
if length(a3) == 1
	a3 = ['0',a3];
end
injdate = [a1,a2,a3]
injtime = injdatetime(13:end); 
injtime = injtime([1,2,4,5,7,8]); 
injtime = [injtime,'.00']; 


%[maximg,mm] = max(img(:)); img(mm) = 0; 
%[maximg,mm] = max(img(:)); img(mm) = 0; 
%[maximg,mm] = max(img(:)); img(mm) = 0; 
[maximg,mm] = max(img(:)); 
ms = 30000/maximg; 
img = img.*ms; 
msi = 1.0/ms; 

img = int16(img); 
imgpetnew = img;

uid = dicomuid; 
uid2 = dicomuid; 

info.SeriesInstanceUID = uid; 
info.StudyInstanceUID = info_ct.StudyInstanceUID;
info.StudyID = info_ct.StudyID; 
%info.StudyInstanceUID = uid2; 
info.SeriesNumber = frame; 
info.SOPClassUID = '1.2.840.10008.5.1.4.1.1.20'; 
info.SOPInstanceUID = dicomuid; 
info.MediaStorageSOPClassUID = '1.2.840.10008.5.1.4.1.1.20'; 
info.MediaStorageSOPInstanceUID = dicomuid; 
%info.ImageType = 'RECON_TOMO\EMISSION';
info.Modality = 'PT'; 
info.Width = num_vox;
info.Height = num_vox;
info.StudyDate = studydate; %change from pet header
info.SeriesDate = studydate;
info.AcquisitionDate = studydate;
info.StudyTime = studytime; 
info.SeriesTime = studytime;
info.AcquisitionTime = studytime; 
info.StudyDescription = study_str;  
info.OperatorName = operator_str;
info.PatientID = info_ct.PatientID; 
info.PatientName = info_ct.PatientID; 
info.PatientBirthDate = info_ct.PatientBirthDate;
info.PatientSex = info_ct.PatientSex;
%info.PatientWeight = info_ct.PatientWeight;
info.SliceThickness = 1.005; 
info.SpacingBetweenSlices = 1.005; 
info.PatientPosition = info_ct.PatientPosition;
info.Rows = num_vox; 
info.Columns = num_vox;
info.PixelSpacing = [1.005;1.005];
ss = ['PET whole-body: ',info_ct.PatientID,': frame',num2str(frame)]; 
info.SeriesDescription = ss; 
%info.ScanOptions = 'Total-Body'; 
info.SliceThickness = 1.005; 
info.NumberOfSlices = num_slices; 
info.NumberOfTimeSlices = 1; 
info.ProtocolName = 'Total-Body'; 
%info.PhotometricInterpretation = info_ct.PhotometricInterpretation;  
% info.InstanceNumber = k; 
info.RescaleIntercept = 0; 
info.RescaleSlope = msi;   
info.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideTotalDose = 37*dose;
info.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideHalfLife = half_life; 
info.RadiopharmaceuticalInformationSequence.Item_1.Radiopharmaceutical = radiopharm_str;
info.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartTime = injtime;
info.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartDate = injdate; 
info.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideCodeSequence.Item_1.CodeMeaning = isotope_str; 
info.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalCodeSequence.Item_1.CodeMeaning = radiopharm_str;
info.RadiopharmaceuticalStartTime = injtime; 
info.RadiopharmaceuticalStartDate = injdate;
info.Radiopharmaceutical = '0';  
info.ReconstructionMethod = 'TOF-LM-OSEM'; 
info.FrameReferenceTime = frame_start*1000; 
info.ActualFrameDuration = frame_length*1000; 

info.SeriesType = 'STATIC\IMAGE';
info.Units = 'kBq/cc'; 
info.DoseUnits = 'MBq';
info.DoseValue = 37*dose;
info.PatientWeight = mmu_weight; 
info.SourceIsotopeName = isotope_str;

warning off

dicom_dir = [fdir_bin,'DCM_frame',num2str(frame)]; 
mkdir(dicom_dir); 
dicom_dir2 = [fdir_bin,'DCM_frame',num2str(frame),'_Gen']; 
mkdir(dicom_dir2); 

for ii=1:num_slices
    imgpetnew(:,:,ii) = img(:,:,ii); 
    imgtemp = imgpetnew(:,:,ii);
    imgtemp = rot90(imgtemp);
    imgtemp = fliplr(imgtemp); 
     
     
    info.InstanceNumber = ii; 
    info.ImageIndex = ii; 
    info.SliceLocation = (223-ii)*1.005;
    if ii==1
    	info;
    	
    end
    
    num_zeros = 5 - length(num2str(ii)); 
	str_zeros = '0'; 
	for z = 1:(num_zeros-1)
		str_zeros = [str_zeros,'0']; 
	end
    
    
    fname_dcm = [dicom_dir,'/Z',str_zeros,num2str(ii),'.dcm']; 
    dicomwrite(imgtemp,fname_dcm,info,'CreateMode','Copy'); 
    
    imgtemp = rot90(imgtemp,2);  % rotate the image for correct orientation with Genentech software, remove in future.
    fname_dcm2 = [dicom_dir2,'/Z',str_zeros,num2str(ii),'.dcm']; 
    dicomwrite(imgtemp,fname_dcm2,info,'CreateMode','Copy'); 
    
    imgpetnew(:,:,ii) = imgtemp;

    
end
img = imgpetnew;
clear imgpetnew; 
info.InstanceNumber = 1; 
info.ImageIndex = 1; 
info.SliceLocation = (223-1)*1.005; 
fname_dcm = [imgfname,'.dcm']; 

str1 = imgfname; 
for kk=1:(length(str1)-6)
	str_temp = str1(kk:kk+4); 
    if strcmp(str_temp,'frame') > 0.5
    	ind = kk + 4; 
    end
    if strcmp(str_temp,'.os.2') > 0.5
        ind2 = kk; 
    end
end

if ind2 == (ind + 2)
	str2 = [str1(1:ind),'00000',str1(ind+1:end)];        
elseif ind2 == (ind + 3)
	str2 = [str1(1:ind),'0000',str1(ind+1:end)];    
elseif ind2 == (ind + 4)
	str2 = [str1(1:ind),'000',str1(ind+1:end)];      
elseif ind2 == (ind + 5)
	str2 = [str1(1:ind),'00',str1(ind+1:end)];     
elseif ind2 == (ind + 6)
	str2 = [str1(1:ind),'0',str1(ind+1:end)];
else
	str2 = str1; 
end

fname_dcm = [str2,'.dcm']; 

dicomwrite(reshape(img,[num_vox,num_vox,1,num_slices]),fname_dcm,info,'CreateMode','Copy','MultiFrameSingleFile',true); 

t=dicominfo(fname_dcm); 
%t.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideTotalDose

end









