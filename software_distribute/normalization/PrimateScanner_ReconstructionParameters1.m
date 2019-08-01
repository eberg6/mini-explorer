function varargout = PrimateScanner_ReconstructionParameters1(varargin)
% Last Modified by GUIDE v2.5 21-Aug-2017 10:23:58
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PrimateScanner_ReconstructionParameters_OpeningFcn, ...
                   'gui_OutputFcn',  @PrimateScanner_ReconstructionParameters_OutputFcn, ...
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
function PrimateScanner_ReconstructionParameters_OpeningFcn(hObject, eventdata, handles, varargin)
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
function varargout = PrimateScanner_ReconstructionParameters_OutputFcn(hObject, eventdata, handles) 

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
set(handles.save_output, 'enable', 'on');
set(handles.save_output, 'String', '');
set(handles.save_output_txt, 'enable', 'on');
set(handles.start2, 'enable', 'on');
set(handles.outcome, 'enable', 'off');
set(handles.sframe, 'enable', 'on');
set(handles.eframe, 'enable', 'on');
set(handles.iter, 'enable', 'on');
set(handles.sframe_txt, 'enable', 'on');
set(handles.eframe_txt, 'enable', 'on');
set(handles.iter_txt, 'enable', 'on');
set(handles.start4, 'enable', 'on');
set(handles.save_output, 'String', '');
set(handles.outcome2, 'enable', 'off');


function choose_Callback(hObject, eventdata, handles)
% if get(handles.study, 'Value') == 2
%     set(handles.start4, 'enable', 'off');
% end

[filename folder] = uigetfile({... % select file
   '*.lm', '.lm Files';...
   '*.*', 'All Files (*.*)';...   
   '*.txt', 'Text Files(*.txt)'},...
   'Select the Primate Scanner Image Dataset',...
   'C:\Documents\Primate scanner\process_lm_sino\Pick A Listmode File');
   % /run/media/meduser/data/software_distribute/users/
       
   

pathname_choose = fullfile(folder, filename);
set(handles.choose_text, 'String', pathname_choose);
handles.pathname_choose = pathname_choose;

if isequal(filename,0) == 1
    pathname_choose = '0';
    set(handles.choose_text, 'String', 'Error!')
end

handles.pathname_filename = filename; % .lm filename
handles.pathstr1 = folder; % .lm folder filepath
handles.pathname_choose = pathname_choose; % .lm filepath
guidata(hObject, handles);



% --- Executes on button press in norm.
function norm_Callback(hObject, eventdata, handles)

pathname_norm = uigetdir('/run/media/meduser/data/software_distribute/process_lm_sino', 'Select Normalization Folder');
% /run/media/meduser/data/software_distribute/reconstruction/normalization
set(handles.norm_text, 'String', pathname_norm)
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
set(handles.ct_text, 'String', pathname_ct);
handles.pathname_ct = pathname_ct;

if isequal(pathname_ct,0) == 1
    pathname_ct = '0';
    set(handles.ct_text, 'String', '0')
end

handles.pathname_ct = pathname_ct; % ct filepath
guidata(hObject, handles);



% --- Executes on button press in start2.
function start2_Callback(hObject, eventdata, handles)

%% values for .txt file

frames_dynamic = get(handles.frames_dynamic, 'String');
save_output = get(handles.save_output, 'String');

%% error messages

filename = 'Reconstruction_Parameters_1';
save_as = fullfile('/run/media/meduser/data/software_distribute/process_lm_sino_normalization/', filename);
    
valid_frames_dynamic = all(ismember(frames_dynamic, ', 1234567890'));

if isfield(handles, 'pathname_choose') == 0 ||...
   strcmp(handles.pathname_choose, '0') == 1
    errordlg('No .lm file selected', 'Brijesh Says!');
    a = 3;
elseif isfield(handles, 'pathname_norm') == 0 ||...
       strcmp(handles.pathname_norm, '0') == 1
    %errordlg('No Normalization Folder Selected', 'Brijesh Says!');
    %a = 3; 
