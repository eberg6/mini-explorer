function run_recon_server_it2(fdir_remote,server_name,petimgpath,sf,ef)

% change permissions on sh
cmd_server = ['ssh -t eberg@',server_name,' chmod +x ',fdir_remote,'/run_sh/*.sh; '];
system(cmd_server); 


% need to change to screen
cmd_server = ['ssh -t eberg@',server_name,'  ',fdir_remote,'/run_sh/run_recon.sh; ']; 
%system(cmd_server); 

% send signal that recon is done



% rename images
% rename 2nd iteration tof.temp.out.1 to tof.temp.out.2
%rename_images(petimgpath,server_name,sf,ef,2); 
%fname_move = 'sh ./rename_imgs.sh'; 
%system(fname_move); 

% rename 2nd iteration images to .2 extension
%rename_images(petimgpath,server_name,sf,ef,3); 
%fname_move = 'sh ./rename_imgs.sh'; 
%system(fname_move); 























%cmd_server = ['ssh -t eberg@',server_name,' screen -d -m ',fdir_remote,'/run_sh/run_recon.sh; ']; 

%system(cmd_server); 




%cmd_server = ['ssh -t eberg@',server_name,' sudo chmod +x ',fdir_remote,'/run_sh/*.sh'];

%system(cmd_server); 

%cmd_server = ['ssh -t eberg@',server_name,' sudo chown eberg:eberg ',fdir_remote]; 

%system(cmd_server); 

%cmd_server = ['ssh -t eberg@',server_name,' sudo ',fdir_remote,'/run_sh/run_recon.sh']; 

%system(cmd_server); 
