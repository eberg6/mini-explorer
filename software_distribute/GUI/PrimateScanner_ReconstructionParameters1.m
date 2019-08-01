function varargout = PrimateScanner_ReconstructionParameters1(varargin)
% Last Modified by GUIDE v2.5 07-May-2019 14:31:46
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PrimateScanner_ReconstructionParameters1_OpeningFcn, ...
                   'gui_OutputFcn',  @PrimateScanner_ReconstructionParameters1_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT



% --- Executes just before PrimateScanner_ReconstructionParameters1 is made visible.
function PrimateScanner_ReconstructionParameters1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no plzwork args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PrimateScanner_ReconstructionParameters1 (see VARARGIN)


% Choose default command line plzwork for PrimateScanner_ReconstructionParameters1
handles.plzwork = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PrimateScanner_ReconstructionParameters1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);



% --- Outputs from this function are returned to the command line.
function varargout = PrimateScanner_ReconstructionParameters1_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.plzwork;

set(handles.choose_text, 'enable', 'off');
set(handles.norm_text, 'enable', 'off');
set(handles.ct_text, 'enable', 'off');
set(handles.choose_text, 'String', '');
set(handles.norm_text, 'String', '');
set(handles.ct_text, 'String', '');
reset = '0';
handles.pathname_filename = reset;
handles.pathname_choose = reset;
handles.pathname_norm = reset;
handles.pathname_ct = reset;

set(handles.text_dynamicframes, 'enable', 'on');
set(handles.frames_dynamic, 'enable', 'on');
set(handles.frames_dynamic, 'String', '');
set(handles.ScanLength, 'enable','off'); 
set(handles.ScanLength, 'String', ''); 
set(handles.TotalFrameLength, 'enable', 'on'); 
set(handles.TotalFrameLength, 'String', ''); 
set(handles.save_output, 'enable', 'on');
set(handles.save_output, 'String', '');
set(handles.save_output_txt, 'enable', 'on');
set(handles.start2, 'enable', 'on');
set(handles.outcome, 'enable', 'off');
set(handles.sframe, 'enable', 'on');
set(handles.eframe, 'enable', 'on');
set(handles.sframe_txt, 'enable', 'on');
set(handles.eframe_txt, 'enable', 'on');
set(handles.start4, 'enable', 'on');
set(handles.save_output, 'String', '');
set(handles.outcome2, 'enable', 'off');
set(handles.dose,'String','0'); 
set(handles.injection_time_edit,'String',''); 

set(handles.radiobutton19, 'Value', 1); 
set(handles.radiobutton20, 'Value', 0); 


function choose_Callback(hObject, eventdata, handles)
% if get(handles.study, 'Value') == 2
%     set(handles.start4, 'enable', 'off');
% end

[filename folder] = uigetfile({... % select file
   '*.lm', '.lm Files';...
   '*.*', 'All Files (*.*)';...   
   '*.txt', 'Text Files(*.txt)'},...
   'Select the Primate Scanner Image Dataset',...
   '../Users/');


set(handles.server_recon,'enable','on'); 
guidata(hObject, handles);

pathname_choose = fullfile(folder, filename);
set(handles.choose_text, 'String', filename);
handles.pathname_choose = pathname_choose;

if isequal(filename,0) == 1
    pathname_choose = '0';
    set(handles.choose_text, 'String', 'Error!')
end

handles.pathname_filename = filename; % .lm filename
handles.pathstr1 = folder; % .lm folder filepath
handles.pathname_choose = pathname_choose; % .lm filepath

scan_time = get_scantime(handles.pathstr1,handles.pathname_filename); 

f_dynamic_str = ['1,',num2str(scan_time)]; 
set(handles.frames_dynamic,'String',f_dynamic_str); 
set(handles.ScanLength, 'String',num2str(scan_time)); 
set(handles.TotalFrameLength, 'String', num2str(scan_time)); 

% guess for norm path
norm_date = get_normdate(handles.pathstr1,handles.pathname_filename,'../normalization_data/'); 
norm_path = ['../normalization_data/',norm_date];
handles.pathname_norm = norm_path; 
set(handles.norm_text,'String',norm_date); 

% guess for CT image
ct_folder = get_ctfolder(handles.pathstr1);
set(handles.ct_text,'String',ct_folder); 
ct_folder = [handles.pathstr1,ct_folder];
%ct_folder = strjoin(ct_folder); 
handles.pathname_ct = ct_folder;

% get injected dose
disp('Check injected dose is correct');
dose1 = check_dose(handles.pathstr1,handles.pathname_filename);
set(handles.dose,'String',num2str(dose1));

% get injected time
disp('Check injection time is correct:'); 
injection_time = check_injtime(handles.pathstr1,handles.pathname_filename); 
set(handles.injection_time_edit, 'String', injection_time); 

set(handles.server_recon,'enable','on'); 



guidata(hObject, handles);



% --- Executes on button press in norm.
function norm_Callback(hObject, eventdata, handles)

pathname_norm = uigetdir('../normalization_data/', 'Select Normalization Folder'); 
pathname_norm_text = erase(pathname_norm,'/run/media/meduser/data/software_distribute/normalization_data/'); 
% /run/media/meduser/data/software_distribute/reconstruction/normalization
set(handles.norm_text, 'String', pathname_norm_text);
handles.pathname_norm = pathname_norm;

if isequal(pathname_norm,0) == 1
    pathname_norm = '0';
    set(handles.norm_text, 'String', 'Error!')
end

handles.pathname_norm = pathname_norm; % norm filepath
guidata(hObject, handles);



% --- Executes on button press in ct.
function ct_Callback(hObject, eventdata, handles)

pathname_ct = uigetdir(handles.pathstr1, 'Select CT Image Folder');
pathname_ct_text = erase(pathname_ct,handles.pathstr1); 
set(handles.ct_text, 'String', pathname_ct_text);
handles.pathname_ct = pathname_ct;

if isequal(pathname_ct,0) == 1
    pathname_ct = '0';
    set(handles.ct_text, 'String', '0');
end

handles.pathname_ct = pathname_ct; % ct filepath
guidata(hObject, handles);



% --- Executes on button press in start2.
function start2_Callback(hObject, eventdata, handles)

%% values for .txt file


guidata(hObject, handles); 

% get the name of the chosen server. 
qlist_server = get(handles.server_recon,'String'); 
q_server = get(handles.server_recon,'Value'); 
server_name = qlist_server{q_server}; 

% set the server
set(handles.server_recon,'enable','off'); 
guidata(hObject, handles); 



