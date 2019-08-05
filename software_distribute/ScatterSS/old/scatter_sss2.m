function scatter_sss2(fdir,ct_path,frame)

% ff1 = 'c:/Documents/Primate scanner/scatter_test/monkey/sinogramblock_f0.raw';
% ff2 = 'c:/Documents/Primate scanner/scatter_test/monkey/sss_sino.raw';
% ff3 = 'c:/Documents/Primate scanner/scatter_test/monkey/de_sino.raw'; 
% ff4 = 'c:/Documents/Primate scanner/scatter_test/monkey/attn_blocksino.raw'; 


ff1 = [fdir,'/sinogramblock_f',num2str(frame),'.raw']; 
ff2 = [fdir,'/sss_sino_f',num2str(frame),'.raw']; 
ff3 = [ct_path,'/de_sino.raw']; 
ff4 = [ct_path,'/attn_blocksino.raw']; 


%ff1 = 'c:/Documents/Primate scanner/scatter/scatter_test/monkey3/sinogramblock_f0.raw';
%ff2 = 'c:/Documents/Primate scanner/scatter/scatter_test/monkey3/sss_sino.raw';
%ff3 = 'c:/Documents/Primate scanner/scatter/scatter_test/monkey3/de_sino.raw'; 
%ff4 = 'c:/Documents/Primate scanner/scatter/scatter_test/monkey3/attn_blocksino2.raw'; 
%

psino = fread(fopen(ff1,'r'),inf,'double'); 
sss_sino = fread(fopen(ff2,'r'),inf,'double');

de_sino = fread(fopen(ff3,'r'),inf,'double'); 
attn_sino = fread(fopen(ff4,'r'),inf,'double'); 

sum(attn_sino(:))

psino = reshape(psino,[13,12,8,8]); 
sss_sino = reshape(sss_sino,[13,12,8,8]); 
de_sino = reshape(de_sino,[13,12,8,8]); 
attn_sino = reshape(attn_sino,[13,12,8,8]); 

sss_sino = sss_sino.*de_sino;




figure
imagesc(psino(:,:,4,4));
pause




figure
imagesc(attn_sino(:,:,4,4));
pause


attn_test = attn_sino(12,6,4,4); 
if attn_test < 0.9
    disp('Attenuation image out of range'); 
end


attn_thr = 0.85; 
inds = ones(size(psino)); 
inds(attn_sino<attn_thr) = 0; 
inds(psino<1) = 0; 

% psino2 = psino; 
% sss_sino2 = sss_sino; 



psum = sum(psino(:))
sss_est = psum*.25; 
sss_sum = sum(sss_sino(:)); 
mfac_init = sss_est/sss_sum

% mfac = 3.5e11; 

sss_sino = sss_sino.*(mfac_init); 

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
        
        sss_sino(:,:,ii,jj) = sss_sino(:,:,ii,jj).*mfac_all(ii,jj); 
        
        ssssumtemp2 = ssssumtemp.*mfac_test(mfac_ind);
%         figure
%         hold on
%         plot(ptempsum,'b');
%         plot(ssssumtemp2,'r');
%         hold off
%         pause
%         
%         mmmm = mfac_test(mfac_ind)

        
        
    end
end
        


% sss_sino = sss_sino./de_sino; 
sf = sum(sss_sino(:))/sum(psino(:))

sss_sinotemp = sss_sino(:,:,4,4); 

sss_sinotemp2 = interp2(sss_sinotemp,4); 

figure
imagesc(sss_sinotemp2);

size(sss_sinotemp2)


figure
imagesc(mfac_all); 







