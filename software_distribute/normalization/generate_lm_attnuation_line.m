%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Attenuation Factor for mini-EXPLORER
% Xuezhu Zhang
% Qi Lab
% 2016-2017
% 



p=genpath('../PETsystem');
addpath(p);
scanner = buildPET('primate_scanner_radialbins157');




numrad = 157;
numang = 156;
numring_wgap = 111;
coef_attn = 0.0096;  %  0.00958;

num_voxels = 323;
num_slices = 445;
image_size = [num_voxels num_voxels num_slices];
voxel_size = [1.005, 1.005, 1.005];


dir_atnimage = './'; 
image_atn_map3d = fread(fopen(strcat(dir_atnimage, 'm7_323x323s445_scale-0.003_float.raw'), 'rb'), inf, 'float');
image_atn_map3d = double(reshape(image_atn_map3d, num_voxels, num_voxels, num_slices));


dir_lmdata = './'
lmdata = fread(fopen(strcat(dir_lmdata, 'lmdata_nontof_idxlor_157x156x111x111_5xint16.raw'), 'rb'), inf, 'int16');
lmdata = reshape(lmdata, 5, numrad*numang*numring_wgap*numring_wgap);


lmdata_attn = scanner.doListModeForwardProjectionNonTOF(image_atn_map3d, image_size, voxel_size, int16(lmdata)); 
lmdata_attn_exp = exp(-coef_attn*lmdata_attn);

data_fname = strcat('lmdata_attenuation_exp_float.raw');
fid = fopen(data_fname, 'w');        
fwrite(fid, lmdata_attn_exp, 'single');        
fclose('all');  



lmdata_attn_exp = reshape(lmdata_attn_exp, numrad, numang, numring_wgap, numring_wgap);
                
ynorm_wgap = touch('../normalization/ynorm_wgap0_10_157x156x111x111-float.raw');
ynorm_wgap = reshape(ynorm_wgap, numrad, numang, numring_wgap, numring_wgap);

ynorm_attn = lmdata_attn_exp .* ynorm_wgap;  %  cylinder_atn .* ynorm_wgap;

file_name = strcat('ynorm_attn_float.raw');
fwrite(fopen(file_name, 'w'), ynorm_attn, 'single');
fclose('all')
     





