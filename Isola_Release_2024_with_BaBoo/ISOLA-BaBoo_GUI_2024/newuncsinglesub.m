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
disp('10/08/2024')


%% check if files/folsers are present
%check if newunc exists..!

fh=exist('newunc','dir');

if (fh~=7)
    errordlg('newunc folder doesn''t exist. ISOLA will create it. ','Folder warning');
    mkdir('newunc');
end

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
% disable Source Type Plot is it is DEV

if strcmp(stype,'FULL')
    set(handles.hudson,'Enable','on')
else
    disp('This is not a FULL type inversion. Source Type Plot will be disabled.')
end

%%
if ispc
         fid = fopen('.\invert\inpinv.dat','r');
            linetmp1=fgetl(fid);         %01 line
            linetmp2=fgetl(fid);        %02 line
            linetmp3=fgetl(fid);          %03 line
            linetmp4=fgetl(fid);         %04 line
            linetmp5=fgetl(fid);          %05 line
            linetmp6=fgetl(fid);          %06 line
            linetmp7=fgetl(fid);          %07 line
            linetmp8=fgetl(fid);          %08 line
            linetmp9=fgetl(fid);          %09 line
            linetmp10=fgetl(fid);          %10 line
            linetmp11=fgetl(fid);          %11 line
            linetmp12=fgetl(fid);          %12 line
            linetmp13=fgetl(fid);           %13 line
            linetmp14=fgetl(fid);          %14 line
            linetmp15=fgetl(fid);         %15 line
            linetmp16=fgetl(fid);         %16 line
       fclose(fid);
else
         fid = fopen('./invert/inpinv.dat','r');
            linetmp1=fgetl(fid);         %01 line
            linetmp2=fgetl(fid);         %02 line
            linetmp3=fgetl(fid);          %03 line
            linetmp4=fgetl(fid);         %04 line
            linetmp5=fgetl(fid);          %05 line
            linetmp6=fgetl(fid);          %06 line
            linetmp7=fgetl(fid);          %07 line
            linetmp8=fgetl(fid);          %08 line
            linetmp9=fgetl(fid);          %09 line
            linetmp10=fgetl(fid);          %10 line
            linetmp11=fgetl(fid);          %11 line
            linetmp12=fgetl(fid);          %12 line
            linetmp13=fgetl(fid);           %13 line
            linetmp14=fgetl(fid);          %14 line
            linetmp15=fgetl(fid);         %15 line
            linetmp16=fgetl(fid);         %16 line
       fclose(fid);
end

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
%% new code to get values from inv4 08/2024
% check for inv4
if ispc 
       fh2=exist('.\invert\inv4.dat','file');
        if (fh2~=2) 
                 errordlg('Invert folder doesn''t contain inv4.dat. Please run inversion. ','File Error');
                 delete(handles.create_synth)
        else
          fid = fopen('.\invert\inv4.dat','r');
            linetmp0=fgetl(fid);         %01 line
            A=sscanf(linetmp0,'%e %e  %e  %e  %e');
          fclose(fid);
            datavar=A(4);
        end
else
       fh2=exist('./invert/inv4.dat','file');
        if (fh2~=2) 
                 errordlg('Invert folder doesn''t contain inv4.dat. Please run inversion. ','File Error');
                 delete(handles.create_synth)
        else
          fid = fopen('./invert/inv4.dat','r');
            linetmp0=fgetl(fid);         %01 line
            A=sscanf(linetmp0,'%e %e  %e  %e  %e');
          fclose(fid);
            datavar=A(4);
        end
end
%% update inpinv with datavar
       % update it
          fid = fopen('.\invert\inpinv.dat','w');
               fprintf(fid,'%s\r\n',linetmp1);
               fprintf(fid,'%s\r\n',linetmp2);
               fprintf(fid,'%s\r\n',linetmp3);
               fprintf(fid,'%s\r\n',linetmp4);
               fprintf(fid,'%s\r\n',linetmp5);
               fprintf(fid,'%s\r\n',linetmp6);
               fprintf(fid,'%s\r\n',linetmp7);
               fprintf(fid,'%s\r\n',linetmp8);
               fprintf(fid,'%s\r\n',linetmp9);
               fprintf(fid,'%s\r\n',linetmp10);
               fprintf(fid,'%s\r\n',linetmp11);
               fprintf(fid,'%s\r\n',linetmp12);
               fprintf(fid,'%s\r\n',linetmp13);
               fprintf(fid,'%s\r\n',linetmp14);
               fprintf(fid,'%s\r\n',linetmp15);
               %% update with datavar  in inv4
               fprintf(fid,'%e\r\n', datavar);
                     
          fclose(fid);
