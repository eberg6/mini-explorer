function S = compute_scatter_tof_fast(scanner_sss, emis_image, attn_image, ...
									  sss_image_size, sss_voxel_size, ...
									  energy_info, tw_resolution, tw_spacing, tbin, ds)
%function SS = compute_scatter_tof_fast(scanner_sss, emis_image, attn_image, ...
%									  sss_image_size, sss_voxel_size, ...
%									  energy_info, tw_resolution, tw_spacing, tbin, ds)
%
% energy_info:[min,max,resolution]
% ds: downsampling factor
%

%scanner_sss = buildPET('lbltof');
scanner_sss = scanner_sss.setDepthRatio(0.5);
K = scanner_sss.system_parms.crystal_array_size(1);
num_of_blocks=scanner_sss.system_parms.number_of_detector_modules_transaxial;

xp = int16(scanner_sss.getDefaultSinogramCrystalPairs);
%xp = reshape(xp, 2, scanner_sss.system_parms.number_of_projections_per_angle, ...
             %scanner_sss.getDefaultNumberOfAngles);

%nb0=size(xp,2);
%na0=size(xp,3);
%xp = xp(:, 1:ds:end, 1:ds:end);
%nb=size(xp,2);
%na=size(xp,3);
%xp = reshape(xp, 2, size(xp,2)*size(xp,3));

tic;


% S = SSS_TOF_fast(emis_image, ...
S = sss_tof_fast(emis_image, ...
	    attn_image, ...
	    sss_image_size, ... 
	    sss_voxel_size, ...
        scanner_sss.getCrystalTransaxialLocations, ...
        scanner_sss.getCrystalRingOffsets, ...
        xp, [tw_resolution, tw_spacing], int32(tbin), ...
        energy_info, [K, num_of_blocks]);
toc; 


whos S
 


%save('S_TOF.mat', 'S')


% S = reshape(S, length(tbin), nb, na);
% S = permute(S, [2 3 1]);

%S = reshape(S, nb, na, nr, nr, length(tbin));   %  xzzhang
% S = permute(S, [2 3 1 4 5]);

%whos S

%save('S_TOF_reshape.mat', 'S')

% % SS=zeros(nb0,na0,size(S,3));
% SS=zeros(nb0, na0, size(S,3), nr, nr);

% if nb0~=nb || na0~=na
% 	for n=1:size(S,3)
% 		SS(:,:,n)=imresize(S(:,:,n),[nb0,na0],'bilinear');
% 	end
% else
	
% end
