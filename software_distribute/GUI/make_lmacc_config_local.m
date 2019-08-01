function [petpath] = make_lmacc_config_local(fdirbp,fdir_local,fdirout,lmfname,numrad,frame,img_init)


if (numrad==77)
    imgsize = 163;
    fdirbp = [fdirbp,'/bp77/'];
elseif (numrad==129)
    imgsize = 267;
    fdirbp = [fdirbp,'/bp129/'];
elseif (numrad == 157)
    imgsize = 323;
    fdirbp = [fdirbp,'/bp157/']; 
else
    disp("invalid radial bins"); 
    return
end



%fname_cfg = ['/run/media/meduser/data/software_distribute/reconstruction/lm_recon/lmacc_scanner_parameter_f',num2str(frame),'.cfg'];

fname_cfg = [fdir_local,'/lmacc_config/lmacc_scanner_parameter_f',num2str(frame),'.cfg'];


fid = fopen(fname_cfg,'w'); 



str = 'ring_diameter = 434.0\n';

fprintf(fid,str);

str = ''; 

str = ['image_size = ',num2str(imgsize),', ',num2str(imgsize),', 445\n'];

fprintf(fid,str);

str = '';

str = 'voxel_size = 1.005, 1.005, 1.005\n'; 

fprintf(fid,str);

str = '';

str = 'xtal_size = 4.02, 4.02, 4.02, 20.0\n';

fprintf(fid,str);

str = '';

str = 'gap_size = 0.0, 0.0, 0.0\n';

fprintf(fid,str);

str = '';

str = 'attn_coeff = 0.087, 0.0096\n';

fprintf(fid,str);

str = '';

str = 'xtal_array_size = 13, 111\n';

fprintf(fid,str);

str = '';

str = 'det_block_number = 24, 1\n';

fprintf(fid,str);

str = '';

str = 'num_of_rings = 111\n';

fprintf(fid,str);

str = '';

str = 'num_of_angles = 156\n';

fprintf(fid,str);

str = '';

str = ['proj_number_per_angle = ',num2str(numrad),'\n'];

fprintf(fid,str);

str='';

str = 'xtal_division = 8, 8, 20,  8, 8, 20\n\n';

fprintf(fid,str);

str = '';

if (numrad == 157)

    str = ['smat_file = /home/meduser/miniEXPLORER/lm/sysmatrix_',num2str(numrad),'x156x111_1mmvoxel_',num2str(imgsize),'x',num2str(imgsize),'x445_compr, primate_nontof.acc_8x8x20.',num2str(numrad),'x156.sysmat.',num2str(imgsize),'x',num2str(imgsize),'x445x1.005x1.005x1.005.r1r\n'];
else
    str = ['smat_file = xxxxx/run/media/meduser/backup2/system_matrix/lm/sysmatrix_',num2str(numrad),'x156x111_1mmvoxel_',num2str(imgsize),'x',num2str(imgsize),'x445_compr, primate_nontof.acc_8x8x20.',num2str(numrad),'x156.sysmat.',num2str(imgsize),'x',num2str(imgsize),'x445x1.005x1.005x1.005.r1r\n']; % no other system matrix files on server yet

end
fprintf(fid,str);

str = '';


if (img_init>0.5)
	str = ['initial_image=',fdirout,'/lmrecon_',lmfname,'_',num2str(imgsize),'x',num2str(imgsize),'x445_frame',num2str(frame),'.oslmem.tof.temp.out.0\n'];
	fprintf(fid,str); 
	str = ''; 
end

str = 'axial_ratio = 4\n';

fprintf(fid,str);

str = '';

str = 'angle_offset = 0\n';

fprintf(fid,str);

str = '';

str = 'inplane_compr_factor = 8\n';

fprintf(fid,str);

str = '';

str = ['sensitivity = ',fdirbp,'bp\n']; 

fprintf(fid,str);

str='';


str = 'tof_info = 610, 78.125\n';

fprintf(fid,str);

str = '';

petpath = ['lmrecon_',lmfname,'_',num2str(imgsize),'x',num2str(imgsize),'x445_frame',num2str(frame)];

str = ['recon_output = ',fdirout,', ',petpath]; 
petpath = [fdirout,'/',petpath]; 

fprintf(fid,str);

fclose(fid);















