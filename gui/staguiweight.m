function varargout = staguiweight(varargin) %(handles)
%handles.passed_figure=varargin{:}
% main=handles.passed_figure;
% mainHandles=guidata(main);

% Initialization tasks
% first read allstat.dat
% 27/08/13 Update inpinv with 1st station freq band
% attempt to take weights into account..!!
% 27/11/2020
%
%

disp('This is staguiweight.m. 27/11/2020')

if ispc   
   h=dir('.\invert\allstat.dat');
else
   h=dir('./invert/allstat.dat');
end

  if isempty(h)
         errordlg('allstat.dat file doesn''t exist in invert folder. Run Station Selection. ','File Error');
     return
  else
      % try to guess allstat version 
      if ispc
        fid=fopen('.\invert\allstat.dat');
      else
        fid=fopen('./invert/allstat.dat');
      end
        tline=fgets(fid);
        [~,cnt]=sscanf(tline,'%s');
      fclose(fid);

      switch cnt
            case 9
                 disp('Found current version of allstat e.g. STA 1 1 1 1 f1 f2 f3 f4')
                 if ispc
                   [stanames,od1,od2,od3,od4,of1,of2,of3,of4] = textread('.\invert\allstat.dat','%s %f %f %f %f %f %f %f %f',-1);
                 else
                   [stanames,od1,od2,od3,od4,of1,of2,of3,of4] = textread('./invert/allstat.dat','%s %f %f %f %f %f %f %f %f',-1);
                 end
            case 6
                 disp('Found version of allstat without frequencies e.g. 001 1 1 1 1 STA')
                 if ispc
                   [~,od1,od2,od3,od4,stanames] = textread('.\invert\allstat.dat','%s %f %f %f %f %s',-1);
                 else
                   [~,od1,od2,od3,od4,stanames] = textread('./invert/allstat.dat','%s %f %f %f %f %s',-1);
                 end
                 % assign default to f1 f2 f3 f4
                 nsta=length(stanames);
                 of1=ones(nsta,1)*0.04;of2=ones(nsta,1)*0.05;of3=ones(nsta,1)*0.08;of4=ones(nsta,1)*0.09;
            case 5
                 disp('Found old version of allstat without frequencies and without station masking e.g. STA 1 1 1 1 ')
                 if ispc
                    [stanames,od1,od2,od3,od4] = textread('.\invert\allstat.dat','%s %f %f %f %f',-1);
                 else
                    [stanames,od1,od2,od3,od4] = textread('./invert/allstat.dat','%s %f %f %f %f',-1);
                 end
                 % assign default to f1 f2 f3 f4
                 nsta=length(stanames);
                 of1=ones(nsta,1)*0.04;of2=ones(nsta,1)*0.05;of3=ones(nsta,1)*0.08;of4=ones(nsta,1)*0.09;
      end

  end
  
% flip names etc
stanames=flipud(stanames);od1=flipud(od1);od2=flipud(od2);od3=flipud(od3);od4=flipud(od4);of1=flipud(of1);of2=flipud(of2);of3=flipud(of3);of4=flipud(of4);
nsta=length(stanames);

%%  check if allstat has weights!
% we'll use the sum of od2,od3,od4 !!

ns_sum=sum(od2);
ew_sum=sum(od3);
ve_sum=sum(od4);
%nsta

if ns_sum > nsta || ew_sum > nsta || ve_sum > nsta

%if (od2(1)~=1 && od2(1)~=0 || od3(1)~=1 && od3(1)~=0 || od4(1)~=1 && od4(1)~=0)
   disp('Found allstat.dat with weights.')
   warndlg('It seems that weights are used. You should recalculate weights before inversion.','Warning');
% keep backup of weights
back_od2=od2';back_od3=od3'; back_od4=od4';
 
%add a flag
weight_flag=1;   

else
   disp('Found allstat.dat without weights.')
   weight_flag=0;  
end

%%
% estimate the height of figure based on number of stations
scrsz = get(0,'ScreenSize');
fh = figure('Visible','on','Name','Select Stations - Filters', 'MenuBar','none',...
           'Position',[60 scrsz(4)/5 950 (nsta+4)*30],'units','characters','Resize','on','ResizeFcn',[]);

