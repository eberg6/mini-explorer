%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Normalization for mini-EXPLORER
% Xuezhu Zhang
% Qi Lab
% 2016-2017
% 

function iternorm(fdir1,fdir2)

% fdir = '/run/media/meduser/data/software_distribute/normalization_data/2017-05-15/bin/';

numrad = 157;
numang = 156;
numxtal = 312;
numring = 104;
numring_wgap = 111;
numring_wgap2 = 112;
numblockring = 8;
numarray = 13;
num_iteration = 10;


% crystal pair
xp = double(fread(fopen('/run/media/meduser/data/software_distribute/miniEXPLORER/idx/index_crystalpairs_transaxial_2x157x156_int16.raw', 'rb'), inf, 'int16'));
xp = reshape(xp, 2, numrad*numang);

% crystal label
dl1 = zeros(numrad, numang, numxtal);
dl2 = dl1;

for detector=1:numxtal
    l1 = xp(1,:)==detector;   
    l2 = xp(2,:)==detector;
    dl1(:,:,detector) = reshape(l1>0, numrad, numang);
    dl2(:,:,detector) = reshape(l2>0, numrad, numang);
end

fname = [fdir1,'/sinogram3D_f0_prompts.raw']; 
m0 = fread(fopen(fname, 'rb'), inf, 'float');
m0 = reshape(m0, numrad, numang, numring_wgap, numring_wgap); 

fprj0 = fread(fopen('/run/media/meduser/data/software_distribute/normalization/fbprj_gap0_157x156x112x112-float.raw', 'rb'), inf, 'float');
fprj0 = reshape(fprj0, numrad, numang, numring_wgap2, numring_wgap2);   


m = zeros(numrad, numang, numring, numring);
fprj = zeros(numrad, numang, numring, numring);

for nbr1 = 1:numblockring
    for nbr2 = 1:numblockring
        for nax1 = 1:numarray
            for nax2 = 1:numarray
                nr1_wogap = (nbr1-1)*numarray + nax1;
                nr2_wogap = (nbr2-1)*numarray + nax2;
                nr1_wgap = (nbr1-1)*(numarray+1) + nax1;
                nr2_wgap = (nbr2-1)*(numarray+1) + nax2;
                m(:,:, nr1_wogap, nr2_wogap) = m0(:,:, nr1_wgap, nr2_wgap);
                fprj(:,:, nr1_wogap, nr2_wogap) = fprj0(:,:, nr1_wgap, nr2_wgap);
            end
        end
    end
end


g = ones(size(fprj));       
g_new = ones(size(fprj));    
de_s = ones(numxtal, numring);    
de_s_old = ones(numxtal, numring);    
s = fprj / mean(fprj(:)) * mean(m(:)); 



for iter = 1:num_iteration
    
    iter

    sg = s .* g;      
    de_s_old = de_s;    
    counting = 0;
    a = randperm(numxtal);

    for detector = a  %  1:numxtal   

        counting = counting + 1;
        fprintf('detector#%d, counting#%d\n', detector, counting);
        % fprintf('detector#%d\n', detector);

        l1 = dl1(:, :, detector)>0;     
        l2 = dl2(:, :, detector)>0;

        de1 = xp(2, l1);               
        de2 = xp(1, l2); 
        
        
        for r1=1:numring
                
            if isempty(de1)
                m2=squeeze(m(:,:,:,r1));    m2= reshape(m2, numrad*numang, numring);
                g2=squeeze(sg(:,:,:,r1));   g2= reshape(g2, numrad*numang, numring);  
                nutor=[m2(l2,:,:)];
                detor=[g2(l2,:,:) .* de_s(de2,:,:)];

            elseif isempty(de2)
                m1=squeeze(m(:,:,r1,:));    m1= reshape(m1, numrad*numang, numring);
                g1=squeeze(sg(:,:,r1,:));   g1= reshape(g1, numrad*numang, numring);  
                nutor=[m1(l1,:,:)];
                detor=[g1(l1,:,:) .* de_s(de1,:,:)];

            else
                m1=squeeze(m(:,:,r1,:));    m1= reshape(m1, numrad*numang, numring);
                g1=squeeze(sg(:,:,r1,:));   g1= reshape(g1, numrad*numang, numring);
                
                m2=squeeze(m(:,:,:,r1));    m2= reshape(m2, numrad*numang, numring);
                g2=squeeze(sg(:,:,:,r1));   g2= reshape(g2, numrad*numang, numring); 
                
                nutor = [m1(l1,:,:); m2(l2,:,:)];
                detor = [g1(l1,:,:) .* de_s(de1,:,:); g2(l2,:,:) .* de_s(de2,:,:)];
                
            end
            
            if ( isnan(sum(detor(:))) )
                error('error!');
            end

            de_s(detector, r1) = sum(nutor(:)) / sum(detor(:));
                   
        end
    end
    
            
    % sinogram formed by detector efficiency
    
    de_sino=zeros(numrad*numang, numring, numring);

    for i=1:numring
        for j=1:numring
            de_sino(:,i,j) = de_s(xp(1,:),i) .* de_s(xp(2,:),j);
        end
    end
    
    file_name_de = [fdir2,'/de.raw']; 
	fidde = fopen(file_name_de,'w'); 
	fwrite(fidde,de_s,'float'); 
	fclose(fidde); 


