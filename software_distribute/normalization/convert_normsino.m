function convert_normsino(norm157,fdir)


num_rings = 111;
nangbins = 156; 
numrad = 157; 

numrad_cut1 = 129;
numrad_cut2 = 77;

aa1 = (numrad - numrad_cut1)/2;
aa2 = (numrad - numrad_cut2)/2;

norm129 = norm157(aa1+1:end-aa1,:,:,:);
norm77 = norm157(aa2+1:end-aa2,:,:,:); 

[planes,offset] = my_sino_config(num_rings);


norm157sinorecon = zeros(numrad, nangbins, num_rings*num_rings);
norm129sinorecon = zeros(numrad_cut1, nangbins, num_rings*num_rings);
norm77sinorecon = zeros(numrad_cut2, nangbins, num_rings*num_rings);


for ni = 1:num_rings
    for nj = 1:num_rings
		norm157sinorecon(:, :, offset(ni, nj)) = norm157(:, :, nj, ni);
        norm129sinorecon(:, :, offset(ni, nj)) = norm129(:, :, nj, ni);
        norm77sinorecon(:, :, offset(ni, nj)) = norm77(:, :, nj, ni);
    end
end

data_fname = [fdir,'ynorm_wgap0_10_157x156x111x111-float_sinorecon.raw']; 
fwrite(fopen(data_fname, 'w'), norm157sinorecon, 'float'); 

data_fname = [fdir,'ynorm_wgap0_10_129x156x111x111-float_sinorecon.raw']; 
fwrite(fopen(data_fname, 'w'), norm129sinorecon, 'float'); 

data_fname = [fdir,'ynorm_wgap0_10_77x156x111x111-float_sinorecon.raw']; 
fwrite(fopen(data_fname, 'w'), norm77sinorecon, 'float'); 


data_fname = [fdir,'ynorm_wgap0_10_129x156x111x111-float.raw']; 
fwrite(fopen(data_fname, 'w'), norm129, 'float'); 

data_fname = [fdir,'ynorm_wgap0_10_77x156x111x111-float.raw']; 
fwrite(fopen(data_fname, 'w'), norm77, 'float'); 



fclose('all');  




clear norm157
clear norm129
clear norm77
clear norm157sinorecon
clear norm129sinorecon
clear norm77sinorecon




