function result = exportgraph(sel)

%%% check event.isl files with event info
h=dir('event.isl');
if isempty(h); 
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

eventid1=[eventdate(3:8) '_' eventhour '_' eventmin '_' eventsec  ];

switch sel
    case 1  %%%  PNG
        eventid=[eventid1 '_wave.png' ];
        cd output
        print('-dpng', '-noui' ,eventid) 
        cd ..
        result='PNG file was created. Check the output folder';
    case 2  %%%   PS
        eventid=[eventid1 '_wave.ps' ];
        cd output
        print('-dpsc2', '-noui', eventid)
        cd ..
        result='PS file was created. Check the output folder';
    case 3  %%%   EPS
        eventid=[eventid1 '_wave.eps' ];
        cd output
     %   set(gcf, 'PaperPositionMode', 'auto')
        print('-depsc2', '-noui', eventid)
        cd ..
        result='EPS file was created. Check the output folder';
    case 4  %%%   TIFF
        eventid=[eventid1 '_wave.tif' ];
        cd output
        print('-dtiff', '-noui', eventid)
        cd ..
        result='TIF file was created. Check the output folder';
    case 5  %%%   EMF
        eventid=[eventid1 '_wave.emf' ];
        cd output
        print('-dmeta', '-noui', eventid)
        cd ..
        result='EMF file was created. Check the output folder';
    case 6  %%%   JPEG
        eventid=[eventid1 '_wave.jpg' ];
        cd output
        print('-djpeg', '-noui', eventid)
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
