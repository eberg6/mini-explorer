function emi_sss_tof_lmdata_rs_xp_609ps_13x12(fdir,petimgpath,ct_path,frame)

p=genpath('./PETsystem');
addpath(p);


g_smooth = 3;

scannerbxp = buildPET('primate_scanner_24b_8br_bxp_13x12');
scannerbxp.system_parms
objbxp=scannerbxp;



bxp = scannerbxp.getDefaultSinogramCrystalPairs;

numvoxel = 323;
numslice = 445;


voxelsize_x = 1.005;
voxelsize_y = 1.005;
voxelsize_z = 1.005;

img_size = [numvoxel numvoxel numslice];

voxelsize = [voxelsize_x  voxelsize_y  voxelsize_z];

emis = touch(petimgpath);  

emis = reshape(emis, img_size);


emis(:,:,1:6) = 0; 
emis(:,:,(end-5):end) = 0; 
emis(1:6,:,:) = 0; 
emis((end-5):end,:,:) = 0; 
emis(:,1:6,:) = 0; 
emis(:,(end-5):end,:) = 0; 

emis = imgaussfilt3(emis,g_smooth/2.355); 


% load CT image
fname2 = [ct_path,'/ct_preregPETinfo.mat'];
ctinfo = load(fname2); 
kVp = ctinfo.kVp;

attn_mask = touch(strcat(ct_path, '/ct_reg.raw'));
attn_mask = reshape(attn_mask, img_size);



%max(emis(:))  % 0.7410
%min(emis(:))  % 0
%max(attn_mask(:))  % 1
%min(attn_mask(:))  % 0


%kVp = 120; 

b = 4.71e-3; 
a = 5.1e-6; 

if kVp == 80
    b = 6.26e-3;
    a = 3.64e-6;
elseif kVp == 120
    b = 4.71e-3;
    a = 5.1e-6;
elseif kVp == 140
	b = 4.08e-3; 
	a = 5.64e-6; 
else
    errordlg('Invalid CT kVp');
end

mu_map = attn_mask; 
mu_map(mu_map<0)=0; 
mu_map(attn_mask<50) = (9.6e-6).*(attn_mask(attn_mask<50)); 
mu_map(attn_mask>=50) = b + a.*(attn_mask(attn_mask>=50)); 

attn = mu_map;


emis(emis<0) = 0;



scale_fold = 4;

if scale_fold == 2
	numvoxel_2 = floor(numvoxel/scale_fold);
	numslice_2 = ceil(numslice/scale_fold);
elseif scale_fold == 4
	numvoxel_2 = ceil(numvoxel/scale_fold);
	numslice_2 = floor(numslice/scale_fold);
end


img_size_2 = [numvoxel_2 numvoxel_2 numslice_2];

voxelsize_2 = scale_fold * [voxelsize_x  voxelsize_y  voxelsize_z];


attn2 = zeros(numvoxel_2, numvoxel_2, numslice_2);
emis2 = zeros(numvoxel_2, numvoxel_2, numslice_2);


[Y X Z]= ndgrid(linspace(1,size(emis, 1), numvoxel_2),...
          linspace(1,size(emis, 2), numvoxel_2),...
          linspace(1,size(emis, 3), numslice_2));

emis2 = interp3(emis, X, Y, Z);

attn2 = interp3(attn, X, Y, Z);


%max(emis2(:))  % 4-fold 4.02mm voxel: 0.2834   2-fold 2.01mm voxel: 0.3950   %  0.7410
%min(emis2(:))  % 0
%max(attn2(:))  % 0.0096
%min(attn2(:))  % 0

rmpath(p);

%filename = strcat('./interp3_emis_', num2str(numvoxel_2), 'x', num2str(numvoxel_2), 's', num2str(numslice_2), '_monkey46166_float.raw');
%fwrite(fopen(filename, 'wb'), emis2, 'single');

%filename = strcat('./interp3_attn_', num2str(numvoxel_2), 'x', num2str(numvoxel_2), 's', num2str(numslice_2), '_monkey46166_float.raw');
%fwrite(fopen(filename, 'wb'), attn2, 'single');

%fclose('all');





lowenergy = 425;  % 435    % 400     % 

highenergy = 650;   %   660    % 

energy_info = 0.13;   %  0.15  % 



% % function S = compute_scatter(emis_image, attn_image, sss_image_size, sss_voxel_size, energy_info)
% S_nonTOF = compute_scatter_OLD_bxp(scannerbxp, emis, attn, img_size, voxelsize, [lowenergy highenergy energy_info]);

%tic
S_nonTOF2_test = compute_scatter_OLD_bxp(scannerbxp, emis2, attn2, img_size_2, voxelsize_2, [lowenergy highenergy energy_info]);


fname = [fdir,'/sss_sino_f',num2str(frame),'.raw']; 
fid22 = fopen(fname,'wb'); 

fwrite(fid22,S_nonTOF2_test,'double'); 
fclose(fid22); 



%toc
pause(1); 



 



