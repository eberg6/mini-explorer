function make_bp_run_sh(fdir,numrad)




fname_sh = '/run/media/meduser/data/software_distribute/reconstruction/lm_recon/run_bp.sh';

fid = fopen(fname_sh,'w');

str = 'export OMP_NUM_THREADS=31\n\n';

fprintf(fid,str);

str = '';

str = ['/run/media/meduser/data/software_distribute/reconstruction/lm_recon/bp_lm_nontof   /run/media/meduser/data/software_distribute/reconstruction/lm_recon/lmacc_scanner_parameter_',num2str(numrad),'_bp.cfg   /run/media/meduser/data/software_distribute/miniEXPLORER/idx/lmdata_nontof_idxlor_',num2str(numrad),'x156x111x111_5xint16.raw   ',fdir,'ynorm_wgap0_10_',num2str(numrad),'x156x111x111-float.raw'];

fprintf(fid,str);

str = '';


fclose(fid);



