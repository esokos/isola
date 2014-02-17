function result = exportgraph(sel)

%%% check event.isl files with event info
h=dir('event.isl');
if length(h) == 0; 
  errordlg('Event.isl file doesn''t exist. Run Event info. ','File Error');
  return
else
    fid = fopen('event.isl','r');
    eventcor=fscanf(fid,'%g',2);
% %%%% READ MAGNITUDE AND DATE .....(not used in computations!!!!!!!!)
    epidepth=fscanf(fid,'%g',1);
    magn=fscanf(fid,'%g',1);
    eventdate=fscanf(fid,'%s',1);
    eventhour=fscanf(fid,'%s',1);
    eventmin=fscanf(fid,'%s',1);
    eventsec=fscanf(fid,'%s',1);
    eventagency=fscanf(fid,'%s',1);
    fclose(fid);
end

switch sel
    case 1  %%%  PNG
        eventid=[eventdate '_' eventhour '_' eventmin '_' eventsec '_sta.png' ];
        cd output
        print('-f1', '-dpng', '-noui', eventid)
        cd ..
        result='PNG file was created. Check the output folder';
    case 2  %%%   PS
        eventid=[eventdate '_' eventhour '_' eventmin '_' eventsec '_sta.ps' ];
        cd output
        print('-f1', '-dpsc2', '-noui', eventid)
        cd ..
        result='PS file was created. Check the output folder';
    case 3  %%%   EPS
        eventid=[eventdate '_' eventhour '_' eventmin '_' eventsec '_sta.eps' ];
        cd output
        print('-f1', '-depsc2', '-noui', eventid)
        cd ..
        result='EPS file was created. Check the output folder';
    case 4  %%%   TIFF
        eventid=[eventdate '_' eventhour '_' eventmin '_' eventsec '_sta.tif' ];
        cd output
        print('-f1', '-dtiff', '-noui', eventid)
        cd ..
        result='TIF file was created. Check the output folder';
    case 5  %%%   EMF
        eventid=[eventdate '_' eventhour '_' eventmin '_' eventsec '_sta.emf' ];
        cd output
        print('-f1', '-dmeta', '-noui', eventid)
        cd ..
        result='EMF file was created. Check the output folder';
    case 6  %%%   JPEG
        eventid=[eventdate '_' eventhour '_' eventmin '_' eventsec '_sta.jpg' ];
        cd output
        print('-f1', '-djpeg', '-noui', eventid)
        cd ..
        result='JPG file was created. Check the output folder';
%     case 7  %%%   Produce a GMT script !!
%         eventid=[eventdate '_' eventhour '_' eventmin '_' eventsec '_wave.jpg' ];
%         cd output
%         print('-f1', '-djpeg', eventid)
%         cd ..
%         result='GMT script file was created. Check the output folder';
%         
    otherwise
      disp('Unknown method.')
end
