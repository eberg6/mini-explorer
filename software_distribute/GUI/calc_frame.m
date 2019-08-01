function tot_length = calc_frame(frames_dynamic)

frames_dyn_str = get(frames_dynamic,'String'); 
frames_dyn_str = [frames_dyn_str]; 

frame_vec = str2num(frames_dyn_str);
if mod(length(frame_vec),2) ~= 0
	frame_vec = frame_vec(1:(end-1)); 
end


tot_length = 0; 
for i = 1:2:(length(frame_vec)-1)
	num_f = frame_vec(i); 
	f_len = frame_vec(i+1); 
	len_temp = num_f * f_len; 
	tot_length = tot_length + len_temp; 
	len_temp = 0; 
end


	
