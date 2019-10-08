function scanner = buildPET(name, single_ring_only)

if nargin < 2
    single_ring_only = false;
else
    if isempty(single_ring_only)
        single_ring_only = false;
    end
end

switch lower(name)



    case 'primate_scanner_24b_16br'
        name_tag = 'primate_scanner_24b_16br';
        ring_diameter = 434.0; % unit in mm
        
        crystal_size = [3.94, 3.94, 3.94, 20]; % tf-tr-a-d (unit in mm)
        crystal_gap_size = [0.08, 0.08, 0.08]; % tf-tr-a (unit in mm)
   
        % crystal_size = [4.0, 4.0, 4.0, 20]; % tf-tr-a-d (unit in mm)
        % crystal_gap_size = [0.077, 0.077, 0.077]; % tf-tr-a (unit in mm)
        % crystal_gap_size = [0.06, 0.06, 0.06]; % tf-tr-a (unit in mm)
    
        if single_ring_only
            crystal_array_size = [13 1];
            number_of_detector_modules_axial = 1;
            detector_modula_axial_extra_offsets = [0.0];
        else
            crystal_array_size = [13 223];   %  13*8 + 7  (104+7)
            number_of_detector_modules_axial = 1;
            detector_modula_axial_extra_offsets = [0.0 0.0];
        end
        number_of_detector_modules_transaxial = 24;
        number_of_DOI_bins = 1;
        detector_module_initial_angle_offset = 0.0;
        

        % number_of_projections_per_angle = 231;     % radial fov 41   cm
        % number_of_projections_per_angle = 181;       % radial fov 35.6 cm
        % number_of_projections_per_angle = 129;     % radial fov 26.9 cm
        number_of_projections_per_angle = 77;     % radial fov 26.9 cm
        
        %         tof_info = [350, 25];
        tof_info = [530, 25];








    case 'primate_scanner_24b_8br_bxp'
        name_tag = 'primate_scanner_24b_8br_bxp';
        ring_diameter = 434.0; % unit in mm
        crystal_size = [52.26, 52.26, 52.26, 20.0]; % tf-tr-a-d (unit in mm)
        crystal_gap_size = [0.0, 0.0, 0.0]; % tf-tr-a (unit in mm)
        if single_ring_only
            crystal_array_size = [1 1];
            number_of_detector_modules_axial = 1;
            detector_modula_axial_extra_offsets = [0.0];
        else
            crystal_array_size = [1 8];
            number_of_detector_modules_axial = 1;
            detector_modula_axial_extra_offsets = [0.0 0.0];
        end
        number_of_detector_modules_transaxial = 24;
        number_of_DOI_bins = 1;
        detector_module_initial_angle_offset = 0.0;
        
                
%         number_of_projections_per_angle = 475;

        number_of_projections_per_angle = 9;  % 29;  % 33;  % 37; % 
        

        %         tof_info = [350, 25];
        % tof_info = [530, 25];
        tof_info = [609, 78.125];   %  xzzhang
        



    case 'primate_scanner_24b_8br_bxp_11x12'
        name_tag = 'primate_scanner_24b_8br_bxp_11x12';
        ring_diameter = 434.0; % unit in mm
        crystal_size = [52.26, 52.26, 52.26, 20.0]; % tf-tr-a-d (unit in mm)
        crystal_gap_size = [0.0, 0.0, 0.0]; % tf-tr-a (unit in mm)
        if single_ring_only
            crystal_array_size = [1 1];
            number_of_detector_modules_axial = 1;
            detector_modula_axial_extra_offsets = [0.0];
        else
            crystal_array_size = [1 8];
            number_of_detector_modules_axial = 1;
            detector_modula_axial_extra_offsets = [0.0 0.0];
        end
        number_of_detector_modules_transaxial = 24;
        number_of_DOI_bins = 1;
        detector_module_initial_angle_offset = 0.0;
        
                
%         number_of_projections_per_angle = 475;

        number_of_projections_per_angle = 11;  % 29;  % 33;  % 37; % 
        

        %         tof_info = [350, 25];
        % tof_info = [530, 25];
        tof_info = [609, 78.125];   %  xzzhang
        





    case 'primate_scanner_24b_8br_bxp_13x12'
        name_tag = 'primate_scanner_24b_8br_bxp_13x12';
        ring_diameter = 434.0; % unit in mm
        crystal_size = [52.26, 52.26, 52.26, 20.0]; % tf-tr-a-d (unit in mm)
        crystal_gap_size = [0.0, 0.0, 0.0]; % tf-tr-a (unit in mm)
        if single_ring_only
            crystal_array_size = [1 1];
            number_of_detector_modules_axial = 1;
            detector_modula_axial_extra_offsets = [0.0];
        else
            crystal_array_size = [1 8];
            number_of_detector_modules_axial = 1;
            detector_modula_axial_extra_offsets = [0.0 0.0];
        end
        number_of_detector_modules_transaxial = 24;
        number_of_DOI_bins = 1;
        detector_module_initial_angle_offset = 0.0;
        
                
%         number_of_projections_per_angle = 475;

        number_of_projections_per_angle = 13;  % 29;  % 33;  % 37; % 
        

        %         tof_info = [350, 25];
        % tof_info = [530, 25];
        tof_info = [609, 78.125];   %  xzzhang
        







    otherwise
        error('unknown scanner! micropet2, toshiba, inveon, ucdpetmr, explorer, explorer2000mm, explorer2000mm_v3_4brscanner');
        
                
end




% create scanner object
scanner = PETsystem(...
    name_tag, ...
    ring_diameter, ...
    crystal_size, ...
    crystal_gap_size, ...
    crystal_array_size, ...
    number_of_detector_modules_transaxial, ...
    number_of_detector_modules_axial, ...
    number_of_DOI_bins, ...
    detector_module_initial_angle_offset, ...
    detector_modula_axial_extra_offsets, ...
    number_of_projections_per_angle, ...
    tof_info);




