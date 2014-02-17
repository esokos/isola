function varargout = eventinfo(varargin)
% EVENTINFO M-file for eventinfo.fig
%      EVENTINFO, by itself, creates a new EVENTINFO or raises the existing
%      singleton*.
%
%      H = EVENTINFO returns the handle to a new EVENTINFO or the handle to
%      the existing singleton*.
%
%      EVENTINFO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EVENTINFO.M with the given input arguments.
%
%      EVENTINFO('Property','Value',...) creates a new EVENTINFO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before eventinfo_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to eventinfo_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help eventinfo

% Last Modified by GUIDE v2.5 28-Aug-2013 13:29:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @eventinfo_OpeningFcn, ...
                   'gui_OutputFcn',  @eventinfo_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before eventinfo is made visible.
function eventinfo_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to eventinfo (see VARARGIN)

% Choose default command line output for eventinfo
handles.output = hObject;
%%%read event and raw data info.....

%check if INVERT exists..!
h=dir('invert');
if isempty(h);

    disp('Invert folder doesn''t exist. Be sure that you call Eventinfo from proper path.');
    msgbox('Invert folder doesn''t exist. Be sure that you call Eventinfo from proper path.','Be careful','warn')
    
end

%%% check event.isl files with event info !!!
h=dir('event.isl');

if isempty(h); 

    %%% first time put defaults...!!
    if ispc
        fid = fopen('event.isl','w');
         fprintf(fid,'%s  ','21.00');
         fprintf(fid,'%s\r\n','38.00');
         fprintf(fid,'%s\r\n','10');
         fprintf(fid,'%s\r\n','5.0');
         fprintf(fid,'%s\r\n','20021231');
         fprintf(fid,'%s\r\n','10');
         fprintf(fid,'%s\r\n','10');
         fprintf(fid,'%s\r\n','00.00');
         fprintf(fid,'%s\r\n','UPSL');
        fclose(fid);
    else
        fid = fopen('event.isl','w');
         fprintf(fid,'%s  ','21.00');
         fprintf(fid,'%s\n','38.00');
         fprintf(fid,'%s\n','10');
         fprintf(fid,'%s\n','5.0');
         fprintf(fid,'%s\n','20021231');
         fprintf(fid,'%s\n','10');
         fprintf(fid,'%s\n','10');
         fprintf(fid,'%s\n','00.00');
         fprintf(fid,'%s\n','UPSL');
        fclose(fid);
    end
%%%%%%%%%%%%%%%%%%%        
        eventcor(1,1)=21.00;
        eventcor(2,1)=38.00;
        epidepth=10;
        magn=5.0;
%%%give current date.....
        str=strrep(datestr(floor(now),2),'/','');
        eventdate=['20' str(5:6) str(1:2) str(3:4)];
%        eventdate='20021231';
        orhour=10;
        ormin=10;
        orsec=00.00;
        agency='UPSL';
        
else
    fid = fopen('event.isl','r');
    eventcor=fscanf(fid,'%g',2);
    epidepth=fscanf(fid,'%g',1);
    magn=fscanf(fid,'%g',1);
    eventdate=fscanf(fid,'%s',1);
    orhour=fscanf(fid,'%s',1);
    ormin=fscanf(fid,'%s',1);
    orsec=fscanf(fid,'%s',1);
    agency=fscanf(fid,'%s',1);
    fclose(fid);

%%%check if it is 2 digits
icheck=length(orhour);
if icheck == 2
%set(handles.rawhour,'String',epih);
else
    orhour=['0' orhour];
end

icheck=length(ormin);
if icheck == 2
%set(handles.rawhour,'String',epih);
else
    ormin=['0' ormin];
end

icheck=length(orsec); 
k = strfind(orsec,'.'); 
 
switch icheck
    case 1
            orsec=['0' orsec '.00'];
    case 2
        if k == 2
            orsec=['0' orsec '00'];
        elseif isempty(k)
            orsec=[orsec '.00'];
        end
    case 3
        if k == 2
            orsec=['0' orsec '0'];
        elseif k == 3
            orsec=[orsec '00'];
        elseif k == 1
            orsec=['00' orsec ];
        end
    case 4
        if k == 2
            orsec=['0' orsec ];
        elseif k == 3
            orsec=[orsec '0'];
        end
     otherwise
      disp('Seconds in proper numeric format.')
