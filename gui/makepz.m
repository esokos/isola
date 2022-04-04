function varargout = makepz(varargin)
% MAKEPZ M-file for makepz.fig
%      MAKEPZ, by itself, creates a new MAKEPZ or raises the existing
%      singleton*.
%
%      H = MAKEPZ returns the handle to a new MAKEPZ or the handle to
%      the existing singleton*.
%
%      MAKEPZ('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAKEPZ.M with the given input arguments.
%
%      MAKEPZ('Property','Value',...) creates a new MAKEPZ or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before makepz_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to makepz_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help makepz

% Last Modified by GUIDE v2.5 31-Aug-2015 23:38:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @makepz_OpeningFcn, ...
                   'gui_OutputFcn',  @makepz_OutputFcn, ...
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


% --- Executes just before makepz is made visible.
function makepz_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to makepz (see VARARGIN)

% Choose default command line output for makepz
handles.output = hObject;

zpos=get(handles.newzero,'Position');
ppos=get(handles.newpole,'Position');

handles.zposition=zpos;
handles.pposition=ppos;

handles.nozeroes=0;
handles.nopoles=0;

 %disp('This is makepz  version 01/09/2015');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes makepz wait for user response (see UIRESUME)
% uiwait(handles.makepz);


% --- Outputs from this function are returned to the command line.
function varargout = makepz_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in newpole.
function newpole_Callback(hObject, eventdata, handles)
% hObject    handle to newpole (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

nopoles=handles.nopoles+1;
position=handles.pposition;

t1=['pr' num2str(nopoles)];
t2=['pi' num2str(nopoles)];

uicontrol('Parent',makepz,'Style', 'edit', 'String', '0.0','Tag', t1,...
    'Position', [position(1) position(2)-40 100 25],'BackgroundColor','white');

uicontrol('Parent',makepz,'Style', 'edit', 'String', '0.0','Tag',t2,...
    'Position', [position(1)+110 position(2)-40 100 25],'BackgroundColor','white');

set(handles.npoles,'String', num2str(nopoles));
%%%
position(2)=position(2)-40;

handles.pposition=position;
handles.nopoles=nopoles;
% Update handles structure
guidata(hObject, handles);
 
% --- Executes on button press in newzero.
function newzero_Callback(hObject, eventdata, handles)
% hObject    handle to newzero (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

nozeroes=handles.nozeroes+1;
position=handles.zposition;

t1=['zr' num2str(nozeroes)];
t2=['zi' num2str(nozeroes)];

uicontrol('Parent',makepz,'Style', 'edit', 'String', '0.0','Tag', t1,...
    'Position', [position(1) position(2)-40 100 25],'BackgroundColor','white');

uicontrol('Parent',makepz,'Style', 'edit', 'String', '0.0','Tag',t2,...
    'Position', [position(1)+110 position(2)-40 100 25],'BackgroundColor','white');

set(handles.nzeroes,'String', num2str(nozeroes));
%%%
position(2)=position(2)-40;

handles.zposition=position;
handles.nozeroes=nozeroes;
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function npoles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to npoles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function npoles_Callback(hObject, eventdata, handles)
% hObject    handle to npoles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of npoles as text
%        str2double(get(hObject,'String')) returns contents of npoles as a double


% --- Executes during object creation, after setting all properties.
function nzeroes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nzeroes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function nzeroes_Callback(hObject, eventdata, handles)
% hObject    handle to nzeroes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nzeroes as text
%        str2double(get(hObject,'String')) returns contents of nzeroes as a double


% --- Executes when makepz window is resized.
function makepz_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to makepz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in savefile.
function savefile_Callback(hObject, eventdata, handles)
% hObject    handle to savefile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ha=guihandles(makepz);
%guidata(makepz,ha);

%%%% read poles
a=get(ha.npoles,'String');

for i=1:str2num(a)
   str1=['get(ha.pr' num2str(i) ',''String'')' ];
   str2=['get(ha.pi' num2str(i) ',''String'')' ];

   p_r(i)=str2num(eval(str1));
   p_i(i)=str2num(eval(str2));
   
end
pfinal=[p_r;  p_i];
%%%read zeroes

b=get(ha.nzeroes,'String');

for i=1:str2num(b)
   str1=['get(ha.zr' num2str(i) ',''String'')' ];
   str2=['get(ha.zi' num2str(i) ',''String'')' ];

   z_r(i)=str2num(eval(str1));
   z_i(i)=str2num(eval(str2));
   
end

zfinal=[z_r; z_i];
%%% read A0
A0=get(ha.A0,'String');

%%% read digitizer sens
Dsens=str2num(get(ha.Dsens,'String'));

%%% read seismometer sens
Ssens=str2num(get(ha.Ssens,'String'));

%%read station name
staname=get(ha.staname,'String');


button = questdlg('Do you want to use same values for all 3 components?','Makepz','Yes','No','Yes');

if strcmp(button,'No')
    
 [newfile, newdir] = uiputfile([staname 'BHZ' '.pz'], 'Save pole zero file as');
  fid = fopen([newdir newfile],'w');
   if ispc     
    fprintf(fid,'%s\r\n','A0');   %%%%%BE CAREFUL THESE NEED EXPONENTIAL FORMAT (are corrected....)
    fprintf(fid,'%s\r\n',A0);
    fprintf(fid,'%s\r\n','count-->m/sec');
    fprintf(fid,'%e\r\n',1/(Dsens*Ssens));
    fprintf(fid,'%s\r\n','zeros');
    fprintf(fid,'%i\r\n',str2num(b));
    fprintf(fid,'%e     %e\r\n',zfinal);
    fprintf(fid,'%s\r\n','poles');
    fprintf(fid,'%i\r\n',str2num(a));
    fprintf(fid,'%e    %e\r\n',pfinal);
    fprintf(fid,'%s\r\n',['Info:  ' date '  '  staname '  Digi sens  '  num2str(Dsens) '  Seism sens   '   num2str(Ssens)]);
    fclose(fid);
   else
    fprintf(fid,'%s\n','A0');   %%%%%BE CAREFUL THESE NEED EXPONENTIAL FORMAT (are corrected....)
    fprintf(fid,'%s\n',A0);
    fprintf(fid,'%s\n','count-->m/sec');
    fprintf(fid,'%e\n',1/(Dsens*Ssens));
    fprintf(fid,'%s\n','zeros');
    fprintf(fid,'%i\n',str2num(b));
    fprintf(fid,'%e     %e\n',zfinal);
    fprintf(fid,'%s\n','poles');
    fprintf(fid,'%i\n',str2num(a));
    fprintf(fid,'%e    %e\n',pfinal);
    fprintf(fid,'%s\n',['Info:  ' date '  '  staname '  Digi sens  '  num2str(Dsens) '  Seism sens   '   num2str(Ssens)]);
    fclose(fid);
   end
elseif strcmp(button,'Yes')
    
 if ispc
    %[newfile, newdir] = uiputfile([staname 'BHZ' '.pz'], 'Save pole zero file as');
    
      h=dir('pzfiles');

     if isempty(h);
        startfolder='';
     else
        startfolder=[pwd '.\pzfiles']; 
     end
     
         newdir = uigetdir(startfolder);
 
     newfile1=[staname 'BHZ' '.pz'];
     newfile2=[staname 'BHE' '.pz'];
     newfile3=[staname 'BHN' '.pz'];
    
    fid = fopen([newdir '\' newfile1],'w');
    fprintf(fid,'%s\r\n','A0');   %%%%%BE CAREFUL THESE NEED EXPONENTIAL FORMAT (are corrected....)
    fprintf(fid,'%s\r\n',A0);
    fprintf(fid,'%s\r\n','count-->m/sec');
    fprintf(fid,'%e\r\n',1/(Dsens*Ssens));
    fprintf(fid,'%s\r\n','zeros');
    fprintf(fid,'%i\r\n',str2num(b));
    fprintf(fid,'%e     %e\r\n',zfinal);
    fprintf(fid,'%s\r\n','poles');
    fprintf(fid,'%i\r\n',str2num(a));
    fprintf(fid,'%e    %e\r\n',pfinal);
    fprintf(fid,'%s\r\n',['Info:  ' date '  '  staname '  Digi sens  '  num2str(Dsens) '  Seism sens   '   num2str(Ssens)]);
    fclose(fid);
    
    %[newfile, newdir] = uiputfile([staname 'BHE' '.pz'], 'Save pole zero file as');
    
    fid = fopen([newdir '\'  newfile2],'w');
    fprintf(fid,'%s\r\n','A0');   %%%%%BE CAREFUL THESE NEED EXPONENTIAL FORMAT (are corrected....)
    fprintf(fid,'%s\r\n',A0);
    fprintf(fid,'%s\r\n','count-->m/sec');
    fprintf(fid,'%e\r\n',1/(Dsens*Ssens));
    fprintf(fid,'%s\r\n','zeros');
    fprintf(fid,'%i\r\n',str2num(b));
    fprintf(fid,'%e     %e\r\n',zfinal);
    fprintf(fid,'%s\r\n','poles');
    fprintf(fid,'%i\r\n',str2num(a));
    fprintf(fid,'%e    %e\r\n',pfinal);
    fprintf(fid,'%s\r\n',['Info:  ' date '  '  staname '  Digi sens  '  num2str(Dsens) '  Seism sens   '   num2str(Ssens)]);
    fclose(fid);

   % [newfile, newdir] = uiputfile([staname 'BHN' '.pz'], 'Save pole zero file as');
    
    fid = fopen([newdir '\'  newfile3],'w');
    fprintf(fid,'%s\r\n','A0');   %%%%%BE CAREFUL THESE NEED EXPONENTIAL FORMAT (are corrected....)
    fprintf(fid,'%s\r\n',A0);
    fprintf(fid,'%s\r\n','count-->m/sec');
    fprintf(fid,'%e\r\n',1/(Dsens*Ssens));
    fprintf(fid,'%s\r\n','zeros');
    fprintf(fid,'%i\r\n',str2num(b));
    fprintf(fid,'%e     %e\r\n',zfinal);
    fprintf(fid,'%s\r\n','poles');
    fprintf(fid,'%i\r\n',str2num(a));
    fprintf(fid,'%e    %e\r\n',pfinal);
    fprintf(fid,'%s\r\n',['Info:  ' date '  '  staname '  Digi sens  '  num2str(Dsens) '  Seism sens   '   num2str(Ssens)]);
    fclose(fid);
 
    
    helpdlg(['Files saved in folder   '   newdir   ],'Info');
    
    
 else
  %    [newfile, newdir] = uiputfile([staname 'BHZ' '.pz'], 'Save pole zero file as');
    
          h=dir('pzfiles');

     if isempty(h);
        startfolder='';
     else
        startfolder=[pwd './pzfiles']; 
     end
     
         newdir = uigetdir(startfolder);
 
     newfile1=[staname 'BHZ' '.pz'];
     newfile2=[staname 'BHE' '.pz'];
     newfile3=[staname 'BHN' '.pz'];
    
  
    fid = fopen([newdir '/'  newfile1],'w');
    fprintf(fid,'%s\n','A0');   %%%%%BE CAREFUL THESE NEED EXPONENTIAL FORMAT (are corrected....)
    fprintf(fid,'%s\n',A0);
    fprintf(fid,'%s\n','count-->m/sec');
    fprintf(fid,'%e\n',1/(Dsens*Ssens));
    fprintf(fid,'%s\n','zeros');
    fprintf(fid,'%i\n',str2num(b));
    fprintf(fid,'%e     %e\n',zfinal);
    fprintf(fid,'%s\n','poles');
    fprintf(fid,'%i\n',str2num(a));
    fprintf(fid,'%e    %e\n',pfinal);
    fprintf(fid,'%s\n',['Info:  ' date '  '  staname '  Digi sens  '  num2str(Dsens) '  Seism sens   '   num2str(Ssens)]);
    fclose(fid);
    
  %  [newfile, newdir] = uiputfile([staname 'BHE' '.pz'], 'Save pole zero file as');
    fid = fopen([newdir '/' newfile2],'w');
    fprintf(fid,'%s\n','A0');   %%%%%BE CAREFUL THESE NEED EXPONENTIAL FORMAT (are corrected....)
    fprintf(fid,'%s\n',A0);
    fprintf(fid,'%s\n','count-->m/sec');
    fprintf(fid,'%e\n',1/(Dsens*Ssens));
    fprintf(fid,'%s\n','zeros');
    fprintf(fid,'%i\n',str2num(b));
    fprintf(fid,'%e     %e\n',zfinal);
    fprintf(fid,'%s\n','poles');
    fprintf(fid,'%i\n',str2num(a));
    fprintf(fid,'%e    %e\n',pfinal);
    fprintf(fid,'%s\n',['Info:  ' date '  '  staname '  Digi sens  '  num2str(Dsens) '  Seism sens   '   num2str(Ssens)]);
    fclose(fid);

 %   [newfile, newdir] = uiputfile([staname 'BHN' '.pz'], 'Save pole zero file as');
    fid = fopen([newdir '/' newfile3],'w');
    fprintf(fid,'%s\n','A0');   %%%%%BE CAREFUL THESE NEED EXPONENTIAL FORMAT (are corrected....)
    fprintf(fid,'%s\n',A0);
    fprintf(fid,'%s\n','count-->m/sec');
    fprintf(fid,'%e\n',1/(Dsens*Ssens));
    fprintf(fid,'%s\n','zeros');
    fprintf(fid,'%i\n',str2num(b));
    fprintf(fid,'%e     %e\n',zfinal);
    fprintf(fid,'%s\n','poles');
    fprintf(fid,'%i\n',str2num(a));
    fprintf(fid,'%e    %e\n',pfinal);
    fprintf(fid,'%s\n',['Info:  ' date '  '  staname '  Digi sens  '  num2str(Dsens) '  Seism sens   '   num2str(Ssens)]);
    fclose(fid);
   
        helpdlg(['Files saved in folder   '   newdir   ],'Info');
 end

end




% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(handles.makepz)


% --- Executes during object creation, after setting all properties.
function A0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to A0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function A0_Callback(hObject, eventdata, handles)
% hObject    handle to A0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of A0 as text
%        str2double(get(hObject,'String')) returns contents of A0 as a double


% --- Executes during object creation, after setting all properties.
function Dsens_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Dsens (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function Dsens_Callback(hObject, eventdata, handles)
% hObject    handle to Dsens (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Dsens as text
%        str2double(get(hObject,'String')) returns contents of Dsens as a double


% --- Executes during object creation, after setting all properties.
function Ssens_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Ssens (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function Ssens_Callback(hObject, eventdata, handles)
% hObject    handle to Ssens (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Ssens as text
%        str2double(get(hObject,'String')) returns contents of Ssens as a double


% --- Executes on button press in plot.
function plot_Callback(hObject, eventdata, handles)
% hObject    handle to plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ha=guihandles(makepz);

%%%% read poles
a=get(ha.npoles,'String');

for i=1:str2num(a)
   str1=['get(ha.pr' num2str(i) ',''String'')' ];
   str2=['get(ha.pi' num2str(i) ',''String'')' ];

   p_r(i)=str2num(eval(str1));
   p_i(i)=str2num(eval(str2));
  
end
pfinal=complex(p_r,p_i);
%%%read zeroes

b=get(ha.nzeroes,'String');

for i=1:str2num(b)
   str1=['get(ha.zr' num2str(i) ',''String'')' ]
   str2=['get(ha.zi' num2str(i) ',''String'')' ]

   z_r(i)=str2num(eval(str1))
   z_i(i)=str2num(eval(str2))
   
end

zfinal=complex(z_r, z_i);
%%% read A0
A0=str2num(get(ha.A0,'String'));
%%%%station name
staname=get(ha.staname,'String');

a_ns=zpk(zfinal,pfinal,A0);
ev1 = tf(a_ns);% 

figure

hb=bodeplot(ev1);
grid on

opts = getoptions(hb);

opts.Title.String = staname;
opts.Title.FontSize=18;
opts.XLabel.FontSize=16;
opts.YLabel.FontSize=16;

opts.FreqUnits='Hz';
opts.TickLabel.FontSize=12;
opts.TickLabel.FontWeight='bold';
% opts.XlimMode={'manual'}
% opts.Xlim={[0, 1000]};

setoptions(hb,opts);

%setoptions(hb,'FreqUnits','Hz','Title.String',staname)

figure 
subplot(2,1,1)

[mag,phase,w] = bode(ev1, {0.01, 1000});
w=w*0.159;		%  translates rad/s in Hz only for graphing purposes  rad/s=2*pi*f (f in Hz)

loglog(w,(mag(:))), grid on
title(['Station ', staname ,'       Amplitude Response   ']);
xlabel('Hz');
subplot(2,1,2);
loglog(w,(phase(:))), grid on
%loglog(w,squeeze(phase)), grid on

xlabel('Hz')
title('Phase Response (Deg)')

max(mag(:));

ha=[];

% --- Executes during object creation, after setting all properties.
function staname_CreateFcn(hObject, eventdata, handles)
% hObject    handle to staname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function staname_Callback(hObject, eventdata, handles)
% hObject    handle to staname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of staname as text
%        str2double(get(hObject,'String')) returns contents of staname as a double




% --- Executes on button press in load.
function load_Callback(hObject, eventdata, handles)
% hObject    handle to load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%% check if pzfiles exists..!
h=dir('pzfiles');

if ~isempty(h);
    if ispc
            [file1,path1] = uigetfile([ '.\pzfiles\*.pz'],'Import ISOLA Pole Zero file');
    else
            [file1,path1] = uigetfile([ './pzfiles/*.pz'],'Import ISOLA Pole Zero file');
    end
else
    [file1,path1] = uigetfile([ '*.pz'],'Import ISOLA Pole Zero file');
end

%% check if we have pz values already and initialise
ha=guihandles(makepz);

%%%% read poles
anzeroes=str2num(get(ha.nzeroes,'String'));
bnpoles=str2num(get(ha.npoles,'String'));
if ~isempty(anzeroes)
    
    for p=1:anzeroes
      h1=findobj('Tag',['zr' num2str(p) ]);
      delete(h1)
      h2=findobj('Tag',['zi' num2str(p) ]);
      delete(h2)
    end
    
    for p=1:bnpoles
      h1=findobj('Tag',['pr' num2str(p) ]);
      delete(h1)
      h2=findobj('Tag',['pi' num2str(p) ]);
      delete(h2)
    end
    
else
    disp('new run')
end


%%
file2=[path1 file1]

% get station name
str2=fliplr(file1);
aa=str2(strfind(str2,'.')+4:end);
sname=fliplr(aa);

   set(handles.staname,'String',sname);

   fid = fopen(file2,'r');
    aa=fgetl(fid);
    A0ns=str2num(fgetl(fid));
    set(handles.A0,'String',num2str(A0ns,'%10.5E'));
    aa=fgetl(fid);
    constantns=str2num(fgetl(fid));

            zer=fgetl(fid);
          %  zer=zer(1:6);  % disabled 10/10/2016 it was creating problems
          %  if user had zeros instead of zeroes..!
            nzerns=str2num(fgetl(fid));
            set(handles.nzeroes,'String',num2str(nzerns));
            
            position=handles.zposition;

        for p=1:nzerns
            zer=str2num(fgetl(fid));
            zeroesns(p)=complex(zer(1,1),zer(1,2));
            % create text boxes
            t1=['zr' num2str(p)];
            t2=['zi' num2str(p)];
            uicontrol('Style', 'edit', 'String',num2str(zer(1,1)),'Tag',t1,'Position', [position(1) position(2)-40 100 25],'BackgroundColor','white');
            uicontrol('Style', 'edit', 'String',num2str(zer(1,2)),'Tag',t2,'Position', [position(1)+110 position(2)-40 100 25],'BackgroundColor','white');
            position(2)=position(2)-40;
        end

        if nzerns == 0
            zeroesns=[];
        end
%%% finished with zeroes
%%% read poles
            pol=fgetl(fid);
            pol=pol(1:5);
            npolns=str2num(fgetl(fid));
            set(handles.npoles,'String',num2str(npolns));
            
            position=handles.pposition;
            
        for p=1:npolns
            pol=str2num(fgetl(fid));
            polesns(p)=complex(pol(1),pol(2));
            % create text boxes
            t1=['pr' num2str(p)];
            t2=['pi' num2str(p)];
            uicontrol('Style', 'edit', 'String',num2str(pol(1)),'Tag',t1,'Position', [position(1) position(2)-40 100 25],'BackgroundColor','white');
            uicontrol('Style', 'edit', 'String',num2str(pol(2)),'Tag',t2,'Position', [position(1)+110 position(2)-40 100 25],'BackgroundColor','white');
            position(2)=position(2)-40;
        end
%%%% check if there is info to compute  clip level 
          ffline=fgets(fid);
          AA=ischar(ffline);
          
            switch AA
            case 1
                idx1 = strfind(ffline, 'Info:');
                if idx1 == 1
                        index1=strfind(ffline,'Digi sens');
                        index2=strfind(ffline,'Seism sens');
                        digisens_ns = sscanf(ffline(index1+9: index2-1),'%f');
                        seismsens_ns = sscanf(ffline(index2+10: length(ffline)),'%f');
                        nsclip=1;
                        disp('Read Clip info for NS.')
                        
                        % update text boxes
                        set(handles.Dsens,'String',num2str(digisens_ns));
                        set(handles.Ssens,'String',num2str(seismsens_ns));
                 else
                        disp('Check the last line in pz file. It doesn''t seem correct. Clip info not read.')
                        nsclip=0;
                 end

            case 0
                nsclip=0;
                disp('Clip info not found for NS')
            otherwise
                nsclip=0;
                disp('Error')
            end
                
fclose(fid);


%%
handles.nozeroes=nzerns;
handles.nopoles=npolns;
% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in help.
function help_Callback(hObject, eventdata, handles)
% hObject    handle to help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% find where isola is installed
infold=which('isola.m');
str = strrep(infold,'isola.m','');

h=dir([str '\doc']);
% 

if isempty(h);
  
   errordlg('Could not find doc folder in isola installation folder. Cannot open documentation','Folder Error');
  
else

    url = [str 'doc\ISOLA_pz.htm'];
    a=exist(url,'file');

  if a~=2
    
    errordlg(['Could not find ' url ],'File Error');
    
  else
    
    stat=web(url) ;
      
       switch stat
        case  0
            disp('Browser was found and launched.')
        case  1
            disp('Browser was not found.')
        case  2
            disp('Browser was found but could not be launched.')
       end
    
  end


end