frames_dynamic = get(handles.frames_dynamic, 'String');
save_output = get(handles.save_output, 'String');

%% error messages

filename = 'Reconstruction_Parameters_1';
save_as = fullfile('../process_lm_sino/', filename); 
    
valid_frames_dynamic = all(ismember(frames_dynamic, ', . 1234567890'));

if isfield(handles, 'pathname_choose') == 0 ||...
   strcmp(handles.pathname_choose, '0') == 1
    errordlg('No .lm file selected', 'Error');
    a = 3;
elseif isfield(handles, 'pathname_norm') == 0 ||...
    strcmp(handles.pathname_norm, '0') == 1
    errordlg('No Normalization Folder Selected', 'Error');
    a = 3; 
elseif isempty(frames_dynamic) == 1
    errordlg('Enter dynamic frames information','Error');
    a = 3;
elseif valid_frames_dynamic == 0
    errordlg('Framing must only contain numeric values, spaces, and commas', 'Error');
    a = 3;
elseif isempty(save_output) == 1
    errordlg('Enter Name for Histogramming Output Folder', 'Error');
    a = 3;
elseif isfield(handles, 'save_output')
    mkdir(handles.pathstr1, save_output);
    mkdir1 = fullfile(handles.pathstr1, save_output);
end

%% execute file

% these override the default values
fov = '3';
static_dynamic = '1';
write_lm = '1';
write_sino = '0';
dtcor = '0';
rando = '0';
atcor = '0';
scatcor = '0';
tof_on = '1'; 
scout = '1'; 
calib = 0; 
 

lmfname1 = handles.pathname_filename; 
lmfname = erase(lmfname1,'.lm'); 

mkdir2 = [handles.pathstr1,'scout/']; 

if (fov=='1')
    numrad = 77;
elseif (fov == '2')
    numrad = 129;
elseif (fov == '3')
    numrad = 157;
else
    numrad = 129; 
end

strct = handles.pathname_ct; 
indstr = find(strct=='/',1,'last'); 
strct = strct(indstr+1:end); 
if strct == '0'
	handles.pathname_ct = '0'; 
end


if (isfield(handles, 'pathname_choose') == 1) &&...
   (strcmp(handles.pathname_choose, '0') == 0) &&...
   (isfield(handles, 'pathname_norm') == 1) &&...
   (strcmp(handles.pathname_norm, '0') == 0) &&...
   (isfield(handles, 'pathname_ct') == 1) &&...
   (get(handles.checkbox9,'Value') == 1) &&...
   (strcmp(handles.pathname_ct, '0') == 0) &&...
   (valid_frames_dynamic == 1) &&...
   (isempty(frames_dynamic) == 0) &&...
   (isempty(save_output) == 0)

    a = 1;
    


elseif (isfield(handles, 'pathname_choose') == 1) &&...
       (strcmp(handles.pathname_choose, '0') == 0) &&...
       (isfield(handles, 'pathname_norm') == 1) &&...
       (strcmp(handles.pathname_norm, '0') == 0) &&...
       (valid_frames_dynamic == 1) &&...
       (isempty(frames_dynamic) == 0) &&...
       ((isfield(handles, 'pathname_ct') == 0) || (strcmp(handles.pathname_ct, '0') == 1) || (get(handles.checkbox9,'Value') == 0)) &&...
       (isempty(save_output) == 0)

    a = 2;
    %handles.pathname_ct = '0';
    
end

get(handles.checkbox9,'Value')
get(handles.checkbox10,'Value')


 % check to see if this is a cylinder calibration scan 
tf = contains(handles.pathstr1,'calibration_data'); 
if tf > 0.5
	disp('Processing calibration scan data'); 
a = 1; 
end