end

end

%%% check rawinfo.isl files with event info
%h=dir('rawinfo.isl');

%if length(h) == 0;   
    %%% first time put defaults...!!
%        fid = fopen('rawinfo.isl','w');
%         fprintf(fid,'%s\r\n','50');
%         fprintf(fid,'%s\r\n','10');
%         fprintf(fid,'%s\r\n','5');
%         fprintf(fid,'%s\r\n','00.00');
%        fclose(fid);
 
%        rawhour=10;
%        rawmin=5;
%        rawsec=00.00;
        
% else
%    fid = fopen('rawinfo.isl','r');
%    sfreq=fscanf(fid,'%g',1);
%    rawhour=fscanf(fid,'%g',1);
%    rawmin=fscanf(fid,'%g',1);
%    rawsec=fscanf(fid,'%g',1);
%    fclose(fid);
%end

h=dir('duration.isl');

%output record duration for inversion
if isempty(h);   
   fid = fopen('duration.isl','w');
     if ispc
      fprintf(fid,'%s\r\n','245.76');
     else
      fprintf(fid,'%s\n','245.76');
     end
   fclose(fid);
   
   tl=245.76;
   
else
    fid = fopen('duration.isl','r');
     tl=fscanf(fid,'%g',1);
    fclose(fid);

%%%%%%%%%%%%%%%
    if tl == 16.384
        set(handles.listbox1,'Value',1)        
    elseif tl == 40.96
        set(handles.listbox1,'Value',2)        
    elseif tl == 81.92
        set(handles.listbox1,'Value',3)        
    elseif tl == 163.84
        set(handles.listbox1,'Value',4)        
    elseif tl == 245.76
        set(handles.listbox1,'Value',5)        
    elseif tl == 327.68
        set(handles.listbox1,'Value',6)        
    elseif tl == 409.6
        set(handles.listbox1,'Value',7)        
    elseif tl == 819.2
        set(handles.listbox1,'Value',8)        
    elseif tl == 1638.4
        set(handles.listbox1,'Value',9)        
    end

end     

%%%% updata handles.....
set(handles.lat,'String',num2str(eventcor(2,1)));        
set(handles.lon,'String',num2str(eventcor(1,1)));          
set(handles.depth,'String',num2str(epidepth));          
set(handles.magnitude,'String',num2str(magn));          
set(handles.date,'String',eventdate);          
set(handles.epihour,'String',num2str(orhour));          
set(handles.epimin,'String',num2str(ormin)) ;         
set(handles.episec,'String',orsec);          
set(handles.agency,'String',agency);          

%%%raw data ....
%set(handles.rawhour,'String',num2str(rawhour));          
%set(handles.rawmin,'String',num2str(rawmin));          
%set(handles.rawsec,'String',num2str(rawsec));          
% set(handles.sfreq,'String',num2str(sfreq))          

% Update handles structure
guidata(hObject, handles);

off =[handles.cancel];
enableoff(off)


% UIWAIT makes eventinfo wait for user response (see UIRESUME)
% uiwait(handles.eventinfo);


% --- Outputs from this function are returned to the command line.
function varargout = eventinfo_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

disp('This is Eventinfo 28/08/2013');
% Layout Change 28/08/2013


% --- Executes during object creation, after setting all properties.
function lat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function lat_Callback(hObject, eventdata, handles)
% hObject    handle to lat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lat as text
%        str2double(get(hObject,'String')) returns contents of lat as a double


% --- Executes during object creation, after setting all properties.
function lon_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function lon_Callback(hObject, eventdata, handles)
% hObject    handle to lon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lon as text
%        str2double(get(hObject,'String')) returns contents of lon as a double


% --- Executes during object creation, after setting all properties.
function magnitude_CreateFcn(hObject, eventdata, handles)
% hObject    handle to magnitude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function magnitude_Callback(hObject, eventdata, handles)
% hObject    handle to magnitude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of magnitude as text
%        str2double(get(hObject,'String')) returns contents of magnitude as a double