elseif isempty(frames_dynamic) == 1
    errordlg('Enter dynamic frames information','Brijesh Says!');
    a = 3;
elseif valid_frames_dynamic == 0
    errordlg('Framing must only contain numeric values, spaces, and commas', 'Brijesh Says!');
    a = 3;
elseif isempty(save_output) == 1
    errordlg('Enter Name for Histogramming Output Folder', 'Brijesh Says!');
    a = 3;
elseif isfield(handles, 'save_output')
    mkdir(handles.pathstr1, save_output);
    mkdir1 = fullfile(handles.pathstr1, save_output);
end

%% execulte file
fov = '3';
static_dynamic = '1';
write_lm = '0';
write_sino = '1';
dtcor = '0';
rando = '0';
atcor = '0';
scatcor = '0';

dir2 = handles.pathname_norm; 
dir2 = [dir2,'/']; 

if (isfield(handles, 'pathname_choose') == 1) &&...
   (strcmp(handles.pathname_choose, '0') == 0) &&...
   (isfield(handles, 'pathname_ct') == 1) &&...
   (strcmp(handles.pathname_ct, '0') == 0) &&...
   (valid_frames_dynamic == 1) &&...
   (isempty(frames_dynamic) == 0) &&...
   (isempty(save_output) == 0)

    a = 1;
    
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
        scatcor);

   fclose(fid);

elseif (isfield(handles, 'pathname_choose') == 1) &&...
       (strcmp(handles.pathname_choose, '0') == 0) &&...
       (valid_frames_dynamic == 1) &&...
       (isempty(frames_dynamic) == 0) &&...
       ((isfield(handles, 'pathname_ct') == 0 ||...
       (strcmp(handles.pathname_ct, '0') == 1))) &&...
       (isempty(save_output) == 0)

    a = 2;
    handles.pathname_ct = '0';
    
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
        scatcor);

    % errordlg('Reminder: no CT Image selected, historgramming has commenced without it', 'Brijesh Says!');
       
    fclose(fid);
end

