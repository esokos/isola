function varargout = crustmodnew2(varargin)
% CRUSTMODNEW2 M-file for crustmodnew2.fig
%      CRUSTMODNEW2, by itself, creates a new CRUSTMODNEW2 or raises the existing
%      singleton*.
%
%      H = CRUSTMODNEW2 returns the handle to a new CRUSTMODNEW2 or the handle to
%      the existing singleton*.
%
%      CRUSTMODNEW2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CRUSTMODNEW2.M with the given input arguments.
%
%      CRUSTMODNEW2('Property','Value',...) creates a new CRUSTMODNEW2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before crustmodnew2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to crustmodnew2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help crustmodnew2

% Last Modified by GUIDE v2.5 17-Nov-2020 21:52:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @crustmodnew2_OpeningFcn, ...
                   'gui_OutputFcn',  @crustmodnew2_OutputFcn, ...
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


% --- Executes just before crustmodnew2 is made visible.
function crustmodnew2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to crustmodnew2 (see VARARGIN)

% Choose default command line output for crustmodnew2
handles.output = hObject;

disp('This is Crustmodnew 14/10/2019');
%
% added crustalmodel.isl creation to remember last file
% 999 is not used anymore to signal end of layers empty box is enough !!


h=dir('green.isl');
%%
if length(h) == 0; 
  disp('Green.isl file doesn''t exist. Single crustal model options will be used.');
  
        fid = fopen('green.isl','w');
         if ispc
           fprintf(fid,'%s\r\n','single');
         else
           fprintf(fid,'%s\n','single');
         end
        fclose(fid);
          
else
    fid = fopen('green.isl','r');
    mulorsin=fscanf(fid,'%s',1);
    fclose(fid);

    switch  mulorsin 
        
        case 'multiple'
          disp('Multiple crustal model options found.')
          
          button = questdlg('Found multiple crustal model options.Do you want to switch to single crustal model?',...
          'Continue Operation','Yes','No','Yes');
      
                  if strcmp(button,'Yes')
                        disp('Switch to single crustal model mode.')
                        
                                fid = fopen('green.isl','w');
                                  if ispc
                                       fprintf(fid,'%s\r\n','single');
                                  else
                                       fprintf(fid,'%s\n','single');
                                  end
                                fclose(fid);
                                
                  elseif strcmp(button,'No')
                        disp('Canceled crustal model change. Continue with multiple model case.')
                  end
      
         case 'single'
           disp('Single crustal model case')  
      end
    
end

%%
h=dir('crustalmodel.isl');

if length(h) == 0; 
  disp('Crustalmodel.isl file doesn''t exist. Start with a blank crustal model form. You can fill the form by hand or load a crustal file.');
    % start in a new folder with a blank form...
    for i=1:15
        eval(['set(handles.depth' num2str(i) ',''String'','''')']);
        eval(['set(handles.vp' num2str(i) ',''String'','''')']);
        eval(['set(handles.vs' num2str(i) ',''String'','''')']);
        eval(['set(handles.density' num2str(i) ',''String'','''')']);
        eval(['set(handles.qp' num2str(i) ',''String'','''')']);
        eval(['set(handles.qs' num2str(i) ',''String'','''')']);
    end
  
  set(handles.mtitle,'String','');
  
else
    fid = fopen('crustalmodel.isl','r');
   % crufile=fscanf(fid,'%s',1);
    crufile=fgetl(fid);
    fclose(fid);
    disp(['Found Crustalmodel.isl. File ' crufile ' will be loaded'])

%%% check if this file exists...!!!
    
    h=dir(crufile);
  
   if length(h) == 0; 
         disp(['Crustal model file '   crufile '  doesn''t exist. Default crustal model will be loaded']);
   else
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      fid  = fopen(crufile,'r');
       line=fgets(fid);         %01 line
       title=line(28:length(line)-2);
       line=fgets(fid);         %02 line
       line=fgets(fid);         %03 line
       nlayers=sscanf(line(1:length(line)-2),'%i');
       
       disp(['Model has ' num2str(nlayers) ' layers'])
       
       %%%check if > 15
     if nlayers > 15
           %  errordlg('Model has more than 15 layers','Error');
            warndlg({'Previoulsy selected model has more than 15 layers.'; 'It cannot be loaded here automatically. Default model will be loaded.'},'!! Warning !!');
%             set(handles.mtitle,'String',title);
%            %
%             line=fgets(fid);         %04 line
%             line=fgets(fid);         %05 line
%             c=fscanf(fid,'%g %g %g %g %g %g',[6 nlayers]);       
%             c = c';
%             fclose(fid);
%       
%             %% PUT VALUES IN THE FORM........
%             for i=1:15
%             eval(['set(handles.depth'   num2str(i) ',''Enable'',''off'')']);
%             eval(['set(handles.vp'      num2str(i) ',''Enable'',''off'')']);
%             eval(['set(handles.vs'      num2str(i) ',''Enable'',''off'')']);
%             eval(['set(handles.density' num2str(i) ',''Enable'',''off'')']);
%             eval(['set(handles.qp'      num2str(i) ',''Enable'',''off'')']);
%             eval(['set(handles.qs'      num2str(i) ',''Enable'',''off'')']);
%             end
%             
%  
%             % save all model in handles
%                 handles.nlayers=nlayers;
%                 handles.largemodel=c;
%                 handles.modeltitle=title;   
%             % Update handles structure
%                 guidata(hObject, handles);
     else
       %%
        line=fgets(fid);         %04 line
        line=fgets(fid);         %05 line
        c=fscanf(fid,'%g %g %g %g %g %g',[6 nlayers]);
        c = c';
        fclose(fid);
        
        % PUT VALUES IN THE FORM........
        %title
        set(handles.mtitle,'String',title);
        for i=1:nlayers
           eval(['set(handles.depth' num2str(i) ',''String'',num2str(c(' num2str(i) ',1)))']);
           eval(['set(handles.vp' num2str(i) ',''String'',num2str(c(' num2str(i) ',2)))']);
           eval(['set(handles.vs' num2str(i) ',''String'',num2str(c(' num2str(i) ',3)))']);
           eval(['set(handles.density' num2str(i) ',''String'',num2str(c(' num2str(i) ',4)))']);
           eval(['set(handles.qp' num2str(i) ',''String'',num2str(c(' num2str(i) ',5)))']);
           eval(['set(handles.qs' num2str(i) ',''String'',num2str(c(' num2str(i) ',6)))']);
        end
        for i=nlayers+1:15
           eval(['set(handles.depth' num2str(i) ',''String'','''')']);
           eval(['set(handles.vp' num2str(i) ',''String'','''')']);
           eval(['set(handles.vs' num2str(i) ',''String'','''')']);
           eval(['set(handles.density' num2str(i) ',''String'','''')']);
           eval(['set(handles.qp' num2str(i) ',''String'','''')']);
           eval(['set(handles.qs' num2str(i) ',''String'','''')']);
        end
   
     end  % nlayers if

   end  % length(h) == 0;

end  % dir('crustalmodel.isl');  if

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes crustmodnew2 wait for user response (see UIRESUME)
% uiwait(handles.crustmodnew2);


% --- Outputs from this function are returned to the command line.
function varargout = crustmodnew2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function vp1_Callback(hObject, eventdata, handles)
% hObject    handle to vp1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vp1 as text
%        str2double(get(hObject,'String')) returns contents of vp1 as a double


% --- Executes during object creation, after setting all properties.
function vp1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vp1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vp8_Callback(hObject, eventdata, handles)
% hObject    handle to vp8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vp8 as text
%        str2double(get(hObject,'String')) returns contents of vp8 as a double


% --- Executes during object creation, after setting all properties.
function vp8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vp8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vp7_Callback(hObject, eventdata, handles)
% hObject    handle to vp7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vp7 as text
%        str2double(get(hObject,'String')) returns contents of vp7 as a double


% --- Executes during object creation, after setting all properties.
function vp7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vp7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vp9_Callback(hObject, eventdata, handles)
% hObject    handle to vp9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vp9 as text
%        str2double(get(hObject,'String')) returns contents of vp9 as a double


% --- Executes during object creation, after setting all properties.
function vp9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vp9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vp10_Callback(hObject, eventdata, handles)
% hObject    handle to vp10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vp10 as text
%        str2double(get(hObject,'String')) returns contents of vp10 as a double


% --- Executes during object creation, after setting all properties.
function vp10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vp10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vp3_Callback(hObject, eventdata, handles)
% hObject    handle to vp3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vp3 as text
%        str2double(get(hObject,'String')) returns contents of vp3 as a double


% --- Executes during object creation, after setting all properties.
function vp3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vp3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vp2_Callback(hObject, eventdata, handles)
% hObject    handle to vp2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vp2 as text
%        str2double(get(hObject,'String')) returns contents of vp2 as a double


% --- Executes during object creation, after setting all properties.
function vp2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vp2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vp4_Callback(hObject, eventdata, handles)
% hObject    handle to vp4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vp4 as text
%        str2double(get(hObject,'String')) returns contents of vp4 as a double


% --- Executes during object creation, after setting all properties.
function vp4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vp4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vp6_Callback(hObject, eventdata, handles)
% hObject    handle to vp6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vp6 as text
%        str2double(get(hObject,'String')) returns contents of vp6 as a double


