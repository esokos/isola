function result = makegmtscript4synobsplot 

disp('This is makegmtscript4synobsplot 09/05/2011')

%% read ISOLA defaults
[gmt_ver,psview,npts] = readisolacfg;

%%
cd invert

%read data from handles
handles1=guidata(gcbo);
nostations=handles1.nostations;
realdatafilename=handles1.realdatafilename;
syntdatafilename=handles1.syntdatafilename;
station=handles1.station;
%useornot=handles1.useornot;
variance_reduction=handles1.variance_reduction;
ftime=handles1.ftime;
totime=handles1.totime;
eventid=handles1.eventid;
maxmindataindex=handles1.maxmindataindex;
compuse=handles1.compuse;
invband=handles1.invband;

%% Compute a few things
%newid  = regexprep(regexprep(eventid, ':', '_'),'  ','_');
 

%% Open batch file
 fid = fopen('plobs_syn.bat','w');
         fprintf(fid,'%s\r\n','REM this is a GMT batch file for plotting OBS vs SYN data');
         fprintf(fid,'%s  %s\r\n','REM ', eventid);
         fprintf(fid,'%s \r\n','  ');
         fprintf(fid,'%s\r\n','del .gmt* ');
        
         if gmt_ver==4
             fprintf(fid,'%s\r\n','gmtset ANNOT_FONT_SIZE_PRIMARY 8 ANNOT_FONT_SIZE_SECONDARY 8  HEADER_FONT_SIZE 8 LABEL_FONT_SIZE 8  '); %%% D_FORMAT %%4.1e
         else
             fprintf(fid,'%s\r\n','gmtset FONT_ANNOT_PRIMARY 8 FONT_ANNOT_SECONDARY 8  FONT_TITLE 8 FONT_LABEL 8  '); %%% D_FORMAT %%4.1e
         end
         fprintf(fid,'%s %s\r\n','set psfile= ', [eventid '_wave.ps']);
         
         fprintf(fid,'%s %s\r\n','set obspen= ', ' -Wthicker ');
         fprintf(fid,'%s %s\r\n','set synpen= ',' -Wthick,red ');
         fprintf(fid,'%s %s\r\n','set obsgpen= ', ' -Wthicker,gray ');
         
         fprintf(fid,'%s \r\n','  ');
         
