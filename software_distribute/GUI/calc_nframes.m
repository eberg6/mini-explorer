function numframes = calc_nframes(f_dyn)

fdyn2 = get(f_dyn,'String'); 
fdyn = strsplit(fdyn2,',');

ntot = 0; 
for i=1:2:(numel(fdyn)-1)
	ni = str2num(fdyn{i});
	ntot = ntot + ni; 
end
ntot = ntot-1; 

numframes = num2str(ntot);
	
