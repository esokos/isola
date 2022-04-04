function result = makegmtscript4synobsplot5 

disp('This is makegmtscript4synobsplot5 17/11/2020')

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
         fprintf(fid,'%s\r\n','del gmt.conf ');

         fprintf(fid,'%s\r\n','gmtset FONT_ANNOT_PRIMARY 8 FONT_ANNOT_SECONDARY 8  FONT_TITLE 8 FONT_LABEL 8  '); %%% D_FORMAT %%4.1e
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
           fprintf(fid,'%s \r\n',['echo ' num2str(totime/2) ' ' num2str(maxmindataindex(1,1,i)+(abs(maxmindataindex(1,2,i))+maxmindataindex(1,1,i))/4)   ' NS      | pstext -R -J -K -O  -N -F+f12,Helvetica-Narrow  >> %psfile% ']);
           fprintf(fid,'%s \r\n',['echo ' num2str(totime-50) ' ' num2str(maxmindataindex(1,1,i)-(abs(maxmindataindex(1,2,i))+maxmindataindex(1,1,i))/4)  ' ' num2str(variance_reduction(i,1),2)  '    | pstext -R -J -K -O  -N   -F+f9,Helvetica-Narrow,blue >> %psfile% ']);
           % event id
           fprintf(fid,'%s \r\n',['echo ' num2str(totime/2) ' ' num2str(maxmindataindex(1,1,i)+(abs(maxmindataindex(1,2,i))+maxmindataindex(1,1,i))*2)  '   ' ['Event Date-Time: ' [eventid(1:2) '/' eventid(3:4) '/' eventid(5:6) '-' eventid(8:9) ':' eventid(11:12) ':' eventid(14:end)] ]  '    | pstext -R -J -K -O  -N  -F+f16,Helvetica-Narrow >> %psfile% ']);
           fprintf(fid,'%s \r\n',['echo ' num2str(totime/2) ' ' num2str(maxmindataindex(1,1,i)+(abs(maxmindataindex(1,2,i))+maxmindataindex(1,1,i))*1.5)  '  ' 'Inversion Band (Hz): ' invband '    | pstext -R -J -K -O  -N -F+f16,Helvetica-Narrow  >> %psfile% ']);
           
           %%%%%%%          problem with exponential Y axis 
           fprintf(fid,'%s\r\n','gmtset FORMAT_FLOAT_MAP %%4.1e ');  
           fprintf(fid,'%s \r\n',['psbasemap  -R' num2str(ftime) '/' num2str(totime) '/' num2str(maxmindataindex(1,2,i)) '/' num2str(maxmindataindex(1,1,i))  ' -JX5c/1.c -K -O   -P -B100/' num2str((abs(maxmindataindex(1,2,i))+maxmindataindex(1,1,i))/3) '::Wen -V    >> %psfile% ']);
           fprintf(fid,'%s\r\n','gmtset FORMAT_FLOAT_MAP %%lg  ');  
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
           fprintf(fid,'%s \r\n',['echo ' num2str(totime/2) ' ' num2str(maxmindataindex(1,1,i)+(abs(maxmindataindex(1,2,i))+maxmindataindex(1,1,i))/4)  '  EW      | pstext -R -J -K -O  -N -F+f12,Helvetica-Narrow  >> %psfile% ']);
           fprintf(fid,'%s \r\n',['echo ' num2str(totime-50) ' ' num2str(maxmindataindex(1,1,i)-(abs(maxmindataindex(1,2,i))+maxmindataindex(1,1,i))/4)  '   ' num2str(variance_reduction(i,2),2)  '    | pstext -R -J -K -O  -N -F+f9,Helvetica-Narrow,blue  >> %psfile% ']);
           fprintf(fid,'%s \r\n','  ');
           
           % Z
           if compuse(3,i)==1 
           fprintf(fid,'%s \r\n',['gawk "{print $1,$4}" ' realdatafilename{i} ' | psxy  -R   -JX5c/1.c -K -O %obspen% -P -B100/.5::wesn -V -X6  >> %psfile% ']);
           fprintf(fid,'%s \r\n',['gawk "{print $1,$4}" ' syntdatafilename{i} ' | psxy  -R  -J   -K -O %synpen%  >> %psfile% ']);
           else
           fprintf(fid,'%s \r\n',['gawk "{print $1,$4}" ' realdatafilename{i} ' | psxy  -R   -JX5c/1.c -K -O %obsgpen% -P -B100/.5::wesn -V -X6  >> %psfile% ']);
           fprintf(fid,'%s \r\n',['gawk "{print $1,$4}" ' syntdatafilename{i} ' | psxy  -R  -J   -K -O %synpen%  >> %psfile% ']);
           end
           fprintf(fid,'%s \r\n',['echo ' num2str(totime+20) ' 0  ' station{i}  '  | pstext -R -J -K -O  -N -F+f10,Helvetica-Narrow-Bold+a90 >> %psfile% ']);  %10 90 15 CT
           fprintf(fid,'%s \r\n',['echo ' num2str(totime/2) ' ' num2str(maxmindataindex(1,1,i)+(abs(maxmindataindex(1,2,i))+maxmindataindex(1,1,i))/4)  '  Z      | pstext -R -J -K -O  -N -F+f12,Helvetica-Narrow >> %psfile% ']);
           fprintf(fid,'%s \r\n',['echo ' num2str(totime-50) ' ' num2str(maxmindataindex(1,1,i)-(abs(maxmindataindex(1,2,i))+maxmindataindex(1,1,i))/4)  '   ' num2str(variance_reduction(i,3),2)  '    | pstext -R -J -K -O  -N -F+f9,Helvetica-Narrow,blue  >> %psfile% ']);
           fprintf(fid,'%s \r\n','   ');
          
       else
           if compuse(1,i)==1 
           fprintf(fid,'%s \r\n',['gawk "{print $1,$2}" ' realdatafilename{i} ' | psxy  -R' num2str(ftime) '/' num2str(totime) '/' num2str(maxmindataindex(1,2,i)) '/' num2str(maxmindataindex(1,1,i))  ' -JX5c/1.c -K -O %obspen% -P -B100::/.2::wesn -V  -Y-1.6c -X-12 >> %psfile% ']);
           fprintf(fid,'%s \r\n',['gawk "{print $1,$2}" ' syntdatafilename{i} ' | psxy  -R  -J   -K -O %synpen%  >> %psfile% ']);
           else
           fprintf(fid,'%s \r\n',['gawk "{print $1,$2}" ' realdatafilename{i} ' | psxy  -R' num2str(ftime) '/' num2str(totime) '/' num2str(maxmindataindex(1,2,i)) '/' num2str(maxmindataindex(1,1,i))  ' -JX5c/1.c -K -O %obsgpen% -P -B100::/.2::wesn -V  -Y-1.6c -X-12 >> %psfile% ']);
           fprintf(fid,'%s \r\n',['gawk "{print $1,$2}" ' syntdatafilename{i} ' | psxy  -R  -J   -K -O %synpen%  >> %psfile% ']);
           end