switch a
    case 1
        run = 'Processing listmode data';
        set(handles.start4, 'enable', 'on');

		% first update dose if necessary
        val_dose = change_dose(handles.pathstr1,handles.pathname_filename,handles.dose); 
        if ~val_dose
            errordlg('Invalid dose, do better (try again)', 'Error'); 
            return
        end
        
        val_injtime = change_injtime(handles.pathstr1,handles.pathname_filename,handles.injection_time_edit); 
        if ~val_injtime
            errordlg('Invalid injection time format, do better (try again)', 'Error');
            return
        end      
        
        do_scout = 1; 
        do_reg = 1; 
		
        
        if tf
            ctdir = [handles.pathstr1,'CT/'];
            fname_ct = [ctdir,'attn_sino_129x156x111x111-float_sinorecon.raw'];           
        else
               
            % check to see if registration has been done yet
            fname_ct = [handles.pathname_ct,'/attn_sino_129x156x111x111-float_sinorecon.raw'];
        end
        
        if exist(fname_ct,'file')
            do_scout = 0; 
            scout = '0';
			
            disp('Found attenuation file');
			answer = questdlg('Redo CT image registration?','Found attenuation file','Yes','No','No');
			switch answer
				case 'Yes'
					do_reg = 1;
					disp('OK, redoing CT image registration...'); 
					set(handles.checkbox9,'Value',0);
                	set(handles.checkbox9,'enable','off');
				case 'No'
					do_reg = 0; 
					set(handles.checkbox9,'Value',1); 
                	set(handles.checkbox9,'enable','on');
			end
		       
        else
            disp('No attenuation file found');		
        end
		guidata(hObject, handles);
             
            
        
            
        if do_reg == 1
           
            
            if tf
				handles.pathname_ct = './CT_10cm_cylinder';                
				mkdir(ctdir); 
                ctdirA = [ctdir,'/A']; 
                mkdir(ctdirA); 
                Adir = [handles.pathname_ct,'/A'] ;
                status = copyfile(Adir,ctdirA); 
                pause(1)
                if status<0.5
                    disp('Could not copy CT image, please copy manually'); 
                    pause
                end
                handles.pathname_ct = ctdir;
            else
                % check if dicoms are in 'A' folder
                dcm_location = [handles.pathname_ct,'/A/Z50'];
                if ~exist(dcm_location,'file')
                    disp('Moving CT dicoms');
                    dcm_name = [handles.pathname_ct,'/Z*'];
                    Adir = [handles.pathname_ct,'/A'];
                    mkdir(Adir);
                    status = movefile(dcm_name,Adir);
                    pause(1); 
                    if status<0.5
                        disp('Could not copy CT dicoms'); 
                        pause
                    end
                end
            
            end
            
            
            if ~exist(mkdir2,'dir')
        		mkdir(mkdir2);
        	end 
            lmacc_config_dir = [mkdir2,'/lmacc_config']; 
        	mkdir(lmacc_config_dir); 
        	run_sh_dir = [mkdir2,'/run_sh']; 
        	mkdir(run_sh_dir); 
			
            petimgpath = make_lmacc_config_local(handles.pathname_norm,mkdir2,mkdir2,lmfname,numrad,0,0);
            petimgpath = [petimgpath,'.os.20.it.1'];
            
            
            fname_petscout = [petimgpath]; 
            
            if exist(fname_petscout,'file')>0.5
                do_scout = 0; 
            end
           
            
            if do_scout == 1
                
                disp('**** PROCESSING SCOUT LISTMODE DATA... ****');
            
                static_dynamic = '1';
                write_lm = '1';
                write_sino = '0';
                dtcor = '0';
                rando = '1';
                atcor = '0';
                scatcor = '0';
                tof_on = '1';
                scout = '1';
                
                fid=fopen(save_as,'wt');
                fprintf(fid,'%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n',...
                    mkdir2,...
                    handles.pathname_choose,...
                    handles.pathname_norm,...
                    handles.pathname_ct,...
                    fov,...
                    static_dynamic,...
                    frames_dynamic,...
                    write_lm,...
                    write_sino,...
                    dtcor,...
                    rando,...
                    atcor,...
                    scatcor,...
                    tof_on,...
                    scout);
                
                fclose(fid);
       
                % Decode scout listmode data
                fname = '../process_lm_sino/process_lm_sino';
                system(fname); 
                
                % make recon run files
                make_server_recon_run_sh(mkdir2,mkdir2,0,0);    
                make_combine_run_sh(mkdir2,mkdir2,0,1,0); 
                make_lmreconext_run_sh(mkdir2,mkdir2,1,20,0);
                
                % run scout reconstruction
                run_recon_local(mkdir2,0,0);
                
                
            end
            
            disp('starting CT image registration'); 
            pp = genpath('../normalization/'); 
            addpath(pp); 
                           
            process_CTimg(handles.pathname_ct);

			if tf %changed
                register_PETCT2(handles.pathname_ct,petimgpath); 
            else
                register_PETCT(handles.pathname_ct,petimgpath); 
            end

            make_mumap(handles.pathname_ct); 
           
			if tf %changed
                % guess for CT image
                ct_folder = 'CT'; 
                set(handles.ct_text,'String',ct_folder); 
                ct_folder = [handles.pathstr1,'CT'];
                handles.pathname_ct = ct_folder;
    
                pause(0.5); 
            end
            guidata(hObject, handles);
			rmpath(pp); 
        end


        % Now start listmode processing
           
        ss = ['Starting listmode processing on ', server_name,]; 
		disp(ss);      

        static_dynamic = '1';
        write_lm = '1';
        write_sino = '0';
        dtcor = '1';
        if (get(handles.radiobutton20,'Value')==1)
            rando = '1'; 
        end
        if (get(handles.radiobutton19,'Value')==1)
            rando = '2'; 
        end
        
        atcor = '1';
        scatcor = '0';
        tof_on = '1';
        scout = '0';
        
        if strcmp(server_name,'Local')
        	fid=fopen(save_as,'wt');
        	fprintf(fid,'%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n',...
                mkdir1,...
                handles.pathname_choose,...
           		handles.pathname_norm,...
           		handles.pathname_ct,...
           		fov,...
           		static_dynamic,...
           		frames_dynamic,...
           		write_lm,...
           		write_sino,...
           		dtcor,...
           		rando,...
           		atcor,...
           		scatcor,...
           		tof_on,...
           		scout);
        
        	fclose(fid);
        	
        	disp('**** PROCESSING LISTMODE DATA ALL FRAMES... ****');
        	
        	% process listmode data
        	fname = '../process_lm_sino/process_lm_sino'; 
        	system(fname);
        
        else 
        
        	str_find1 = 'Users/berg'; 
        	str_find2 = 'normalization_data'; 
        
        	str_replace = '/mnt/ssd/eberg/'; 
        
			if strcmp(server_name,'explorer-r740-00q') == 1
				str_replace = '/mnt/ssd-00q/eberg/'; 
			end
        
        	ind_s1 = strfind(mkdir1,str_find1); 
        	ind_s2 = strfind(handles.pathname_choose,str_find1); 
        	ind_s3 = strfind(handles.pathname_norm,str_find2); 
        	ind_s4 = strfind(handles.pathname_ct,str_find1); 
            
            pathstr11 = handles.pathstr1;
            pathstr11 = pathstr11(ind_s1:end); 
            pathstr11 = [str_replace,pathstr11]; 
            
        	mkdir11 = mkdir1; 
        	mkdir11 = mkdir11(ind_s1:end); 
        	mkdir11 = [str_replace,mkdir11]; 
        
        	pathname_choose11 = handles.pathname_choose; 
        	pathname_choose11 = pathname_choose11(ind_s2:end); 
        	pathname_choose11 = [str_replace,pathname_choose11]; 
        
        	pathname_norm11 = handles.pathname_norm; 
        	pathname_norm11 = pathname_norm11(ind_s3:end); 
        	pathname_norm11 = [str_replace,pathname_norm11]; 
        
        	pathname_ct11 = handles.pathname_ct; 
        	pathname_ct11 = pathname_ct11(ind_s4:end); 
        	pathname_ct11 = [str_replace,pathname_ct11]; 
        	
        	% get project name
        	inds_dir = strfind(pathstr11(1:end-2),'/'); 
        	inds_dir = inds_dir((end-1):end);
        	project_str = pathstr11((inds_dir(1)+1):(inds_dir(2)-1));
        	
        	project_fullpath = pathstr11(1:(inds_dir(2)-1));
        	
        
        
        	fid=fopen(save_as,'wt');
        	fprintf(fid,'%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n',...
            	mkdir11,...
            	pathname_choose11,...
            	pathname_norm11,...
            	pathname_ct11,...
            	fov,...
            	static_dynamic,...
            	frames_dynamic,...
            	write_lm,...
            	write_sino,...
            	dtcor,...
            	rando,...
            	atcor,...
            	scatcor,...
            	tof_on,...
            	scout);
        
        	fclose(fid);
        
        
        
        	disp('**** CONNECTING TO SERVER... ****'); 


            % check if data is already on the server, if not transfer files using SCP
            fname_process = ['ssh eberg@',server_name,' test -d "',project_fullpath,'" || ssh eberg@',server_name,'  " cd ',str_replace,str_find1, '; mkdir ',project_str,' "']; 
            
          
            system(fname_process); 

            
            fname_process = ['ssh eberg@',server_name,' test -f "',pathname_choose11,'" || scp -P 8300 -r ',handles.pathstr1(1:(end-1)),'  eberg@',server_name,':',project_fullpath];
           
            
            system(fname_process);
            
          
            
            fname_process = ['ssh eberg@',server_name,' test -d "',mkdir11,'" || ssh eberg@',server_name,'  "mkdir ',mkdir11,' "']; 
            
            system(fname_process); 
            
            
            
            make_send_to_server_sh(mkdir1,mkdir11,server_name,1,1);
        	pause(0.5); 
        	fname_process2 = 'sh ./send_to_server.sh'; 
        	system(fname_process2);
        	pause(1);
        
        
        	disp('**** PROCESSING LISTMODE DATA ALL FRAMES... ****');
        
        	run_process_lm_sino_server(mkdir11,server_name); 
        
        	pause(1); 
        
        end
	
		
		set(handles.start4,'Value',1); 
		start4_Callback(hObject, eventdata, handles);
              
        
    case 2
        run = 'Histogramming started WITHOUT CT or attenuation correction';
        set(handles.start4, 'enable', 'on');
        set(handles.checkbox9,'Value',0); 
        %set(handles.checkbox9,'enable','off'); 
        
        static_dynamic = '1';
        write_lm = '1';
        write_sino = '0';
        dtcor = '1';
        if (get(handles.radiobutton20,'Value')==1)
            rando = '1'; 
        end
        if (get(handles.radiobutton19,'Value')==1)
            rando = '2'; 
        end
        atcor = '0';
        scatcor = '0';
        tof_on = '1';
        scout = '0';
        
        if strcmp(server_name,'Local')
        	fid=fopen(save_as,'wt');
        	fprintf(fid,'%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n',...
                mkdir1,...
                handles.pathname_choose,...
           		handles.pathname_norm,...
           		handles.pathname_ct,...
           		fov,...
           		static_dynamic,...
           		frames_dynamic,...
           		write_lm,...
           		write_sino,...
           		dtcor,...
           		rando,...
           		atcor,...
           		scatcor,...
           		tof_on,...
           		scout);
        
        	fclose(fid);
        	
        	disp('**** PROCESSING LISTMODE DATA ALL FRAMES... ****');
        	fname = '../process_lm_sino/process_lm_sino'; 
        	system(fname);
        
        else 
        
        	str_find1 = 'Users/berg'; 
        	str_find2 = 'normalization_data'; 
        	%str_replace = '/mnt/ssd-00q/eberg/'; 
        
        	str_replace = '/mnt/ssd/eberg/'; 
        
			if strcmp(server_name,'explorer-r740-00q') == 1
				str_replace = '/mnt/ssd-00q/eberg/'; 
			end
        
        	ind_s1 = strfind(mkdir1,str_find1); 
        	ind_s2 = strfind(handles.pathname_choose,str_find1); 
        	ind_s3 = strfind(handles.pathname_norm,str_find2); 
        	ind_s4 = strfind(handles.pathname_ct,str_find1); 
            
            pathstr11 = handles.pathstr1;
            pathstr11 = pathstr11(ind_s1:end); 
            pathstr11 = [str_replace,pathstr11]; 
            
        	mkdir11 = mkdir1; 
        	mkdir11 = mkdir11(ind_s1:end); 
        	mkdir11 = [str_replace,mkdir11]; 
        
        	pathname_choose11 = handles.pathname_choose; 
        	pathname_choose11 = pathname_choose11(ind_s2:end); 
        	pathname_choose11 = [str_replace,pathname_choose11]; 
        
        	pathname_norm11 = handles.pathname_norm; 
        	pathname_norm11 = pathname_norm11(ind_s3:end); 
        	pathname_norm11 = [str_replace,pathname_norm11]; 
        
        	pathname_ct11 = handles.pathname_ct; 
        	pathname_ct11 = pathname_ct11(ind_s4:end); 
        	pathname_ct11 = [str_replace,pathname_ct11]; 
        
        
        	fid=fopen(save_as,'wt');
        	fprintf(fid,'%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n',...
            	mkdir11,...
            	pathname_choose11,...
            	pathname_norm11,...
            	pathname_ct11,...
            	fov,...
            	static_dynamic,...
            	frames_dynamic,...
            	write_lm,...
            	write_sino,...
            	dtcor,...
            	rando,...
            	atcor,...
            	scatcor,...
            	tof_on,...
            	scout);
        
        	fclose(fid);
        
        
        
        	disp('**** CONNECTING TO SERVER... ****'); 
        
        	


            % check if data is already on the server, if not transfer files using SCP
            fname_process = ['ssh eberg@',server_name,' test -d "',project_fullpath,'" || ssh eberg@',server_name,'  " cd ',str_replace,str_find1, '; mkdir ',project_str,' "'];  
            
            system(fname_process); 
            

            fname_process = ['ssh eberg@',server_name,' test -f "',pathname_choose11,'" || scp -P 8300 -r ',handles.pathstr1(1:(end-1)),'  eberg@',server_name,':',project_fullpath];
           
            
            system(fname_process); 

           
        
        
        	disp('**** PROCESSING LISTMODE DATA ALL FRAMES... ****');
        
        
        	run_process_lm_sino_server(mkdir11,server_name); 
        
        	pause(1); 
        
        	
        end

		set(handles.start4,'Value',1); 
		start4_Callback(hObject, eventdata, handles);
        
        
    case 3
        run = 'Not started, fix errors to begin histogramming';
        set(handles.start4, 'enable', 'off');