%%
%  Construct the components
for i=1:nsta
   
   sth(i) = uicontrol(fh,'Style','text',...
                'String',char(stanames{i}),'Units','Pixels','FontWeight','Bold',...
                'Position',[30 (i+1)*30 80 20]);
            
   % check box for station use
   cbsta(i) = uicontrol(fh,'Style','checkbox',...  
                'String','Use Station',...
                'Value',od1(i),'Position',[120 (i+1)*30 80 20]);
            
%%            
   if(od2(i)~=0)  % change due to allstat with weights
       od2(i)=1;
   else
       od2(i)=0;
   end
   % check box for NS use
   cbns(i) = uicontrol(fh,'Style','checkbox',...  
                'String','Use NS',...
                'Value',od2(i),'Position',[220 (i+1)*30 80 20],'Userdata',od2(i));            
            
   if(od3(i)~=0) 
       od3(i)=1;
   else
       od3(i)=0;
   end
   % check box for EW use
   cbew(i) = uicontrol(fh,'Style','checkbox',...  
                'String','Use EW',...
                'Value',od3(i),'Position',[320 (i+1)*30 80 20],'Userdata',od3(i));               
            
   if(od4(i)~=0) 
       od4(i)=1;
   else
       od4(i)=0;
   end
   % check box for Z use
   cbz(i) = uicontrol(fh,'Style','checkbox',...  
                'String','Use Z',...
                'Value',od4(i),'Position',[420 (i+1)*30 80 20],'Userdata',od4(i));    
%%            
  if nargin==0
    
   % frequency 1
   freq1(i) = uicontrol(fh,'Style','edit',...
                'String','',...
                'Position',[520 (i+1)*30 80 20],'String',num2str(of1(i)));
   % frequency 2
   freq4(i) = uicontrol(fh,'Style','edit',...
                'String','',...
                'Position',[620 (i+1)*30 80 20],'String',num2str(of4(i)));          
  
  elseif nargin==4
      
      of1=ones(nsta,1)*varargin{1};of2=ones(nsta,1)*varargin{2};of3=ones(nsta,1)*varargin{3};of4=ones(nsta,1)*varargin{4};
      
   % frequency 1
   freq1(i) = uicontrol(fh,'Style','text',...
                'String','',...
                'Position',[520 (i+1)*30 80 20],'String',num2str(of1(i)));

   % frequency 2
   freq4(i) = uicontrol(fh,'Style','text',...
                'String','',...
                'Position',[620 (i+1)*30 80 20],'String',num2str(of4(i)));  
    
  end    
    
end

%% Add labels
%  Frequencies
   l1 = uicontrol(fh,'Style','text',...
                'String','Stations','FontWeight','Bold',...
                'Position',[30 (nsta+2)*30 80 20]);
   l2 = uicontrol(fh,'Style','text',...
                'String','Components','FontWeight','Bold',...
                'Position',[320 (nsta+2)*30 80 20]);
   l3 = uicontrol(fh,'Style','text',...
                'String','LF','FontWeight','Bold',...
                'Position',[520 (nsta+2)*30 80 20]);
   l4 = uicontrol(fh,'Style','text',...
                'String','HF','FontWeight','Bold',...
                'Position',[620 (nsta+2)*30 80 20]);
% Cancel button
cnl = uicontrol(fh,'Style','pushbutton','String','Exit',...
                'Position',[720 10 60 40],...
                 'Callback',@cancel);
            
% Update button
upt = uicontrol(fh,'Style','pushbutton','String','Update and Exit',...
                'Position',[800 10 100 40],...
                 'Callback',@update);

% normalize            
hUIControls = findall(fh,'type','uicontrol');
set(hUIControls,'units','normalized','fontunits','normalized');            

defaultBackground = get(0,'defaultUicontrolBackgroundColor');
set(fh,'Color',defaultBackground)

for ii=1:nsta
    set(freq1(ii),'BackgroundColor',[ 1 1 1])
    set(freq4(ii),'BackgroundColor',[ 1 1 1])
end


% Wait until something is pressed
uiwait(gcf)


