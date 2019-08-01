function run_recon_local(fdir_local,petimgpath,sf,ef)

% change permissions on sh
cmd_server = ['chmod +x ',fdir_local,'/run_sh/*.sh; '];
system(cmd_server); 


% need to change to screen
cmd_server = [fdir_local,'/run_sh/run_recon.sh; ']; 
system(cmd_server); 





























%cmd_server = ['ssh -t eberg@',server_name,' screen -d -m ',fdir_remote,'/run_sh/run_recon.sh; ']; 

%system(cmd_server); 




%cmd_server = ['ssh -t eberg@',server_name,' sudo chmod +x ',fdir_remote,'/run_sh/*.sh'];

%system(cmd_server); 

%cmd_server = ['ssh -t eberg@',server_name,' sudo chown eberg:eberg ',fdir_remote]; 

%system(cmd_server); 

%cmd_server = ['ssh -t eberg@',server_name,' sudo ',fdir_remote,'/run_sh/run_recon.sh']; 

%system(cmd_server); 
