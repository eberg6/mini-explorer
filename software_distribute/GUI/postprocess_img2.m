function postprocess_img(fdir_bin,lmfname1,imgfname,os,it,frame)

Afac = 5.9866e4; % to convert from counts/second/voxel --> kBq / cc 

xx = strfind(fdir_bin,'/'); 
xx = xx(end); 
fdir = [fdir_bin(1:xx-1),'/']; 
fdir_bin = [fdir_bin,'/'];  
lmfname1 = [lmfname1,'.lm'];
imgfname = [imgfname,'.os.',num2str(os),'.it.',num2str(it)];


lm_infofname = [fdir_bin,'lm_info_f',num2str(frame)]; 

lmfname = [fdir,lmfname1]; 


lmfname_hdr = [lmfname,'.hdr']
fid = fopen(lmfname_hdr,'r'); 
A = fscanf(fid,'%s',inf); 


str_find = 'injection_time'; 
k = strfind(A,str_find); 
k = k+14; 
inj_time_str = A(k:k+19)
inj_time_str = inj_time_str(4:end); 
inj_time = datetime(inj_time_str,'InputFormat','MMMddHH:mm:ssyyyy')
inj_timevec = datevec(inj_time)

str_find = 'isotope_half_life'; 
m = strfind(A,str_find); 
m = m+17; 
strtemp = A(m:m+10); 
mm = strfind(strtemp,'#')-2; 
mend = mm+m; 
half_life = str2num(A(m:mend))

str_find = 'isotope_branching_fraction'; 
n = strfind(A,str_find);
n = n+26; 
strtemp = A(n:n+10);
nn = strfind(strtemp,'#') - 2; 
nend = nn+n; 
branching_ratio = str2num(A(n:nend))

str_find = 'Injected dose (float)';
p = strfind(A,str_find); 
p = p+26; 
strtemp = A(p:p+6); 
pp = strfind(strtemp,'#') - 2;
pend = pp+p;
%dose = str2num(A(p:pend)); 
dose = A(p:pend)

%dose_str = ['Dose = ',num2str(dose),' mCi']; 



logfname = [lmfname,'.*.log']; 
lst = dir(logfname);
ff = lst.name;
ff = erase(ff,lmfname1);
ff = erase(ff,'.');
scan_start_str = erase(ff,'log');
scan_start_str = scan_start_str(4:end)

scan_start = datetime(scan_start_str,'InputFormat','ddMMMyyyy_HHmmss')
scan_startvec = datevec(scan_start);

time_elapse = etime(scan_startvec,inj_timevec)



 
fid1 = fopen(lm_infofname,'r'); 

il = 1;
tline = fgetl(fid1); 
B{il} = tline; 
while ischar(tline)
	il = il+1; 
	tline = fgetl(fid1); 
	B{il} = tline;
end
fclose(fid1);

%ii = fscanf(fid1,'%s',inf); 

strtemp = B{1}; 
str_find = 'frame_start='; 
frame_start_str = erase(strtemp,str_find); 
frame_start = str2num(frame_start_str)

strtemp = B{2}; 
str_find = 'frame_length=';
frame_length_str = erase(strtemp,str_find); 
frame_length = str2num(frame_length_str)

%str_find = 'frame_start='; 
%ss = strfind(ii,str_find); 
%strtemp = ii(ss:end)
%frame_start_str = erase(strtemp,str_find);
%frame_start_str = erase(frame_start_str,'='); 
%frame_start = str2num(frame_start_str)

%strtemp = ii(1:ss-1); 
%str_find = 'frame_length='; 
%frame_length_str = erase(strtemp,str_find); 
%frame_length = str2num(frame_length_str)



t1 = time_elapse+frame_start; 
t2 = t1+frame_length; 

decay_factor = (exp(t1*log(2)/half_life) * (log(2)/half_life) * (t2-t1)) / (1-exp(-(log(2)/half_life)*(t2-t1)))
frame_length_factor = 1/frame_length; 
branching_factor = 1/branching_ratio;  

B{3} = ['time_elapse=',num2str(time_elapse)];
B{4} = ['decay_factor=',num2str(decay_factor)];

fid11 = fopen(lm_infofname,'w'); 
 
for tt = 1:numel(B)
	if B{tt+1} == -1
		fprintf(fid11,'%s',B{tt});
		break
	else
		fprintf(fid11,'%s\n',B{tt});
	end
end
fclose(fid11)


%fseek(fid1,0,'bof');

%strtemp1 = ['frame_start=',frame_start_str]; 
%strtemp2 = ['frame_length=',frame_length_str];
%strtemp3 = ['time_elapse=',num2str(time_elapse)]; 
%strtemp4 = ['decay_factor=',num2str(decay_factor)];

% fseek(fid1,0,'eof'); 
% strtemp1 = ['time_elapse = ',num2str(time_elapse)]; 
% strtemp2 = ['decay_factor = ',num2str(decay_factor)];
%fprintf(fid11,'%s\n',strtemp1);
%fprintf(fid11,'%s\n',strtemp2);
%fprintf(fid11,'%s\n',strtemp3);
%fprintf(fid11,'%s',strtemp4); 


imgfname
fid2 = fopen(imgfname,'r'); 
img = fread(fid2,inf,'float'); 

num_slices = 445; 
num_vox = length(img)/num_slices; 
num_vox = round(sqrt(num_vox));

if (num_vox*num_vox*num_slices ~= length(img))
	disp('image size invalid'); 
end 

img = reshape(img,num_vox,num_vox,num_slices); 

% delete outside rows of image
img(:,:,1:6) = 0; 
img(:,:,(end-5):end) = 0; 
img(1:6,:,:) = 0; 
img((end-5):end,:,:) = 0; 
img(:,1:6,:) = 0; 
img(:,(end-5):end,:) = 0; 




img = img.*decay_factor.*frame_length_factor*branching_factor*Afac;

img(img<0.0) = 0.0; 


fclose(fid2);  


imgfnameout = [imgfname,'.cor.raw']; 
fid3 = fopen(imgfnameout,'w'); 
fwrite(fid3,img,'float'); 

fclose(fid3); 


fclose(fid); 
fclose(fid1);







