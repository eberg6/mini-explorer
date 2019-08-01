function val_injtime = change_injtime(fdir_bin,lmfname1,injtime)

val_injtime = true; 

injtimee = get(injtime, 'String'); 

lmfname = erase(lmfname1,'.lm');
lmfname1 = lmfname; 

xx = strfind(fdir_bin,'/'); 
xx = xx(end); 
fdir = [fdir_bin(1:xx-1),'/']; 
fdir_bin = [fdir_bin,'/'];  
lmfname1 = [lmfname1,'.lm'];


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



inj_str_old = A{305}




if length(injtimee) ~= 20
	val_injtime = false; 
end

if contains(injtimee,'06:00:00')
	val_injtime = false;
end

inj_time_vec = datetime(injtimee,'InputFormat','MMMddHH:mm:ssyyyy')
	
if val_injtime

	inj_str_old(end-19:end) = injtimee; 
	A{305} = inj_str_old; 

 	
	fid2 = fopen(lmfname_hdr,'w'); 
	for tt = 1:numel(A)
		if A{tt+1} == -1
			fprintf(fid2,'%s',A{tt});
			break
		else
			fprintf(fid2,'%s\n',A{tt});
		end
	end
	fclose(fid2);

end
	

