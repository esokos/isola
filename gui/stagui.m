function varargout = stagui(varargin) %(handles)

%handles.passed_figure=varargin{:}
% main=handles.passed_figure;
% mainHandles=guidata(main);

% Initialization tasks
% first read allstat.dat
% 27/08/13 Update inpinv with 1st station freq band

disp('This is stagui.m. 27/08/2013.')
  
if ispc   
   h=dir('.\invert\allstat.dat');
else
   h=dir('./invert/allstat.dat');
end

  if isempty(h); 
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
            
%    if(od2(i)~=0)  % change due to allstat with weights
%        od2value=1;
%    else
%        od2value=0;
%    end
   % check box for NS use
   cbns(i) = uicontrol(fh,'Style','checkbox',...  
                'String','Use NS',...
                'Value',od2(i),'Position',[220 (i+1)*30 80 20],'Userdata',od2(i));            
            
%    if(od3(i)~=0) 
%        od3value=1;
%    else
%        od3value=0;
%    end
   % check box for EW use
   cbew(i) = uicontrol(fh,'Style','checkbox',...  
                'String','Use EW',...
                'Value',od3(i),'Position',[320 (i+1)*30 80 20],'Userdata',od3(i));               
            
%    if(od4(i)~=0) 
%        od4value=1;
%    else
%        od4value=0;
%    end
   % check box for Z use
   cbz(i) = uicontrol(fh,'Style','checkbox',...  
                'String','Use Z',...
                'Value',od4(i),'Position',[420 (i+1)*30 80 20],'Userdata',od4(i));            
  if nargin==0
    
   % frequency 1
   freq1(i) = uicontrol(fh,'Style','edit',...
                'String','',...
                'Position',[520 (i+1)*30 80 20],'String',num2str(of1(i)));
            
   % frequency 2
   freq2(i) = uicontrol(fh,'Style','edit',...
                'String','',...
                'Position',[620 (i+1)*30 80 20],'String',num2str(of2(i)));          

   % frequency 3
   freq3(i) = uicontrol(fh,'Style','edit',...
                'String','',...
                'Position',[720 (i+1)*30 80 20],'String',num2str(of3(i)));      

   % frequency 4
   freq4(i) = uicontrol(fh,'Style','edit',...
                'String','',...
                'Position',[820 (i+1)*30 80 20],'String',num2str(of4(i)));          
  
  elseif nargin==4
      
      of1=ones(nsta,1)*varargin{1};of2=ones(nsta,1)*varargin{2};of3=ones(nsta,1)*varargin{3};of4=ones(nsta,1)*varargin{4};
      
   % frequency 1
   freq1(i) = uicontrol(fh,'Style','text',...
                'String','',...
                'Position',[520 (i+1)*30 80 20],'String',num2str(of1(i)));
            
   % frequency 2
   freq2(i) = uicontrol(fh,'Style','text',...
                'String','',...
                'Position',[620 (i+1)*30 80 20],'String',num2str(of2(i)));          

   % frequency 3
   freq3(i) = uicontrol(fh,'Style','text',...
                'String','',...
                'Position',[720 (i+1)*30 80 20],'String',num2str(of3(i)));      

   % frequency 4
   freq4(i) = uicontrol(fh,'Style','text',...
                'String','',...
                'Position',[820 (i+1)*30 80 20],'String',num2str(of4(i)));  
    
  end    
    
end

% Add labels
   l1 = uicontrol(fh,'Style','text',...
                'String','Stations','FontWeight','Bold',...
                'Position',[30 (nsta+2)*30 80 20]);

   l2 = uicontrol(fh,'Style','text',...
                'String','Components','FontWeight','Bold',...
                'Position',[320 (nsta+2)*30 80 20]);
%
   l3 = uicontrol(fh,'Style','text',...
                'String','f1','FontWeight','Bold',...
                'Position',[520 (nsta+2)*30 80 20]);
   l4 = uicontrol(fh,'Style','text',...
                'String','f2','FontWeight','Bold',...
                'Position',[620 (nsta+2)*30 80 20]);
   l5 = uicontrol(fh,'Style','text',...
                'String','f3','FontWeight','Bold',...
                'Position',[720 (nsta+2)*30 80 20]);
   l6 = uicontrol(fh,'Style','text',...
                'String','f4','FontWeight','Bold',...
                'Position',[820 (nsta+2)*30 80 20]);
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
for i=1:nsta

    set(freq1(i),'BackgroundColor',[ 1 1 1])
    set(freq2(i),'BackgroundColor',[ 1 1 1])
    set(freq3(i),'BackgroundColor',[ 1 1 1])
    set(freq4(i),'BackgroundColor',[ 1 1 1])
    
