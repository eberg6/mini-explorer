function make_lmreconext_run_sh(fdir_local,fdir,iter,subs,frame)

num_threads = 40; 

% check if multple frames or not 
fdir_c = [fdir_local,'/lmacc_config']; 
lst = dir(fdir_c); 
if length(lst) > 3
	num_threads = 18; 
end
if strcmp(fdir_local,fdir) > 0.5; 
	num_threads = 40;  
end

fname_sh = [fdir_local,'/run_sh/run_lm_tof_ext_f',num2str(frame),'.sh'];

fid = fopen(fname_sh,'w');

str = ['export OMP_NUM_THREADS=',num2str(num_threads),'\n\n'];

fprintf(fid,str);

str = '';

str1 = '/home/eberg/reconstruction/lmacc_tof_ext  ';
if strcmp(fdir_local,fdir) > 0.5; 
	str1 = '../reconstruction/lm_recon/lmacc_tof_ext   '; 
end

str = [str1,fdir,'/lmacc_config/lmacc_scanner_parameter_f',num2str(frame),'.cfg  ',fdir,'/lm_reorder_f',num2str(frame),'_prompts_cor.raw  ',num2str(subs),' ',num2str(iter), ' 1'];

fprintf(fid,str);

str = '';


fclose(fid);