end
run = 'Processing complete, ready for reconstruction'; 

set(handles.outcome, 'String', run);

set(handles.server_recon,'enable','on'); 

guidata(hObject, handles);



% --- Executes when selected object is changed in reconstruction_selection.
function reconstruction_selection_SelectionChangeFcn(hObject, eventdata, handles)




% --- Executes when selected object is changed in frames_panel.
function frames_panel_SelectionChangeFcn(hObject, eventdata, handles)

switch get(handles.recon_all, 'Value')
    case 1
        set(handles.sframe, 'enable', 'off');
        set(handles.eframe, 'enable', 'off');
        set(handles.sframe_txt, 'enable', 'off');
        set(handles.eframe_txt, 'enable', 'off');
        set(handles.sframe, 'string', '0');
        set(handles.eframe, 'string', '0');
    case 0
        set(handles.sframe, 'enable', 'on');
        set(handles.eframe, 'enable', 'on');
        set(handles.sframe_txt, 'enable', 'on');
        set(handles.eframe_txt, 'enable', 'on');
        set(handles.sframe, 'string', '0');
        set(handles.eframe, 'string', '1');
end



% --- Executes on button press in start4.
function start4_Callback(hObject, eventdata, handles)


guidata(hObject, handles); 


qlist_server = get(handles.server_recon,'String'); 

