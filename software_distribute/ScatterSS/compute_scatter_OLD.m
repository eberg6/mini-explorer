function S = compute_scatter(emis_image, attn_image, sss_image_size, sss_voxel_size, energy_info)

if nargin < 5
	% warning('not specify energy info, use [440 665 0.11]!');
	% energy_info = [440 665 0.11];
	warning('not specify energy info, use [440 665 0.11]!');
	energy_info = [440 665 0.13];	
end

if 1
tic;

% % scanner_sss = buildPET('lbltof');
% scanner_sss = buildPET('lbltof_human');
% scanner_sss = buildPET('lbltof_human_191x192');
scanner_bxp_sss = buildPET('explorer2000mm_v3_bxp');


S = SSS_nonTOF(emis_image, ...
			   attn_image, ...
			   sss_image_size, ... 
			   sss_voxel_size, ...
        	   scanner_bxp_sss.getCrystalTransaxialLocations, ...
        	   scanner_bxp_sss.getCrystalRingOffsets, ...
        	   int16(scanner_bxp_sss.getDefaultSinogramCrystalPairs), ...
        	   energy_info);
toc; 
end
S = reshape(S, scanner_bxp_sss.system_parms.number_of_projections_per_angle, ...
             scanner_bxp_sss.getDefaultNumberOfAngles);