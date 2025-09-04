function varargout = newuncsinglesub(varargin)
% NEWUNCSINGLESUB MATLAB code for newuncsinglesub.fig
%      NEWUNCSINGLESUB, by itself, creates a new NEWUNCSINGLESUB or raises the existing
%      singleton*.
%
%      H = NEWUNCSINGLESUB returns the handle to a new NEWUNCSINGLESUB or the handle to
%      the existing singleton*.
%
%      NEWUNCSINGLESUB('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NEWUNCSINGLESUB.M with the given input arguments.
%
%      NEWUNCSINGLESUB('Property','Value',...) creates a new NEWUNCSINGLESUB or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before newuncsinglesub_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to newuncsinglesub_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help newuncsinglesub

% Last Modified by GUIDE v2.5 05-Mar-2024 23:03:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @newuncsinglesub_OpeningFcn, ...
                   'gui_OutputFcn',  @newuncsinglesub_OutputFcn, ...
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


% --- Executes just before newuncsinglesub is made visible.
function newuncsinglesub_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to newuncsinglesub (see VARARGIN)

disp('This is newuncsinglesub')
%disp('27/02/2024')


%% check if files/folsers are present
%check if newunc exists..!

% fh=exist('newunc','dir');
% 
% if (fh~=7)
%     errordlg('newunc folder doesn''t exist. ISOLA will create it. ','Folder warning');
%     mkdir('newunc');
% end

%% check if INVERT exists..!
fh2=exist('invert','dir');

if (fh2~=7)
    errordlg('Invert folder doesn''t exist. Please create it. ','Folder Error');
    delete(handles.newuncsinglesub)
end

%% check if INPINV.DAT exists..!
if ispc 
        fh2=exist('.\invert\inpinv.dat','file'); 
         if (fh2~=2) 
                  errordlg('Invert folder doesn''t contain inpinv.dat. Please run inversion. ','File Error');
                  delete(handles.newuncsinglesub)
         end
         
         % read from inpinv.dat if we have DEV or FULL inversion
         [id,~,~,~,~,~,~] = readinpinv('.\invert\inpinv.dat');
         
         switch id
             case 1
                 stype='FULL';
             case 2
                 stype='DEV';
             case 3
                 stype='DC';
             case 4
                 stype='FIXED';
         end
         
         
else
        fh2=exist('./invert/inpinv.dat','file'); 
         if (fh2~=2) 
                  errordlg('Invert folder doesn''t contain inpinv.dat. Please run inversion. ','File Error');
                  delete(handles.newuncsinglesub)
         end
         
       % read from inpinv.dat if we have DEV or FULL inversion
         [id,~,~,~,~,~,~] = readinpinv('./invert/inpinv.dat');
         
         switch id
             case 1
                 stype='FULL';
             case 2
                 stype='DEV';
             case 3
                 stype='DC';
             case 4
                 stype='FIXED';
         end
         
         
end
 
%
disp(['Inversion Type is   :  '   stype])

%%
if ispc 
        fh2=exist('.\invert\sigma_all.dat','file'); 
         if (fh2~=2) 
                  errordlg('Invert folder doesn''t contain sigma_all.dat. Please run inversion. ','File Error');
                  delete(handles.newuncsinglesub)
         end
else
        fh2=exist('./invert/sigma_all.dat','file'); 
         if (fh2~=2) 
                  errordlg('Invert folder doesn''t contain sigma_all.dat. Please run inversion. ','File Error');
                  delete(handles.newuncsinglesub)
         end
end

%%
if ispc 
        fh2=exist('.\invert\inv3.dat','file'); 
         if (fh2~=2) 
                  errordlg('Invert folder doesn''t contain inv3.dat. Please run inversion. ','File Error');
                  delete(handles.newuncsinglesub)
         end
else
        fh2=exist('./invert/inv3.dat','file'); 
         if (fh2~=2) 
                  errordlg('Invert folder doesn''t contain inv3.dat. Please run inversion. ','File Error');
                  delete(handles.newuncsinglesub)
         end
end

%% 
 handles.stype=stype;  


% Choose default command line output for newuncsinglesub
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes newuncsinglesub wait for user response (see UIRESUME)
% uiwait(handles.newuncsinglesub);


% --- Outputs from this function are returned to the command line.
function varargout = newuncsinglesub_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function subno_Callback(hObject, eventdata, handles)
% hObject    handle to subno (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of subno as text
%        str2double(get(hObject,'String')) returns contents of subno as a double


% --- Executes during object creation, after setting all properties.
function subno_CreateFcn(hObject, eventdata, handles)
% hObject    handle to subno (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nsamples_Callback(hObject, eventdata, handles)
% hObject    handle to nsamples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nsamples as text
%        str2double(get(hObject,'String')) returns contents of nsamples as a double


% --- Executes during object creation, after setting all properties.
function nsamples_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nsamples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in plot.
function plot_Callback(hObject, eventdata, handles)
% hObject    handle to plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

stype=handles.stype;        

%pwd

%%
% read inv3.dat
% get the subevent number
subevnt_no=str2double(get(handles.subno,'String')); 


SUB_TABLE=readtable('.\invert\inv3.dat','Delimiter',' ','FileType','text','MultipleDelimsAsOne',1,'HeaderLines',0); 

SUB_TABLE.Properties.VariableNames =["Trial_Source_position", "Time_dt","Mrr","Mtt","Mpp","Mrt","Mrp","Mtp"]

% check if subevent number is not larger than Table's dimension
if subevnt_no > height(SUB_TABLE)
    errordlg('Your subevent selection is larger than subevents included in inv3 file.','Error');
    return
else
    
end

disp(['Selected subevent is no  ' get(handles.subno,'String')])
sel_sub=SUB_TABLE(subevnt_no,:)

% Convert HRV MT components to ‘a-coefficients’. 
% If a(6)=0, it is devia, otherwise full MT. In your newunc, these a’s are in vector A.
[hrv,trialsource] =readinv3sub(subevnt_no);
%format longEng
Alphas = hrv2alpha(hrv); 

%%
if strcmp(stype,'DEV') | strcmp(stype,'DC')
   disp('Deviatoric or DC-constrained solution') 
   A=[Alphas(1) Alphas(2) Alphas(3) Alphas(4) Alphas(5)];
   stype='DEV' ;
   sigma=read_sigmaall('.\invert\sigma_all.dat',trialsource,stype)

   scalefact=1;

          sigma=(sigma+sigma.')/2;   %% for problems with round-off
          sigma=sigma .* 1e20;
          sigma=sigma .* scalefact;

          nsamples=str2double(get(handles.nsamples,'String'));
%
r6 = mvnrnd(A,sigma,nsamples); 
r6=[r6 zeros(nsamples,1)];

%
 [m,~]=size(r6) ;

% allocate  
 str1=zeros(1,m);dp1=zeros(1,m);rk1=zeros(1,m);  str2=zeros(1,m);dp2=zeros(1,m);rk2=zeros(1,m);
 adc_1=zeros(1,m);adc_2=zeros(1,m);avol_1=zeros(1,m);avol_2=zeros(1,m);aclvd_1=zeros(1,m);aclvd_2=zeros(1,m);amt=zeros(1,m);
  
  for ii=1:m
     [str1(ii),dp1(ii),rk1(ii),str2(ii),dp2(ii),rk2(ii),~,adc_2(ii),~,~,~,aclvd_2(ii),~] = silsubnew2(r6(ii,:)) ;
  end
 
    
%% PLOTING
xbins=[-100   -80   -60   -40   -20     0    20    40    60    80   100];
dcbins=[0    10    20    30    40    50    60    70    80    90   100];
%
     figure; %DC_1
                subplot(1,4,1)
                histogram(adc_2,dcbins);title('DC%    ','FontSize',14);
                ax=gca;set(ax,'Linewidth',2,'FontSize',12);xlim([0,100]);

                subplot(1,4,2)  %aclvd_2
                histogram(aclvd_2,xbins);title('CLVD%   ','FontSize',14);
                ax=gca;set(ax,'Linewidth',2,'FontSize',12);xlim([-100,100]);
                
                subplot(1,4,3)% NODAL LINE PLOT
                Stereonet(0,90*pi/180,1000*pi/180,1);axis ([-1 1 -1 1]);
                hold on
                for i=1:length(str1)
                   path = GreatCircle(deg2rad(str1(i)),deg2rad(dp1(i)),1);plot(path(:,1),path(:,2),'r-')
                   path = GreatCircle(deg2rad(str2(i)),deg2rad(dp2(i)),1);plot(path(:,1),path(:,2),'r-')
                end
                title('Nodal plot  ','FontSize',14)
                hold off
                
                subplot(1,4,4)% P-T axis PLOT
                Stereonet(0,90*pi/180,1000*pi/180,1);axis ([-1 1 -1 1]);
                hold on
                for ii=1:length(str1)
                   P_T_axes_notext(str1(ii),dp1(ii),rk1(ii));
                end
%                   P_T_axes_notext2(30,90,0);
                title('P(o)-T(+) axes plot  ','FontSize',14)

%%
% compute mean and one standard deviation

disp(['Mean of DC% is : ' num2str(mean(adc_2),'%3.1f')])
disp(['STD  of DC% is : ' num2str(std(adc_2),'%3.1f')])

disp(['Mean of CLVD% is : ' num2str(mean(aclvd_2),'%3.1f')])
disp(['STD  of CLVD% is : ' num2str(std(aclvd_2),'%3.1f')])



elseif strcmp(stype,'FULL')
   disp('Full solution')  
   stype='FULL';
   % call the read signa_all function with appropriate trial source
sigma=read_sigmaall('.\invert\sigma_all.dat',trialsource,stype)
 
 scalefact=1;

          sigma=(sigma+sigma.')/2;   %% for problems with round-off
          sigma=sigma .* 1e20;
          sigma=sigma .* scalefact;

          nsamples=str2double(get(handles.nsamples,'String'));
%
r6 = mvnrnd(Alphas,sigma,nsamples) ;
%
 [m,~]=size(r6) ;

% allocate  
 str1=zeros(1,m);dp1=zeros(1,m);rk1=zeros(1,m);  str2=zeros(1,m);dp2=zeros(1,m);rk2=zeros(1,m);
 adc_1=zeros(1,m);adc_2=zeros(1,m);avol_1=zeros(1,m);avol_2=zeros(1,m);aclvd_1=zeros(1,m);aclvd_2=zeros(1,m);amt=zeros(1,m);
  
  for ii=1:m
     [str1(ii),dp1(ii),rk1(ii),str2(ii),dp2(ii),rk2(ii),~,adc_2(ii),~,avol_2(ii),~,aclvd_2(ii),amt(ii)] = silsubnew2(r6(ii,:)) ;
  end
 %[str1(ii),dp1(ii),rk1(ii),str2(ii),dp2(ii),rk2(ii),adc_1(ii),adc_2(ii),avol_1(ii),avol_2(ii),aclvd_1(ii),aclvd_2(ii),amt(ii)] = silsubnew2(total_req6(ii,:));               

%% PLOTING
xbins=[-100   -80   -60   -40   -20     0    20    40    60    80   100];
dcbins=[0    10    20    30    40    50    60    70    80    90   100];
%
     figure; %DC_1
                subplot(1,5,1)
                histogram(adc_2,dcbins);title('DC%    ','FontSize',14);
                ax=gca;set(ax,'Linewidth',2,'FontSize',12);xlim([0,100]);

                subplot(1,5,2)  %avol_1
                histogram(avol_2,xbins);title('VOL%   ','FontSize',14);
                ax=gca;set(ax,'Linewidth',2,'FontSize',12);xlim([-100,100]);
                
                subplot(1,5,3)  %aclvd_2
                histogram(aclvd_2,xbins);title('CLVD%   ','FontSize',14);
                ax=gca;set(ax,'Linewidth',2,'FontSize',12);xlim([-100,100]);
                
                subplot(1,5,4)% NODAL LINE PLOT
                Stereonet(0,90*pi/180,1000*pi/180,1);axis ([-1 1 -1 1]);
                hold on
                for i=1:length(str1)
                   path = GreatCircle(deg2rad(str1(i)),deg2rad(dp1(i)),1);plot(path(:,1),path(:,2),'r-')
                   path = GreatCircle(deg2rad(str2(i)),deg2rad(dp2(i)),1);plot(path(:,1),path(:,2),'r-')
                end
                title('Nodal plot  ','FontSize',14)
                hold off
                axis square
                axis off
                
                subplot(1,5,5)% P-T axis PLOT
                Stereonet(0,90*pi/180,1000*pi/180,1);axis ([-1 1 -1 1]);
                hold on
                for ii=1:length(str1)
                   P_T_axes_notext(str1(ii),dp1(ii),rk1(ii));
                end
%                P_T_axes_notext2(30,90,0);
                title('P(o)-T(+) axes plot  ','FontSize',14)
                
%
disp(['Mean of DC% is : ' num2str(mean(adc_2),'%3.1f')])
disp(['STD  of DC% is : ' num2str(std(adc_2),'%3.1f')])

disp(['Mean of CLVD% is : ' num2str(mean(aclvd_2),'%3.1f')])
disp(['STD  of CLVD% is : ' num2str(std(aclvd_2),'%3.1f')])
                
disp(['Mean of ISO% is : ' num2str(mean(avol_2),'%3.1f')])
disp(['STD  of ISO% is : ' num2str(std(avol_2),'%3.1f')])


%% new output .. file with avol_2. aclvd_2 adc_2 amt Mw
                
                % compute Mw 
                Mw=(2./3.)*log10(amt)-6.0333;
              %   whos
                total_req6=r6;
                
                % compute Mxx/Myy and Mxx/Mzz
                a1=total_req6(:,1);a2=total_req6(:,2);a3=total_req6(:,3);
                a4=total_req6(:,4);a5=total_req6(:,5);a6=total_req6(:,6); 
                
                Mxx=-a4+a6;
                Myy=-a5+a6;
                Mzz=a4+a5+a6;
                
                Mxx_Myy=Mxx./Myy;
                Mxx_Mzz=Mxx./Mzz;
              %  whos
                % add a header
                 
                fid2=fopen('.\newunc\CLVD_ISO_DC_Mo_MW_eq6.dat','w');
                 fprintf(fid2,'%s\r\n','CLVD          ISO       DC         Mo         Mw          a1           a2           a3          a4           a5           a6            Mxx          Myy         Mzz           Mxx/Myy   Mxx/Mzz '); 
                 
                all=[aclvd_2; avol_2; adc_2; amt; Mw; a1'; a2'; a3'; a4'; a5'; a6'; Mxx'; Myy'; Mzz'; Mxx_Myy'; Mxx_Mzz'; fix(str1); fix(dp1); fix(rk1)];  
                     
                 fprintf(fid2,'%f %f %f %e %f %e %e %e %e %e %e  %e %e %e  %e %e   %5d  %5d  %5d\r\n',all);
                fclose(fid2);
                     

else
    disp('not supported')
    
end


% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.newuncsinglesub)


% --- Executes on button press in hudson.
function hudson_Callback(hObject, eventdata, handles)
% hObject    handle to hudson (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('Calling  sourceplotuncnew')
disp('It will produce a Hudson plot see Hudson, J.A., Pearce, R.G. and Rogers, R.M., 1989. Source time plot for inversion of the moment tensor, J. Geophys. Res., 94(B1), 765-774.')
disp('Code is based on RFOC package by Jonathan M. Lees')


sourceplotuncnew
