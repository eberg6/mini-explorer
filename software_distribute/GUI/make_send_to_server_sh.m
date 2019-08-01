function make_send_to_server_sh(fdir_local,fdir_remote,server_name,frames,file_choice)

% file_choice = 1: this is sending the Reconstruction_Parameters_1 text file to run the listmode decoding
% file_choice = 2: this is sending the lmacc_config and .sh scripts to the server to run reconstruction

fname_sh = './send_to_server.sh';


fid = fopen(fname_sh,'w');


str = '';

%for k = frames(1):frames(end)
for k = 1:1

if ~isempty(find(file_choice == 1))

	str = ['scp -P 8300 ../process_lm_sino/Reconstruction_Parameters_1 eberg@',server_name,':~/process_lm_sino','\n\n']; 
	
	fprintf(fid,str); 
end

% send lmacc config files and run_recon.sh files
if ~isempty(find(file_choice == 2))
	str = ['scp -P 8300 -r ',fdir_local,'/lmacc_config ',fdir_local,'/run_sh  eberg@',server_name,':',fdir_remote,'\n\n']; 
	fprintf(fid,str); 
end

% SSS scaled sinos
if ~isempty(find(file_choice == 3))
	str = ['scp -P 8300 ',fdir_local,'/sss_sino_tof_f*_scaled.raw  eberg@',server_name,':',fdir_remote,'\n\n']; 
	fprintf(fid,str); 
end

% Get images from server iter 1
if ~isempty(find(file_choice == 4))
	str = ['scp -P 8300 eberg@',server_name,':',fdir_remote,'/lmrecon_*_frame*.temp.out.0 ',fdir_local,'\n\n']; 
	fprintf(fid,str); 
end

% get sinos from server
if ~isempty(find(file_choice == 5))
	str = ['scp -P 8300 eberg@',server_name,':',fdir_remote,'/sinogramblock*.raw ',fdir_local,'\n\n'];
	fprintf(fid,str); 
end

%if ~isempty(find(file_choice == 5))
	%str = ['scp -P 8300 eberg@',server_name,':',fdir_remote,'/sinogramblock_f',num2str(k),'_tof.raw ',fdir_local,'\n\n'];
%	fprintf(fid,str); 
%end

if ~isempty(find(file_choice == 6))
	str = ['scp -P 8300 -r ',fdir_local,'/run_sss  eberg@',server_name,':',fdir_remote,'\n\n']; 
	fprintf(fid,str); 
end

if ~isempty(find(file_choice == 7))
	str = ['scp -P 8300 eberg@',server_name,':',fdir_remote,'/lmrecon_*_frame*.os.*.it.2  ',fdir_local,'\n\n']; 
	fprintf(fid,str); 
end


if ~isempty(find(file_choice == 7))
	str = ['scp -P 8300 eberg@',server_name,':',fdir_remote,'/lm_info_f*  ',fdir_local,'\n\n']; 
	fprintf(fid,str); 
end

end
%fprintf(fid,str); 

str = ''; 

fclose(fid); 

