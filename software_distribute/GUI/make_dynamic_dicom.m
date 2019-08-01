function make_dynamic_dicom(fdir_bin,start_frame,end_frame); 

xx = strfind(fdir_bin,'/'); 
xx = xx(end); 
fdir = [fdir_bin(1:xx-1),'/']; 
fdir_bin = [fdir_bin,'/'];


fdir_out = [fdir_bin,'DYNAMIC_DICOM/']; 
mkdir(fdir_out); 

uid1 = dicomuid;
uid2 = dicomuid;
uid3 = dicomuid; 
uid4 = dicomuid; 

num_tframe = end_frame - start_frame + 1; 

img_all = zeros(323,323,445*num_tframe); 

img_index = 1; 
cc = 0; 
cc2 = 1; 

iii = 445; 

for ff=start_frame:end_frame

	fdir = [fdir_bin,'DCM_frame',num2str(ff),'/']; 

	lm_infofname = [fdir_bin,'lm_info_f',num2str(ff)];
	
	dcm_fname = [fdir,'Z10.dcm'];
	infot = dicominfo(dcm_fname); 
	num_slice = double(infot.NumberOfSlices); 
	
	
	for ii = 1:num_slice
		dcm_fname = [fdir,'Z',num2str(ii),'.dcm']; 
		info = dicominfo(dcm_fname);
		
		imgtemp = dicomread(info); 
		img_index = double(info.ImageIndex); 
		img_index = img_index + (num_slice*cc); 
		info.ImageIndex = img_index;
		info.InstanceNumber = iii; 
		info.NumberOfTimeSlices = num_tframe; 
		info.SeriesType = 'DYNAMIC\IMAGE'; 
		info.SeriesInstanceUID = uid1;
		info.StudyInstanceUID = uid2;
		info.SOPInstanceUID = uid3;
		info.SOPClassUID = '1.2.840.10008.5.1.4.1.1.128';  
		info.MediaStorageSOPClassUID = '1.2.840.10008.5.1.4.1.1.128'; 
		info.MediaStorageSOPInstanceUID = uid4; 
		info = rmfield(info,'SeriesDescription'); 
		info.SeriesNumber = 1;  
		
		
		img_all(:,:,img_index) = imgtemp; 
		
		num_zeros = 7 - length(num2str(cc2)); 
		str_zeros = '0'; 
		for z = 1:(num_zeros-1)
			str_zeros = [str_zeros,'0']; 
		end
		
		dcm_fname2 = [fdir_out,'Z',str_zeros,num2str(cc2),'.dcm']; 
		dicomwrite(imgtemp,dcm_fname2,info,'CreateMode','Copy'); 
		cc2 = cc2 + 1;
		iii=iii-1; 
		
	end
	iii = iii+890; 
	
	cc = cc+1; 
	
end
		
img_all = int16(img_all); 
info2 = info; 
info2.ImageIndex = 1; 
info2.InstanceNumber = 1; 
uid = dicomuid;
info2.SeriesInstanceUID = uid; 
dcm_fname = [fdir_bin,'DYNAMIC_DICOM_3D.dcm']; 
dicomwrite(img_all,dcm_fname,info2,'CreateMode','Copy','MultiFrameSingleFile',true); 
		
		
		
		
		
		
		
		
		
		
		
