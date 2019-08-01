function scale_sss_sino(fdir,ct_path,frame)

ff1 = [fdir,'/sinogramblock_f',num2str(frame),'.raw'];
ff11 = [fdir,'/sinogramblock_f',num2str(frame),'_tof.raw'];
%ff2 = [fdir,'/sss_sino_f',num2str(frame),'.raw'];
ff2 = [fdir,'/sss_sino_tof_f',num2str(frame),'.raw']; 
ff3 = [ct_path,'/de_sino.raw']; 
ff4 = [ct_path,'/attn_blocksino.raw']; 


psino = fread(fopen(ff1,'r'),inf,'double'); 
psino_tof =fread(fopen(ff11,'r'),inf,'double'); 
sss_sino = fread(fopen(ff2,'r'),inf,'double');

de_sino = fread(fopen(ff3,'r'),inf,'double'); 
attn_sino = fread(fopen(ff4,'r'),inf,'double'); 

%sum(attn_sino(:))

psino = reshape(psino,[13,12,8,8]); 
psino_tof = reshape(psino_tof,[64,13,12,8,8]); 
%sss_sino = reshape(sss_sino,[13,12,8,8]); 
sss_sino_tof = reshape(sss_sino,[11,13,12,8,8]); 
de_sino = reshape(de_sino,[13,12,8,8]); 
attn_sino = reshape(attn_sino,[13,12,8,8]); 

sss_sino = squeeze(sum(sss_sino_tof,1)); 

sss_sino = sss_sino.*de_sino;

de_sino_tof = de_sino; 
de_sino_tof = permute(de_sino_tof,[5,1,2,3,4]); 
de_sino_tof = repmat(de_sino_tof,11,1,1,1,1); 

sss_sino_tof = sss_sino_tof.*de_sino_tof; 

%sss_sino_tofsum = squeeze(sum(sss_sino_tof,1)); 

%sdiff = sss_sino_tofsum - sss_sino; 
%sdiff2 = sum(sdiff(:))



figure
imagesc(psino(:,:,4,4));
pause(0.5); 




figure
imagesc(attn_sino(:,:,4,4));
pause(0.5); 


attn_test = attn_sino(12,6,4,4); 
if attn_test < 0.9
    disp('Attenuation image out of range'); 
end


attn_thr = 0.85; 
inds = ones(size(psino)); 
inds(attn_sino<attn_thr) = 0; 
inds(psino<1) = 0; 


psum = sum(psino(:));
sss_est = psum*.25; 
sss_sum = sum(sss_sino(:)); 
mfac_init = sss_est/sss_sum;

% mfac = 3.5e11; 

sss_sino = sss_sino.*(mfac_init);
sss_sino_tof = sss_sino_tof.*(mfac_init);  

psino2 = psino;
sss_sino2 = sss_sino;

sss_sino2(inds<0.5) = 0; 
psino2(inds<0.5) = 0; 


mfac_all = zeros(8,8); 
mfac_test = 0.4:0.01:1.6; 
mmin = 1; 
mfac_ind = 1; 

for ii = 1:8
    for jj = 1:8
        ptemp = psino2(:,:,ii,jj); 
        ssstemp = sss_sino2(:,:,ii,jj);
        
        ptempsum = sum(ptemp,2); 
        ssssumtemp = sum(ssstemp,2); 
        
        
        inds2 = ones(1,13); 
        inds2(ptempsum<1) = 0; 
        inds2(1) = 0; inds2(end) = 0; 

        wt = ptempsum./sum(ptempsum); 
        
        for nn = 1:length(mfac_test)
            ssssumtemp2 = ssssumtemp.*mfac_test(nn); 
            res = (ptempsum - ssssumtemp2).^2; 
            R = wt.*res; 
            R = R(inds2>0.5); 
            Rtemp = sum(R); 
            if nn == 1
                mmin = Rtemp; 
                mfac_ind = nn; 
            end
            if Rtemp < mmin
                mmin = Rtemp; 
                mfac_ind = nn;
            end
        end
        
        mfac_all(ii,jj) = mfac_test(mfac_ind); 
        if mfac_all(ii,jj) == mfac_test(1) || mfac_all(ii,jj) == mfac_test(end)
        	mfac_all(ii,jj) = 1.0; 
        end
        
        sss_sino(:,:,ii,jj) = sss_sino(:,:,ii,jj).*mfac_all(ii,jj); 
        sss_sino_tof(:,:,:,ii,jj) = sss_sino_tof(:,:,:,ii,jj).*mfac_all(ii,jj); 
        
        ssssumtemp2 = ssssumtemp.*mfac_test(mfac_ind);
        
    end
end
        

figure
imagesc(mfac_all); 

% sss_sino = sss_sino./de_sino; 
sf = sum(sss_sino(:))/sum(psino(:)); 

%fname_out = [fdir,'/sss_sino_tof_f',num2str(frame),'_scaled.raw']; 
fname_out = [fdir,'/sss_sino_tof_f',num2str(frame),'_scaled.raw']; 
fid22 = fopen(fname_out,'w'); 
fwrite(fid22,sss_sino_tof,'double'); 
fclose(fid22); 