%  Initialization tasks
%%  Callbacks for MYGUI
function cancel(hObject,eventdata)
        delete(fh)
end


%%
% Update files based on GUI !!!
function update(hObject,eventdata)
% get names etc ??
    for k=1:nsta
        lab{k}=get(sth(k),'String');
        usestn(k)=get(cbsta(k),'Value');
%
        usens(k)=get(cbns(k),'Value');
        useew(k)=get(cbew(k),'Value');
        usez(k)=get(cbz(k),'Value');
%
        freq11(k)=str2double(get(freq1(k),'String'));
        freq22(k)=str2double(get(freq1(k),'String'));
        freq33(k)=str2double(get(freq4(k),'String'));
        freq44(k)=str2double(get(freq4(k),'String'));
        
    end
    
% check that frequencies are ok
for k=1:nsta    
      if freq44(k) <= freq11(k)
         errordlg(['Frequency f4 =' num2str(freq44(k)) '  is smaller or equal than f1 =' num2str(freq11(k)) ' for station ' lab{k}  ' . Please correct it' ] ,'Error');
         return
      else
      end
end
    
% output in allstat..!!  
lab=fliplr(lab);
trlab=lab.';
labp=char(trlab);
usestn=fliplr(usestn);

if weight_flag==1 
   usens=fliplr(usens);back_od2=fliplr(back_od2);
   useew=fliplr(useew);back_od3=fliplr(back_od3);
   usez=fliplr(usez);back_od4=fliplr(back_od4);
else
   usens=fliplr(usens); 
   useew=fliplr(useew); 
   usez=fliplr(usez); 
end
freq11=fliplr(freq11);freq22=fliplr(freq22);freq33=fliplr(freq33);freq44=fliplr(freq44);
%% check if user re-enabled a component
if weight_flag==1 
  for kk=1:length(back_od4)
   if  usens(kk)==1 && back_od2(kk) ==0
       back_od2(kk)=1;
   else
   end

   if  useew(kk)==1 && back_od3(kk) ==0
       back_od3(kk)=1;
   else
   end
   
    
   if  usez(kk)==1 && back_od4(kk) ==0
       back_od4(kk)=1;
   else
   end
   
  end
else
    
end

%% update allstat
if ispc
    
  fid = fopen('.\invert\allstat.dat','w');
     for p=1:nsta
       if weight_flag==0 
        fprintf(fid,'%s %u %u %u %u %7.3f %7.3f %7.3f %7.3f\r\n', labp(p,1:end),usestn(p),usens(p),useew(p),usez(p),freq11(p),freq22(p),freq33(p),freq44(p));
       else
        fprintf(fid,'%s %u %7.3f %7.3f %7.3f %7.3f %7.3f %7.3f %7.3f\r\n', labp(p,1:end),usestn(p), back_od2(p)*usens(p), back_od3(p)*useew(p), back_od4(p)*usez(p),freq11(p),freq22(p),freq33(p),freq44(p));
       end
     end
  fclose(fid);
  
else  % Linux
    
  fid = fopen('./invert/allstat.dat','w');
     for p=1:nsta
       if weight_flag==0 
        fprintf(fid,'%s %u %u %u %u %7.3f %7.3f %7.3f %7.3f\n', labp(p,1:end),usestn(p),usens(p),useew(p),usez(p),freq11(p),freq22(p),freq33(p),freq44(p));
       else
        fprintf(fid,'%s %u %7.3f %7.3f %7.3f %7.3f %7.3f %7.3f %7.3f\n', labp(p,1:end),usestn(p), back_od2(p)*usens(p), back_od3(p)*useew(p), back_od4(p)*usez(p),freq11(p),freq22(p),freq33(p),freq44(p));
       end
     end
  fclose(fid);
end

