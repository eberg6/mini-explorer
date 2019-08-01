function file_images(fdir_bin)

%,lmfname1,imgfname,ct_path)


xx = strfind(fdir_bin,'/'); 
xx = xx(end); 
fdir = [fdir_bin(1:xx-1),'/']; 
fdir_bin = [fdir_bin,'/']; 


dir_raws = [fdir_bin,'IMAGES_RAW']; 
dir_dcm = [fdir_bin,'IMAGES_DICOM']; 
dir_dcm_stack1 = [fdir_bin,'IMAGES_STACKDICOM']; 
dir_dcm_stack2 = [fdir_bin,'IMAGES_STACKDICOM_OLD']; 
dir_lminfo = [fdir_bin,'LM_INFO'];

if ~exist(dir_raws,'dir')
	stat1 = mkdir(dir_raws); 
	if ~stat1
		disp('Could not create raw image directory'); 
	end
end
if ~exist(dir_dcm,'dir'); 
	stat2 = mkdir(dir_dcm); 
	if ~stat2
		disp('Could not create dicom image directory');
	end
end

if exist(dir_dcm_stack1,'dir')
	ss = ['rm -r ',dir_dcm_stack1]; 
	system(ss);  
end
if exist(dir_dcm_stack2,'dir')
	ss = ['rm -r ',dir_dcm_stack2]; 
	system(ss);  
end

if ~exist(dir_dcm_stack1,'dir'); 
	stat3 = mkdir(dir_dcm_stack1); 
	if ~stat3
		disp('Could not create dicom stack image directory');
	end
end
if ~exist(dir_dcm_stack2,'dir'); 
	stat4 = mkdir(dir_dcm_stack2); 
	if ~stat4
		disp('Could not create dicom stack old image directory');
	end
end
if ~exist(dir_lminfo)
	stat5 = mkdir(dir_lminfo); 
	if ~stat5
		disp('Could not create lm_info directory directory');
	end
end



ff = ls(fdir_bin);

deli = {'\t','    ','   ','  '}; 

newstr = splitlines(ff);
count = 1; 
for iii = 1:size(newstr,1)
	newstr2 = newstr(iii,:);
	newstr2 = newstr2{1};
	newstr2 = erase(newstr2,'''');
	if length(newstr2) > 1
	newstr3 = strsplit(newstr2,deli);  
	for iiii = 1:numel(newstr3)
		%newstr3{iiii}
		A{count,1} = newstr3{iiii};
		count = count+1; 
	end
	end
end
%A
%pause


fname_process = ['mv  ',fdir_bin,'lmrecon*.cor.raw ',dir_raws,'&  mv  ',fdir_bin,'lmrecon*.dcm  ',dir_dcm,'&  mv  ',fdir_bin,'lm_info_f* ',dir_lminfo,' &  mv ',fdir_bin,'DCM*Gen ', dir_dcm_stack1,';   mv ',fdir_bin,'DCM_frame* ',dir_dcm_stack2,'; ']; 

system(fname_process); 


