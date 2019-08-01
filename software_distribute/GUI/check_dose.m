function dose=check_dose(fdir_bin,lmfname1)

xx = strfind(fdir_bin,'/'); 
xx = xx(end); 
fdir = [fdir_bin(1:xx-1),'/']; 
fdir_bin = [fdir_bin,'/'];  
%lmfname1 = [lmfname1,'.lm'];


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


dose_str1 = A{300}; 
dose_str1 = dose_str1(6:end);
dose = str2num(dose_str1);


 