%% Update inpinv.dat
% read first
      if ispc
          fid = fopen('.\invert\inpinv.dat','r');
      else
          fid = fopen('./invert/inpinv.dat','r');
      end
            linetmp1=fgets(fid);         %01 line
            linetmp2=fgets(fid);         %02 line
            linetmp3=fgets(fid);         %03 line
            linetmp4=fgets(fid);         %04 line
            linetmp5=fgets(fid);         %05 line
            linetmp6=fgets(fid);         %06 line
            linetmp7=fgets(fid);         %07 line
            linetmp8=fgets(fid);         %08 line
            linetmp9=fgets(fid);         %09 line
            linetmp10=fgets(fid);         %10 line
            linetmp11=fgets(fid);         %11 line
            linetmp12=fgets(fid);         %12 line
            linetmp13=fgets(fid);         %13 line
            linetmp14=fgets(fid);         %14 line
            linetmp15=fgets(fid);         %15 line
            linetmp16=fgets(fid);         %16 line
       fclose(fid);

% update
if ispc
    
      fid = fopen('.\invert\inpinv.dat','w');
           fprintf(fid,'%s',linetmp1);
           fprintf(fid,'%s',linetmp2);
           fprintf(fid,'%s',linetmp3);
           fprintf(fid,'%s',linetmp4);
           fprintf(fid,'%s',linetmp5);
           fprintf(fid,'%s',linetmp6);
           fprintf(fid,'%s',linetmp7);
           fprintf(fid,'%s',linetmp8);
           fprintf(fid,'%s',linetmp9);
           fprintf(fid,'%s',linetmp10);
           fprintf(fid,'%s',linetmp11);
           fprintf(fid,'%s',linetmp12);
           fprintf(fid,'%s',linetmp13);
           fprintf(fid,'%4.2f %4.2f %4.2f %4.2f\r\n',freq11(1),freq22(1),freq33(1),freq44(1));
           fprintf(fid,'%s',linetmp15);
           fprintf(fid,'%s',linetmp16);
       fclose(fid);
  
else
      fid = fopen('./invert/inpinv.dat','w');
           fprintf(fid,'%s',linetmp1);
           fprintf(fid,'%s',linetmp2);
           fprintf(fid,'%s',linetmp3);
           fprintf(fid,'%s',linetmp4);
           fprintf(fid,'%s',linetmp5);
           fprintf(fid,'%s',linetmp6);
           fprintf(fid,'%s',linetmp7);
           fprintf(fid,'%s',linetmp8);
           fprintf(fid,'%s',linetmp9);
           fprintf(fid,'%s',linetmp10);
           fprintf(fid,'%s',linetmp11);
           fprintf(fid,'%s',linetmp12);
           fprintf(fid,'%s',linetmp13);
           fprintf(fid,'%4.2f %4.2f %4.2f %4.2f\n',freq11(1),freq22(1),freq33(1),freq44(1));
           fprintf(fid,'%s',linetmp15);
           fprintf(fid,'%s',linetmp16);
      fclose(fid);
      
end

%% calculate  SNR now...
snr=zeros(1,nsta);
% check if we have files and compute overall SNR  
            if ispc
              for i=1:nsta
                 realdatafilename{i}=['.\' char(lab(i)) 'snr.dat'];
              end
            else
              for i=1:nsta
                 realdatafilename{i}=['./' char(lab(i)) 'snr.dat'];
              end
            end
                for i=1:nsta
                  if exist(realdatafilename{i},'file')
%                      disp(['Found ' realdatafilename{i} ])
                        % now open files and compute SNR
                        % if station is included in inversion
                        if usestn(i)==1
                            snr(i)=avesnr(realdatafilename{i},freq11(i),freq44(i));
                            disp(['Calculating SNR for station  ' char(lab(i)) ' and freq ' num2str(freq11(i)) ' - ' num2str(freq44(i))])
                            
                            disp('  ')
                        else
                            disp(['Station ' char(lab(i))   ' not included in inversion'])
                            disp('  ')
                        end
                             
                  else 
                      disp(['File ' realdatafilename{i} ' is missing. Nan will be used'])
                     % errordlg(['File ' realdatafilename{i} '  not found in isola run folder  ' pwd ' . Run S/N spectral analysis tool for this station' ] ,'File Error');   
                      % make SNR null ...???
                      snr(i)=NaN;
                  end
                end
            
disp(['Mean SNR over all stations ' num2str(nanmean(snr))])

if ~isnan(nanmean(snr))
   assignin('base','snrvalue',nanmean(snr) );
else
    
end


%% exit
 delete(fh)

end  % end of update function

%%  Utility functions for MYGUI


end