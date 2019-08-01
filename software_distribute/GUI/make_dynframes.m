function f_dyn = make_dynframes(scan_time)

len1 = 10*60; 
len2 = 30*60; 
f_dyn = ['30,2,24,5,21,20']; 

numframe_1min = floor((scan_time-len1)/60); 
nf1 = num2str(numframe_1min); 

if numframe_1min > 20
	numframe_1min = 20; 
	nf1 = num2str(numframe_1min); 
end
if numframe_1min > 0.5
	f_dyn = [f_dyn,',',nf1,',60']; 
end

if numframe_1min > 19
	
	numframe_2min = floor((scan_time-len2)/120); 
	nf2 = num2str(numframe_2min);

	if numframe_2min > 0.5

    	f_dyn = [f_dyn,',',nf2,',120'];
	end
end
