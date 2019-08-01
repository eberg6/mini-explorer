function run_process_lm_sino_server(fdir_remote, server_name)

%cmd_server = ['ssh -t eberg@',server_name,' "sudo chown eberg ',fdir_remote,'; /home/eberg/process_lm_sino/process_lm_sino"']; 

cmd_server = ['ssh -t eberg@',server_name,' "/home/eberg/process_lm_sino/process_lm_sino"'];

system(cmd_server); 

