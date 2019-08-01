function scan_length = get_scantime(fdir_bin,lmfname1)

% xx = strfind
% fdir = [fdir_bin(1:xx-1),'/']; 
% fdir = [fdir_bin,'/']
%lmfname1 = [lmfname1,'.lm'];

lmfname = [fdir_bin,lmfname1];

logfname = [lmfname,'.*.log']; 
lst = dir(logfname);
ff = lst.name; 
ff = [fdir_bin,ff]; 

fid = fopen(ff,'r'); 
il = 1;
tline = fgetl(fid); 
A = tline; 
found_scantime = false; 
str_find = 'Preset Value: ';
while ~found_scantime
	il = il+1; 
	tline = fgetl(fid); 
	if  il > 100
		disp('Could not find scan time')
		scan_length_str = '0'; 
		break
	else
		ss = strfind(tline,str_find); 
		if ~isempty(ss)
			ss = ss+13; 
			scan_length_str = tline(ss:end); 
			found_scantime = true; 
		end
	end
end		
	
fclose(fid);

scan_length = str2num(scan_length_str); 

 