q_server = get(handles.server_recon,'Value'); 

server_name = qlist_server{q_server};


set(handles.server_recon,'enable','off'); 

guidata(hObject, handles);

sframe = get(handles.sframe, 'String');
eframe = get(handles.eframe, 'String');
% iter = get(handles.iter, 'String');
save_output = get(handles.save_output, 'String');

%% error messages
valid_sframe = all(isstrprop(sframe, 'digit'));
valid_eframe = all(isstrprop(eframe, 'digit'));
% valid_iter = all(isstrprop(iter, 'digit'));

if valid_sframe == 0 || valid_eframe == 0
    errordlg('Start and End Frames must only contain numeric values (no spaces)', 'Brijesh Says!');
    a = 7;
elseif isempty(sframe) == 1
    errordlg('Enter Start Frame','Brijesh Says!');
    a = 7;
elseif isempty(eframe) == 1
    errordlg('Enter End Frame','Brijesh Says!');
    a = 7;

elseif str2num(sframe) > str2num(eframe)
    errordlg('Start Frame must be smaller than End Frame', 'Brijesh Says!');
    a = 7;

end


%% execute file
filename2 = 'Reconstruction_Parameters_2_simple';
%save_as2 = fullfile('/run/media/meduser/data/software_distribute/reconstruction/', filename2);
save_as2 = fullfile('../reconstruction/', filename2);


% these override the default values
fov = '3';
static_dynamic = '1';
write_lm = '1';
write_sino = '0';
dtcor = '0';
rando = '0';
atcor = '0';
scatcor = '0';

sss_tof = 0; 

% check to see if registration has been done yet
fname_ct = [handles.pathname_ct,'/attn_sino_129x156x111x111-float_sinorecon.raw']

if exist(fname_ct,'file')<0.5
    set(handles.checkbox9,'Value',0); 
    %set(handles.checkbox9,'enable','off');
    disp('No CT, no attenuation correction!'); 
    %set(handles.checkbox9,'Value',1); 
    %set(handles.checkbox9,'enable','on');

else
    set(handles.checkbox9,'Value',1); 
    set(handles.checkbox9,'enable','on');
end

sub = 0; 
mult = 0; 
sc = 0; 
if (get(handles.checkbox10,'Value')==1)
    sub=1; 
end
if (get(handles.checkbox9,'Value')==1)
    mult=1; 
end
if (get(handles.scatter_checkbox,'Value')==1)
    sc = 1; 
end


lmfname1 = handles.pathname_filename; 
lmfname = erase(lmfname1,'.lm'); 

if (fov=='1')
    numrad=77;
elseif (fov == '2')
    numrad=129;
elseif (fov == '3')
    numrad = 157;
else
    numrad = 129; 
end

iter=2;
subs=20;

sf = str2num(sframe);
ef = str2num(eframe); 


if  ((valid_sframe == 1) &&...
    (valid_eframe == 1) &&...
    (str2num(eframe) >= str2num(sframe)) &&...
    (isempty(sframe) == 0) &&...
    (isempty(eframe) == 0))
    
    if get(handles.start2,'Value') == 1 && isfield(handles, 'pathstr1') == 1 && isfield(handles, 'save_output') == 1
		handles.pathname_start4 = fullfile(handles.pathstr1, get(handles.save_output,'String'));
		set(handles.outcome2,'String',handles.pathname_start4); 
		pathname_start4 = handles.pathname_start4;
	end
    if isfield(handles, 'pathstr1') == 1 && isfield(handles, 'save_output') == 1 && get(handles.start2,'Value') == 0
            hist_dir = fullfile(handles.pathstr1, save_output);
            pathname_start4 = uigetdir(hist_dir, 'Select Data Folder');
            set(handles.outcome2, 'String', pathname_start4);
            handles.pathname_start4 = pathname_start4;
    end
    
    if (isequal(pathname_start4,0) == 1)
