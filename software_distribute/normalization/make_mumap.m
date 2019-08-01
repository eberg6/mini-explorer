function make_mumap(CTpath)

petpix = 1.005; 
g_smooth = 3.5; 

numrad = 157; 
numang = 156;
numrings = 111;

num_voxels = 323;
num_slices = 445;
image_size = [num_voxels num_voxels num_slices];
voxel_size = [1.005, 1.005, 1.005];

% load CT image

fname1 = [CTpath,'/ct_reg.raw'];
fid1 = fopen(fname1,'rb');
ctimg = fread(fid1,inf,'float'); 
ctimg = reshape(ctimg,num_voxels,num_voxels,num_slices); 

fname11 = [CTpath,'/ct_reg_nobed.raw'];
fid11 = fopen(fname11,'rb');
ctimg_nobed = fread(fid11,inf,'float'); 
ctimg_nobed = reshape(ctimg_nobed,num_voxels,num_voxels,num_slices); 


% smooth ct image
%disp('smoothing CT image to PET resolution'); 
%ctimg = imgaussfilt3(ctimg,[g_smooth/(2.355*petpix) g_smooth/(2.355*petpix) g_smooth/(2.355*petpix)]); 

 

fname2 = [CTpath,'/ct_preregPETinfo.mat'];
ctinfo = load(fname2); 
kVp = ctinfo.kVp; 
ct_imsize = ctinfo.imsize; 


% convert CT to mu-map
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


mu_map=ctimg;
mu_map(mu_map<0)=0; 
mu_map(ctimg<50)=(9.6e-6).*(ctimg(ctimg<50));
mu_map(ctimg>=50)=b + a.*(ctimg(ctimg>=50));


mu_map2=ctimg_nobed;
mu_map2(mu_map2<0)=0; 
mu_map2(ctimg_nobed<50)=(9.6e-6).*(ctimg_nobed(ctimg_nobed<50));
mu_map2(ctimg_nobed>=50)=b + a.*(ctimg_nobed(ctimg_nobed>=50));





ss = ['primate_scanner_radialbins',num2str(numrad)];


p=genpath('../PETsystem/');
addpath(p);
scanner = buildPET(ss); 



%dir_lmidx = '/home/meduser/miniEXPLORER/idx/'; 
%fname_lmidx = [dir_lmidx,'lmdata_nontof_idxlor_',num2str(numrad),'x156x111x111_5xint16.raw'];
fname_lmidx = ['../normalization/lmdata_nontof_idxlor_',num2str(numrad),'x156x111x111_5xint16.raw'];

fid_idx = fopen(fname_lmidx,'rb'); 
if ~fid_idx
    disp('Could not open lm index file, paused'); 
    pause
end

lmidx=fread(fid_idx,inf,'int16'); 
fclose(fid_idx); 

lmidx = reshape(lmidx, 5, numrad*numang*numrings*numrings);

% forward project ct img
disp('Forward project'); 
attn_sino157 = scanner.doListModeForwardProjectionNonTOF(mu_map, image_size, voxel_size, int16(lmidx)); 

attn_sino157_nobed = scanner.doListModeForwardProjectionNonTOF(mu_map2, image_size, voxel_size, int16(lmidx));

attn_sino157 = exp(-attn_sino157);
attn_sino157_nobed = exp(-attn_sino157_nobed);

attn_sino157 = reshape(attn_sino157,numrad,numang,numrings,numrings);
attn_sino157_nobed = reshape(attn_sino157_nobed,numrad,numang,numrings,numrings); 

tempsino=attn_sino157(:,:,round(111/2),round(111/2));

size(attn_sino157)

disp('Making attenuation sinograms'); 
% write attenuation sinogram
numrad_cut1 = 129;
numrad_cut2 = 77;

aa1 = (numrad - numrad_cut1)/2;
aa2 = (numrad - numrad_cut2)/2;

attn_sino129 = attn_sino157(aa1+1:end-aa1,:,:,:);
%attn_sino77 = attn_sino157(aa2+1:end-aa2,:,:,:); 


[planes,offset] = my_sino_config(numrings);


attn_sino157_sinorecon = zeros(numrad, numang, numrings*numrings);
attn_sino129_sinorecon = zeros(numrad_cut1, numang, numrings*numrings);
%attn_sino77_sinorecon = zeros(numrad_cut2, numang, numrings*numrings);
attn_sinoi157_sinorecon_nobed = zeros(numrad, numang, numrings*numrings);


for ni = 1:numrings
    for nj = 1:numrings
		attn_sino157_sinorecon(:, :, offset(ni, nj)) = attn_sino157(:, :, nj, ni);
        attn_sino129_sinorecon(:, :, offset(ni, nj)) = attn_sino129(:, :, nj, ni);
        %attn_sino77_sinorecon(:, :, offset(ni, nj)) = attn_sino77(:, :, nj, ni);
        attn_sino157_sinorecon_nobed(:, :, offset(ni, nj)) = attn_sino157_nobed(:, :, nj, ni); 
    end
end

data_fname = [CTpath,'/attn_sino_157x156x111x111-float_sinorecon.raw']; 
fwrite(fopen(data_fname, 'w'), attn_sino157_sinorecon, 'float'); 

data_fname = [CTpath,'/attn_sino_129x156x111x111-float_sinorecon.raw']; 
fwrite(fopen(data_fname, 'w'), attn_sino129_sinorecon, 'float'); 

%data_fname = [CTpath,'/attn_sino_77x156x111x111-float_sinorecon.raw']; 
%fwrite(fopen(data_fname, 'w'), attn_sino77_sinorecon, 'float'); 


data_fname = [CTpath,'/attn_sino_157x156x111x111-float_sinorecon_nobed.raw']; 
fwrite(fopen(data_fname, 'w'), attn_sino157_sinorecon_nobed, 'float'); 


fclose('all'); 

clear attn_sino157_sinorecon;
clear attn_sino129_sinorecon;
%clear attn_sino77_sinorecon; 
clear attn_sino157; 
clear attn_sino129;
%clear attn_sino77; 
clear attn_sino157_nobed; 
clear attn_sino157_sinorecon_nobed; 

clear scanner;
rmpath(p); 



