function remove_raws(fdir,frame)


str = '../reconstruction/lm_recon/combine  '; 
str = [str, fdir, '/lm_reorder_f',num2str(frame),'_prompts.raw  ']; 

str1 = [fdir,'/lm_reorder_f',num2str(frame),'_prompts.raw']; 
if (exist(str1,'file'))
	delete(str1); 
end

str2 = [fdir,'/lm_reorder_f',num2str(frame),'_randoms.raw'];
if (exist(str2,'file'))
	delete(str2); 
end

str3 = [fdir,'/lm_reorder_f',num2str(frame),'_mult.raw'];
if (exist(str3,'file'))
	delete(str3); 
end

str4 = [fdir,'/lm_reorder_f',num2str(frame),'_sub.raw'];
if (exist(str4,'file'))
	delete(str4); 
end

str5 = [fdir,'/lm_reorder_f',num2str(frame),'_prompts_cor.raw'];
if (exist(str5,'file'))
	delete(str5); 
end

str6 = [fdir,'/lm_reorder_f',num2str(frame),'_sub2.raw'];
if (exist(str6,'file'))
	delete(str6); 
end


str7 = [fdir,'/sinogramblock_f',num2str(frame),'.raw'];
if (exist(str7,'file'))
	delete(str7); 
end

str8 = [fdir,'/sinogramblock_f',num2str(frame),'_tof.raw'];
if (exist(str8,'file'))
	delete(str8); 
end

str9 = [fdir,'/sss_sino_f',num2str(frame),'.raw'];
if (exist(str9,'file'))
	delete(str9); 
end

str10 = [fdir,'/sss_sino_f',num2str(frame),'_scaled.raw'];
if (exist(str10,'file'))
	delete(str10); 
end

str11 = [fdir,'/sss_sino_tof_f',num2str(frame),'_scaled.raw'];
if (exist(str11,'file'))
	delete(str11); 
end




disp('Extra listmode files removed'); 



