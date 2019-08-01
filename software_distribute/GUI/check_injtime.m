function injection_time = check_injtime(fdir_bin,lmfname1)


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


time_str1 = A{305}; 
time_str1 = time_str1(20:end);
injection_time = time_str1; 

%injection_time = datetime(time_str1,'InputFormat','MMMddHH:mm:ssyyyy')



