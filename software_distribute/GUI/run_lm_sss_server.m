function run_lm_sss_server(fdir_remote)

%cmd_server = ['ssh -t explorer-r740-00q sudo chmod -R +x ',fdir_remote,'/run_sss'];

%system(cmd_server); 

%cmd_server = ['ssh -t explorer-r740-00q sudo ',fdir_remote,'/run_sss/run_lmsss.sh']; 
cmd_server = ['sh -t ',fdir_remote,'/run_sss/run_lmsss.sh']; 

system(cmd_server); 
