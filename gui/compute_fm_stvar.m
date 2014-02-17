function [fmvar_mean,fmvar_std,STVAR]=compute_fm_stvar(cor)
%% it will calculate tsvar index based on threshold and corr.dat
% it will work for 1 subevent only

%eventidnew=handles.eventidnew;

% first check if we have corr01.dat
if ispc
 h=dir('.\invert\corr01.dat');
else
 h=dir('./invert/corr01.dat');
end
if isempty(h); 
         errordlg('corr01.dat file doesn''t exist in invert folder. Run Inversion. ','File Error');
     return
else
    disp('Corr01.dat found. Code will work for 1 subevent based on corr01.dat')
end

% check if we have inv2.dat
if ispc
 h=dir('.\invert\inv2.dat');
else
 h=dir('./invert/inv2.dat');
end
%%%%%%%%%%%%%%%%%%%%%%  check length of inv2.dat
if isempty(h); 
    errordlg('inv2.dat file doesn''t exist. Run Inversion. ','File Error');
    cd ..
  return    
else
    if ispc
       fid = fopen('.\invert\inv2.dat','r');
    else
       fid = fopen('./invert/inv2.dat','r');
    end
    tline = fgetl(fid);
      if length(tline) > 125
          disp('New inv2.dat')
          inv2age='new';
          fclose(fid);
%          fid = fopen('.\invert\inv2.dat','r');
         if ispc
          [srcpos2,srctime2,mo,str1,dip1,rake1,str2,dip2,rake2,aziP,plungeP,aziT,plungeT,aziB,plungeB,dc,varred] = textread('.\invert\inv2.dat','%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f',1);
         else
          [srcpos2,srctime2,mo,str1,dip1,rake1,str2,dip2,rake2,aziP,plungeP,aziT,plungeT,aziB,plungeB,dc,varred] = textread('./invert/inv2.dat','%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f',1);
         end
%          fclose(fid);
      else
          disp('Old inv2.dat')
          inv2age='old';
          fclose(fid);
%          fid = fopen('.\invert\inv2.dat','r');
         if ispc
          [srcpos2,srctime2,mo,str1,dip1,rake1,str2,dip2,rake2,aziP,plungeP,aziT,plungeT,dc,varred] = textread('.\invert\inv2.dat','%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f',1);
         else
          [srcpos2,srctime2,mo,str1,dip1,rake1,str2,dip2,rake2,aziP,plungeP,aziT,plungeT,dc,varred] = textread('./invert/inv2.dat','%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f',1);
         end
%          fclose(fid);
      end
end      
%% look for inpinv.dat to get limits of plot
% check if we have inpinv.dat
if ispc
 h=dir('.\invert\inpinv.dat');
else
 h=dir('./invert/inpinv.dat');   
end
%%%%%%%%%%%%%%%%%%%%%%  check length of inv2.dat
if isempty(h); 
    errordlg('inpinv.dat file doesn''t exist. Run Inversion. ','File Error');
    cd ..
  return    
else
    if ispc
     [~,tstep,nsources,tshifts,~,~,~] = readinpinv('.\invert\inpinv.dat');
    else
     [~,tstep,nsources,tshifts,~,~,~] = readinpinv('./invert/inpinv.dat');
    end
end

% xaxis will be
%iseqm=round((tshifts(3)-tshifts(1))/tshifts(2))

tint=tshifts(2)*tstep;

xaxisl=(tshifts(1)*tstep)+tint;
xaxisr=tshifts(3)*tstep;

%% find how many sources we have and distance

h=dir('tsources.isl');

if isempty(h); 
    errordlg('tsources.isl file doesn''t exist. Run Source create. ','File Error');
  return    
else
    fid = fopen('tsources.isl','r');
    tsource=fscanf(fid,'%s',1);
    
     if strcmp(tsource,'line')
        disp('Inversion was done for a line of sources.')
        nsources=fscanf(fid,'%i',1);
        distep=fscanf(fid,'%f',1);
        sdepth=fscanf(fid,'%f',1);
        invtype=fscanf(fid,'%c');
          
        conplane=2;   % Line
        % dummy sdepth
        sdepth=-333;
        
     elseif strcmp(tsource,'depth')
        disp('Inversion was done for a line of sources under epicenter.')
        nsources=fscanf(fid,'%i',1);
        distep=fscanf(fid,'%f',1);
        sdepth=fscanf(fid,'%f',1);
        invtype=fscanf(fid,'%c');
        
        conplane=0;   %%%depth
    
     elseif strcmp(tsource,'plane')
        disp('Inversion was done for a plane of sources.')
        nsources=fscanf(fid,'%i',1);
%         distep=fscanf(fid,'%f',1);
           noSourcesstrike=fscanf(fid,'%i',1);
           strikestep=fscanf(fid,'%f',1);
           noSourcesdip=fscanf(fid,'%i',1);
           dipstep=fscanf(fid,'%f',1);
%           nsources=noSourcesstrike*noSourcesdip;
          
           invtype='   Multiple Source line or plane ';%(Trial Sources on a plane or line)';
           conplane=1;
           
 %          set(handles.udistdep,'Enable','Off') %   disp('Distance corel plot is not available for plane source model. Source number will be used.')
           % dummy sdepth
           sdepth=-333;
           distep=-333;
           
     elseif strcmp(tsource,'point')
       disp('Inversion was done for one source.')
       nsources=fscanf(fid,'%i',1);
       distep=fscanf(fid,'%f',1);
       sdepth=fscanf(fid,'%f',1);
       invtype=fscanf(fid,'%c');
        
     end
     
          fclose(fid);
          
end

%% this is our reference solution
strref=str1;
dipref=dip1;
rakeref=rake1;

disp(['Reference solution is ' num2str(strref) ' ' num2str(dipref) ' ' num2str(rakeref) ])
    
% get correlation level
% cor=str2num(get(handles.tsvarcor,'String'));

% pwd

% call function
cd invert

    [srcpos2C,srctimeC,allsrcpos,allsrctime,allvariance,strC,dipC,rakeC,maxvar]=preparecor4kagan('corr01.dat',cor,strref,dipref,rakeref);


% call fortran code
   [status, result] = system('corr_kag');

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   FMVAR part 
if status ==0 
    pause(2)
    % read the output    
    kag=load('kagselect.dat');
     
    fmvar_mean=mean(kag);
    fmvar_std = std(kag);
    fmvar_median=median(kag);
    
    FMVAR=fix(fmvar_std);

disp(' ')    
disp(['FMVAR = '     num2str(round(fmvar_mean)) ' +- ' num2str(round(fmvar_std))]);
disp(' ')    
    
else
    disp('Error....')
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   STVAR part 
% compute stvar as a ratio between number of points above threshold and
% total number of grid points

STVAR=comp_stvar(nsources,tshifts,srcpos2C,srctimeC);
disp(' ')   
disp(['STVAR = '     num2str(STVAR,'%2.2f')]);
disp(' ')    
     
cd ..
