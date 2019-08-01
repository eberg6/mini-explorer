function ct_folder = get_ctfolder(fdir_bin)

% str_find = 'CT'; 
% CTnamefind = [fdir_bin,'*CT*']; 
ct_folder = '0'; 

ff = ls(fdir_bin);

deli = {'\t','    ','   ','  '}; 

newstr = splitlines(ff);
count = 1; 
for iii = 1:size(newstr,1)
	newstr2 = newstr(iii,:);
	newstr2 = newstr2{1};
	newstr2 = erase(newstr2,'''');
	if length(newstr2) > 1
	newstr3 = strsplit(newstr2,deli);  
	for iiii = 1:numel(newstr3)
		%newstr3{iiii}
		A{count} = newstr3{iiii};
		count = count+1; 
	end
	end
end


%while 
	%str_temp = ff(cc:(cc+1)); 
	%if contains(str_temp,'20'); 
	%A{iii} = ff(cc:cc+9)
		%cc = cc + 9; 
		%iii = iii + 1; 	
	%else
		%cc = cc+1; 
	%end
%end


for k = 1:numel(A)
    strtemp = A{k};
%     ii = strfind(stretemp,'CT');
    if contains(strtemp,'_CT')
        dirtemp = [fdir_bin,strtemp,'/'];
        %dirtemp = strjoin(dirtemp) 
        inds = strfind(dirtemp,'/');
        inds = inds(1:(end-1)); 
        for kk = 1:length(inds)
        	st1 = dirtemp(inds(kk)+1); 
        	if contains(st1,' ')
        		dirtemp = [dirtemp(1:inds(kk)),dirtemp((inds(kk)+2):end)];
        		inds((kk+1):end) = inds((kk+1):end) - 1; 
        	end
        end
        dcm_f1 = [dirtemp,'Z10'];
        %dcm_f1 = strjoin(dcm_f1,'\0')
        dirtemp2 = [dirtemp,'A/'];
        dcm_f2 = [dirtemp2,'Z10'];
        %dcm_f2 = strjoin(dcm_f2,'\0')
        if exist(dcm_f1,'file') || exist(dcm_f2,'file')
            disp('Found CT folder'); 
            ct_folder = strtemp;
        end
        
    end
end

% remove extra white spaces in CT folder name
chr_start = ct_folder(1); 
while contains(chr_start,' '); 
	ct_folder = ct_folder(2:end);
	chr_start = ct_folder(1); 
end
        

chr_end = ct_folder(end);
while contains(chr_end,' ');
    ct_folder = ct_folder(1:end-1);
    chr_end = ct_folder(end); 
end

