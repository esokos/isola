function varargout = staguienv(varargin) %(handles)
% New statgui for envelope inversion..!!
% May 2017

disp('This is staguienv.m. 09/05/2017.')
  
if ispc   
   h=dir('.\env_amp_inv\allstat.dat');
else
   h=dir('./env_amp_inv/allstat.dat');
end

  if isempty(h); 
         errordlg('allstat.dat file doesn''t exist in env_amp_inv folder.','File Error');
     return
  else
      % try to guess allstat version 
      if ispc
        fid=fopen('.\env_amp_inv\allstat.dat');
      else
        fid=fopen('./env_amp_inv/allstat.dat');
      end
      
      if ispc
        [stanames,od1,od2,od3,od4,of1,of2,of3,of4] = textread('.\env_amp_inv\allstat.dat','%s %f %f %f %f %f %f %f %f',-1);
      else
        [stanames,od1,od2,od3,od4,of1,of2,of3,of4] = textread('./env_amp_inv/allstat.dat','%s %f %f %f %f %f %f %f %f',-1);
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
   % check box for NS use
   cbns(i) = uicontrol(fh,'Style','checkbox',...  
                'String','Use NS',...
                'Value',od2(i),'Position',[220 (i+1)*30 80 20],'Userdata',od2(i));            
   % check box for EW use
   cbew(i) = uicontrol(fh,'Style','checkbox',...  
                'String','Use EW',...
                'Value',od3(i),'Position',[320 (i+1)*30 80 20],'Userdata',od3(i));               
   % check box for Z use
   cbz(i) = uicontrol(fh,'Style','checkbox',...  
                'String','Use Z',...
                'Value',od4(i),'Position',[420 (i+1)*30 80 20],'Userdata',od4(i));            
  if nargin==0
    
   % frequency 1
   freq1(i) = uicontrol(fh,'Style','edit',...
                'String','',...
                'Position',[520 (i+1)*30 80 20],'String',num2str(of1(i)));
   % frequency 4
   freq4(i) = uicontrol(fh,'Style','edit',...
                'String','',...
                'Position',[620 (i+1)*30 80 20],'String',num2str(of4(i)));          
  
  elseif nargin==4
      
      of1=ones(nsta,1)*varargin{1};of2=ones(nsta,1)*varargin{2};of3=ones(nsta,1)*varargin{3};of4=ones(nsta,1)*varargin{4};
      
   % frequency 1
   freq1(i) = uicontrol(fh,'Style','text',...
                'String','',...
                'Position',[520 (i+1)*30 80 20],'String',num2str(of1(i)));
            
   % frequency 4
   freq4(i) = uicontrol(fh,'Style','text',...
                'String','',...
                'Position',[620 (i+1)*30 80 20],'String',num2str(of4(i)));  
    
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

for i=1:nsta

    set(freq1(i),'BackgroundColor',[ 1 1 1])
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
usens=fliplr(usens);
useew=fliplr(useew);
usez=fliplr(usez);
freq11=fliplr(freq11);
freq22=fliplr(freq22);
freq33=fliplr(freq33);
freq44=fliplr(freq44);

% update allstat
if ispc
  fid = fopen('.\env_amp_inv\allstat.dat','w');
     for p=1:nsta
       fprintf(fid,'%s %u %u %u %u %7.3f %7.3f %7.3f %7.3f\r\n', labp(p,1:end),usestn(p),usens(p),useew(p),usez(p),freq11(p),freq22(p),freq33(p),freq44(p));
     end
  fclose(fid);
else
  fid = fopen('./env_amp_inv/allstat.dat','w');
     for p=1:nsta
       fprintf(fid,'%s %u %u %u %u %7.3f %7.3f %7.3f %7.3f\n', labp(p,1:end),usestn(p),usens(p),useew(p),usez(p),freq11(p),freq22(p),freq33(p),freq44(p));
     end
  fclose(fid);
end

%% exit
 delete(fh)

end  % end of update function

%%  Utility functions for MYGUI


end