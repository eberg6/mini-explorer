% function S = compute_scatter(emis_image, attn_image, sss_image_size, sss_voxel_size, energy_info)
function S = compute_scatter_OLD_bxp(scanner_bxp_sss, emis_image, attn_image, sss_image_size, sss_voxel_size, energy_info)


if nargin < 5
	warning('not specify energy info, use [440 665 0.11]!');
	energy_info = [440 665 0.11];
end

if 1
tic;

% % scanner_sss = buildPET('lbltof');
% scanner_sss = buildPET('lbltof_human');
% scanner_sss = buildPET('lbltof_human_191x192');
% scanner_bxp_sss = buildPET('explorer2000mm_v3_bxp');
% scanner_bxp_sss = buildPET('primate_scanner_24b_8br_bxp');

scanner_bxp_sss.getCrystalTransaxialLocations;
idxx = int16(scanner_bxp_sss.getDefaultSinogramCrystalPairs); 

fname = 'index_blockpairs_transaxial_2x13x12_int16.raw';
fid = fopen(fname,'wb'); 
fwrite(fid,idxx,'int16'); 
fclose(fid); 
% S = SSS_nonTOF()
S = sss(emis_image, ...
			   attn_image, ...
			   sss_image_size, ... 
			   sss_voxel_size, ...
        	   scanner_bxp_sss.getCrystalTransaxialLocations, ...
        	   scanner_bxp_sss.getCrystalRingOffsets, ...
        	   int16(scanner_bxp_sss.getDefaultSinogramCrystalPairs), ...
        	   energy_info);
toc; 
end


% S = reshape(S, scanner_bxp_sss.system_parms.number_of_projections_per_angle, ...
             % scanner_bxp_sss.getDefaultNumberOfAngles);

whos S

% save('S_nonTOF.mat', 'S')
save('S_nonTOF_interplinear.mat', 'S');


% S = reshape(S, scanner_bxp_sss.system_parms.number_of_projections_per_angle, ...
%              scanner_bxp_sss.getDefaultNumberOfAngles);

S = reshape(S, scanner_bxp_sss.system_parms.number_of_projections_per_angle, ...
             scanner_bxp_sss.getDefaultNumberOfAngles, scanner_bxp_sss.getNumberOfCrystalRings, scanner_bxp_sss.getNumberOfCrystalRings);



