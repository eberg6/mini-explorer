function rename_images(petimgpath,server_name,start_frame,end_frame,opt)

fname_sh = ['./rename_imgs.sh']; 
fid = fopen(fname_sh,'w');

if strcmp(server_name,'Local') > 0.5
    str = ''; 
else
    str = ['ssh -t eberg@',server_name,' "']; 
end
fprintf(fid,str); 
str = ''; 


for N = start_frame:end_frame

	if opt == 1
		str = [' mv ',petimgpath{N+1},'.oslmem.tof.temp.out.1  ',petimgpath{N+1},'.oslmem.tof.temp.out.0; '];
	end
	if opt == 2
	    str = [' mv ',petimgpath{N+1},'.oslmem.tof.temp.out.1  ',petimgpath{N+1},'.oslmem.tof.temp.out.2; '];
	end
	if opt == 3
		str = [' mv ',petimgpath{N+1},'.os.20.it.1  ',petimgpath{N+1},'.os.20.it.2; '];
	end
	if opt == 4
		str = [' rm ',petimgpath{N+1},'.os.20.it.1; '];
	end
	
	fprintf(fid,str); 
	str = ''; 
	
end

if strcmp(server_name,'Local') > 0.5
    str = '';
else	
	str = ' "';
end 

 
fprintf(fid,str); 
fclose(fid); 



	