%%
% check if invert was done using COVA

% look for  cova.sel

if exist('cova.sel','file') 
   fid = fopen('cova.sel');
      covatype=fscanf(fid,'%s',1); 
   fclose(fid);
   if strcmp(covatype(1:3),'sta')
       disp('Run without COVA')
        cova=0;   
   else
       disp('Run with COVA')
       cova=1;
   end
   
else
   disp('cova.sel not found cannot continue') 
end



%% 
handles.stype=stype;  
handles.datavar=datavar;
handles.cova=cova; 


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
cova=handles.cova;
stype=handles.stype;        
%pwd
%%
% read inv3.dat and get the subevent number
subevnt_no=str2double(get(handles.subno,'String')); 

disp(['Selected subevent is no  ' get(handles.subno,'String')])

% SUB_TABLE=readtable('.\invert\inv3.dat','Delimiter'," ",'LeadingDelimitersRule','ignore','FileType','delimitedtext','HeaderLines',0,'ConsecutiveDelimitersRule','join');
% new code because readtable was unstable in different matlab versions

fid=fopen('.\invert\inv3.dat'); C=textscan(fid,'%f %f %f %f %f %f %f %f'); fclose(fid);

SUB_TABLE = array2table(cell2mat(C)); SUB_TABLE.Properties.VariableNames =["Trial_Source_position", "Time_dt","Mrr","Mtt","Mpp","Mrt","Mrp","Mtp"]

% check if subevent number is not larger than Table's dimension
if subevnt_no > height(SUB_TABLE)
    errordlg('Your subevent selection is larger than subevents included in inv3 file.','Error');
    return
else
    
end

sel_sub=SUB_TABLE(subevnt_no,:)

% Convert HRV MT components to ‘a-coefficients’. 
% If a(6)=0, it is devia, otherwise full MT. In your newunc, these a’s are in vector A.
[hrv,trialsource] =readinv3sub(subevnt_no);


hrv

trialsource

if iscell(trialsource)
   trialsource=cell2mat(trialsource);
else
   disp('trialsource not cell')
end


%format longEng
Alphas = hrv2alpha(hrv); 

%% we must run isola_nocova
% prepare a batch file to run isola15unc and norm
 
if cova==0  % i.e. NO COVA invert run

fid = fopen('.\invert\runisola15unc.bat','w');
     fprintf(fid,'%s\r\n','call "C:\Program Files (x86)\Intel\oneAPI\setvars.bat"');  %for 64bit
     fprintf(fid,'%s\r\n','isola_nocova.exe');
     fprintf(fid,'%s\r\n','norm.exe');
     fprintf(fid,'%s\r\n','done.exe');
fclose(fid);

% Run the batch file
        disp('Calculating sigma..')

cd invert        
        % remove done file before running the code
        if FileExist('done.tmp')
            delete('done.tmp')
        end

        % run the batch file        
        [status , result] = system('runisola15unc.bat')
         
        % wait here for fortran part to end
        done = 0;
        while done == 0
            done = FileExist('done.tmp');
        end
        disp('         '); disp('Fortran uncertainty code finished.');disp('         ')     
        
        % remove done file before next run !
        delete('done.tmp')

cd .. 

elseif cova==1
    disp('This is a COVA type invert run. No need to do something here.')  