% --- Executes during object creation, after setting all properties.
function vp6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vp6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vp5_Callback(hObject, eventdata, handles)
% hObject    handle to vp5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vp5 as text
%        str2double(get(hObject,'String')) returns contents of vp5 as a double


% --- Executes during object creation, after setting all properties.
function vp5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vp5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vs1_Callback(hObject, eventdata, handles)
% hObject    handle to vs1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vs1 as text
%        str2double(get(hObject,'String')) returns contents of vs1 as a double


% --- Executes during object creation, after setting all properties.
function vs1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vs1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vs8_Callback(hObject, eventdata, handles)
% hObject    handle to vs8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vs8 as text
%        str2double(get(hObject,'String')) returns contents of vs8 as a double


% --- Executes during object creation, after setting all properties.
function vs8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vs8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vs7_Callback(hObject, eventdata, handles)
% hObject    handle to vs7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vs7 as text
%        str2double(get(hObject,'String')) returns contents of vs7 as a double


% --- Executes during object creation, after setting all properties.
function vs7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vs7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vs9_Callback(hObject, eventdata, handles)
% hObject    handle to vs9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vs9 as text
%        str2double(get(hObject,'String')) returns contents of vs9 as a double


% --- Executes during object creation, after setting all properties.
function vs9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vs9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vs10_Callback(hObject, eventdata, handles)
% hObject    handle to vs10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vs10 as text
%        str2double(get(hObject,'String')) returns contents of vs10 as a double


% --- Executes during object creation, after setting all properties.
function vs10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vs10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vs3_Callback(hObject, eventdata, handles)
% hObject    handle to vs3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vs3 as text
%        str2double(get(hObject,'String')) returns contents of vs3 as a double


% --- Executes during object creation, after setting all properties.
function vs3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vs3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vs2_Callback(hObject, eventdata, handles)
% hObject    handle to vs2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vs2 as text
%        str2double(get(hObject,'String')) returns contents of vs2 as a double


% --- Executes during object creation, after setting all properties.
function vs2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vs2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vs4_Callback(hObject, eventdata, handles)
% hObject    handle to vs4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vs4 as text
%        str2double(get(hObject,'String')) returns contents of vs4 as a double


% --- Executes during object creation, after setting all properties.
function vs4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vs4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vs6_Callback(hObject, eventdata, handles)
% hObject    handle to vs6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vs6 as text
%        str2double(get(hObject,'String')) returns contents of vs6 as a double


% --- Executes during object creation, after setting all properties.
function vs6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vs6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vs5_Callback(hObject, eventdata, handles)
% hObject    handle to vs5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vs5 as text
%        str2double(get(hObject,'String')) returns contents of vs5 as a double


% --- Executes during object creation, after setting all properties.
function vs5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vs5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function qp1_Callback(hObject, eventdata, handles)
% hObject    handle to qp1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of qp1 as text
%        str2double(get(hObject,'String')) returns contents of qp1 as a double


% --- Executes during object creation, after setting all properties.
function qp1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qp1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function qp8_Callback(hObject, eventdata, handles)
% hObject    handle to qp8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of qp8 as text
%        str2double(get(hObject,'String')) returns contents of qp8 as a double


% --- Executes during object creation, after setting all properties.
function qp8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qp8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function qp7_Callback(hObject, eventdata, handles)
% hObject    handle to qp7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of qp7 as text
%        str2double(get(hObject,'String')) returns contents of qp7 as a double


% --- Executes during object creation, after setting all properties.
function qp7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qp7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function qp9_Callback(hObject, eventdata, handles)
% hObject    handle to qp9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of qp9 as text
%        str2double(get(hObject,'String')) returns contents of qp9 as a double


% --- Executes during object creation, after setting all properties.
function qp9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qp9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function qp10_Callback(hObject, eventdata, handles)
% hObject    handle to qp10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of qp10 as text
%        str2double(get(hObject,'String')) returns contents of qp10 as a double


% --- Executes during object creation, after setting all properties.
function qp10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qp10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function qp3_Callback(hObject, eventdata, handles)
% hObject    handle to qp3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of qp3 as text
%        str2double(get(hObject,'String')) returns contents of qp3 as a double


% --- Executes during object creation, after setting all properties.
function qp3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qp3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function qp2_Callback(hObject, eventdata, handles)
% hObject    handle to qp2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of qp2 as text
%        str2double(get(hObject,'String')) returns contents of qp2 as a double


% --- Executes during object creation, after setting all properties.
function qp2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qp2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function qp4_Callback(hObject, eventdata, handles)
% hObject    handle to qp4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of qp4 as text
%        str2double(get(hObject,'String')) returns contents of qp4 as a double


% --- Executes during object creation, after setting all properties.
function qp4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qp4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function qp6_Callback(hObject, eventdata, handles)
% hObject    handle to qp6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of qp6 as text
%        str2double(get(hObject,'String')) returns contents of qp6 as a double


% --- Executes during object creation, after setting all properties.
function qp6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qp6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function qp5_Callback(hObject, eventdata, handles)
% hObject    handle to qp5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of qp5 as text
%        str2double(get(hObject,'String')) returns contents of qp5 as a double


% --- Executes during object creation, after setting all properties.
function qp5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qp5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function qs1_Callback(hObject, eventdata, handles)
% hObject    handle to qs1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of qs1 as text
%        str2double(get(hObject,'String')) returns contents of qs1 as a double


% --- Executes during object creation, after setting all properties.
function qs1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qs1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function qs8_Callback(hObject, eventdata, handles)
% hObject    handle to qs8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of qs8 as text
%        str2double(get(hObject,'String')) returns contents of qs8 as a double


% --- Executes during object creation, after setting all properties.
function qs8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qs8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function qs7_Callback(hObject, eventdata, handles)
% hObject    handle to qs7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of qs7 as text
%        str2double(get(hObject,'String')) returns contents of qs7 as a double


% --- Executes during object creation, after setting all properties.
function qs7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qs7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function qs9_Callback(hObject, eventdata, handles)
% hObject    handle to qs9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of qs9 as text
%        str2double(get(hObject,'String')) returns contents of qs9 as a double


% --- Executes during object creation, after setting all properties.
function qs9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qs9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function qs10_Callback(hObject, eventdata, handles)
% hObject    handle to qs10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of qs10 as text
%        str2double(get(hObject,'String')) returns contents of qs10 as a double


% --- Executes during object creation, after setting all properties.
function qs10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qs10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function qs3_Callback(hObject, eventdata, handles)
% hObject    handle to qs3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of qs3 as text
%        str2double(get(hObject,'String')) returns contents of qs3 as a double


% --- Executes during object creation, after setting all properties.
function qs3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qs3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function qs2_Callback(hObject, eventdata, handles)
% hObject    handle to qs2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of qs2 as text
%        str2double(get(hObject,'String')) returns contents of qs2 as a double


% --- Executes during object creation, after setting all properties.
function qs2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qs2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function qs4_Callback(hObject, eventdata, handles)
% hObject    handle to qs4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of qs4 as text
%        str2double(get(hObject,'String')) returns contents of qs4 as a double


% --- Executes during object creation, after setting all properties.
function qs4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qs4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function qs6_Callback(hObject, eventdata, handles)
% hObject    handle to qs6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of qs6 as text
%        str2double(get(hObject,'String')) returns contents of qs6 as a double


% --- Executes during object creation, after setting all properties.
function qs6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qs6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function qs5_Callback(hObject, eventdata, handles)
% hObject    handle to qs5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of qs5 as text
%        str2double(get(hObject,'String')) returns contents of qs5 as a double