%        (strcmp(pathname_start4, 'C:\') == 1)
        errordlg('Invalid directory chosen.', 'Brijesh Says!')
        a = 7;
    else
        fid=fopen(save_as2,'wt');
        fprintf(fid,'%s\n%.0f\n%s\n%s\n%.0f\n%s\n',...
            pathname_start4,...
            sframe,...
            eframe,...
            'lm_tof',...
            iter,...
            subs);
        fclose(fid);
        a = 8;
    end

end





if strcmp(server_name,'Local') == 1
	
	pathname_start44 = pathname_start4;
    pathname_norm11 = handles.pathname_norm;
    pathname_ct11 = handles.pathname_ct;
	
	% 
else

	str_find1 = 'Users/berg'; 
	str_find2 = 'normalization_data'; 
	str_replace = '/mnt/ssd/eberg/'; 

	if strcmp(server_name,'explorer-r740-00q') == 1
		str_replace = '/mnt/ssd-00q/eberg/'; 
	end
    
	ind_s1 = strfind(pathname_start4,str_find1); 
	ind_s2 = strfind(handles.pathname_choose,str_find1); 
	ind_s3 = strfind(handles.pathname_norm,str_find2); 
	ind_s4 = strfind(handles.pathname_ct,str_find1); 
        
	pathname_start44 = pathname_start4; 
	pathname_start44 = pathname_start44(ind_s1:end); 
	pathname_start44 = [str_replace,pathname_start44];  
        
	pathname_norm11 = handles.pathname_norm; 
	pathname_norm11 = pathname_norm11(ind_s3:end); 
	pathname_norm11 = [str_replace,pathname_norm11]; 
        
	pathname_ct11 = handles.pathname_ct; 
	pathname_ct11 = pathname_ct11(ind_s4:end); 
	pathname_ct11 = [str_replace,pathname_ct11]; 

end

switch a
    case 8
        run = pathname_start4;
        
        lmacc_config_dir = [pathname_start4,'/lmacc_config']; 
        mkdir(lmacc_config_dir); 
        run_sh_dir = [pathname_start4,'/run_sh']; 
        mkdir(run_sh_dir); 
        
        % check to see if this is a cylinder calibration scan 
        tf = contains(handles.pathstr1,'calibration_data'); 
        
        
        
        for k=sf:ef
            f1 = ['**** STARTING IMAGE RECONSTRUCTION FRAME ',num2str(k),' ****'];       
            disp(f1);
			          
            fid=fopen(save_as2,'wt');
            fprintf(fid,'%s\n%.0f\n%s\n%s\n%.0f\n%s\n',...
                pathname_start4,...
                k); 
            
            fclose(fid);
			
            
        end
        
          
        img_check = 0; 
        
        for kk = sf:ef
            petimgpathtemp = ''; 
            petimgpathtemp = make_lmacc_config(pathname_norm11,pathname_start4,pathname_start4,lmfname,numrad,kk,0);
            petimgpathtemp = [petimgpathtemp,'.oslmem.tof.temp.out.0'];
             
            if exist(petimgpathtemp,'file') 
                img_check = img_check + 1;              
            end
        end
        
        
        do_recon_it1 = 1; 
        if img_check >= (ef - sf + 0.5) 
            do_recon_it1 = 0;
            disp('First iteration recon already done'); 
        end
        
        
        if do_recon_it1 > 0.5
        
        	for k = sf:ef
        		img_init = 0; 
            	if strcmp(server_name,'Local') == 1
            		petimgpath{k+1} = make_lmacc_config_local(pathname_norm11,pathname_start4,pathname_start44,lmfname,numrad,k,img_init); 
            	elseif strcmp(server_name,'explorer-r740-00q') == 1
            		petimgpath{k+1} = make_lmacc_config2(pathname_norm11,pathname_start4,pathname_start44,lmfname,numrad,k,img_init); 	
            	else
            		petimgpath{k+1} = make_lmacc_config(pathname_norm11,pathname_start4,pathname_start44,lmfname,numrad,k,img_init);
            	end
            
            	iter = 1;  
            	if (sub > 0.5 || mult > 0.5)
                	make_combine_run_sh(pathname_start4,pathname_start44,k,sub,mult);
                	make_lmreconext_run_sh(pathname_start4,pathname_start44,iter,subs,k);
            	else
            		make_lmrecon_run_sh(pathname_start4,pathname_start44,iter,subs,k);
            	end
            end
            
            make_server_recon_run_sh(pathname_start4,pathname_start44,sf,ef);
            
            if strcmp(server_name,'Local') > 0.5
            	disp('Starting local reconstruction 1st iteration'); 
            	run_recon_local_it1(pathname_start4,server_name,petimgpath,sf,ef); 
            
            else
            
            	% send lmacc and run_sh files to server
            	make_send_to_server_sh(pathname_start4,pathname_start44,server_name,1,2); 
            	pause(0.5); 
            	fname_process = 'sh ./send_to_server.sh'; 
            	system(fname_process);
            	pause(1);
        		
            	disp('Paused before reconstruction iteration 1.');  
            	
            	run_recon_server_it1(pathname_start44,server_name,petimgpath,sf,ef); 
            	pause(1)
            	pause
            	
            	
				% rename images
				% change tof.temp.out.1 to tof.temp.out.0 image extension 
				rename_images(petimgpath,server_name,sf,ef,1);
				fname_move = 'sh ./rename_imgs.sh'; 
				system(fname_move); 

				% remove .it.1 images from server (to avoid confusion for second iteration)
				rename_images(petimgpath,server_name,sf,ef,4);
				fname_move = 'sh ./rename_imgs.sh'; 
				system(fname_move);
            
            
            	% get images and sinos from server
            	%make_send_to_server_sh(pathname_start4,pathname_start44,server_name,[sf:ef],[4,5]); 
            	make_send_to_server_sh(pathname_start4,pathname_start44,server_name,1,[4,5]); 
            	pause(0.5); 
            	fname_process = 'sh ./send_to_server.sh'; 
            	system(fname_process)
            	pause(1);
            end
            
        end
        
       
              
        img_check = 1; 
        for kk = sf:ef
            petimgpathtemp = make_lmacc_config(pathname_norm11,pathname_start4,pathname_start4,lmfname,numrad,kk,0);
            petimgpathtemp = [petimgpathtemp,'.oslmem.tof.temp.out.0'];
             
            if ~exist(petimgpathtemp,'file') 
                img_check = 0; 
                disp('Some images not transferred / reconstructed successfully after 1st iteration.'); 
                return 
            end
        end
 
 		
        
        % scatter estimation             
        if sc > 0.5
        
            pp2 = genpath('../ScatterSS/');
            addpath(pp2);
            
            do_sc = 0; 
            for kk = sf:ef
                ftest = [pathname_start4,'/sss_sino_tof_f',num2str(kk),'_scaled.raw']; 
                if ~exist(ftest,'file') 
                    do_sc = 1; 
                end
            end
            
            if do_sc > 0.5
            
                fdir_sss_par = [pathname_start4,'/run_sss'];
                mkdir(fdir_sss_par);
                if strcmp(server_name,'Local') > 0.5
                	f_ex_sss = '../process_lm_sino/scatter_lm_sino_tof_local'; 
                else
                	f_ex_sss = '../process_lm_sino/scatter_lm_sino_tof_server';
				end
				
                for k = sf:ef
                    % estimate SSS scatter sino

                    petimgpathtemp = make_lmacc_config(pathname_norm11,pathname_start4,pathname_start4,lmfname,numrad,k,0);
                    petimgpath22 = [petimgpathtemp,'.oslmem.tof.temp.out.0'];
                    disp('Estimating SSS block sino');
                    emi_sss_tof_lmdata_rs_xp_609ps_13x12(pathname_start4,petimgpath22,handles.pathname_ct,k);

                    pause(0.5);

                    % scale SSS sino
                    disp('Scaling SSS sino');
                    scale_sss_sino_globalscale(pathname_start4,handles.pathname_ct,k);

                    pause(0.5);

                    warning off
                    sss_save_as = [fdir_sss_par,'/f',num2str(k)];
                    mkdir(sss_save_as);
                    sss_fout = [sss_save_as,'/Reconstruction_Parameters_2_simple'];
                    fid=fopen(sss_fout,'wt');
                    fprintf(fid,'%s\n%.0f\n%s\n%s\n%.0f\n%s\n',...
                        pathname_start44,...
                        k);

                    fclose(fid);

                    [s,m,mm] = copyfile(f_ex_sss,sss_save_as);

                end
            end
            
            rmpath(pp2);
            
            make_server_lmsss_run_sh(pathname_start4,pathname_start44,server_name,sf,ef);
            
            if strcmp(server_name,'Local') < 0.5
                %send run sss to server
                make_send_to_server_sh(pathname_start4,pathname_start44,server_name,1,6);
                pause(0.5);
                fname_process = 'sh ./send_to_server.sh';
                system(fname_process)
                pause(1);

                % send scaled SSS sinos to the server
                make_send_to_server_sh(pathname_start4,pathname_start44,server_name,sf:ef,3);
                pause(0.5);
                fname_process = 'sh ./send_to_server.sh';
                system(fname_process)
                pause(1);
            end
            
            
            if do_sc > 0.5
                sys_cmd = 'sh ./run_lmsss.sh';
                system(sys_cmd);
            end
            pause(0.5)
        
        end
        
        
        
        % 2nd iteration
        img_check = 0; 
        
        for kk = sf:ef
            petimgpathtemp = ''; 
            petimgpathtemp = make_lmacc_config(pathname_norm11,pathname_start4,pathname_start4,lmfname,numrad,kk,0);
            petimgpathtemp = [petimgpathtemp,'.os.20.it.2'];
             
            if exist(petimgpathtemp,'file') 
                img_check = img_check + 1;              
            end
        end
        
        
        
        
        do_recon_it2 = 1; 
        if img_check >= (ef - sf + 0.5) 
            do_recon_it2 = 0;
            disp('2nd iteration recon already done'); 
        end
        
        
        if do_recon_it2 > 0.5
        
        	for k = sf:ef
        		img_init = 1; 
            	if strcmp(server_name,'Local') == 1
            		petimgpath{k+1} = make_lmacc_config_local(pathname_norm11,pathname_start4,pathname_start44,lmfname,numrad,k,img_init); 
            	elseif strcmp(server_name,'explorer-r740-00q') == 1
            		petimgpath{k+1} = make_lmacc_config2(pathname_norm11,pathname_start4,pathname_start44,lmfname,numrad,k,img_init); 	
            	else
            		petimgpath{k+1} = make_lmacc_config(pathname_norm11,pathname_start4,pathname_start44,lmfname,numrad,k,img_init);
            	end
            
            	iter = 1; 
            	if sc > 0.5
                	make_combine_run_sub2_sh(pathname_start4,pathname_start44,k,sub,mult);
                	make_lmreconext_run_sh(pathname_start4,pathname_start44,iter,subs,k);
            	elseif (mult > 0.5 && sc < 0.5) || (sub > 0.5)
                	make_combine_run_sh(pathname_start4,pathname_start44,k,sub,mult); 
                	make_lmreconext_run_sh(pathname_start4,pathname_start44,iter,subs,k);
            	else
                	make_lmrecon_run_sh(pathname_start4,pathname_start44,iter,subs,k);
            	end
            end
            
            make_server_recon_run_sh(pathname_start4,pathname_start44,sf,ef);
            
            if strcmp(server_name,'Local') > 0.5
            	disp('Starting local reconstruction 2nd iteration'); 
            	run_recon_local_it2(pathname_start4,server_name,petimgpath,sf,ef); 
            
            else
            
            	% send lmacc and run_sh files to server
            	make_send_to_server_sh(pathname_start4,pathname_start44,server_name,1,2); 
            	pause(0.5); 
            	fname_process = 'sh ./send_to_server.sh'; 
            	system(fname_process);
            	pause(1); 
            	
            	
            	
        		
            	disp('Paused before reconstruction iteration 2.');  
            	
            	run_recon_server_it2(pathname_start44,server_name,petimgpath,sf,ef); 
            	pause(1)
            	pause
            
            
            	% rename images
				% rename 2nd iteration tof.temp.out.1 to tof.temp.out.2
				rename_images(petimgpath,server_name,sf,ef,2); 
				fname_move = 'sh ./rename_imgs.sh'; 
				system(fname_move); 

				% rename 2nd iteration images to .2 extension
				rename_images(petimgpath,server_name,sf,ef,3); 
				fname_move = 'sh ./rename_imgs.sh'; 
				system(fname_move); 
            
            
            	% get images and sinos from server
        		make_send_to_server_sh(pathname_start4,pathname_start44,server_name,[sf:ef],7); 
        		pause(0.5); 
        		fname_process = 'sh ./send_to_server.sh'; 
        		system(fname_process)
        		pause(1);
            
            
            	
            end
            
        end
        
        
              
        img_check = 1; 
        for kk = sf:ef
            petimgpathtemp = make_lmacc_config(pathname_norm11,pathname_start4,pathname_start4,lmfname,numrad,kk,0);
            petimgpathtemp = [petimgpathtemp,'.os.20.it.2'];
             
            if ~exist(petimgpathtemp,'file') 
                img_check = 0; 
                disp('Some images not transferred / reconstructed successfully after 2nd iteration.'); 
                return 
            end
        end
        
      
        % Post process images (dicom etc)
        iter = 2; 
        for k=sf:ef
        	petimgpath = make_lmacc_config(pathname_norm11,pathname_start4,pathname_start4,lmfname,numrad,k,0);
        	postprocess_img(pathname_start4,lmfname,petimgpath,handles.pathname_ct,tf,handles.pathname_norm,subs,iter,k);
        end
               
    case 7
        run = 'Not Saved';
end

if (get(handles.dynamic,'Value') == 1)
    disp('Making dynamic DICOMs'); 
    make_dynamic_dicom(pathname_start4,sf,ef); 
end

file_images(pathname_start4); 

set(handles.outcome2, 'String', run);
set(handles.start2,'Value',0); 
guidata(hObject, handles);

disp(''); 
disp('** FINISHED! **'); 



function choose_text_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function choose_text_CreateFcn(hObject, eventdata, handles)
 
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function norm_text_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function norm_text_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ct_text_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function ct_text_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function recon_panel_CreateFcn(hObject, eventdata, handles)

% Hint: get(hObject,'Value') returns toggle state of attenuation
	
	
function frames_dynamic_Callback(hObject, eventdata, handles)

scan_time = get_scantime(handles.pathstr1,handles.pathname_filename); 
tot_length = calc_frame(handles.frames_dynamic);
nframes = calc_nframes(handles.frames_dynamic)
	
set(handles.sframe,'String','0'); 
set(handles.eframe,'String',nframes);
set(handles.TotalFrameLength, 'String', num2str(tot_length)); 
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function frames_dynamic_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function save_output_Callback(hObject, eventdata, handles)

set(handles.server_recon,'enable','on'); 
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function save_output_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function outcome_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function outcome_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% 
% function iter_Callback(hObject, eventdata, handles)
% 
% % --- Executes during object creation, after setting all properties.
% function iter_CreateFcn(hObject, eventdata, handles)
% 
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end
% 

% 
% function subs_Callback(hObject, eventdata, handles)
% 
% % --- Executes during object creation, after setting all properties.
% function subs_CreateFcn(hObject, eventdata, handles)
% 
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end



function sframe_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function sframe_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function eframe_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function eframe_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function outcome2_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function outcome2_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox9.
function checkbox9_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox9


% --- Executes on button press in checkbox10.
function checkbox10_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox10


% --- Executes on button press in radiobutton19.
function singles_Callback(hObject, eventdata, handles)

r_singles = get(handles.radiobutton19,'Value'); 
if (r_singles==1)
    set(handles.radiobutton20,'Value',0); 
end
if (r_singles==0)
    set(handles.radiobutton20,'Value',1); 
end
% hObject    handle to radiobutton19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton19


% --- Executes on button press in radiobutton20.
function delays_Callback(hObject, eventdata, handles)

r_delays = get(handles.radiobutton20,'Value'); 
if (r_delays==1)
    set(handles.radiobutton19,'Value',0); 
end
if (r_delays==0)
    set(handles.radiobutton19,'Value',1); 
end
% hObject    handle to radiobutton20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton20


% --- Executes on button press in dynamic.
function dynamic_Callback(hObject, eventdata, handles)

is_dynamic = get(handles.dynamic,'Value'); 
if (is_dynamic == 1) 
    scan_time = get_scantime(handles.pathstr1,handles.pathname_filename)
	pause(0.1); 
	inj_start = get_injtime(handles.pathstr1,handles.pathname_filename,scan_time);
	
    if inj_start < 10
        inj_start = 0; 
    end
    scan_time_winj = scan_time - inj_start; 
	
    f_dyn = make_dynframes(scan_time_winj); 
	pause(0.1); 
%     set(handles.frames_dynamic,'String',''); 
%     guidata(hObject, handles)
    
	
	
	if inj_start > 1
        f_dyn = ['1,',num2str(inj_start),',',f_dyn]; 
    end
	set(handles.frames_dynamic,'String',f_dyn);
	nframes = calc_nframes(handles.frames_dynamic)
	tot_length = calc_frame(handles.frames_dynamic);
	set(handles.sframe,'String','0'); 
    set(handles.eframe,'String',nframes);  
	set(handles.TotalFrameLength, 'String', num2str(tot_length)); 
    guidata(hObject, handles); 
    
end
if (is_dynamic == 0)
    scan_time = get_scantime(handles.pathstr1,handles.pathname_filename)
    f_dynamic_str = ['1,',num2str(scan_time)]; 
    set(handles.frames_dynamic,'String',f_dynamic_str); 
	set(handles.sframe, 'String','0');
	set(handles.eframe, 'String','0');
    guidata(hObject, handles)
end
    

% hObject    handle to dynamic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dynamic



		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				
				
				


% --- Executes on button press in scatter_checkbox.
function scatter_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to scatter_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of scatter_checkbox



function TotalFrameLength_Callback(hObject, eventdata, handles)
% hObject    handle to TotalFrameLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TotalFrameLength as text
%        str2double(get(hObject,'String')) returns contents of TotalFrameLength as a double


is_dynamic = get(handles.dynamic,'Value'); 
if (is_dynamic == 1) 
    scan_time = str2num(get(handles.TotalFrameLength,'String'));
    tot_time = str2num(get(handles.ScanLength,'String')); 
    pause(0.1); 
    inj_start = get_injtime(handles.pathstr1,handles.pathname_filename,tot_time);
    if inj_start < 10
        inj_start = 0; 
    end
    scan_time_winj = scan_time - inj_start; 

    f_dyn = make_dynframes(scan_time_winj); 
    pause(0.1); 

%     set(handles.frames_dynamic,'String',''); 
%     guidata(hObject, handles)

    if inj_start > 1
        f_dyn = ['1,',num2str(inj_start),',',f_dyn]; 
    end
    set(handles.frames_dynamic,'String',f_dyn); 
    tot_length = calc_frame(handles.frames_dynamic); 
    set(handles.TotalFrameLength, 'String', num2str(tot_length));
    guidata(hObject, handles);
end
if (is_dynamic == 0)
    scan_time = str2num(get(handles.TotalFrameLength,'String'));
    f_dynamic_str = ['1,',num2str(scan_time)]; 
    set(handles.frames_dynamic,'String',f_dynamic_str); 
    guidata(hObject, handles);
end



%f_dyn = make_dynframes(str2num(get(handles.TotalFrameLength,'String')));
%set(handles.frames_dynamic,'String',f_dyn);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function TotalFrameLength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TotalFrameLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ScanLength_Callback(hObject, eventdata, handles)
% hObject    handle to ScanLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ScanLength as text
%        str2double(get(hObject,'String')) returns contents of ScanLength as a double


% --- Executes during object creation, after setting all properties.
function ScanLength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ScanLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
	
	
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





function dose_Callback(hObject, eventdata, handles)
% hObject    handle to dose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dose as text
%        str2double(get(hObject,'String')) returns contents of dose as a double


% --- Executes during object creation, after setting all properties.
function dose_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over dose.
function dose_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to dose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% 
% function edit48_Callback(hObject, eventdata, handles)
% % hObject    handle to TotalFrameLength (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hints: get(hObject,'String') returns contents of TotalFrameLength as text
% %        str2double(get(hObject,'String')) returns contents of TotalFrameLength as a double
% 
% 
% % --- Executes during object creation, after setting all properties.
% function edit48_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to TotalFrameLength (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called
% 
% % Hint: edit controls usually have a white background on Windows.
% %       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end



function injection_time_edit_Callback(hObject, eventdata, handles)
% hObject    handle to injection_time_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of injection_time_edit as text
%        str2double(get(hObject,'String')) returns contents of injection_time_edit as a double


% --- Executes during object creation, after setting all properties.
function injection_time_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to injection_time_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in server_recon.
function server_recon_Callback(hObject, eventdata, handles)
% hObject    handle to server_recon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns server_recon contents as cell array
%        contents{get(hObject,'Value')} returns selected item from server_recon


% --- Executes during object creation, after setting all properties.
function server_recon_CreateFcn(hObject, eventdata, handles)
% hObject    handle to server_recon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
