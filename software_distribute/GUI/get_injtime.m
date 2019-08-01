function inj_start = get_injtime(fdir_bin,lmfname1,scan_time)

rate_thr = 400000; 

lmfname = [fdir_bin,lmfname1];

logfname = [lmfname,'.*.log']; 
lst = dir(logfname);
ff = lst.name; 
ff = [fdir_bin,ff]; 

fid = fopen(ff,'r'); 
il = 1;
tline = fgetl(fid); 
A = tline; 

inj_start = 0; 
found_inj = false; 
str_find1 = 'Time Remaining = ';
str_find2 = 'Event Rate = ';
cur_time_str = num2str(scan_time); 
cur_time = scan_time; 
event_rate_str = '0'; 
event_rate = 0; 
while ~found_inj
	il = il+1; 
	tline = fgetl(fid); 
	if  scan_time - cur_time > 300
		disp('Could not find injection time')
        inj_start = 0; 
% 		scan_length_str = '0'; 
		break
	else
		ss1 = strfind(tline,str_find1);
        ss2 = strfind(tline,str_find2); 
		if ~isempty(ss1)
			ss1 = ss1+17; 
			cur_time_str = tline(ss1:end);
            cur_time = str2num(cur_time_str);
		end
        if ~isempty(ss2)
			ss2 = ss2+12; 
			event_rate_str = tline(ss2:end); 
            event_rate = str2num(event_rate_str);
            if event_rate > rate_thr
                inj_start = scan_time - cur_time - 10; 
                found_inj = true; 
            end
		end
        
	end
end		
if inj_start < 0
	inj_start = 0; 
end
fclose(fid);