end



% Wait until something is pressed
uiwait(gcf)

%  Initialization tasks

%%  Callbacks for MYGUI
function cancel(hObject,eventdata)
        delete(fh)
end
%%
% Update !!!
function update(hObject,eventdata)

% get names etc ??
    for k=1:nsta
        lab{k}=get(sth(k),'String');
        usestn(k)=get(cbsta(k),'Value');
%
        usens(k)=get(cbns(k),'Value');
%         nsweight(k)=get(cbns(k),'Userdata');
%         
%         if(usens(k)==0)
%             nsweight(k)=0;
%         end
        
        useew(k)=get(cbew(k),'Value');
%         ewweight(k)=get(cbew(k),'Userdata');
%         
%         if(useew(k)==0)
%             ewweight(k)=0;
%         end
        
        usez(k)=get(cbz(k),'Value');
%         zweight(k)=get(cbz(k),'Userdata');
%         
%         if(usez(k)==0)
%             zweight(k)=0;
%         end

        %
        freq11(k)=str2double(get(freq1(k),'String'));
        freq22(k)=str2double(get(freq2(k),'String'));
        freq33(k)=str2double(get(freq3(k),'String'));
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
usens=fliplr(usens);
useew=fliplr(useew);
usez=fliplr(usez);
% nsweight=fliplr(nsweight);
% ewweight=fliplr(ewweight);
% zweight=fliplr(zweight);
freq11=fliplr(freq11);
freq22=fliplr(freq22);
freq33=fliplr(freq33);
freq44=fliplr(freq44);

% uodate allstat
if ispc
  fid = fopen('.\invert\allstat.dat','w');
     for p=1:nsta
       fprintf(fid,'%s %u %u %u %u %7.3f %7.3f %7.3f %7.3f\r\n', labp(p,1:end),usestn(p),usens(p),useew(p),usez(p),freq11(p),freq22(p),freq33(p),freq44(p));
   
  %   fprintf(fid,'%s %u %6.2f %6.2f %6.2f %5.2f %5.2f %5.2f %5.2f\r\n', labp(p,1:end),usestn(p),nsweight(p),ewweight(p),zweight(p),freq11(p),freq22(p),freq33(p),freq44(p));
   
     end
  fclose(fid);
else
  fid = fopen('./invert/allstat.dat','w');
     for p=1:nsta
       fprintf(fid,'%s %u %u %u %u %7.3f %7.3f %7.3f %7.3f\n', labp(p,1:end),usestn(p),usens(p),useew(p),usez(p),freq11(p),freq22(p),freq33(p),freq44(p));
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
           fprintf(fid,'%s',linetmp1)
           fprintf(fid,'%s',linetmp2)
           fprintf(fid,'%s',linetmp3)
           fprintf(fid,'%s',linetmp4)
           fprintf(fid,'%s',linetmp5)
           fprintf(fid,'%s',linetmp6)
           fprintf(fid,'%s',linetmp7)
           fprintf(fid,'%s',linetmp8)
           fprintf(fid,'%s',linetmp9)
           fprintf(fid,'%s',linetmp10)
           fprintf(fid,'%s',linetmp11)
           fprintf(fid,'%s',linetmp12)
           fprintf(fid,'%s',linetmp13)
           fprintf(fid,'%4.2f %4.2f %4.2f %4.2f\r\n',freq11(1),freq22(1),freq33(1),freq44(1));
           fprintf(fid,'%s',linetmp15)
           fprintf(fid,'%s',linetmp16)
       fclose(fid);
  
else
      fid = fopen('./invert/inpinv.dat','w');
           fprintf(fid,'%s',linetmp1)
           fprintf(fid,'%s',linetmp2)
           fprintf(fid,'%s',linetmp3)
           fprintf(fid,'%s',linetmp4)
           fprintf(fid,'%s',linetmp5)
           fprintf(fid,'%s',linetmp6)
           fprintf(fid,'%s',linetmp7)
           fprintf(fid,'%s',linetmp8)
           fprintf(fid,'%s',linetmp9)
           fprintf(fid,'%s',linetmp10)
           fprintf(fid,'%s',linetmp11)
           fprintf(fid,'%s',linetmp12)
           fprintf(fid,'%s',linetmp13)
           fprintf(fid,'%4.2f %4.2f %4.2f %4.2f\n',freq11(1),freq22(1),freq33(1),freq44(1));
           fprintf(fid,'%s',linetmp15)
           fprintf(fid,'%s',linetmp16)
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

if nanmean(snr)~=NaN
   assignin('base','snrvalue',nanmean(snr) );
else
    
end


%% exit
 delete(fh)

end  % end of update function

%%  Utility functions for MYGUI


end