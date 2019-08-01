function make_server_lmsss_run_sh(fdir_local, fdir_remote, server_name,start_frame, end_frame)



%fname_sh_all = [fdir_local,'/run_sss/run_lmsss.sh'];
fname_sh_all = ['./run_lmsss.sh']; 
fid = fopen(fname_sh_all,'w');


%str = ['ssh -t eberg@',server_name,' sudo  chmod -R +x ',fdir_remote,'/run_sss\n\n'];
if strcmp(server_name,'Local') > 0.5
    str = ['chmod -R +x ',fdir_remote,'/run_sss\n\n']; 
else
    str = ['ssh -t eberg@',server_name,'  chmod -R +x ',fdir_remote,'/run_sss\n\n']; 
end
fprintf(fid,str); 
str = ''; 

if strcmp(server_name,'Local') > 0.5
    str = ['']; 
else
    str = ['ssh -t eberg@',server_name,' "']; 
end 
fprintf(fid,str); 
str = ''; 


for N = start_frame:end_frame

	fname_sh1 = [fdir_local,'/run_sss/f',num2str(N),'/run_lmsss_f',num2str(N),'.sh'];

	fid1 = fopen(fname_sh1,'w'); 
	
	if strcmp(server_name,'Local') > 0.5
		str = [fdir_remote,'/run_sss/f',num2str(N),'/scatter_lm_sino_tof_local']; 
	else
		str = [fdir_remote,'/run_sss/f',num2str(N),'/scatter_lm_sino_tof_server']; 
	end
	
	fprintf(fid1,str); 
	str = ''; 
	
	fclose(fid1); 
	
	str = ['cd ',fdir_remote,'/run_sss/f',num2str(N),'; ./run_lmsss_f',num2str(N),'.sh  &  ']; 
	
	%if N == start_frame
	%	str = ['"cd ',fdir_remote,'/run_sss/f',num2str(N),'; ./run_lmsss_f',num2str(N),'.sh']; 
	%else
	%	str = [' & cd ',fdir_remote,'/run_sss/f',num2str(N),'; ./run_lmsss_f',num2str(N),'.sh'];
	%end
	fprintf(fid,str); 
	str = ''; 
	
end

if strcmp(server_name,'Local') > 0.5
    str = [' wait ']; 
else
    str = ' wait "';
end 

 
fprintf(fid,str); 
fclose(fid); 



	

