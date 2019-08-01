%
% cut the sinogram 157x156x111x111 to ???x156x111x111
% 


function normnew = cut_norm(norm)


numrad = 157;
numang = 156;
numring = 111;

numrad_cut1 = 129;
numrad_cut2 = 77;

aa1 = (numrad - numrad_cut1)/2;
aa2 = (numrad - numrad_cut2)/2;




norm157 = fread(fopen('/run/media/meduser/data/software_distribute/normalization_data/2017-05-15/ynorm_wgap0_157-float.raw','rb'),inf,'float');
norm157 = reshape(norm157,numrad,numang,numring,numring); 

norm129 = norm157(aa1+1:end-aa1,:,:,:);
norm77 = norm157(aa2+1:end-aa2,:,:,:); 


file_name = ['/run/media/meduser/data/software_distribute/normalization_data/2017-05-15/ynorm_wgap0_129x156-float.raw'];

fwrite(fopen(file_name,'w'),norm129,'float');
fclose('all');


file_name = ['/run/media/meduser/data/software_distribute/normalization_data/2017-05-15/ynorm_wgap0_77x156-float.raw'];

fwrite(fopen(file_name,'w'),norm77,'float');
fclose('all');