%% loop over stations
 for i=1:nostations-1
     
      
       if i==1            %% first line 
           
           if compuse(1,i)==1 
           fprintf(fid,'%s \r\n',['gawk "{print $1,$2}" ' realdatafilename{i} ' | psxy  -R' num2str(ftime) '/' num2str(totime) '/' num2str(maxmindataindex(1,2,i)) '/' num2str(maxmindataindex(1,1,i)) '  -JX5c/1.c -K %obspen% -P -B100/' num2str((abs(maxmindataindex(1,2,i))+maxmindataindex(1,1,i))/3) '::wesn -V -Y26c > %psfile% ']);
           fprintf(fid,'%s \r\n',['gawk "{print $1,$2}" ' syntdatafilename{i} ' | psxy  -R  -J   -K -O %synpen%  >> %psfile% ']);
           else
           fprintf(fid,'%s \r\n',['gawk "{print $1,$2}" ' realdatafilename{i} ' | psxy  -R' num2str(ftime) '/' num2str(totime) '/' num2str(maxmindataindex(1,2,i)) '/' num2str(maxmindataindex(1,1,i)) '  -JX5c/1.c -K %obsgpen% -P -B100/' num2str((abs(maxmindataindex(1,2,i))+maxmindataindex(1,1,i))/3) '::wesn -V -Y26c > %psfile% ']);
           fprintf(fid,'%s \r\n',['gawk "{print $1,$2}" ' syntdatafilename{i} ' | psxy  -R  -J   -K -O %synpen%  >> %psfile% ']);
           end    
           if gmt_ver==4
           fprintf(fid,'%s \r\n',['echo ' num2str(totime/2) ' ' num2str(maxmindataindex(1,1,i)+(abs(maxmindataindex(1,2,i))+maxmindataindex(1,1,i))/4)  ' 12 0 21 LB NS      | pstext -R -J -K -O  -N  >> %psfile% ']);
           fprintf(fid,'%s \r\n',['echo ' num2str(totime-50) ' ' num2str(maxmindataindex(1,1,i)-(abs(maxmindataindex(1,2,i))+maxmindataindex(1,1,i))/4)  ' 9 0 21 LB ' num2str(variance_reduction(i,1),2)  '    | pstext -R -J -K -O  -N -Gblue  >> %psfile% ']);
           % event id
           fprintf(fid,'%s \r\n',['echo ' num2str(totime/2) ' ' num2str(maxmindataindex(1,1,i)+(abs(maxmindataindex(1,2,i))+maxmindataindex(1,1,i))*2)  ' 16 0 21 LB ' ['Event Date-Time: ' [eventid(1:2) '/' eventid(3:4) '/' eventid(5:6) '-' eventid(8:9) ':' eventid(11:12) ':' eventid(14:end)] ]  '    | pstext -R -J -K -O  -N   >> %psfile% ']);
           fprintf(fid,'%s \r\n',['echo ' num2str(totime/2) ' ' num2str(maxmindataindex(1,1,i)+(abs(maxmindataindex(1,2,i))+maxmindataindex(1,1,i))*1.5)  ' 16 0 21 LB ' 'Inversion Band (Hz): ' invband '    | pstext -R -J -K -O  -N   >> %psfile% ']);
           else
           fprintf(fid,'%s \r\n',['echo ' num2str(totime/2) ' ' num2str(maxmindataindex(1,1,i)+(abs(maxmindataindex(1,2,i))+maxmindataindex(1,1,i))/4)  '   NS      | pstext -R -J -K -O  -N -F+f12 >> %psfile% ']);
           fprintf(fid,'%s \r\n',['echo ' num2str(totime-50) ' ' num2str(maxmindataindex(1,1,i)-(abs(maxmindataindex(1,2,i))+maxmindataindex(1,1,i))/4)  '   ' num2str(variance_reduction(i,1),2)  '    | pstext -R -J -K -O  -N  -F+f12 >> %psfile% ']);
           % event id
           fprintf(fid,'%s \r\n',['echo ' num2str(totime/2) ' ' num2str(maxmindataindex(1,1,i)+(abs(maxmindataindex(1,2,i))+maxmindataindex(1,1,i))*2)  ' 16 0 21 LB ' ['Event Date-Time: ' [eventid(1:2) '/' eventid(3:4) '/' eventid(5:6) '-' eventid(8:9) ':' eventid(11:12) ':' eventid(14:end)] ]  '    | pstext -R -J -K -O  -N   >> %psfile% ']);
           fprintf(fid,'%s \r\n',['echo ' num2str(totime/2) ' ' num2str(maxmindataindex(1,1,i)+(abs(maxmindataindex(1,2,i))+maxmindataindex(1,1,i))*1.5)  ' 16 0 21 LB ' 'Inversion Band (Hz): ' invband '    | pstext -R -J -K -O  -N   >> %psfile% ']);
           end
           %%%%%%%          problem with exponential Y axis 
           fprintf(fid,'%s\r\n','gmtset D_FORMAT %%4.1e ');  
           fprintf(fid,'%s \r\n',['psbasemap  -R' num2str(ftime) '/' num2str(totime) '/' num2str(maxmindataindex(1,2,i)) '/' num2str(maxmindataindex(1,1,i))  ' -JX5c/1.c -K -O   -P -B100/' num2str((abs(maxmindataindex(1,2,i))+maxmindataindex(1,1,i))/3) '::Wen -V    >> %psfile% ']);
           fprintf(fid,'%s\r\n','gmtset D_FORMAT %%lg  ');  
           fprintf(fid,'%s \r\n','  ');
           
           % EW
           if compuse(2,i)==1 
           fprintf(fid,'%s \r\n',['gawk "{print $1,$3}" ' realdatafilename{i} ' | psxy  -R  -JX5c/1.c -K -O %obspen% -P -B100/.5::wesn -V -X6  >> %psfile% ']);
           fprintf(fid,'%s \r\n',['gawk "{print $1,$3}" ' syntdatafilename{i} ' | psxy  -R  -J   -K -O %synpen%  >> %psfile% ']);
           else
           fprintf(fid,'%s \r\n',['gawk "{print $1,$3}" ' realdatafilename{i} ' | psxy  -R  -JX5c/1.c -K -O %obsgpen% -P -B100/.5::wesn -V -X6  >> %psfile% ']);
           fprintf(fid,'%s \r\n',['gawk "{print $1,$3}" ' syntdatafilename{i} ' | psxy  -R  -J   -K -O %synpen%  >> %psfile% ']);
           end    
           %fprintf(fid,'%s \r\n',['echo -100 -0.65 10 90 21 0 ' station{i}  '  | pstext -R -J -K -O  -N  >> %psfile% ']);
           fprintf(fid,'%s \r\n',['echo ' num2str(totime/2) ' ' num2str(maxmindataindex(1,1,i)+(abs(maxmindataindex(1,2,i))+maxmindataindex(1,1,i))/4)  ' 12 0 21 LB EW      | pstext -R -J -K -O  -N  >> %psfile% ']);
           fprintf(fid,'%s \r\n',['echo ' num2str(totime-50) ' ' num2str(maxmindataindex(1,1,i)-(abs(maxmindataindex(1,2,i))+maxmindataindex(1,1,i))/4)  ' 9 0 21 LB ' num2str(variance_reduction(i,2),2)  '    | pstext -R -J -K -O  -N -Gblue  >> %psfile% ']);
           fprintf(fid,'%s \r\n','  ');
           
           % Z
           if compuse(3,i)==1 
           fprintf(fid,'%s \r\n',['gawk "{print $1,$4}" ' realdatafilename{i} ' | psxy  -R   -JX5c/1.c -K -O %obspen% -P -B100/.5::wesn -V -X6  >> %psfile% ']);
           fprintf(fid,'%s \r\n',['gawk "{print $1,$4}" ' syntdatafilename{i} ' | psxy  -R  -J   -K -O %synpen%  >> %psfile% ']);
           else
           fprintf(fid,'%s \r\n',['gawk "{print $1,$4}" ' realdatafilename{i} ' | psxy  -R   -JX5c/1.c -K -O %obsgpen% -P -B100/.5::wesn -V -X6  >> %psfile% ']);
           fprintf(fid,'%s \r\n',['gawk "{print $1,$4}" ' syntdatafilename{i} ' | psxy  -R  -J   -K -O %synpen%  >> %psfile% ']);
           end
           fprintf(fid,'%s \r\n',['echo ' num2str(totime+20) ' 0 10 90 15 CT ' station{i}  '  | pstext -R -J -K -O  -N  >> %psfile% ']);
           fprintf(fid,'%s \r\n',['echo ' num2str(totime/2) ' ' num2str(maxmindataindex(1,1,i)+(abs(maxmindataindex(1,2,i))+maxmindataindex(1,1,i))/4)  ' 12 0 21 LB Z      | pstext -R -J -K -O  -N  >> %psfile% ']);
           fprintf(fid,'%s \r\n',['echo ' num2str(totime-50) ' ' num2str(maxmindataindex(1,1,i)-(abs(maxmindataindex(1,2,i))+maxmindataindex(1,1,i))/4)  ' 9 0 21 LB ' num2str(variance_reduction(i,3),2)  '    | pstext -R -J -K -O  -N -Gblue  >> %psfile% ']);
           fprintf(fid,'%s \r\n','  ');
          
       else
           if compuse(1,i)==1 
           fprintf(fid,'%s \r\n',['gawk "{print $1,$2}" ' realdatafilename{i} ' | psxy  -R' num2str(ftime) '/' num2str(totime) '/' num2str(maxmindataindex(1,2,i)) '/' num2str(maxmindataindex(1,1,i))  ' -JX5c/1.c -K -O %obspen% -P -B100::/.2::wesn -V  -Y-1.6c -X-12 >> %psfile% ']);
           fprintf(fid,'%s \r\n',['gawk "{print $1,$2}" ' syntdatafilename{i} ' | psxy  -R  -J   -K -O %synpen%  >> %psfile% ']);
           else
           fprintf(fid,'%s \r\n',['gawk "{print $1,$2}" ' realdatafilename{i} ' | psxy  -R' num2str(ftime) '/' num2str(totime) '/' num2str(maxmindataindex(1,2,i)) '/' num2str(maxmindataindex(1,1,i))  ' -JX5c/1.c -K -O %obsgpen% -P -B100::/.2::wesn -V  -Y-1.6c -X-12 >> %psfile% ']);
           fprintf(fid,'%s \r\n',['gawk "{print $1,$2}" ' syntdatafilename{i} ' | psxy  -R  -J   -K -O %synpen%  >> %psfile% ']);
           end