%           fprintf(fid,'%s \r\n',['echo -60 0 10 90 21 CT ' station{i}  '  | pstext -R -J -K -O  -N  >> %psfile% ']);
           fprintf(fid,'%s \r\n',['echo ' num2str(totime-50) ' ' num2str(maxmindataindex(1,1,i)-(abs(maxmindataindex(1,2,i))+maxmindataindex(1,1,i))/4)  '   ' num2str(variance_reduction(i,1),2)  '    | pstext -R -J -K -O  -N -F+f9,Helvetica-Narrow,blue  >> %psfile% ']);
           fprintf(fid,'%s \r\n','  ');
           %%%%%%%          problem with exponential Y axis 
           fprintf(fid,'%s\r\n','gmtset FORMAT_FLOAT_MAP %%4.1e ');  
           fprintf(fid,'%s \r\n',['psbasemap  -R' num2str(ftime) '/' num2str(totime) '/' num2str(maxmindataindex(1,2,i)) '/' num2str(maxmindataindex(1,1,i))  ' -JX5c/1.c -K -O   -P -B100/' num2str((abs(maxmindataindex(1,2,i))+maxmindataindex(1,1,i))/3) '::Wen -V    >> %psfile% ']);
           fprintf(fid,'%s\r\n','gmtset FORMAT_FLOAT_MAP %%lg  ');  
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
           fprintf(fid,'%s \r\n',['echo ' num2str(totime-50) ' ' num2str(maxmindataindex(1,1,i)-(abs(maxmindataindex(1,2,i))+maxmindataindex(1,1,i))/4)  '   ' num2str(variance_reduction(i,2),2)  '    | pstext -R -J -K -O  -N -F+f9,Helvetica-Narrow,blue  >> %psfile% ']);
           fprintf(fid,'%s \r\n','  ');
           %
           if compuse(3,i)==1 
           fprintf(fid,'%s \r\n',['gawk "{print $1,$4}" ' realdatafilename{i} ' | psxy  -R  -JX5c/1.c -K -O %obspen% -P -B100::/.2::wesn -V -X6  >> %psfile% ']);
           fprintf(fid,'%s \r\n',['gawk "{print $1,$4}" ' syntdatafilename{i} ' | psxy  -R  -J   -K -O %synpen%  >> %psfile% ']);
           else
           fprintf(fid,'%s \r\n',['gawk "{print $1,$4}" ' realdatafilename{i} ' | psxy  -R  -JX5c/1.c -K -O %obsgpen% -P -B100::/.2::wesn -V -X6  >> %psfile% ']);
           fprintf(fid,'%s \r\n',['gawk "{print $1,$4}" ' syntdatafilename{i} ' | psxy  -R  -J   -K -O %synpen%  >> %psfile% ']);
           end
           fprintf(fid,'%s \r\n',['echo ' num2str(totime+20) ' 0   ' station{i}  '  | pstext -R -J -K -O  -N  -F+f10,Helvetica-Narrow-Bold+a90  >> %psfile% ']);
           fprintf(fid,'%s \r\n',['echo ' num2str(totime-50) ' ' num2str(maxmindataindex(1,1,i)-(abs(maxmindataindex(1,2,i))+maxmindataindex(1,1,i))/4)  '  ' num2str(variance_reduction(i,3),2)  '    | pstext -R -J -K -O  -N -F+f9,Helvetica-Narrow,blue  >> %psfile% ']);
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
           fprintf(fid,'%s \r\n',['echo ' num2str(totime-50) ' ' num2str(maxmindataindex(1,1,i)-(abs(maxmindataindex(1,2,i))+maxmindataindex(1,1,i))/4)  '  ' num2str(variance_reduction(i,1),'%5.2f')  '    | pstext -R -J -K -O  -N -F+f9,Helvetica-Narrow,blue  >> %psfile% ']);  %9 0 21 LB
           fprintf(fid,'%s \r\n','  ');
           %%%%%%%          problem with exponential Y axis 
           fprintf(fid,'%s\r\n','gmtset FORMAT_FLOAT_MAP %%4.1e ');  
           fprintf(fid,'%s \r\n',['psbasemap  -R' num2str(ftime) '/' num2str(totime) '/' num2str(maxmindataindex(1,2,i)) '/' num2str(maxmindataindex(1,1,i))  ' -JX5c/1.c -K -O   -P -B100/' num2str((abs(maxmindataindex(1,2,i))+maxmindataindex(1,1,i))/3) '::Wen -V    >> %psfile% ']);
           fprintf(fid,'%s\r\n','gmtset FORMAT_FLOAT_MAP %%lg  ');  
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
           fprintf(fid,'%s \r\n',['echo ' num2str(totime-50) ' ' num2str(maxmindataindex(1,1,i)-(abs(maxmindataindex(1,2,i))+maxmindataindex(1,1,i))/4)  '   ' num2str(variance_reduction(i,2),'%5.2f')  '    | pstext -R -J -K -O  -N -F+f9,Helvetica-Narrow,blue  >> %psfile% ']);
           fprintf(fid,'%s \r\n','  ');
          %
          if compuse(3,i)==1 
           fprintf(fid,'%s \r\n',['gawk "{print $1,$4}" ' realdatafilename{i} ' | psxy  -R  -JX5c/1.c -K -O %obspen% -P -B100:"Time (sec)":/.2::weSn -V -X6  >> %psfile% ']);
           fprintf(fid,'%s \r\n',['gawk "{print $1,$4}" ' syntdatafilename{i} ' | psxy  -R  -J   -K -O %synpen%  >> %psfile% ']);
          else
           fprintf(fid,'%s \r\n',['gawk "{print $1,$4}" ' realdatafilename{i} ' | psxy  -R  -JX5c/1.c -K -O %obsgpen% -P -B100:"Time (sec)":/.2::weSn -V -X6  >> %psfile% ']);
           fprintf(fid,'%s \r\n',['gawk "{print $1,$4}" ' syntdatafilename{i} ' | psxy  -R  -J   -K -O %synpen%  >> %psfile% ']);
          end
           fprintf(fid,'%s \r\n',['echo ' num2str(totime+20) ' 0   ' station{i}  '  | pstext -R -J -K -O  -N -F+f10,Helvetica-Narrow-Bold+a90 >> %psfile% ']);
           fprintf(fid,'%s \r\n',['echo ' num2str(totime-50) ' ' num2str(maxmindataindex(1,1,i)-(abs(maxmindataindex(1,2,i))+maxmindataindex(1,1,i))/4)  '   ' num2str(variance_reduction(i,3),'%5.2f')  '    | pstext -R -J -K -O  -N -F+f9,Helvetica-Narrow,blue  >> %psfile% ']);
           fprintf(fid,'%s \r\n','  ');
   
         end

%%% DEcide where to write Displacement (m)
               
   %        fprintf(fid,'%s \r\n',['psbasemap -JX18c/' num2str(1.6*nostations) 'c -R0/100/0/100 -P   -X-12.5c -K -O -V >> %psfile%']);
           
           fprintf(fid,'%s \r\n',['echo -10 50 ' ' Displacement (m) | pstext -R0/100/0/100 -JX18c/' num2str(1.6*nostations) 'c -O  -N -V -F+f16,Helvetica-Narrow+a90  -X-12.5c  >> %psfile% ']); %16 90 21 CT
         
           fprintf(fid,'%s \r\n','  ');
           fprintf(fid,'%s \r\n','  ');
           
           fprintf(fid,'%s \r\n','psconvert %psfile% -A -P -Tg -D..\output -V');
           
           

 fclose(fid);


    cd ..


h = msgbox('A GMT 5 batch file called plobs_syn.bat was created in INVERT folder. Run this file from a command window to get a high quality GMT plot.','GMT plot file.','help')
    
    
result='Check the INVERT folder for plobs_syn.bat file';