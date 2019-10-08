%A class to perform fast listmode- or sinogram-based PET image reconstruction
%Author: Jian Zhou
%Date: Aug. 1, 2013
%Modified: Xuezhu Zhang 


classdef PETsystem
    
    properties(GetAccess = 'public', SetAccess = 'private')
        name_tag; % scanner name
        system_parms; % structure that contains various system parameters
    end
    
        
    
    
    methods(Access = 'public')
              
        
        function obj = PETsystem(...
                tag, ...
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
                tof_info)
            
            obj.name_tag = tag;
            obj.system_parms.ring_diameter = ring_diameter;
            obj.system_parms.crystal_size = crystal_size;
            obj.system_parms.crystal_gap_size = crystal_gap_size;
            obj.system_parms.crystal_array_size = crystal_array_size;
            obj.system_parms.number_of_detector_modules_transaxial = ...
                number_of_detector_modules_transaxial;
            obj.system_parms.number_of_detector_modules_axial = ...
                number_of_detector_modules_axial;
            obj.system_parms.number_of_DOI_bins = number_of_DOI_bins;
            obj.system_parms.detector_module_initial_angle_offset = ...
                detector_module_initial_angle_offset;
            obj.system_parms.detector_module_axial_extra_offsets = ...
                detector_modula_axial_extra_offsets;
            obj.system_parms.number_of_projections_per_angle = ...
                number_of_projections_per_angle;
            obj.system_parms.tof_info = tof_info;
            obj.system_parms.projector = 'Siddon';
            obj.system_parms.depth_ratio = 0.5;
        end
        
        
        
        
        
        function obj = setProjector(obj, projector)
            %set projector type: `Siddon' or `Bresenham' or 'Linterp'
            %function obj = setProjector(projector)
            obj.system_parms.projector = projector;
        end
        
        
        
        
        
        
        function obj = setDepthRatio(obj, ratio)
            %set a ratio to determine average depth interaction point inside crystal
            %0.5 is default, meaning at the crystal center
            %function obj = setDepthRatio(ratio)
            if ratio < 0 || ratio > 1.0
                error('ratio must be in [0 1]!');
            end
            obj.system_parms.depth_ratio = ratio;
        end
        
        
        
        
        
        function obj = setNumberOfProjectionsPerAngle(obj, num_of_radial_bins)
            %set number of radial bins
            %function obj = setNumberOfProjectionsPerAngle(num_of_radial_bins)
            obj.system_parms.number_of_projections_per_angle = num_of_radial_bins;
        end
        
        
        
        
        
        function dmo = getDetectorModuleAxialOffsets(obj)
            %calculate detector module axial offsets
            %function dmo = getDetectorModuleAxialOffsets
            crystal_axial_pitch = obj.system_parms.crystal_size(3) + ...
                obj.system_parms.crystal_gap_size(3);
            detector_module_axial_size = crystal_axial_pitch * ...
                obj.system_parms.crystal_array_size(2);
            
            nb = obj.system_parms.number_of_detector_modules_axial;
            dmo = (- nb * 0.5 + 0.5 + (0 : (nb-1))) * ...
                detector_module_axial_size + ...
                obj.system_parms.detector_module_axial_extra_offsets;
        end
        
        
        
        
        
        
        function nr = getNumberOfCrystalRings(obj)
            %get number of crystal rings
            %function nr = getNumberOfCrystalRings
            nr = obj.system_parms.crystal_array_size(2) * ...
                obj.system_parms.number_of_detector_modules_axial;
        end
        
        
        
        
        
        
        function na = getDefaultNumberOfAngles(obj)
            %get number of projection angles in default mode
            %function na = getDefaultNumberOfAngles
            na = obj.system_parms.crystal_array_size(1) * ...
                obj.system_parms.number_of_detector_modules_transaxial / 2;
        end
        
        
        
        
        
        
        function ro = getCrystalRingOffsets(obj)   % define axial gap (2014-0311)
            %get crystal ring axial offsets
            %function ro = getCrystalRingOffsets
            crystal_axial_pitch = obj.system_parms.crystal_size(3) + ...
                obj.system_parms.crystal_gap_size(3);
            dm_offsets = getDetectorModuleAxialOffsets(obj);
            nb = obj.system_parms.crystal_array_size(2);
            xt_centers = (- nb * 0.5 + 0.5 + (0 : (nb-1))) * crystal_axial_pitch;
            ro = [];
            for n = 1 : obj.system_parms.number_of_detector_modules_axial
                ro = [ro , xt_centers + dm_offsets(n)];
            end
        end
        
        
        
        
        
        
        function tc = getCrystalTransaxialLocations(obj)
            %calculate crystal bin transaxial coordinates (bin means DOI bin)
            %function tc = getCrystalTransaxialLocations
            tfs = (obj.system_parms.crystal_size(1) + obj.system_parms.crystal_gap_size(1));
            trs = (obj.system_parms.crystal_size(2) + obj.system_parms.crystal_gap_size(2));
            nxtal_trans = obj.system_parms.crystal_array_size(1);
            df = (-nxtal_trans*0.5 + 0.5 + (0 : nxtal_trans-1)) * tfs;
            dr = (-nxtal_trans*0.5 + 0.5 + (0 : nxtal_trans-1)) * trs;
            
            num_of_doi_bins = obj.system_parms.number_of_DOI_bins;
            xtal_loc = zeros(2, num_of_doi_bins, nxtal_trans);
            xtal_size_depth = obj.system_parms.crystal_size(4);
            for n=1: nxtal_trans
                l = df(n)-dr(n);
                dl = l / num_of_doi_bins;
                cl = l * 0.5 - ((0:num_of_doi_bins-1) + 0.5) * dl;
                h = xtal_size_depth;
                dh = h / num_of_doi_bins;
                ch = h * 0.5 - ((0:num_of_doi_bins-1) + 0.5) * dh;
                xtal_loc(:, :, n) = [cl(:) + dr(n), ch(:)]';
            end
            
            R = obj.system_parms.ring_diameter * 0.5;
            nblock_trans = obj.system_parms.number_of_detector_modules_transaxial;
            tc = zeros(2, num_of_doi_bins, nxtal_trans, nblock_trans);
            for n=1:nblock_trans
                % always start at 3 o'clock
                a0 = (n-1) * 2*pi / nblock_trans  + ...
                    obj.system_parms.detector_module_initial_angle_offset * pi / 180;
                xs = xtal_loc(1,:,:);
                ys = xtal_loc(2,:,:);
                
                t = pi * 0.5 + a0;
                x = xs * cos(t) - ys * sin(t) + (R + xtal_size_depth*obj.system_parms.depth_ratio) * cos(a0);
                y = xs * sin(t) + ys * cos(t) + (R + xtal_size_depth*obj.system_parms.depth_ratio) * sin(a0);
                
                tc(1,:,:,n) = x;
                tc(2,:,:,n) = y;
            end
            tc = reshape(tc, 2, num_of_doi_bins, nxtal_trans*nblock_trans);
            tc = squeeze(tc);
        end
        
        
        
    end
    
    
    
    
    
    
    
    
    
    
    
    
    
    methods
        
        
        
        function xtal_pairs = getDefaultSinogramCrystalPairs(obj)
            % create crystal pairs according my own numbering scheme
            %function xtal_pairs = getDefaultCrystalPairs
            %
            
            % always equal to total number of crystals per ring divided by
            % 2
            nxtal_trans = obj.system_parms.crystal_array_size(1);
            xtal_num_trans_total = obj.system_parms.number_of_detector_modules_transaxial * ...
                obj.system_parms.crystal_array_size(1);
            
            num_of_angles = xtal_num_trans_total / 2;
            
            if obj.system_parms.number_of_projections_per_angle > (fix(xtal_num_trans_total/2)*2 - 2)
                error('too many projections!');
            end
            
            % case when detector module is not located exactly at 3-clock
            if obj.system_parms.detector_module_initial_angle_offset ~= 0
                disp('The 1st detector module is rotated by an angle!');
                disp('NOTE: For crystal pairing, this angle offset is never used directly!');
                disp('but always assume it is equal to 180 / (number_of_detector_modules_transaxial)');
                id0 = 0;
                id1 = num_of_angles;
                nr = fix(num_of_angles/2) * 2 - 2;
                h0 = zeros(nr,1);
                h1 = zeros(nr,1);
                
                for i=0:nr-1
                    
                    id=id0 + fix(nr/2) - i - 1;
                    if id < 0
                        id = id + xtal_num_trans_total;
                    end
                    
                    h0(i+1)=id;
                    id = id1-fix(nr/2) + i;
                    h1(i+1)=id;
                end
            else
                
                id0 = fix(nxtal_trans / 2);
                odd = mod(nxtal_trans, 2) ~= 0;
                
                if odd
                    id1 = fix(xtal_num_trans_total / 2) + fix(nxtal_trans / 2);
                    nr = fix(num_of_angles / 2) * 2 - 1;
                else
                    id1 = fix(xtal_num_trans_total / 2) + fix(nxtal_trans / 2) - 1;
                    nr = fix(num_of_angles / 2) * 2;
                end
                
                h0 = zeros(nr,1);
                h1 = zeros(nr,1);
                
                for i=0:nr-1
                    if odd
                        id = id0 + fix(nr/2) - i;
                    else
                        id = id0 + fix(nr/2) -1 - i;
                    end
                    
                    if id < 0
                        id = id + xtal_num_trans_total;
                    end
                    
                    h0(i+1) = id;
                    if odd
                        id = id1 - fix(nr/2) + i;
                    else
                        id = id1 - fix(nr/2) + 1 + i;
                    end
                    h1(i+1) = id;
                end
            end
            
            % pairing
            c = 1; k = 1;
            while c < length(h0)
                xtal_id1 = h0(c);
                xtal_id2 = h1(c);
                xp_first_angle(:,k) = [xtal_id1; xtal_id2];
                k = k + 1;
                if (c+1) <= length(h1)
                    xtal_id1 = h0(c);
                    xtal_id2 = h1(c+1);
                    xp_first_angle(:,k) = [xtal_id1; xtal_id2];
                    k = k + 1;
                end
                c = c + 1;
            end
            
            %
            nn = size(xp_first_angle,2);
            num_of_projs_per_angle = obj.system_parms.number_of_projections_per_angle;
            xtal_pairs = zeros(2, num_of_angles * num_of_projs_per_angle);
            k = 1;
            for i=1:num_of_angles
                for j=1:num_of_projs_per_angle
                    pp = xp_first_angle(:, fix(nn / 2) - fix(num_of_projs_per_angle / 2) + j);
                    p0 = mod(pp(1) + i-1, xtal_num_trans_total);
                    p1 = mod(pp(2) + i-1, xtal_num_trans_total);
                    xtal_pairs(:,k) = [p0; p1];
                    k = k + 1;
                end
            end
            xtal_pairs = xtal_pairs + 1;
        end
        
        
        
        
        
        
        
        
        
        
        
        %         function block_pairs_sinogram = getDefaultSinogramBlockPairs(obj, nblockwidth, nblockwidth_half)
        %
        %
        %             block_num_trans_total = obj.system_parms.number_of_detector_modules_transaxial;
        %
        %             num_of_angles = block_num_trans_total / 2;
        %
        %
        %             for i = 1:num_of_angles
        %
        %
        %
        %
        %             end
        %
        %         end
        
        
        
        
    end
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    methods(Access = 'public')
        
        
        
        function rp = getDefaultSinogramPlaneOrder(obj)
            %get default plane arrangement in terms of ring pair (different from Micxx-gram)
            %function rp = getDefaultSinogramPlaneOrder
            %
            nring = obj.getNumberOfCrystalRings();
            rp = zeros(2, nring*nring);
            offset = 0;
            for n = 1 : nring
                if n==1
                    rp(:,1:nring) = [1:nring; 1:nring];
                    offset = offset + nring;
                else
                    r_odd = [1:(nring-n+1); n:(nring)];
                    r_even = nring-r_odd+1;
                    nr = (nring-n+1)*2;
                    rp(:, offset + (1:2:nr)) = r_odd;
                    rp(:, offset + (2:2:nr)) = r_even;
                    offset = offset + nr;
                end
            end
        end
    end
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    methods(Access = 'public')
        
        
        function scattermean_sino = scattermean_block_sinogram(obj, lmdata, sino_blockpairs, ncrystal, nring)
            
            
            fprintf('calculating scattr mean ...\n');
            fprintf('sinogram size: %d x %d x %d \n',  image_size, voxel_size);
            
                        
            t1_trans = lmdata(1,:)/ncrystal;
            t2_trans = lmdata(3,:)/ncrystal;
            
            nblock;
            nring;
            
            
            %             sino_xpairs = int16(obj.getDefaultSinogramCrystalPairs);
            %             size(sino_xpairs);
            
            
            nrad = obj.system_parms.number_of_projections_per_angle;
            nang = obj.getDefaultNumberOfAngles;
            
            num_bins_radial = nrad;
            num_bins_angular = nang;
            
            num_bins_sino = num_bins_radial * num_bins_angular;
            
            crystal_array = obj.system_parms.crystal_array_size(1);
            num_blocks = obj.system_parms.number_of_detector_modules_transaxial;
            
            num_crystals = crystal_array * num_blocks;
            
            nocrypairs = zeros(num_crystals, num_crystals, 'int32');
            
            
            
            for m=1:num_bins_sino
                
                nv = sino_blockpairs(1, m);
                nu = sino_blockpairs(2, m);
                
                nocrypairs(nv, nu) = m;
                nocrypairs(nu, nv) = m;
                
            end
            
            
            
            
            
            
            linearInd = int32(sub2ind(size(nocrypairs), lmdata(1,:)+1, lmdata(3,:)+1));
            
            noindex_2Dsinogram = nocrypairs(linearInd);
            
            ringdifference = int32(abs(lmdata(2,:)-lmdata(4,:)));
            
            linearInd2 = int32(sub2ind(size(sino_lineintegral), noindex_2Dsinogram+1, ringdifference+1));
            
            raw_data = single(sino_lineintegral(linearInd2));
            
            clear linearInd linearInd2 ringdifference noindex_2Dsinogram
            
            
        end


        
        
        
    end
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    methods
        
        
                
        
        function mask = getImageMask(obj, image_size, radius_unit_in_pixel)
            %create a circular mask
            %function mask = getImageMask(image_size, radius_unit_in_pixel)
            %
            t1 = (0:image_size(1)-1) - image_size(1)/2 + 0.5;
            t2 = (0:image_size(2)-1) - image_size(2)/2 + 0.5;
            [I, J] = ndgrid(t1, t2);
            m0 = sqrt(I.^2 + J.^2) < radius_unit_in_pixel;
            if length(image_size) == 3
                mask = repmat(m0(:), 1, image_size(3));
                mask = reshape(mask, image_size);
            else
                mask = m0;
            end
        end
        
        
        
        function G = getSimple2DMatrix(obj, image_size, voxel_size)
            %create a 2d system matrix
            %function G = getSimple2DMatrix(image_size, voxel_size)
            %
            if obj.getNumberOfCrystalRings > 1
                error('sorry, only for 2D scanner!');
            end
            if length(image_size)<3
                if length(image_size)<2
                    error('invalid image dimension!');
                else
                    image_size(3) = 1;
                end
            end
            if length(voxel_size)<3
                if length(voxel_size)<2
                    error('invalid voxel size!');
                else
                    voxel_size(3) = 1;
                end
            end
            xp = obj.getDefaultSinogramCrystalPairs;
            xp = int16(xp);
            lm = int16(zeros(5, size(xp,2)));
            lm(1,:) = xp(1,:)-1;
            lm(3,:) = xp(2,:)-1;
            nz0 = 30000000;
            ii=zeros(nz0, 1);
            jj=zeros(nz0, 1);
            ss=zeros(nz0, 1);
            offset = 0;
            for n = 1 : size(lm,2)
                if mod(n, obj.system_parms.number_of_projections_per_angle) == 0
                    fprintf('processing #%d ... (nnz=%d)\n', n, offset);
                end
                bp = obj.doListModeBackProjectionNonTOFSingleThread([], ...
                    image_size, voxel_size, lm(:,n));
                lor_nz = nnz(bp);
                if lor_nz > 0
                    [i] = find(bp(:));
                    ii([1:lor_nz] + offset) = i;
                    ss([1:lor_nz] + offset) = bp(i);
                    jj([1:lor_nz] + offset) = n*ones(size(i));
                    offset = offset + lor_nz;
                end
            end
            ii=ii(1:offset);
            jj=jj(1:offset);
            ss=ss(1:offset);
            G = sparse(jj, ii, ss, size(lm,2), prod(image_size(1:2)));
        end

    
    end
      
    
    
end
