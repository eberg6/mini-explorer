function make_combine_run_sh(fdir_local,fdir_remote,frame,sub,mult)




fname_sh = [fdir_local,'/run_sh/run_combine_f',num2str(frame),'.sh'];

fid = fopen(fname_sh,'w');

if strcmp(fdir_local,fdir_remote) > 0.5
	str = '../reconstruction/lm_recon/combine   '; 
else
	str = '/home/eberg/reconstruction/combine  '; 
end
str = [str, fdir_remote, '/lm_reorder_f',num2str(frame),'_prompts.raw  ']; 

if (sub > 0.5) 
	str = [str, fdir_remote, '/lm_reorder_f',num2str(frame),'_sub.raw  '];
end
if (sub < 0.5)
	str = [str, 'xxx  '];
end
if (mult > 0.5)
	str = [str, fdir_remote, '/lm_reorder_f',num2str(frame),'_mult.raw  ']; 
end
if (mult < 0.5) 
	str = [str, 'yyy  ']; 
end	

str=[str,fdir_remote, '/lm_reorder_f',num2str(frame),'_prompts_cor.raw']; 


fprintf(fid,str);

str = '';


fclose(fid);