end

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

                path11=[];   path22=[];

                for i=1:length(str1)
                   path1(:,:) = GreatCircle(deg2rad(str1(i)),deg2rad(dp1(i)),1);    %plot(path(:,1),path(:,2),'r-')
                   path2(:,:) = GreatCircle(deg2rad(str2(i)),deg2rad(dp2(i)),1);    %plot(path(:,1),path(:,2),'r-')
                   path11=[path11;[NaN NaN];path1]; path22=[path22;[NaN NaN];path2];
                end
                % plot
                plot(path11(:,1),path11(:,2),'r-');  plot(path22(:,1),path22(:,2),'r-')
                title('Nodal plot  ','FontSize',14)
                hold off
                
                P_y=zeros(1,m);P_x=zeros(1,m);T_y=zeros(1,m);T_x=zeros(1,m);
                subplot(1,4,4)% P-T axis PLOT
                Stereonet(0,90*pi/180,1000*pi/180,1);axis ([-1 1 -1 1]);
                hold on

                for ii=1:length(str1)
                   [P_y(ii),P_x(ii),T_y(ii),T_x(ii)]=P_T_axes_notext_fun(str1(ii),dp1(ii),rk1(ii));
                end
                % plot
                plot(P_y,P_x,'ro','MarkerSize',10,'LineWidth',1.5);
                plot(T_y,T_x,'g+','MarkerSize',10,'LineWidth',1.5);
                %title('P(red o)-T(green +) axes plot  ','FontSize',14)
                title(['\fontsize{15}   {\color{red}P(o) \color{black}-'...
                    '\color{green}T(+)}   axes plot'],'interpreter','tex');


                hold off

%%
% compute mean and one standard deviation
disp('      ')

disp(['Mean of DC% is   : ' num2str(mean(adc_2),'%3.1f')     '      STD  of DC% is   : ' num2str(std(adc_2),'%3.1f')       ])
disp(['Mean of CLVD% is : ' num2str(mean(aclvd_2),'%3.1f')   '      STD  of CLVD% is : ' num2str(std(aclvd_2),'%3.1f')     ])

disp('         ')



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

                subplot(1,5,2)  %aclvd_2
                histogram(aclvd_2,xbins);title('CLVD%   ','FontSize',14);
                ax=gca;set(ax,'Linewidth',2,'FontSize',12);xlim([-100,100]);

                subplot(1,5,3)  %avol_1
                histogram(avol_2,xbins);title('VOL%   ','FontSize',14);
                ax=gca;set(ax,'Linewidth',2,'FontSize',12);xlim([-100,100]);
                

                subplot(1,5,4)% NODAL LINE PLOT
                Stereonet(0,90*pi/180,1000*pi/180,1);axis ([-1 1 -1 1]);
                hold on

                path11=[];   path22=[];

                for i=1:length(str1)
                   path1(:,:) = GreatCircle(deg2rad(str1(i)),deg2rad(dp1(i)),1);    %plot(path(:,1),path(:,2),'r-')
                   path2(:,:) = GreatCircle(deg2rad(str2(i)),deg2rad(dp2(i)),1);    %plot(path(:,1),path(:,2),'r-')
                   path11=[path11;[NaN NaN];path1]; path22=[path22;[NaN NaN];path2];
                end
                % plot
                plot(path11(:,1),path11(:,2),'r-');  plot(path22(:,1),path22(:,2),'r-')
                title('Nodal plot  ','FontSize',14)
                hold off
                axis square
                axis off
                
                P_y=zeros(1,m);P_x=zeros(1,m);T_y=zeros(1,m);T_x=zeros(1,m);
                subplot(1,5,5)% P-T axis PLOT
                Stereonet(0,90*pi/180,1000*pi/180,1);axis ([-1 1 -1 1]);
                hold on

                for ii=1:length(str1)
                   [P_y(ii),P_x(ii),T_y(ii),T_x(ii)]=P_T_axes_notext_fun(str1(ii),dp1(ii),rk1(ii));
                end
                % plot
                plot(P_y,P_x,'ro','MarkerSize',10,'LineWidth',1.5);
                plot(T_y,T_x,'g+','MarkerSize',10,'LineWidth',1.5);
                %title('P(red o)-T(green +) axes plot  ','FontSize',14)
                title(['\fontsize{15}   {\color{red}P(o) \color{black}-'...
                    '\color{green}T(+)}   axes plot'],'interpreter','tex');
                hold off

                
%
disp('       ')

disp(['Mean of DC% is   : ' num2str(mean(adc_2),'%3.1f')   '   STD  of DC% is   : ' num2str(std(adc_2),'%3.1f')  ])
disp(['Mean of CLVD% is : ' num2str(mean(aclvd_2),'%3.1f') '   STD  of CLVD% is : ' num2str(std(aclvd_2),'%3.1f')])
disp(['Mean of ISO% is  : ' num2str(mean(avol_2),'%3.1f')  '   STD  of ISO% is  : ' num2str(std(avol_2),'%3.1f') ])

disp('       ')


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