% convert_desino(de_sino,fdir2); 
        

    de_sino = reshape(de_sino, numrad, numang, numring, numring);
    de_sinos = de_sino .* s;
    
    

    % geometric profile

    de_sino_symm = zeros(numrad, numarray, numring, numring);
    m_symm = zeros(size(de_sino_symm));
    
    for i=1:numarray-1
        de_sino_symm = de_sino_symm + de_sinos(:,((i-1)*numarray+1):(i*numarray),:,:);
        m_symm = m_symm + m(:,((i-1)*numarray+1):(i*numarray),:,:);
    end
        
    g_temp = m_symm ./ de_sino_symm;    
    g_temp(isnan(g_temp))=0;    
    g_temp(isinf(g_temp))=0;

    for i=1:numarray-1
        g_new(:,((i-1)*numarray+1):(i*numarray),:,:)=g_temp;
    end
    
    g = g_new;      

    ynorm = de_sino .* g;
    file_name = strcat('ynorm_iterno', num2str(iter), '-float.raw');
    % fwrite(fopen(file_name, 'w'), ynorm, 'single');
    fclose('all')

    
end

file_name_de = [fdir2,'/de.raw']; 
fidde = fopen(file_name_de,'w'); 
fwrite(fidde,de_s,'float'); 
fclose(fidde); 


% convert_desino(de_sino,fdir2); 
  




ynorm_wgap = zeros(numrad, numang, numring_wgap, numring_wgap, 'single');

for nbr1 = 1:numblockring
    for nbr2 = 1:numblockring
        for nax1 = 1:numarray
            for nax2 = 1:numarray
                nr1_wogap = (nbr1-1)*numarray + nax1;
                nr2_wogap = (nbr2-1)*numarray + nax2;
                nr1_wgap = (nbr1-1)*(numarray+1) + nax1;
                nr2_wgap = (nbr2-1)*(numarray+1) + nax2;
                ynorm_wgap(:,:, nr1_wgap, nr2_wgap) = ynorm(:,:, nr1_wogap, nr2_wogap);
            end
        end
    end
end

for nr1 = 1:(numblockring-1)
    for nr2 = 1:(numblockring-1)
        ynorm_wgap(:,:, :, (numarray+1)*nr2) = 0;
        ynorm_wgap(:,:, (numarray+1)*nr1, :) = 0;
    end
end

% file_name = strcat('ynorm_wgap0_', num2str(iter), '_157x156x111x111-float.raw');
file_name = [fdir2,'ynorm_wgap0_',num2str(iter),'_157x156x111x111-float.raw'];
fwrite(fopen(file_name, 'w'), ynorm_wgap, 'single');
fclose('all')

convert_normsino(ynorm_wgap,fdir2); % writes norm files for all radial bins

clear ynorm_wgap


