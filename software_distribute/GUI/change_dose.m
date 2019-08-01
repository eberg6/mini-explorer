function val_dose = change_dose(fdir_bin,lmfname1,dose)


val_dose = 'true'; 

dosee = get(dose, 'String'); 

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
 

if length(dosee) > 5
		%numremove =  length(dose_str2) - length(num2str(dose));
	dosee = dosee(1:5); 
end

if length(dosee) == 3 && contains(dosee,'0.1'); 
	val_dose = false; 
end

if ~all(ismember(dosee, '. 1234567890'));
	val_dose = false;
end

if val_dose == true
	A{300} = ['dose ',dosee]; 
	
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
	
	
 
