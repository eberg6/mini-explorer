function norm_date = get_normdate(fdir_bin,lmfname1,norm_folder)



lmfname = [fdir_bin,lmfname1];

logfname = [lmfname,'.*.log']; 
lst = dir(logfname);
ff = lst.name; 


ff = erase(ff,lmfname1);
ff = erase(ff,'.');
scan_start_str = erase(ff,'log');
scan_start_str = scan_start_str(4:end);

scan_start = datetime(scan_start_str,'InputFormat','ddMMMyyyy_HHmmss');
scan_startvec = datevec(scan_start); 

lstnorm1 = ls(norm_folder);

ff = strfind(lstnorm1,'20');
for ii = 1:length(ff)
	lstnorm{ii} = lstnorm1(ff(ii):ff(ii)+9);
	
end

i = 1; 
for k = 1:numel(lstnorm)
    b = lstnorm{k};
    %if length(b) > 2 && b(1:2) == '20'
        norm_all{i} = b;
        normyear = str2num(b(1:4));
        normmonth = str2num(b(6:7));
        normday = str2num(b(9:10));
        norm_date_ss = datetime(normyear,normmonth,normday,0,0,0);
        norm_date_vec = datevec(norm_date_ss); 
        t_elapse(i) = etime(scan_startvec,norm_date_vec);
        i = i+1; 
    %end
end

t_elapse(t_elapse<0) = inf; 

[m,ind] = min(t_elapse);
norm_date = norm_all{ind};

 