%           fprintf(fid,'%s \r\n',['echo -60 0 10 90 21 CT ' station{i}  '  | pstext -R -J -K -O  -N  >> %psfile% ']);
           fprintf(fid,'%s \r\n',['echo ' num2str(totime-50) ' ' num2str(maxmindataindex(1,1,i)-(abs(maxmindataindex(1,2,i))+maxmindataindex(1,1,i))/4)  ' 9 0 21 LB ' num2str(variance_reduction(i,1),2)  '    | pstext -R -J -K -O  -N -Gblue  >> %psfile% ']);
           fprintf(fid,'%s \r\n','  ');
           %%%%%%%          problem with exponential Y axis 
           fprintf(fid,'%s\r\n','gmtset D_FORMAT %%4.1e ');  
           fprintf(fid,'%s \r\n',['psbasemap  -R' num2str(ftime) '/' num2str(totime) '/' num2str(maxmindataindex(1,2,i)) '/' num2str(maxmindataindex(1,1,i))  ' -JX5c/1.c -K -O   -P -B100/' num2str((abs(maxmindataindex(1,2,i))+maxmindataindex(1,1,i))/3) '::Wen -V    >> %psfile% ']);
           fprintf(fid,'%s\r\n','gmtset D_FORMAT %%lg  ');  
           fprintf(fid,'%s \r\n','  ');
  
           %
           if compuse(2,i)==1 
           fprintf(fid,'%s \r\n',['gawk "{print $1,$3}" ' realdatafilename{i} ' | psxy  -R  -JX5c/1.c -K -O %obspen% -P -B100::/.2::wesn -V -X6  >> %psfile% ']);
           fprintf(fid,'%s \r\n',['gawk "{print $1,$3}" ' syntdatafilename{i} ' | psxy  -R  -J   -K -O %synpen%  >> %psfile% ']);
           else
           fprintf(fid,'%s \r\n',['gawk "{print $1,$3}" ' realdatafilename{i} ' | psxy  -R  -JX5c/1.c -K -O %obsgpen% -P -B100::/.2::wesn -V -X6  >> %psfile% ']);
           fprintf(fid,'%s \r\n',['gawk "{print $1,$3}" ' syntdatafilename{i} ' | psxy  -R  -J   -K -O %synpen%  >> %psfile% ']);
           end
           %fprintf(fid,'%s \r\n',['echo -100 -0.65 10 90 21 0 ' station{i}  '  | pstext -R -J -K -O  -N  >> %psfile% ']);
           fprintf(fid,'%s \r\n',['echo ' num2str(totime-50) ' ' num2str(maxmindataindex(1,1,i)-(abs(maxmindataindex(1,2,i))+maxmindataindex(1,1,i))/4)  ' 9 0 21 LB ' num2str(variance_reduction(i,2),2)  '    | pstext -R -J -K -O  -N -Gblue  >> %psfile% ']);
           fprintf(fid,'%s \r\n','  ');
           %
           if compuse(3,i)==1 
           fprintf(fid,'%s \r\n',['gawk "{print $1,$4}" ' realdatafilename{i} ' | psxy  -R  -JX5c/1.c -K -O %obspen% -P -B100::/.2::wesn -V -X6  >> %psfile% ']);
           fprintf(fid,'%s \r\n',['gawk "{print $1,$4}" ' syntdatafilename{i} ' | psxy  -R  -J   -K -O %synpen%  >> %psfile% ']);
           else
           fprintf(fid,'%s \r\n',['gawk "{print $1,$4}" ' realdatafilename{i} ' | psxy  -R  -JX5c/1.c -K -O %obsgpen% -P -B100::/.2::wesn -V -X6  >> %psfile% ']);
           fprintf(fid,'%s \r\n',['gawk "{print $1,$4}" ' syntdatafilename{i} ' | psxy  -R  -J   -K -O %synpen%  >> %psfile% ']);
           end
           fprintf(fid,'%s \r\n',['echo ' num2str(totime+20) ' 0 10 90 15 CT ' station{i}  '  | pstext -R -J -K -O  -N  >> %psfile% ']);
           fprintf(fid,'%s \r\n',['echo ' num2str(totime-50) ' ' num2str(maxmindataindex(1,1,i)-(abs(maxmindataindex(1,2,i))+maxmindataindex(1,1,i))/4)  ' 9 0 21 LB ' num2str(variance_reduction(i,3),2)  '    | pstext -R -J -K -O  -N -Gblue  >> %psfile% ']);
           fprintf(fid,'%s \r\n','  ');
          
       end
           
 end
 
 %%% last station        
         for i=nostations
             %
           if compuse(1,i)==1 
           fprintf(fid,'%s \r\n',['gawk "{print $1,$2}" ' realdatafilename{i} ' | psxy  -R' num2str(ftime) '/' num2str(totime) '/' num2str(maxmindataindex(1,2,i)) '/' num2str(maxmindataindex(1,1,i))  ' -JX5c/1.c -K -O %obspen% -P -B100:"Time (sec)":/.2::weSn -V  -Y-1.6c -X-12 >> %psfile% ']);
           fprintf(fid,'%s \r\n',['gawk "{print $1,$2}" ' syntdatafilename{i} ' | psxy  -R  -J   -K -O %synpen%  >> %psfile% ']);
           else
           fprintf(fid,'%s \r\n',['gawk "{print $1,$2}" ' realdatafilename{i} ' | psxy  -R' num2str(ftime) '/' num2str(totime) '/' num2str(maxmindataindex(1,2,i)) '/' num2str(maxmindataindex(1,1,i))  ' -JX5c/1.c -K -O %obsgpen% -P -B100:"Time (sec)":/.2::weSn -V  -Y-1.6c -X-12 >> %psfile% ']);
           fprintf(fid,'%s \r\n',['gawk "{print $1,$2}" ' syntdatafilename{i} ' | psxy  -R  -J   -K -O %synpen%  >> %psfile% ']);
           end
 %          fprintf(fid,'%s \r\n',['echo -60 0 10 90 21 CT ' station{i}  '  | pstext -R -J -K -O  -N  >> %psfile% ']);
           fprintf(fid,'%s \r\n',['echo ' num2str(totime-50) ' ' num2str(maxmindataindex(1,1,i)-(abs(maxmindataindex(1,2,i))+maxmindataindex(1,1,i))/4)  ' 9 0 21 LB ' num2str(variance_reduction(i,1),'%5.2f')  '    | pstext -R -J -K -O  -N -Gblue  >> %psfile% ']);
           fprintf(fid,'%s \r\n','  ');
           %%%%%%%          problem with exponential Y axis 
           fprintf(fid,'%s\r\n','gmtset D_FORMAT %%4.1e ');  
           fprintf(fid,'%s \r\n',['psbasemap  -R' num2str(ftime) '/' num2str(totime) '/' num2str(maxmindataindex(1,2,i)) '/' num2str(maxmindataindex(1,1,i))  ' -JX5c/1.c -K -O   -P -B100/' num2str((abs(maxmindataindex(1,2,i))+maxmindataindex(1,1,i))/3) '::Wen -V    >> %psfile% ']);
           fprintf(fid,'%s\r\n','gmtset D_FORMAT %%lg  ');  
           fprintf(fid,'%s \r\n','  ');

           %
          if compuse(2,i)==1 
           fprintf(fid,'%s \r\n',['gawk "{print $1,$3}" ' realdatafilename{i} ' | psxy  -R  -JX5c/1.c -K -O %obspen% -P -B100:"Time (sec)":/.2::weSn -V -X6  >> %psfile% ']);
           fprintf(fid,'%s \r\n',['gawk "{print $1,$3}" ' syntdatafilename{i} ' | psxy  -R  -J   -K -O %synpen%  >> %psfile% ']);
          else
           fprintf(fid,'%s \r\n',['gawk "{print $1,$3}" ' realdatafilename{i} ' | psxy  -R  -JX5c/1.c -K -O %obsgpen% -P -B100:"Time (sec)":/.2::weSn -V -X6  >> %psfile% ']);
           fprintf(fid,'%s \r\n',['gawk "{print $1,$3}" ' syntdatafilename{i} ' | psxy  -R  -J   -K -O %synpen%  >> %psfile% ']);
          end
           %fprintf(fid,'%s \r\n',['echo -100 -0.65 10 90 21 0 ' station{i}  '  | pstext -R -J -K -O  -N  >> %psfile% ']);
           fprintf(fid,'%s \r\n',['echo ' num2str(totime-50) ' ' num2str(maxmindataindex(1,1,i)-(abs(maxmindataindex(1,2,i))+maxmindataindex(1,1,i))/4)  ' 9 0 21 LB ' num2str(variance_reduction(i,2),'%5.2f')  '    | pstext -R -J -K -O  -N -Gblue  >> %psfile% ']);
           fprintf(fid,'%s \r\n','  ');
          %
          if compuse(3,i)==1 
           fprintf(fid,'%s \r\n',['gawk "{print $1,$4}" ' realdatafilename{i} ' | psxy  -R  -JX5c/1.c -K -O %obspen% -P -B100:"Time (sec)":/.2::weSn -V -X6  >> %psfile% ']);
           fprintf(fid,'%s \r\n',['gawk "{print $1,$4}" ' syntdatafilename{i} ' | psxy  -R  -J   -K -O %synpen%  >> %psfile% ']);
          else
           fprintf(fid,'%s \r\n',['gawk "{print $1,$4}" ' realdatafilename{i} ' | psxy  -R  -JX5c/1.c -K -O %obsgpen% -P -B100:"Time (sec)":/.2::weSn -V -X6  >> %psfile% ']);
           fprintf(fid,'%s \r\n',['gawk "{print $1,$4}" ' syntdatafilename{i} ' | psxy  -R  -J   -K -O %synpen%  >> %psfile% ']);
          end
           fprintf(fid,'%s \r\n',['echo ' num2str(totime+20) ' 0 10 90 15 CT ' station{i}  '  | pstext -R -J -K -O  -N  >> %psfile% ']);
           fprintf(fid,'%s \r\n',['echo ' num2str(totime-50) ' ' num2str(maxmindataindex(1,1,i)-(abs(maxmindataindex(1,2,i))+maxmindataindex(1,1,i))/4)  ' 9 0 21 LB ' num2str(variance_reduction(i,3),'%5.2f')  '    | pstext -R -J -K -O  -N -Gblue  >> %psfile% ']);
           fprintf(fid,'%s \r\n','  ');
   
         end

%%% DEcide where to write Displacement (m)
               
           fprintf(fid,'%s \r\n',['psbasemap -JX18c/' num2str(1.6*nostations) 'c -R0/100/0/100 -P -G -X-12.5c -K -O -V >> %psfile%']);
           fprintf(fid,'%s \r\n','echo -10 50 16 90 21 CT Displacement (m) | pstext -R -J -O  -N -V >> %psfile% ');
         
           fprintf(fid,'%s \r\n','  ');
           fprintf(fid,'%s \r\n','  ');
           
           fprintf(fid,'%s \r\n','ps2raster %psfile% -A -P -Tg -D..\output -V');
           
           

 fclose(fid);


    cd ..


h = msgbox('A GMT batch file called plobs_syn.bat was created in INVERT folder. Run this file from a command window to get a high quality GMT plot.','GMT plot file.','help')
    
    
result='Check the INVERT folder for plobs_syn.bat file';