% --- Executes during object creation, after setting all properties.
function qs5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qs5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Save_cru.
function Save_cru_Callback(hObject, eventdata, handles)
% hObject    handle to Save_cru (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Here we save crustal model in a file....

%% decide is we have a model with > 15 layers or not

if15=get(handles.depth1,'Enable');

 
switch if15
        
    case 'off'  % >15layers
        disp('Model has many layers > 15')
        % we must read from handles and write file in proper folder
        
        %% read model info from handles
        newdir=handles.newdir;stationfile=handles.stationfile;
        crustalmodel=handles.largemodel;
        mtitle=handles.modeltitle;
        %%
        [nlayers,~]=size(crustalmodel);
        disp(['Found crustal model with ' num2str(nlayers) '  layers'])
        %% we have to check if GREEN folder exists...
        
        h=dir('green');
        if size(h) > 0 
            cd green
            if ispc
                % KEEP THE NAME FIXED
                fid = fopen('crustal.dat','w');
                    fprintf(fid,'%s\r\n',['Crustal model                  ' mtitle]);
                    fprintf(fid,'%s\r\n','number of layers ');
                    fprintf(fid,'   %i\r\n',nlayers);
                    fprintf(fid,'%s\r\n','Parameters of the layers');
                    fprintf(fid,'%s\r\n','depth of layer top(km)   Vp(km/s)    Vs(km/s)    Rho(g/cm**3)    Qp     Qs');

                    for i=1:nlayers
                        fprintf(fid,'%9.3f%21.3f%12.3f%13.3f%12i%7i\r\n',crustalmodel(i,1),crustalmodel(i,2),crustalmodel(i,3),crustalmodel(i,4),crustalmodel(i,5),crustalmodel(i,6) );
                    end

                    fprintf(fid,'%s\r\n','*************************************************************************');
               fclose(fid);
            else
                % KEEP THE NAME FIXED
                fid = fopen('crustal.dat','w');
                    fprintf(fid,'%s\n',['Crustal model                  ' mtitle]);
                    fprintf(fid,'%s\n','number of layers ');
                    fprintf(fid,'   %i\n',nlayers);
                    fprintf(fid,'%s\n','Parameters of the layers');
                    fprintf(fid,'%s\n','depth of layer top(km)   Vp(km/s)    Vs(km/s)    Rho(g/cm**3)    Qp     Qs');

                    for i=1:nlayers
                        fprintf(fid,'%9.3f%21.3f%12.3f%13.3f%12i%7i\n',crustalmodel(i,1),crustalmodel(i,2),crustalmodel(i,3),crustalmodel(i,4),crustalmodel(i,5),crustalmodel(i,6) );
                    end

                    fprintf(fid,'%s\n','*************************************************************************');
                fclose(fid);
            end
        cd ..
        pwd
        else
            errordlg('Green folder doesn''t exist. Please create it. ','Folder Error');
        end
        
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

       h=msgbox('Crustal model was saved in GREEN folder as crustal.dat file.','Save crustal model');

%% now create crustalmodel.isl
        try
            newdir=handles.newdir;    stationfile=handles.stationfile;

        fid = fopen('crustalmodel.isl','w');
            if ispc
            fprintf(fid,'%s\r\n',[newdir stationfile]);
            else
            fprintf(fid,'%s\n',[newdir stationfile]);
            end
    
        fclose(fid);   

        catch      %% in case user doesn't load a file but creates a new one
    
            newdir=pwd;  stationfile='\green\crustal.dat';
  
        fid = fopen('crustalmodel.isl','w');
            if ispc 
            fprintf(fid,'%s\r\n',[newdir stationfile]);
            else
            fprintf(fid,'%s\n',[newdir stationfile]);
            end
        fclose(fid);     
    
        end
        
        %%
        set(handles.Cancel,'Enable','On')
    
        
    case 'on'   % <= 15 layers
      disp('Model number of layers is <= 15')
    
      
      % find how many layers we have
    crustalmodel(1,1)=str2double(get(handles.depth1,'String'));    crustalmodel(2,1)=str2double(get(handles.depth2,'String'));
    crustalmodel(3,1)=str2double(get(handles.depth3,'String'));    crustalmodel(4,1)=str2double(get(handles.depth4,'String'));
    crustalmodel(5,1)=str2double(get(handles.depth5,'String'));    crustalmodel(6,1)=str2double(get(handles.depth6,'String'));
    crustalmodel(7,1)=str2double(get(handles.depth7,'String'));    crustalmodel(8,1)=str2double(get(handles.depth8,'String'));
    crustalmodel(9,1)=str2double(get(handles.depth9,'String'));    crustalmodel(10,1)=str2double(get(handles.depth10,'String'));
    crustalmodel(11,1)=str2double(get(handles.depth11,'String'));  crustalmodel(12,1)=str2double(get(handles.depth12,'String'));
    crustalmodel(13,1)=str2double(get(handles.depth13,'String')); crustalmodel(14,1)=str2double(get(handles.depth14,'String'));
    crustalmodel(15,1)=str2double(get(handles.depth15,'String'));
%
    for i=15:-1:1
        if isnan(crustalmodel(i,1))
            nlayers=i-1;
        end
    end

    disp(['Found crustal model with ' num2str(nlayers) '  layers'])
%% First we put values in a matrix....
     %read title
     mtitle=get(handles.mtitle,'String');
     
     for i=1:nlayers
         % DEPTH,vp,vs,Density,Qp,Qs
          eval(['crustalmodel(' num2str(i) ',1)=str2double(get(handles.depth' num2str(i) ',''String''));']);
          eval(['crustalmodel(' num2str(i) ',2)=str2double(get(handles.vp' num2str(i) ',''String''));']);
          eval(['crustalmodel(' num2str(i) ',3)=str2double(get(handles.vs' num2str(i) ',''String''));']);
          eval(['crustalmodel(' num2str(i) ',4)=str2double(get(handles.density' num2str(i) ',''String''));']);
          eval(['crustalmodel(' num2str(i) ',5)=str2double(get(handles.qp' num2str(i) ',''String''));']);
          eval(['crustalmodel(' num2str(i) ',6)=str2double(get(handles.qs' num2str(i) ',''String''));']);
     end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%we have to check if GREEN folder exists...

h=dir('green');

if size(h) > 0 
  cd green
    pwd
   if ispc
    %%%%%%%%KEEP THE NAME FIXED
    fid = fopen('crustal.dat','w');
    fprintf(fid,'%s\r\n',['Crustal model                  ' mtitle]);
    fprintf(fid,'%s\r\n','number of layers ');
    fprintf(fid,'   %i\r\n',nlayers);
    fprintf(fid,'%s\r\n','Parameters of the layers');
    fprintf(fid,'%s\r\n','depth of layer top(km)   Vp(km/s)    Vs(km/s)    Rho(g/cm**3)    Qp     Qs');

      for i=1:nlayers
       fprintf(fid,'%9.3f%21.3f%12.3f%13.3f%12i%7i\r\n',crustalmodel(i,1),crustalmodel(i,2),crustalmodel(i,3),crustalmodel(i,4),crustalmodel(i,5),crustalmodel(i,6) );
      end

    fprintf(fid,'%s\r\n','*************************************************************************');
    fclose(fid);
   else
    %%%%%%%%KEEP THE NAME FIXED
    fid = fopen('crustal.dat','w');
    fprintf(fid,'%s\n',['Crustal model                  ' mtitle]);
    fprintf(fid,'%s\n','number of layers ');
    fprintf(fid,'   %i\n',nlayers);
    fprintf(fid,'%s\n','Parameters of the layers');
    fprintf(fid,'%s\n','depth of layer top(km)   Vp(km/s)    Vs(km/s)    Rho(g/cm**3)    Qp     Qs');

      for i=1:nlayers
       fprintf(fid,'%9.3f%21.3f%12.3f%13.3f%12i%7i\n',crustalmodel(i,1),crustalmodel(i,2),crustalmodel(i,3),crustalmodel(i,4),crustalmodel(i,5),crustalmodel(i,6) );
      end

    fprintf(fid,'%s\n','*************************************************************************');
    fclose(fid);
   end
  cd ..
    pwd
else
    errordlg('Green folder doesn''t exist. Please create it. ','Folder Error');
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   h=msgbox('Crustal model was saved in GREEN folder as crustal.dat file.','Save crustal model');

%% %% now create crustalmodel.isl
try
   newdir=handles.newdir;    stationfile=handles.stationfile;

  fid = fopen('crustalmodel.isl','w');
    if ispc
       fprintf(fid,'%s\r\n',[newdir stationfile]);
    else
       fprintf(fid,'%s\n',[newdir stationfile]);
    end
    
  fclose(fid);   

catch      %% in case user doesn't load a file but creates a new one
    
  newdir=pwd;
  stationfile='\green\crustal.dat';
  
  fid = fopen('crustalmodel.isl','w');
    if ispc 
       fprintf(fid,'%s\r\n',[newdir stationfile]);
    else
       fprintf(fid,'%s\n',[newdir stationfile]);
    end
  fclose(fid);     
    
end

set(handles.Cancel,'Enable','On')
    
end

 



% --- Executes on button press in Read_cru.
function Read_cru_Callback(hObject, eventdata, handles)
% hObject    handle to Read_cru (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% IF THE FORMAT IS RETAINED.................!!

[stationfile, newdir] = uigetfile('*.cru', 'Select crustal model file');

   if stationfile == 0
       disp('File load canceled')
       return
   else
   end

%%
fid  = fopen([newdir, stationfile],'r');
       line=fgets(fid);         %01 line
       title=line(28:length(line)-2);
      
       line=fgets(fid);         %02 line
       line=fgets(fid);         %03 line
       nlayers=sscanf(line(1:length(line)-2),'%i');
       
       disp(['Model has ' num2str(nlayers) ' layers'])
       
       %%%check if > 15 
        if nlayers > 15
            warndlg({'Model has more than 15 layers.'; 'You cannot edit this model here but you can Save and Plot it.'},'!! Warning !!');
        else
        end
        %%%%%
       line=fgets(fid);         %04 line
       line=fgets(fid);         %05 line

    c=fscanf(fid,'%g %g %g %g %g %g',[6 nlayers]);       
    c = c';
fclose(fid);

%% PUT VALUES IN THE FORM........
if nlayers <=15
      set(handles.mtitle,'String',title);
      
     for i=1:nlayers
           eval(['set(handles.depth' num2str(i) ',''String'',num2str(c(' num2str(i) ',1)))']);
           eval(['set(handles.vp' num2str(i) ',''String'',num2str(c(' num2str(i) ',2)))']);
           eval(['set(handles.vs' num2str(i) ',''String'',num2str(c(' num2str(i) ',3)))']);
           eval(['set(handles.density' num2str(i) ',''String'',num2str(c(' num2str(i) ',4)))']);
           eval(['set(handles.qp' num2str(i) ',''String'',num2str(c(' num2str(i) ',5)))']);
           eval(['set(handles.qs' num2str(i) ',''String'',num2str(c(' num2str(i) ',6)))']);
     end
     for i=nlayers+1:15
           eval(['set(handles.depth' num2str(i) ',''String'','''')']);
           eval(['set(handles.vp' num2str(i) ',''String'','''')']);
           eval(['set(handles.vs' num2str(i) ',''String'','''')']);
           eval(['set(handles.density' num2str(i) ',''String'','''')']);
           eval(['set(handles.qp' num2str(i) ',''String'','''')']);
           eval(['set(handles.qs' num2str(i) ',''String'','''')']);
     end
     
handles.newdir=newdir;
handles.stationfile=stationfile;
handles.nlayers=nlayers;
% Update handles structure
guidata(hObject, handles);

else
%% if the model has more than 15 layers we should save in handles!! and disable the text boxes
      set(handles.mtitle,'String',title);
      
%      for i=1:15
%            eval(['set(handles.depth' num2str(i) ',''String'',num2str(c(' num2str(i) ',1)))']);
%            eval(['set(handles.vp' num2str(i) ',''String'',num2str(c(' num2str(i) ',2)))']);
%            eval(['set(handles.vs' num2str(i) ',''String'',num2str(c(' num2str(i) ',3)))']);
%            eval(['set(handles.density' num2str(i) ',''String'',num2str(c(' num2str(i) ',4)))']);
%            eval(['set(handles.qp' num2str(i) ',''String'',num2str(c(' num2str(i) ',5)))']);
%            eval(['set(handles.qs' num2str(i) ',''String'',num2str(c(' num2str(i) ',6)))']);
%      end

     for i=1:15
           eval(['set(handles.depth'   num2str(i) ',''Enable'',''off'')']);
           eval(['set(handles.vp'      num2str(i) ',''Enable'',''off'')']);
           eval(['set(handles.vs'      num2str(i) ',''Enable'',''off'')']);
           eval(['set(handles.density' num2str(i) ',''Enable'',''off'')']);
           eval(['set(handles.qp'      num2str(i) ',''Enable'',''off'')']);
           eval(['set(handles.qs'      num2str(i) ',''Enable'',''off'')']);
     end
    
% save all model in handles
handles.newdir=newdir;
handles.stationfile=stationfile;
handles.nlayers=nlayers;
handles.largemodel=c;
handles.modeltitle=title;   
% Update handles structure
guidata(hObject, handles);
    
end


function vpvsvalue_Callback(hObject, eventdata, handles)
% hObject    handle to vpvsvalue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vpvsvalue as text
%        str2double(get(hObject,'String')) returns contents of vpvsvalue as a double


% --- Executes during object creation, after setting all properties.
function vpvsvalue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vpvsvalue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in vpvsCheck.
function vpvsCheck_Callback(hObject, eventdata, handles)
% hObject    handle to vpvsCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of vpvsCheck

%IF THIS IS PRESSED THE PROGRAM READS VP/VS RATIO AND VP AND CALCULATES VS

%%
checkstate=get(handles.vpvsCheck,'Value');
vpvs=str2double(get(handles.vpvsvalue,'String'));
%% find how many layers we have
crustalmodel(1,1)=str2double(get(handles.depth1,'String'));
crustalmodel(2,1)=str2double(get(handles.depth2,'String'));
crustalmodel(3,1)=str2double(get(handles.depth3,'String'));
crustalmodel(4,1)=str2double(get(handles.depth4,'String'));
crustalmodel(5,1)=str2double(get(handles.depth5,'String'));
crustalmodel(6,1)=str2double(get(handles.depth6,'String'));
crustalmodel(7,1)=str2double(get(handles.depth7,'String'));
crustalmodel(8,1)=str2double(get(handles.depth8,'String'));
crustalmodel(9,1)=str2double(get(handles.depth9,'String'));
crustalmodel(10,1)=str2double(get(handles.depth10,'String'));
crustalmodel(11,1)=str2double(get(handles.depth11,'String'));
crustalmodel(12,1)=str2double(get(handles.depth12,'String'));
crustalmodel(13,1)=str2double(get(handles.depth13,'String'));
crustalmodel(14,1)=str2double(get(handles.depth14,'String'));
crustalmodel(15,1)=str2double(get(handles.depth15,'String'));
%
for i=15:-1:1
   if isnan(crustalmodel(i,1))
      nlayers=i-1;
  end
end
disp(['Found crustal model with ' num2str(nlayers) '  layers'])
%%

if checkstate==1   % use vp/vs to calculate s velocity
      %save old values just in case !!!!!
      for i=1:nlayers
        eval(['handles.vs_old' num2str(i) '=str2double(get(handles.vs' num2str(i) ',''String''))'';']);
      end
      guidata(hObject, handles);
      %assign new S wave velocities.....
      for i=1:nlayers
         eval(['set(handles.vs' num2str(i) ',''String'',num2str(str2double(get(handles.vp' num2str(i) ',''String''))/vpvs,''%7.3f''))' ';']);
      end
elseif checkstate==0   % do not use vp/vs to calculate s velocity
      %put the old values back.....
      for i=1:nlayers
        eval(['vs_old' num2str(i) '=handles.vs_old' num2str(i) ';']);
        eval(['set(handles.vs' num2str(i) ',''String'',vs_old' num2str(i) ')';'']);
      end
end






function depth1_Callback(hObject, eventdata, handles)
% hObject    handle to depth1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of depth1 as text
%        str2double(get(hObject,'String')) returns contents of depth1 as a double


% --- Executes during object creation, after setting all properties.
function depth1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to depth1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function depth8_Callback(hObject, eventdata, handles)
% hObject    handle to depth8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of depth8 as text
%        str2double(get(hObject,'String')) returns contents of depth8 as a double


% --- Executes during object creation, after setting all properties.
function depth8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to depth8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function depth7_Callback(hObject, eventdata, handles)
% hObject    handle to depth7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of depth7 as text
%        str2double(get(hObject,'String')) returns contents of depth7 as a double


% --- Executes during object creation, after setting all properties.
function depth7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to depth7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function depth9_Callback(hObject, eventdata, handles)
% hObject    handle to depth9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of depth9 as text
%        str2double(get(hObject,'String')) returns contents of depth9 as a double


% --- Executes during object creation, after setting all properties.
function depth9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to depth9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function depth10_Callback(hObject, eventdata, handles)
% hObject    handle to depth10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of depth10 as text
%        str2double(get(hObject,'String')) returns contents of depth10 as a double


% --- Executes during object creation, after setting all properties.
function depth10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to depth10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function depth3_Callback(hObject, eventdata, handles)
% hObject    handle to depth3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of depth3 as text
%        str2double(get(hObject,'String')) returns contents of depth3 as a double


% --- Executes during object creation, after setting all properties.
function depth3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to depth3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function depth2_Callback(hObject, eventdata, handles)
% hObject    handle to depth2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of depth2 as text
%        str2double(get(hObject,'String')) returns contents of depth2 as a double


% --- Executes during object creation, after setting all properties.
function depth2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to depth2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function depth4_Callback(hObject, eventdata, handles)
% hObject    handle to depth4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of depth4 as text
%        str2double(get(hObject,'String')) returns contents of depth4 as a double


% --- Executes during object creation, after setting all properties.
function depth4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to depth4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function depth6_Callback(hObject, eventdata, handles)
% hObject    handle to depth6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of depth6 as text
%        str2double(get(hObject,'String')) returns contents of depth6 as a double


% --- Executes during object creation, after setting all properties.
function depth6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to depth6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function depth5_Callback(hObject, eventdata, handles)
% hObject    handle to depth5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of depth5 as text
%        str2double(get(hObject,'String')) returns contents of depth5 as a double


% --- Executes during object creation, after setting all properties.
function depth5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to depth5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function density1_Callback(hObject, eventdata, handles)
% hObject    handle to density1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of density1 as text
%        str2double(get(hObject,'String')) returns contents of density1 as a double


% --- Executes during object creation, after setting all properties.
function density1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to density1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function density8_Callback(hObject, eventdata, handles)
% hObject    handle to density8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of density8 as text
%        str2double(get(hObject,'String')) returns contents of density8 as a double


% --- Executes during object creation, after setting all properties.
function density8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to density8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function density7_Callback(hObject, eventdata, handles)
% hObject    handle to density7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of density7 as text
%        str2double(get(hObject,'String')) returns contents of density7 as a double


% --- Executes during object creation, after setting all properties.
function density7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to density7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function density9_Callback(hObject, eventdata, handles)
% hObject    handle to density9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of density9 as text
%        str2double(get(hObject,'String')) returns contents of density9 as a double


% --- Executes during object creation, after setting all properties.
function density9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to density9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function density10_Callback(hObject, eventdata, handles)
% hObject    handle to density10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of density10 as text
%        str2double(get(hObject,'String')) returns contents of density10 as a double


% --- Executes during object creation, after setting all properties.
function density10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to density10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function density3_Callback(hObject, eventdata, handles)
% hObject    handle to density3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of density3 as text
%        str2double(get(hObject,'String')) returns contents of density3 as a double


% --- Executes during object creation, after setting all properties.
function density3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to density3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function density2_Callback(hObject, eventdata, handles)
% hObject    handle to density2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of density2 as text
%        str2double(get(hObject,'String')) returns contents of density2 as a double


% --- Executes during object creation, after setting all properties.
function density2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to density2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function density4_Callback(hObject, eventdata, handles)
% hObject    handle to density4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of density4 as text
%        str2double(get(hObject,'String')) returns contents of density4 as a double


% --- Executes during object creation, after setting all properties.
function density4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to density4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function density6_Callback(hObject, eventdata, handles)
% hObject    handle to density6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of density6 as text
%        str2double(get(hObject,'String')) returns contents of density6 as a double


% --- Executes during object creation, after setting all properties.
function density6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to density6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function density5_Callback(hObject, eventdata, handles)
% hObject    handle to density5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of density5 as text
%        str2double(get(hObject,'String')) returns contents of density5 as a double


% --- Executes during object creation, after setting all properties.
function density5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to density5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in calcdensity.
function calcdensity_Callback(hObject, eventdata, handles)
% hObject    handle to calcdensity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of calcdensity

checkstatedensity=get(handles.calcdensity,'Value');

%% find how many layers we have
crustalmodel(1,1)=str2double(get(handles.depth1,'String'));
crustalmodel(2,1)=str2double(get(handles.depth2,'String'));
crustalmodel(3,1)=str2double(get(handles.depth3,'String'));
crustalmodel(4,1)=str2double(get(handles.depth4,'String'));
crustalmodel(5,1)=str2double(get(handles.depth5,'String'));
crustalmodel(6,1)=str2double(get(handles.depth6,'String'));
crustalmodel(7,1)=str2double(get(handles.depth7,'String'));
crustalmodel(8,1)=str2double(get(handles.depth8,'String'));
crustalmodel(9,1)=str2double(get(handles.depth9,'String'));
crustalmodel(10,1)=str2double(get(handles.depth10,'String'));
crustalmodel(11,1)=str2double(get(handles.depth11,'String'));
crustalmodel(12,1)=str2double(get(handles.depth12,'String'));
crustalmodel(13,1)=str2double(get(handles.depth13,'String'));
crustalmodel(14,1)=str2double(get(handles.depth14,'String'));
crustalmodel(15,1)=str2double(get(handles.depth15,'String'));
%
for i=15:-1:1
   if isnan(crustalmodel(i,1))
      nlayers=i-1;
  end
end
disp(['Found crustal model with ' num2str(nlayers) '  layers'])
%%
if checkstatedensity==1   % use d=1.7+0.2*Vp to calculate density
      %save old values just in case !!!!!
      for i=1:nlayers
        eval(['handles.density_old' num2str(i) '=str2double(get(handles.density' num2str(i) ',''String''))'';']);
      end
      guidata(hObject, handles);
      %assign new density values.....the formula is d=1.7+0.2*Vp
      for i=1:nlayers
         eval(['set(handles.density' num2str(i) ',''String'',num2str(1.7+str2double(get(handles.vp' num2str(i) ',''String''))*0.2,''%7.3f''))' ';']);
      end
elseif checkstatedensity==0   % do not use Vp to calculate density
     %put the old values back.....
     for i=1:nlayers
       eval(['density_old' num2str(i) '=handles.density_old' num2str(i) ';']);
       eval(['set(handles.density' num2str(i) ',''String'',density_old' num2str(i) ')';'']);
     end
%     
end


% --- Executes on button press in Plot_cru.
function Plot_cru_Callback(hObject, eventdata, handles)
% hObject    handle to Plot_cru (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% decide is we have a model with > 15 layers or not



if15=get(handles.depth1,'Enable');

switch if15
        
    case 'off'  % >15layers
        disp('Model number of layers is > 15. ')
        %% read model info from handles
        newdir=handles.newdir;stationfile=handles.stationfile;
        crustalmodel=handles.largemodel;
        vmtitle=handles.modeltitle;
        %%
        [nlayers,~]=size(crustalmodel);
        disp(['Found crustal model with ' num2str(nlayers) '  layers'])        
        
        %% prepare plot
        vmtitle=get(handles.mtitle,'String');

        for i=1:nlayers
            if  crustalmodel(i,1) < 999
                vp(i+1)=crustalmodel(i,2); vs(i+1)=crustalmodel(i,3); depth(i+1)=-crustalmodel(i,1);
            else
                break
            end
        end
        for i=1:length(depth)-1
            vptmp(i)=vp(i+1);  vstmp(i)=vs(i+1); depthtmp(i)=depth(i+1);
        end

        a=0; j=1; k=1;
        for i=1:(2*(length(depth)))-1
            if a==0
                dep3(i)=depth(k);     vp3(i)=vp(k);     vs3(i)=vs(k);     k=k+1;     a=1;    
            else
                dep3(i)=depthtmp(j);     vp3(i)=vp(j);     vs3(i)=vs(j);     j=j+1;     a=0;
            end
        end
    
        % % %%% add another layer for Moho....
            vp3=[vp3 vp(length(vp )) ];    vs3=[vs3 vs(length(vs )) ];    dep3=[dep3 depth(length(depth))-10 ];

        % plot Moho 
            mohoX=((vp(length(vp)-1)- vs(length(vs)-1))/2)+vs(length(vs)-1);  mohoY=depth(length(depth));

        figure(2)

        plot(vp3(3:length(vp3) ),-dep3(3:length(vp3) ),'-rs','LineWidth',2)
        axis ij
        hold on
        %grid
        plot(vs3(3:length(vs3) ),-dep3(3:length(vs3) ),'-bs','LineWidth',2)
        %text(mohoX,-mohoY,'\leftarrow moho \rightarrow','FontSize',16,'VerticalAlignment','middle')
        h = legend('Vp','Vs'); 
        grid
        xlabel('Velocity (km/sec)')
        ylabel('Depth (km)')
        title(['Plot of Vp, Vs  ' vmtitle])
        
        
    
    %%
    case 'on'   % <= 15 layers
        disp('Model number of layers is <= 15')
        % THIS IS DEPTH
        crustalmodel(1,1)=str2double(get(handles.depth1,'String'));crustalmodel(2,1)=str2double(get(handles.depth2,'String'));crustalmodel(3,1)=str2double(get(handles.depth3,'String'));
        crustalmodel(4,1)=str2double(get(handles.depth4,'String'));crustalmodel(5,1)=str2double(get(handles.depth5,'String'));crustalmodel(6,1)=str2double(get(handles.depth6,'String'));
        crustalmodel(7,1)=str2double(get(handles.depth7,'String'));crustalmodel(8,1)=str2double(get(handles.depth8,'String'));crustalmodel(9,1)=str2double(get(handles.depth9,'String'));
        crustalmodel(10,1)=str2double(get(handles.depth10,'String'));crustalmodel(11,1)=str2double(get(handles.depth11,'String'));crustalmodel(12,1)=str2double(get(handles.depth12,'String'));
        crustalmodel(13,1)=str2double(get(handles.depth13,'String'));crustalmodel(14,1)=str2double(get(handles.depth14,'String'));crustalmodel(15,1)=str2double(get(handles.depth15,'String'));
        % THIS IS Vp
        crustalmodel(1,2)=str2double(get(handles.vp1,'String'));crustalmodel(2,2)=str2double(get(handles.vp2,'String'));crustalmodel(3,2)=str2double(get(handles.vp3,'String'));
        crustalmodel(4,2)=str2double(get(handles.vp4,'String'));crustalmodel(5,2)=str2double(get(handles.vp5,'String'));crustalmodel(6,2)=str2double(get(handles.vp6,'String'));
        crustalmodel(7,2)=str2double(get(handles.vp7,'String'));crustalmodel(8,2)=str2double(get(handles.vp8,'String'));crustalmodel(9,2)=str2double(get(handles.vp9,'String'));
        crustalmodel(10,2)=str2double(get(handles.vp10,'String'));crustalmodel(11,2)=str2double(get(handles.vp11,'String'));crustalmodel(12,2)=str2double(get(handles.vp12,'String'));
        crustalmodel(13,2)=str2double(get(handles.vp13,'String'));crustalmodel(14,2)=str2double(get(handles.vp14,'String'));crustalmodel(15,2)=str2double(get(handles.vp15,'String'));
        % THIS IS Vs
        crustalmodel(1,3)=str2double(get(handles.vs1,'String'));crustalmodel(2,3)=str2double(get(handles.vs2,'String'));crustalmodel(3,3)=str2double(get(handles.vs3,'String'));
        crustalmodel(4,3)=str2double(get(handles.vs4,'String'));crustalmodel(5,3)=str2double(get(handles.vs5,'String'));crustalmodel(6,3)=str2double(get(handles.vs6,'String'));
        crustalmodel(7,3)=str2double(get(handles.vs7,'String'));crustalmodel(8,3)=str2double(get(handles.vs8,'String'));crustalmodel(9,3)=str2double(get(handles.vs9,'String'));
        crustalmodel(10,3)=str2double(get(handles.vs10,'String'));crustalmodel(11,3)=str2double(get(handles.vs11,'String'));crustalmodel(12,3)=str2double(get(handles.vs12,'String'));
        crustalmodel(13,3)=str2double(get(handles.vs13,'String'));crustalmodel(14,3)=str2double(get(handles.vs14,'String'));crustalmodel(15,3)=str2double(get(handles.vs15,'String'));
        %% prepare plot
        vmtitle=get(handles.mtitle,'String');

        for i=1:15
            if  crustalmodel(i,1) < 999
                vp(i+1)=crustalmodel(i,2); vs(i+1)=crustalmodel(i,3); depth(i+1)=-crustalmodel(i,1);
            else
                break
            end
        end
        for i=1:length(depth)-1
            vptmp(i)=vp(i+1);  vstmp(i)=vs(i+1); depthtmp(i)=depth(i+1);
        end

        a=0; j=1; k=1;
        for i=1:(2*(length(depth)))-1
            if a==0
                dep3(i)=depth(k);     vp3(i)=vp(k);     vs3(i)=vs(k);     k=k+1;     a=1;    
            else
                dep3(i)=depthtmp(j);     vp3(i)=vp(j);     vs3(i)=vs(j);     j=j+1;     a=0;
            end
        end
    
        % % %%% add another layer for Moho....
            vp3=[vp3 vp(length(vp )) ];    vs3=[vs3 vs(length(vs )) ];    dep3=[dep3 depth(length(depth))-10 ];

        % plot Moho 
            mohoX=((vp(length(vp)-1)- vs(length(vs)-1))/2)+vs(length(vs)-1);  mohoY=depth(length(depth));

        figure(2)

        plot(vp3(3:length(vp3) ),-dep3(3:length(vp3) ),'-rs','LineWidth',2)
        axis ij
        hold on
        %grid
        plot(vs3(3:length(vs3) ),-dep3(3:length(vs3) ),'-bs','LineWidth',2)
        %text(mohoX,-mohoY,'\leftarrow moho \rightarrow','FontSize',16,'VerticalAlignment','middle')
        h = legend('Vp','Vs'); 
        grid
        xlabel('Velocity (km/sec)')
        ylabel('Depth (km)')
        title(['Plot of Vp, Vs  ' vmtitle])
    
end




function mtitle_Callback(hObject, eventdata, handles)
% hObject    handle to mtitle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mtitle as text
%        str2double(get(hObject,'String')) returns contents of mtitle as a double


% --- Executes during object creation, after setting all properties.
function mtitle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mtitle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vp14_Callback(hObject, eventdata, handles)
% hObject    handle to vp14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vp14 as text
%        str2double(get(hObject,'String')) returns contents of vp14 as a double


% --- Executes during object creation, after setting all properties.
function vp14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vp14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vp13_Callback(hObject, eventdata, handles)
% hObject    handle to vp13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vp13 as text
%        str2double(get(hObject,'String')) returns contents of vp13 as a double


% --- Executes during object creation, after setting all properties.
function vp13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vp13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vp15_Callback(hObject, eventdata, handles)
% hObject    handle to vp15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vp15 as text
%        str2double(get(hObject,'String')) returns contents of vp15 as a double


% --- Executes during object creation, after setting all properties.
function vp15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vp15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vp12_Callback(hObject, eventdata, handles)
% hObject    handle to vp12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vp12 as text
%        str2double(get(hObject,'String')) returns contents of vp12 as a double


% --- Executes during object creation, after setting all properties.
function vp12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vp12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vp11_Callback(hObject, eventdata, handles)
% hObject    handle to vp11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vp11 as text
%        str2double(get(hObject,'String')) returns contents of vp11 as a double


% --- Executes during object creation, after setting all properties.
function vp11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vp11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vs14_Callback(hObject, eventdata, handles)
% hObject    handle to vs14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vs14 as text
%        str2double(get(hObject,'String')) returns contents of vs14 as a double


% --- Executes during object creation, after setting all properties.
function vs14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vs14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vs13_Callback(hObject, eventdata, handles)
% hObject    handle to vs13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vs13 as text
%        str2double(get(hObject,'String')) returns contents of vs13 as a double


% --- Executes during object creation, after setting all properties.
function vs13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vs13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vs15_Callback(hObject, eventdata, handles)
% hObject    handle to vs15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vs15 as text
%        str2double(get(hObject,'String')) returns contents of vs15 as a double


% --- Executes during object creation, after setting all properties.
function vs15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vs15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vs12_Callback(hObject, eventdata, handles)
% hObject    handle to vs12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vs12 as text
%        str2double(get(hObject,'String')) returns contents of vs12 as a double


% --- Executes during object creation, after setting all properties.
function vs12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vs12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vs11_Callback(hObject, eventdata, handles)
% hObject    handle to vs11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vs11 as text
%        str2double(get(hObject,'String')) returns contents of vs11 as a double


% --- Executes during object creation, after setting all properties.
function vs11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vs11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function qp14_Callback(hObject, eventdata, handles)
% hObject    handle to qp14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of qp14 as text
%        str2double(get(hObject,'String')) returns contents of qp14 as a double


% --- Executes during object creation, after setting all properties.
function qp14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qp14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function qp13_Callback(hObject, eventdata, handles)
% hObject    handle to qp13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of qp13 as text
%        str2double(get(hObject,'String')) returns contents of qp13 as a double


% --- Executes during object creation, after setting all properties.
function qp13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qp13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function qp15_Callback(hObject, eventdata, handles)
% hObject    handle to qp15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of qp15 as text
%        str2double(get(hObject,'String')) returns contents of qp15 as a double


% --- Executes during object creation, after setting all properties.
function qp15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qp15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function qp12_Callback(hObject, eventdata, handles)
% hObject    handle to qp12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of qp12 as text
%        str2double(get(hObject,'String')) returns contents of qp12 as a double


% --- Executes during object creation, after setting all properties.
function qp12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qp12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function qp11_Callback(hObject, eventdata, handles)
% hObject    handle to qp11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of qp11 as text
%        str2double(get(hObject,'String')) returns contents of qp11 as a double


% --- Executes during object creation, after setting all properties.
function qp11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qp11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function qs14_Callback(hObject, eventdata, handles)
% hObject    handle to qs14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of qs14 as text
%        str2double(get(hObject,'String')) returns contents of qs14 as a double


% --- Executes during object creation, after setting all properties.
function qs14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qs14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function qs13_Callback(hObject, eventdata, handles)
% hObject    handle to qs13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of qs13 as text
%        str2double(get(hObject,'String')) returns contents of qs13 as a double


% --- Executes during object creation, after setting all properties.
function qs13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qs13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function qs15_Callback(hObject, eventdata, handles)
% hObject    handle to qs15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of qs15 as text
%        str2double(get(hObject,'String')) returns contents of qs15 as a double


% --- Executes during object creation, after setting all properties.
function qs15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qs15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function qs12_Callback(hObject, eventdata, handles)
% hObject    handle to qs12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of qs12 as text
%        str2double(get(hObject,'String')) returns contents of qs12 as a double


% --- Executes during object creation, after setting all properties.
function qs12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qs12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function qs11_Callback(hObject, eventdata, handles)
% hObject    handle to qs11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of qs11 as text
%        str2double(get(hObject,'String')) returns contents of qs11 as a double


% --- Executes during object creation, after setting all properties.
function qs11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qs11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function depth14_Callback(hObject, eventdata, handles)
% hObject    handle to depth14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of depth14 as text
%        str2double(get(hObject,'String')) returns contents of depth14 as a double


% --- Executes during object creation, after setting all properties.
function depth14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to depth14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function depth15_Callback(hObject, eventdata, handles)
% hObject    handle to depth15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of depth15 as text
%        str2double(get(hObject,'String')) returns contents of depth15 as a double


% --- Executes during object creation, after setting all properties.
function depth15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to depth15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function depth13_Callback(hObject, eventdata, handles)
% hObject    handle to depth13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of depth13 as text
%        str2double(get(hObject,'String')) returns contents of depth13 as a double


% --- Executes during object creation, after setting all properties.
function depth13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to depth13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function depth12_Callback(hObject, eventdata, handles)
% hObject    handle to depth12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of depth12 as text
%        str2double(get(hObject,'String')) returns contents of depth12 as a double


% --- Executes during object creation, after setting all properties.
function depth12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to depth12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function depth11_Callback(hObject, eventdata, handles)
% hObject    handle to depth11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of depth11 as text
%        str2double(get(hObject,'String')) returns contents of depth11 as a double


% --- Executes during object creation, after setting all properties.
function depth11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to depth11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function density14_Callback(hObject, eventdata, handles)
% hObject    handle to density14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of density14 as text
%        str2double(get(hObject,'String')) returns contents of density14 as a double


% --- Executes during object creation, after setting all properties.
function density14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to density14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function density13_Callback(hObject, eventdata, handles)
% hObject    handle to density13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of density13 as text
%        str2double(get(hObject,'String')) returns contents of density13 as a double


% --- Executes during object creation, after setting all properties.
function density13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to density13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function density15_Callback(hObject, eventdata, handles)
% hObject    handle to density15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of density15 as text
%        str2double(get(hObject,'String')) returns contents of density15 as a double


% --- Executes during object creation, after setting all properties.
function density15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to density15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function density12_Callback(hObject, eventdata, handles)
% hObject    handle to density12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of density12 as text
%        str2double(get(hObject,'String')) returns contents of density12 as a double


% --- Executes during object creation, after setting all properties.
function density12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to density12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function density11_Callback(hObject, eventdata, handles)
% hObject    handle to density11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of density11 as text
%        str2double(get(hObject,'String')) returns contents of density11 as a double


% --- Executes during object creation, after setting all properties.
function density11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to density11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Cancel.
function Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.crustmodnew)



function enableoff(off)
set(off,'Enable','off')

function enableon(on)
set(on,'Enable','on')


% --- Executes on button press in Save_cru1.
function Save_cru1_Callback(hObject, eventdata, handles)
% hObject    handle to Save_cru1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Here we save crustal model in a file....
%% First we put values in a matrix....
%% find how many layers we have
crustalmodel(1,1)=str2double(get(handles.depth1,'String'));
crustalmodel(2,1)=str2double(get(handles.depth2,'String'));
crustalmodel(3,1)=str2double(get(handles.depth3,'String'));
crustalmodel(4,1)=str2double(get(handles.depth4,'String'));
crustalmodel(5,1)=str2double(get(handles.depth5,'String'));
crustalmodel(6,1)=str2double(get(handles.depth6,'String'));
crustalmodel(7,1)=str2double(get(handles.depth7,'String'));
crustalmodel(8,1)=str2double(get(handles.depth8,'String'));
crustalmodel(9,1)=str2double(get(handles.depth9,'String'));
crustalmodel(10,1)=str2double(get(handles.depth10,'String'));
crustalmodel(11,1)=str2double(get(handles.depth11,'String'));
crustalmodel(12,1)=str2double(get(handles.depth12,'String'));
crustalmodel(13,1)=str2double(get(handles.depth13,'String'));
crustalmodel(14,1)=str2double(get(handles.depth14,'String'));
crustalmodel(15,1)=str2double(get(handles.depth15,'String'));
%
for i=15:-1:1
   if isnan(crustalmodel(i,1))
      nlayers=i-1;
  end
end
disp(['Found crustal model with ' num2str(nlayers) '  layers'])
%%

%% First we put values in a matrix....
     %read title
     mtitle=get(handles.mtitle,'String');
     
     for i=1:nlayers
         % DEPTH,vp,vs,Density,Qp,Qs
          eval(['crustalmodel(' num2str(i) ',1)=str2double(get(handles.depth' num2str(i) ',''String''));']);
          eval(['crustalmodel(' num2str(i) ',2)=str2double(get(handles.vp' num2str(i) ',''String''));']);
          eval(['crustalmodel(' num2str(i) ',3)=str2double(get(handles.vs' num2str(i) ',''String''));']);
          eval(['crustalmodel(' num2str(i) ',4)=str2double(get(handles.density' num2str(i) ',''String''));']);
          eval(['crustalmodel(' num2str(i) ',5)=str2double(get(handles.qp' num2str(i) ',''String''));']);
          eval(['crustalmodel(' num2str(i) ',6)=str2double(get(handles.qs' num2str(i) ',''String''));']);
     end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% we have to check if GREEN folder exists...


h=dir('green');

if size(h) > 0 
  cd green
  pwd
   if ispc
    %%%%%%%%KEEP THE NAME FIXED
    fid = fopen('crustal_01.dat','w');
    fprintf(fid,'%s\r\n',['Crustal model                  ' mtitle]);
    fprintf(fid,'%s\r\n','number of layers ');
    fprintf(fid,'   %i\r\n',nlayers);
    fprintf(fid,'%s\r\n','Parameters of the layers');
    fprintf(fid,'%s\r\n','depth of layer top(km)   Vp(km/s)    Vs(km/s)    Rho(g/cm**3)    Qp     Qs');

    for i=1:nlayers
       fprintf(fid,'%9.1f%21.2f%12.3f%13.3f%12i%7i\r\n',crustalmodel(i,1),crustalmodel(i,2),crustalmodel(i,3),crustalmodel(i,4),crustalmodel(i,5),crustalmodel(i,6) );
    end

    fprintf(fid,'%s\r\n','*************************************************************************');
    fclose(fid);

   else
    %%%%%%%%KEEP THE NAME FIXED
    fid = fopen('crustal_01.dat','w');
    fprintf(fid,'%s\n',['Crustal model                  ' mtitle]);
    fprintf(fid,'%s\n','number of layers ');
    fprintf(fid,'   %i\n',nlayers);
    fprintf(fid,'%s\n','Parameters of the layers');
    fprintf(fid,'%s\n','depth of layer top(km)   Vp(km/s)    Vs(km/s)    Rho(g/cm**3)    Qp     Qs');

    for i=1:nlayers
       fprintf(fid,'%9.1f%21.2f%12.3f%13.3f%12i%7i\n',crustalmodel(i,1),crustalmodel(i,2),crustalmodel(i,3),crustalmodel(i,4),crustalmodel(i,5),crustalmodel(i,6) );
    end

    fprintf(fid,'%s\n','*************************************************************************');
    fclose(fid);
   end
  cd ..
  pwd
else
    errordlg('Green folder doesn''t exist. Please create it. ','Folder Error');
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   h=msgbox('Crustal model #1 was saved in GREEN folder as crustal_01.dat file.','Save crustal model');
   

% --- Executes on button press in Save_cru2.
function Save_cru2_Callback(hObject, eventdata, handles)
% hObject    handle to Save_cru2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% First we put values in a matrix....
%% find how many layers we have
crustalmodel(1,1)=str2double(get(handles.depth1,'String'));
crustalmodel(2,1)=str2double(get(handles.depth2,'String'));
crustalmodel(3,1)=str2double(get(handles.depth3,'String'));
crustalmodel(4,1)=str2double(get(handles.depth4,'String'));
crustalmodel(5,1)=str2double(get(handles.depth5,'String'));
crustalmodel(6,1)=str2double(get(handles.depth6,'String'));
crustalmodel(7,1)=str2double(get(handles.depth7,'String'));
crustalmodel(8,1)=str2double(get(handles.depth8,'String'));
crustalmodel(9,1)=str2double(get(handles.depth9,'String'));
crustalmodel(10,1)=str2double(get(handles.depth10,'String'));
crustalmodel(11,1)=str2double(get(handles.depth11,'String'));
crustalmodel(12,1)=str2double(get(handles.depth12,'String'));
crustalmodel(13,1)=str2double(get(handles.depth13,'String'));
crustalmodel(14,1)=str2double(get(handles.depth14,'String'));
crustalmodel(15,1)=str2double(get(handles.depth15,'String'));
%
for i=15:-1:1
   if isnan(crustalmodel(i,1))
      nlayers=i-1;
  end
end
disp(['Found crustal model with ' num2str(nlayers) '  layers'])
%%

%% First we put values in a matrix....
     %read title
     mtitle=get(handles.mtitle,'String');
     
     for i=1:nlayers
         % DEPTH,vp,vs,Density,Qp,Qs
          eval(['crustalmodel(' num2str(i) ',1)=str2double(get(handles.depth' num2str(i) ',''String''));']);
          eval(['crustalmodel(' num2str(i) ',2)=str2double(get(handles.vp' num2str(i) ',''String''));']);
          eval(['crustalmodel(' num2str(i) ',3)=str2double(get(handles.vs' num2str(i) ',''String''));']);
          eval(['crustalmodel(' num2str(i) ',4)=str2double(get(handles.density' num2str(i) ',''String''));']);
          eval(['crustalmodel(' num2str(i) ',5)=str2double(get(handles.qp' num2str(i) ',''String''));']);
          eval(['crustalmodel(' num2str(i) ',6)=str2double(get(handles.qs' num2str(i) ',''String''));']);
     end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% we have to check if GREEN folder exists...


h=dir('green');

if size(h) > 0 
  cd green
    pwd
   if ispc
    %%%%%%%%KEEP THE NAME FIXED
    fid = fopen('crustal_02.dat','w');
    fprintf(fid,'%s\r\n',['Crustal model                  ' mtitle]);
    fprintf(fid,'%s\r\n','number of layers ');
    fprintf(fid,'   %i\r\n',nlayers);
    fprintf(fid,'%s\r\n','Parameters of the layers');
    fprintf(fid,'%s\r\n','depth of layer top(km)   Vp(km/s)    Vs(km/s)    Rho(g/cm**3)    Qp     Qs');

    for i=1:nlayers
       fprintf(fid,'%9.1f%21.2f%12.3f%13.3f%12i%7i\r\n',crustalmodel(i,1),crustalmodel(i,2),crustalmodel(i,3),crustalmodel(i,4),crustalmodel(i,5),crustalmodel(i,6) );
    end

    fprintf(fid,'%s\r\n','*************************************************************************');
    fclose(fid);
   else
    %%%%%%%%KEEP THE NAME FIXED
    fid = fopen('crustal_02.dat','w');
    fprintf(fid,'%s\n',['Crustal model                  ' mtitle]);
    fprintf(fid,'%s\n','number of layers ');
    fprintf(fid,'   %i\n',nlayers);
    fprintf(fid,'%s\n','Parameters of the layers');
    fprintf(fid,'%s\n','depth of layer top(km)   Vp(km/s)    Vs(km/s)    Rho(g/cm**3)    Qp     Qs');

    for i=1:nlayers
       fprintf(fid,'%9.1f%21.2f%12.3f%13.3f%12i%7i\n',crustalmodel(i,1),crustalmodel(i,2),crustalmodel(i,3),crustalmodel(i,4),crustalmodel(i,5),crustalmodel(i,6) );
    end

    fprintf(fid,'%s\n','*************************************************************************');
    fclose(fid);
   end
   
  cd ..
    pwd
else
    errordlg('Green folder doesn''t exist. Please create it. ','Folder Error');
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   h=msgbox('Crustal model #2 was saved in GREEN folder as crustal_02.dat file.','Save crustal model');



% --- Executes on button press in Save_cru3.
function Save_cru3_Callback(hObject, eventdata, handles)
% hObject    handle to Save_cru3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% First we put values in a matrix....
%% find how many layers we have
crustalmodel(1,1)=str2double(get(handles.depth1,'String'));
crustalmodel(2,1)=str2double(get(handles.depth2,'String'));
crustalmodel(3,1)=str2double(get(handles.depth3,'String'));
crustalmodel(4,1)=str2double(get(handles.depth4,'String'));
crustalmodel(5,1)=str2double(get(handles.depth5,'String'));
crustalmodel(6,1)=str2double(get(handles.depth6,'String'));
crustalmodel(7,1)=str2double(get(handles.depth7,'String'));
crustalmodel(8,1)=str2double(get(handles.depth8,'String'));
crustalmodel(9,1)=str2double(get(handles.depth9,'String'));
crustalmodel(10,1)=str2double(get(handles.depth10,'String'));
crustalmodel(11,1)=str2double(get(handles.depth11,'String'));
crustalmodel(12,1)=str2double(get(handles.depth12,'String'));
crustalmodel(13,1)=str2double(get(handles.depth13,'String'));
crustalmodel(14,1)=str2double(get(handles.depth14,'String'));
crustalmodel(15,1)=str2double(get(handles.depth15,'String'));
%
for i=15:-1:1
   if isnan(crustalmodel(i,1))
      nlayers=i-1;
  end
end
disp(['Found crustal model with ' num2str(nlayers) '  layers'])
%%

%% First we put values in a matrix....
     %read title
     mtitle=get(handles.mtitle,'String');
     
     for i=1:nlayers
         % DEPTH,vp,vs,Density,Qp,Qs
          eval(['crustalmodel(' num2str(i) ',1)=str2double(get(handles.depth' num2str(i) ',''String''));']);
          eval(['crustalmodel(' num2str(i) ',2)=str2double(get(handles.vp' num2str(i) ',''String''));']);
          eval(['crustalmodel(' num2str(i) ',3)=str2double(get(handles.vs' num2str(i) ',''String''));']);
          eval(['crustalmodel(' num2str(i) ',4)=str2double(get(handles.density' num2str(i) ',''String''));']);
          eval(['crustalmodel(' num2str(i) ',5)=str2double(get(handles.qp' num2str(i) ',''String''));']);
          eval(['crustalmodel(' num2str(i) ',6)=str2double(get(handles.qs' num2str(i) ',''String''));']);
     end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% we have to check if GREEN folder exists...


h=dir('green');

if size(h) > 0 
  cd green
    pwd
  if ispc
    %%%%%%%%KEEP THE NAME FIXED
    fid = fopen('crustal_03.dat','w');
    fprintf(fid,'%s\r\n',['Crustal model                  ' mtitle]);
    fprintf(fid,'%s\r\n','number of layers ');
    fprintf(fid,'   %i\r\n',nlayers);
    fprintf(fid,'%s\r\n','Parameters of the layers');
    fprintf(fid,'%s\r\n','depth of layer top(km)   Vp(km/s)    Vs(km/s)    Rho(g/cm**3)    Qp     Qs');

    for i=1:nlayers
       fprintf(fid,'%9.1f%21.2f%12.3f%13.3f%12i%7i\r\n',crustalmodel(i,1),crustalmodel(i,2),crustalmodel(i,3),crustalmodel(i,4),crustalmodel(i,5),crustalmodel(i,6) );
    end

    fprintf(fid,'%s\r\n','*************************************************************************');
    fclose(fid);

  else
    %%%%%%%%KEEP THE NAME FIXED
    fid = fopen('crustal_03.dat','w');
    fprintf(fid,'%s\n',['Crustal model                  ' mtitle]);
    fprintf(fid,'%s\n','number of layers ');
    fprintf(fid,'   %i\n',nlayers);
    fprintf(fid,'%s\n','Parameters of the layers');
    fprintf(fid,'%s\n','depth of layer top(km)   Vp(km/s)    Vs(km/s)    Rho(g/cm**3)    Qp     Qs');

    for i=1:nlayers
       fprintf(fid,'%9.1f%21.2f%12.3f%13.3f%12i%7i\n',crustalmodel(i,1),crustalmodel(i,2),crustalmodel(i,3),crustalmodel(i,4),crustalmodel(i,5),crustalmodel(i,6) );
    end

    fprintf(fid,'%s\n','*************************************************************************');
    fclose(fid);
  end
   
    cd ..
    pwd
else
    errordlg('Green folder doesn''t exist. Please create it. ','Folder Error');
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   h=msgbox('Crustal model #3 was saved in GREEN folder as crustal_03.dat file.','Save crustal model');


% --- Executes on button press in Save_cru4.
function Save_cru4_Callback(hObject, eventdata, handles)
% hObject    handle to Save_cru4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Here we save crustal model in a file....
%% First we put values in a matrix....
%% find how many layers we have
crustalmodel(1,1)=str2double(get(handles.depth1,'String'));
crustalmodel(2,1)=str2double(get(handles.depth2,'String'));
crustalmodel(3,1)=str2double(get(handles.depth3,'String'));
crustalmodel(4,1)=str2double(get(handles.depth4,'String'));
crustalmodel(5,1)=str2double(get(handles.depth5,'String'));
crustalmodel(6,1)=str2double(get(handles.depth6,'String'));
crustalmodel(7,1)=str2double(get(handles.depth7,'String'));
crustalmodel(8,1)=str2double(get(handles.depth8,'String'));
crustalmodel(9,1)=str2double(get(handles.depth9,'String'));
crustalmodel(10,1)=str2double(get(handles.depth10,'String'));
crustalmodel(11,1)=str2double(get(handles.depth11,'String'));
crustalmodel(12,1)=str2double(get(handles.depth12,'String'));
crustalmodel(13,1)=str2double(get(handles.depth13,'String'));
crustalmodel(14,1)=str2double(get(handles.depth14,'String'));
crustalmodel(15,1)=str2double(get(handles.depth15,'String'));
%
for i=15:-1:1
   if isnan(crustalmodel(i,1))
      nlayers=i-1;
  end
end
disp(['Found crustal model with ' num2str(nlayers) '  layers'])
%%

%% First we put values in a matrix....
     %read title
     mtitle=get(handles.mtitle,'String');
     
     for i=1:nlayers
         % DEPTH,vp,vs,Density,Qp,Qs
          eval(['crustalmodel(' num2str(i) ',1)=str2double(get(handles.depth' num2str(i) ',''String''));']);
          eval(['crustalmodel(' num2str(i) ',2)=str2double(get(handles.vp' num2str(i) ',''String''));']);
          eval(['crustalmodel(' num2str(i) ',3)=str2double(get(handles.vs' num2str(i) ',''String''));']);
          eval(['crustalmodel(' num2str(i) ',4)=str2double(get(handles.density' num2str(i) ',''String''));']);
          eval(['crustalmodel(' num2str(i) ',5)=str2double(get(handles.qp' num2str(i) ',''String''));']);
          eval(['crustalmodel(' num2str(i) ',6)=str2double(get(handles.qs' num2str(i) ',''String''));']);
     end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% we have to check if GREEN folder exists...


h=dir('green');

if size(h) > 0 
  cd green
    pwd
   if ispc
    %%%%%%%%KEEP THE NAME FIXED
    fid = fopen('crustal_04.dat','w');
    fprintf(fid,'%s\r\n',['Crustal model                  ' mtitle]);
    fprintf(fid,'%s\r\n','number of layers ');
    fprintf(fid,'   %i\r\n',nlayers);
    fprintf(fid,'%s\r\n','Parameters of the layers');
    fprintf(fid,'%s\r\n','depth of layer top(km)   Vp(km/s)    Vs(km/s)    Rho(g/cm**3)    Qp     Qs');

    for i=1:nlayers
       fprintf(fid,'%9.1f%21.2f%12.3f%13.3f%12i%7i\r\n',crustalmodel(i,1),crustalmodel(i,2),crustalmodel(i,3),crustalmodel(i,4),crustalmodel(i,5),crustalmodel(i,6) );
    end

    fprintf(fid,'%s\r\n','*************************************************************************');
    fclose(fid);
   else
    %%%%%%%%KEEP THE NAME FIXED
    fid = fopen('crustal_04.dat','w');
    fprintf(fid,'%s\n',['Crustal model                  ' mtitle]);
    fprintf(fid,'%s\n','number of layers ');
    fprintf(fid,'   %i\n',nlayers);
    fprintf(fid,'%s\n','Parameters of the layers');
    fprintf(fid,'%s\n','depth of layer top(km)   Vp(km/s)    Vs(km/s)    Rho(g/cm**3)    Qp     Qs');

    for i=1:nlayers
       fprintf(fid,'%9.1f%21.2f%12.3f%13.3f%12i%7i\n',crustalmodel(i,1),crustalmodel(i,2),crustalmodel(i,3),crustalmodel(i,4),crustalmodel(i,5),crustalmodel(i,6) );
    end

    fprintf(fid,'%s\n','*************************************************************************');
    fclose(fid);
   end
    cd ..
    pwd
else
    errordlg('Green folder doesn''t exist. Please create it. ','Folder Error');
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   h=msgbox('Crustal model #4 was saved in GREEN folder as crustal_04.dat file.','Save crustal model');