switch a
    case 1
        run = 'Histogramming started WITH CT';
        set(handles.start4, 'enable', 'on');
        disp('**** PROCESSING NORMALIZATION LISTMODE DATA... ****'); 
        
        fname = '/run/media/meduser/data/software_distribute/process_lm_sino_normalization/process_lm_sino_normalization';
        system(fname);
        
        disp('**** STARTING ITERATIVE NORMALIZATION... ****'); 
        
        iternorm(mkdir1,dir2); % do iterative normalization
        
        disp('**** MAKING BP IMAGES... ****'); 
        
        mkdir(dir2,'bp77');
        mkdir(dir2,'bp129');
        mkdir(dir2,'bp157');
        
        make_bp_config(dir2,77);
        make_bp_config(dir2,129);
        make_bp_config(dir2,157);  
        
        
        make_bp_run_sh(dir2,77);
        
        fname = 'sh /run/media/meduser/data/software_distribute/reconstruction/lm_recon/run_bp.sh';
        system(fname);
        
        pause(1)
        
        ff1 = ['mv /run/media/meduser/data/software_distribute/normalization/bp ',dir2,'bp77/'];
        system(ff1);
        
        disp('Finished making bp file for 77 bins'); 
        
        
        make_bp_run_sh(dir2,129);
        
        fname = 'sh /run/media/meduser/data/software_distribute/reconstruction/lm_recon/run_bp.sh';
        system(fname);
        
        pause(1);
        
        ff1 = ['mv /run/media/meduser/data/software_distribute/normalization/bp ',dir2,'bp129/'];
        system(ff1);
        
        disp('Finished making bp file for 129 bins');
        
        
        
        make_bp_run_sh(dir2,157);
        
        fname = 'sh /run/media/meduser/data/software_distribute/reconstruction/lm_recon/run_bp.sh';
        system(fname);
        
        pause(1)
        
        ff1 = ['mv /run/media/meduser/data/software_distribute/normalization/bp ',dir2,'bp157/'];
        system(ff1);
        
        disp('Finished making bp file for 157 bins');
        
    case 2
        run = 'Histogramming started WITHOUT CT';
        set(handles.start4, 'enable', 'on'); 
        
        disp('**** PROCESSING NORMALIZATION LISTMODE DATA... ****'); 
        
        fname = '/run/media/meduser/data/software_distribute/process_lm_sino_normalization/process_lm_sino_normalization';
        system(fname);
        
        disp('**** STARTING ITERATIVE NORMALIZATION... ****'); 
        
        iternorm(mkdir1,dir2); 
        
        disp('**** MAKING BP IMAGES... ****'); 
        
        mkdir(dir2,'bp77');
        mkdir(dir2,'bp129');
        mkdir(dir2,'bp157');
        
        make_bp_config(dir2,77);
        make_bp_config(dir2,129);
        make_bp_config(dir2,157); 
        
        
        make_bp_run_sh(dir2,77);
        
        fname = 'sh /run/media/meduser/data/software_distribute/reconstruction/lm_recon/run_bp.sh';
        system(fname);
        
        pause(1)
        
        ff1 = ['mv /run/media/meduser/data/software_distribute/normalization/bp ',dir2,'bp77/'];
        system(ff1);
        
        disp('Finished making bp file for 77 bins'); 
        
        
        make_bp_run_sh(dir2,129);
        
        fname = 'sh /run/media/meduser/data/software_distribute/reconstruction/lm_recon/run_bp.sh';
        system(fname);
        
        pause(1);
        
        ff1 = ['mv /run/media/meduser/data/software_distribute/normalization/bp ',dir2,'bp129/'];
        system(ff1);
        
        disp('Finished making bp file for 129 bins');
        
        
        
        make_bp_run_sh(dir2,157);
        
        fname = 'sh /run/media/meduser/data/software_distribute/reconstruction/lm_recon/run_bp.sh';
        system(fname);
        
        pause(1)
        
        ff1 = ['mv /run/media/meduser/data/software_distribute/normalization/bp ',dir2,'bp157/'];
        system(ff1);
        
        disp('Finished making bp file for 157 bins');
        
        
        
        
        
        
        
    case 3
        run = 'Not started, fix errors to begin histogramming';
        set(handles.start4, 'enable', 'off');
end
set(handles.outcome, 'String', run);



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

%% values for .txt file
recon_lm = get(handles.recon_lm, 'Value');
recon_lm_tof = get(handles.recon_lm_tof, 'Value');
recon_sino = get(handles.recon_sino, 'Value');
switch 1
    case recon_lm_tof
        recon = 1;
    case recon_lm
        recon = 2;
    case recon_sino
        recon = 3;
end

recon_all = get(handles.recon_all, 'Value');
recon_select = get(handles.recon_select, 'Value');
switch 1
    case recon_all
        frames = 1;
    case recon_select
        frames = 2;
end

sframe = get(handles.sframe, 'String');
eframe = get(handles.eframe, 'String');
iter = get(handles.iter, 'String');
save_output = get(handles.save_output, 'String');

%% error messages
valid_sframe = all(isstrprop(sframe, 'digit'));
valid_eframe = all(isstrprop(eframe, 'digit'));
valid_iter = all(isstrprop(iter, 'digit'));

if valid_sframe == 0 || valid_eframe == 0
    errordlg('Start and End Frames must only contain numeric values (no spaces)', 'Brijesh Says!');
    a = 7;
elseif isempty(sframe) == 1
    errordlg('Enter Start Frame','Brijesh Says!');
    a = 7;
elseif isempty(eframe) == 1
    errordlg('Enter End Frame','Brijesh Says!');
    a = 7;
