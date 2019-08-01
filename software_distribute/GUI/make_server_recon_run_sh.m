function make_server_recon_run_sh(fdir_local, fdir_remote, start_frame, end_frame)


num_par_recon_max = 3; 

if strcmp(fdir_local,fdir_remote) == 1
    num_par_recon_max = 1; 
end

num_par_recon = end_frame-start_frame+1; 
num_par_recon(num_par_recon > num_par_recon_max) = num_par_recon_max; 


fname_sh_all = [fdir_local,'/run_sh/run_recon.sh'];
fid = fopen(fname_sh_all,'w');

for N = 1:num_par_recon

	fname_sh1 = [fdir_local,'/run_sh/run',num2str(N),'.sh'];

	fid1 = fopen(fname_sh1,'w'); 
 

	for m = (start_frame+N-1):num_par_recon_max:end_frame
		str = [fdir_remote,'/run_sh/run_combine_f',num2str(m),'.sh\n\n ',fdir_remote,'/run_sh/run_lm_tof_ext_f',num2str(m),'.sh\n\n']; 
		fprintf(fid1,str); 
		str = ''; 
	end
	fclose(fid1); 
	
	
	str = [fdir_remote,'/run_sh/run',num2str(N),'.sh  &  ']; 
	
	fprintf(fid,str); 
	str = ''; 
end

str = 'wait  '; 
fprintf(fid,str); 


fclose(fid); 



	