% --- Executes during object creation, after setting all properties.
function date_CreateFcn(hObject, eventdata, handles)
% hObject    handle to date (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function date_Callback(hObject, eventdata, handles)
% hObject    handle to date (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of date as text
%        str2double(get(hObject,'String')) returns contents of date as a double
epidate=get(handles.date,'String');

%%%check if it is 8 digits
icheck=length(epidate);
if icheck == 8
%set(handles.rawmin,'String',epimin);
else

    errordlg('Enter a valid date YYYYMMDD e.g. 20040704','Error')
    
end

% --- Executes during object creation, after setting all properties.
function depth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to depth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function depth_Callback(hObject, eventdata, handles)
% hObject    handle to depth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of depth as text
%        str2double(get(hObject,'String')) returns contents of depth as a double


% --- Executes on button press in ok.
function ok_Callback(hObject, eventdata, handles)
% hObject    handle to ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


durselindex=get(handles.listbox1,'Value');
doptions = get(handles.listbox1,'String');
tl= doptions{durselindex}

%output record duration for inversion
fid = fopen('duration.isl','w');
  if ispc
    fprintf(fid,'%s\r\n',tl);
  else
    fprintf(fid,'%s\n',tl);
  end
fclose(fid);

%output event coordinates
%%%%%%EPICENTER
epilat = get(handles.lat,'String')
epilon = get(handles.lon,'String')
epidepth = get(handles.depth,'String')
magnitude = get(handles.magnitude,'String')
edate = get(handles.date,'String')
epihour = get(handles.epihour,'String')
epimin = get(handles.epimin,'String')
episec = get(handles.episec,'String')
agency = get(handles.agency,'String')


%%%check if it is 2 digits
icheck=length(epihour);
if icheck == 2
%set(handles.rawhour,'String',epih);
else
    epihour=['0' epihour];
end

icheck=length(epimin);
if icheck == 2
%set(handles.rawhour,'String',epih);
else
    epimin=['0' epimin];
end


%%%read raw data file start
%rawhour = get(handles.rawhour,'String')
%rawmin = get(handles.rawmin,'String')
%rawsec = get(handles.rawsec,'String')
%%%%%%%%%
if ispc
  fid = fopen('event.isl','w');
   fprintf(fid,'%s  ',epilon);
   fprintf(fid,'%s\r\n',epilat);
   fprintf(fid,'%s\r\n',epidepth);
   fprintf(fid,'%s\r\n',magnitude);
   fprintf(fid,'%s\r\n',edate);
   fprintf(fid,'%s\r\n',epihour);
   fprintf(fid,'%s\r\n',epimin);
   fprintf(fid,'%s\r\n',episec);
   fprintf(fid,'%s\r\n',agency);
  fclose(fid);
else
  fid = fopen('event.isl','w');
   fprintf(fid,'%s  ',epilon);
   fprintf(fid,'%s\n',epilat);
   fprintf(fid,'%s\n',epidepth);
   fprintf(fid,'%s\n',magnitude);
   fprintf(fid,'%s\n',edate);
   fprintf(fid,'%s\n',epihour);
   fprintf(fid,'%s\n',epimin);
   fprintf(fid,'%s\n',episec);
   fprintf(fid,'%s\n',agency);
  fclose(fid);
end
%output sampling frequency information 
%sfreq = get(handles.sfreq,'String')
%fid = fopen('rawinfo.isl','w');
%%fprintf(fid,'%s\r\n',sfreq);
%fprintf(fid,'%s\r\n',rawhour);
%fprintf(fid,'%s\r\n',rawmin);
%fprintf(fid,'%s\r\n',rawsec);
%fclose(fid);


on =[handles.cancel];
enableon(on)




% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
% hObject    handle to cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(handles.eventinfo)


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function sfreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sfreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function sfreq_Callback(hObject, eventdata, handles)
% hObject    handle to sfreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sfreq as text
%        str2double(get(hObject,'String')) returns contents of sfreq as a double


% --- Executes during object creation, after setting all properties.
function epihour_CreateFcn(hObject, eventdata, handles)
% hObject    handle to epihour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function epihour_Callback(hObject, eventdata, handles)
% hObject    handle to epihour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of epihour as text
%        str2double(get(hObject,'String')) returns contents of epihour as a double

epih=get(handles.epihour,'String');

%%%check if it is 2 digits
icheck=length(epih);
if icheck == 2
%set(handles.rawhour,'String',epih);
else
    epih=['0' epih];
    set(handles.epihour,'String',epih);
%    set(handles.rawhour,'String',epih);
end

function epimin_Callback(hObject, eventdata, handles)
% hObject    handle to epimin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of epimin as text
%        str2double(get(hObject,'String')) returns contents of epimin as a double
epimin=get(handles.epimin,'String');

%%%check if it is 2 digits
icheck=length(epimin);
if icheck == 2
%set(handles.rawmin,'String',epimin);
else
    epimin=['0' epimin];
    set(handles.epimin,'String',epimin);
%    set(handles.rawmin,'String',epimin);
end


% --- Executes during object creation, after setting all properties.
function epimin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to epimin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes during object creation, after setting all properties.
function episec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to episec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function episec_Callback(hObject, eventdata, handles)
% hObject    handle to episec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of episec as text
%        str2double(get(hObject,'String')) returns contents of episec as a double
% 
episec=get(handles.episec,'String');
%%%check if it is 5 digits
icheck=length(episec);
k = strfind(episec,'.'); 
 
switch icheck
    case 1
            episec=['0' episec '.00'];
            set(handles.episec,'String',episec);
    case 2
        if k == 2
            episec=['0' episec '00'];
            set(handles.episec,'String',episec);
        elseif isempty(k)
            episec=[episec '.00'];
            set(handles.episec,'String',episec);
        end
    case 3
        if k == 2
            episec=['0' episec '0'];
            set(handles.episec,'String',episec);
        elseif k == 3
            episec=[episec '00'];
            set(handles.episec,'String',episec);
        elseif k == 1
            episec=['00' episec ];
            set(handles.episec,'String',episec);
        end
    case 4
        if k == 2
            episec=['0' episec ];
            set(handles.episec,'String',episec);
        elseif k == 3
            episec=[episec '0'];
            set(handles.episec,'String',episec);
        end
     otherwise
      disp('Seconds in proper numeric format.')
end

% --- Executes during object creation, after setting all properties.
function rawhour_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rawhour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function rawhour_Callback(hObject, eventdata, handles)
% hObject    handle to rawhour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rawhour as text
%        str2double(get(hObject,'String')) returns contents of rawhour as a double



% --- Executes during object creation, after setting all properties.
function rawmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rawmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function rawmin_Callback(hObject, eventdata, handles)
% hObject    handle to rawmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rawmin as text
%        str2double(get(hObject,'String')) returns contents of rawmin as a double


% --- Executes during object creation, after setting all properties.
function rawsec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rawsec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function rawsec_Callback(hObject, eventdata, handles)
% hObject    handle to rawsec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rawsec as text
%        str2double(get(hObject,'String')) returns contents of rawsec as a double


% --- Executes during object creation, after setting all properties.
function latdeg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to latdeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function latdeg_Callback(hObject, eventdata, handles)
% hObject    handle to latdeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of latdeg as text
%        str2double(get(hObject,'String')) returns contents of latdeg as a double


% --- Executes during object creation, after setting all properties.
function latmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to latmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function latmin_Callback(hObject, eventdata, handles)
% hObject    handle to latmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of latmin as text
%        str2double(get(hObject,'String')) returns contents of latmin as a double


% --- Executes during object creation, after setting all properties.
function londeg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to londeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function londeg_Callback(hObject, eventdata, handles)
% hObject    handle to londeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of londeg as text
%        str2double(get(hObject,'String')) returns contents of londeg as a double


% --- Executes during object creation, after setting all properties.
function lonmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lonmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function lonmin_Callback(hObject, eventdata, handles)
% hObject    handle to lonmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lonmin as text
%        str2double(get(hObject,'String')) returns contents of lonmin as a double


% --- Executes on button press in convert.
function convert_Callback(hObject, eventdata, handles)
% hObject    handle to convert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

latdeg = str2num(get(handles.latdeg,'String'));
latmin = str2num(get(handles.latmin,'String'));
londeg = str2num(get(handles.londeg,'String'));
lonmin = str2num(get(handles.lonmin,'String'));


declat=latdeg+latmin/60;
declon=londeg+lonmin/60;

set(handles.lat,'String',num2str(declat))        
set(handles.lon,'String',num2str(declon))  





function enableoff(off)
set(off,'Enable','off')

function enableon(on)
set(on,'Enable','on')



% --- Executes during object creation, after setting all properties.
function agency_CreateFcn(hObject, eventdata, handles)
% hObject    handle to agency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function agency_Callback(hObject, eventdata, handles)
% hObject    handle to agency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of agency as text
%        str2double(get(hObject,'String')) returns contents of agency as a double


% --- Executes on button press in Read.
function Read_Callback(hObject, eventdata, handles)
% hObject    handle to Read (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sol=strrep(get(handles.evtinfo,'String'),'E',' ');
% disp(sol)

%[A,count,errmsg,nextindex]  = sscanf(sol,'%8i %i %f %2i %f %2i %f %f %f')
%[A,count,errmsg,nextindex]  = sscanf(sol,'%8c %4c %5c %2c %5c  %2c %5c  %6c %4c')

[AA,count,errmsg,nextindex] = sscanf(sol, '%s%c');
sol2=strrep(AA,' ',';');
A=eval(['[' sol2 ']']);
% 
% num2str(A(1)) 
% num2str(A(2))
% num2str(A(3))
% num2str(A(4))
% num2str(A(5))
% num2str(A(6))
% num2str(A(7))
% num2str(A(8))
% num2str(A(9))

if strcmp(errmsg,'')
    %update info 
    set(handles.latdeg,'String',num2str(A(4)));     
    set(handles.latmin,'String',num2str(A(5)));     
    set(handles.londeg,'String',num2str(A(6)));     
    set(handles.lonmin,'String',num2str(A(7)));     
    set(handles.magnitude,'String',num2str(A(9)));     
    set(handles.depth,'String',num2str(round(A(8))));

    declat=A(4)+A(5)/60;declon=A(6)+A(7)/60;
    
    set(handles.lat,'String',num2str(declat));        
    set(handles.lon,'String',num2str(declon));  
    

%%%check if it is 4 digits for hour+min
icheck=length(num2str(A(2)));
hhmm=num2str(A(2));
if icheck == 4
     set(handles.epihour,'String',hhmm(1:2));
     set(handles.epimin,'String',hhmm(3:4));
else
    hhmm=['0' hhmm];
     set(handles.epihour,'String',hhmm(1:2));
     set(handles.epimin,'String',hhmm(3:4));
end

     set(handles.episec,'String',num2str(A(3)));
    
    set(handles.date,'String',num2str(A(1)));

    
    episec=get(handles.episec,'String');
%%%check if it is 5 digits
icheck=length(episec);
k = strfind(episec,'.') ;
 
switch icheck
    case 1
            episec=['0' episec '.00'];
            set(handles.episec,'String',episec);
    case 2
        if k == 2
            episec=['0' episec '00'];
            set(handles.episec,'String',episec);
        elseif isempty(k)
            episec=[episec '.00'];
            set(handles.episec,'String',episec);
        end
    case 3
        if k == 2
            episec=['0' episec '0'];
            set(handles.episec,'String',episec);
        elseif k == 3
            episec=[episec '00'];
            set(handles.episec,'String',episec);
        elseif k == 1
            episec=['00' episec ];
            set(handles.episec,'String',episec);
        end
    case 4
        if k == 2
            episec=['0' episec ];
            set(handles.episec,'String',episec);
        elseif k == 3
            episec=[episec '0'];
            set(handles.episec,'String',episec);
        end
     otherwise
      disp(['Unknown case.....icheck = ' num2str(icheck)] )
end
    
    
    
    epimin=get(handles.epimin,'String');

%%%check if it is 2 digits
icheck=length(epimin);
if icheck == 2
%set(handles.rawmin,'String',epimin);
else
    epimin=['0' epimin];
    set(handles.epimin,'String',epimin);
 %   set(handles.rawmin,'String',epimin);
end

epih=get(handles.epihour,'String');

%%%check if it is 2 digits
icheck=length(epih);
if icheck == 2

%set(handles.rawhour,'String',epih);
else
    epih=['0' epih];
    set(handles.epihour,'String',epih);
%    set(handles.rawhour,'String',epih);
end

    
    
else
    disp('error')
    
    errordlg('There was an error in reading Event Info check the format','Error');
end





% --- Executes during object creation, after setting all properties.
function evtinfo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to evtinfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function evtinfo_Callback(hObject, eventdata, handles)
% hObject    handle to evtinfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of evtinfo as text
%        str2double(get(hObject,'String')) returns contents of evtinfo as a double


% --- Executes when eventinfo window is resized.
function eventinfo_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to eventinfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes when uipanel2 is resized.
function uipanel2_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to uipanel2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