elseif isempty(iter) == 1
    errordlg('Enter Number of Iterations','Brijesh Says!');
    a = 7;
elseif valid_iter == 0
    errordlg('Iterations must only contain numeric values (no spaces)', 'Brijesh Says!')
    a = 7;
elseif str2num(sframe) > str2num(eframe)
    errordlg('Start Frame must be smaller than End Frame', 'Brijesh Says!');
    a = 7;
elseif str2num(iter) > 100
    errordlg('Must have 100 iterations or less', 'Brijesh Says!');
    a = 7;
end


%% execute file
filename2 = 'Reconstruction_Parameters_2_simple.txt';
save_as2 = fullfile('c:/Documents/Primate scanner/process_lm_sino/', filename2);

if  (valid_sframe == 1) &&...
    (valid_eframe == 1) &&...
    (valid_iter == 1) &&...
    (str2num(iter) < 101) &&...
    (str2num(eframe) >= str2num(sframe)) &&...
    ~(recon_lm == 0 && recon_sino == 0 && recon_lm_tof == 0) &&...
    (isempty(sframe) == 0) &&...
    (isempty(eframe) == 0) &&...
    (isempty(iter) == 0)
   
    if isfield(handles, 'pathstr1') == 1 && isfield(handles, 'save_output') == 1
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
            frames,...
            sframe,...
            eframe,...
            recon,...
            iter);
        fclose(fid);
        a = 8;
    end
% elseif  (valid_sframe == 1) &&...
%     (valid_eframe == 1) &&...
%     (valid_iter == 1) &&...
%     (valid_subs == 1) &&...
%     (str2num(iter) < 101) &&...
%     (str2num(subs) < 101) &&...
%     (str2num(eframe) >= str2num(sframe)) &&...
%     ~(recon_lm == 0 && recon_sino == 0 && recon_lm_tof == 0) &&...
%     (isempty(sframe) == 0) &&...
%     (isempty(eframe) == 0) &&...
%     (isempty(iter) == 0) &&...
%     (isempty(subs) == 0) &&...
%     (hist_yn == 2)
% 
%     switch 1
%         case isfield(handles, 'histy')
%             hist_dir = handles.histy;
%             pathname_start4 = uigetdir(hist_dir, 'Select Data Folder');
%             set(handles.outcome2, 'String', pathname_start4);
%             handles.pathname_start4 = pathname_start4;
%     end 
%     
%     if (isequal(pathname_start4,0) == 1)
% %        (strcmp(pathname_start4, 'C:\') == 1)
%         errordlg('Invalid directory chosen.', 'Brijesh Says!')
%         a = 7;
%     else
%         fid=fopen(save_as2,'wt');
%         fprintf(fid,'%s\n%.0f\n%s\n%s\n%.0f\n%s\n%s\n',...
%             pathname_start4,...
%             frames,...
%             sframe,...
%             eframe,...
%             recon,...
%             iter,...
%             subs);
%         fclose(fid);
%         a = 8;
%     end
end

switch a
    case 8
        run = pathname_start4;
    case 7
        run = 'Not Saved';
end
set(handles.outcome2, 'String', run);
guidata(hObject, handles);



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



% --- Executes when selected object is changed in fov.
function fov_SelectionChangeFcn(hObject, eventdata, handles)



% --- Executes during object creation, after setting all properties.
function recon_panel_CreateFcn(hObject, eventdata, handles)



% --- Executes on button press in correction_dt.
function correction_dt_Callback(hObject, eventdata, handles)



% --- Executes on button press in scatter.
function scatter_Callback(hObject, eventdata, handles)



% --- Executes on button press in attenuation.
function attenuation_Callback(hObject, eventdata, handles)



% Hint: get(hObject,'Value') returns toggle state of attenuation
function frames_dynamic_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function frames_dynamic_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function save_output_Callback(hObject, eventdata, handles)

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



function iter_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function iter_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function subs_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function subs_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



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
