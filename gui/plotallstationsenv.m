function plotallstationsenv(nostations,staname,normalized,invband,ftime,totime,uselimits,dtime,eventid,addvarred,pbw,net_use,fullstationfile)
%%%%%prepare filenames  
%%% we keep fixed that data will be e.g. evrfil.dat
%%% and synthetics will be               evrsyn.dat

for i=1:nostations
    realdatafilename{i}=[staname{i} 'fil.dat'];
    syntdatafilename{i}=[staname{i} 'syn.dat'];
end

realdatafilename=realdatafilename';
syntdatafilename=syntdatafilename';

%try    
%%%%%%%%%NOW WE KNOW FILENAMES AND WE CAN PLOT .....
%%%%%%%%%go in invert first
 
cd env_amp_inv

%%
%%%%%%%%%%%initialize data matrices
realdataall=zeros(8192,4,nostations);    %%%% 8192 points  fixed....
syntdataall=zeros(8192,4,nostations); 
maxmindataindex=zeros(1,2,nostations);
%%%%open data files and read data
for i=1:nostations
    
fid1  = fopen(realdatafilename{i},'r');
fid2  = fopen(syntdatafilename{i},'r');

        a=fscanf(fid1,'%f %f %f %f',[4 inf]);
        realdata=a';
        b=fscanf(fid2,'%f %f %f %f',[4 inf]);
        syntdata=b';

fclose(fid1);
fclose(fid2);

realdataall(:,:,i)=realdata;
maxmindataindex(:,:,i)=findlimits4plot(realdata);    %%% find data limits for plotting  ... June 2010 
syntdataall(:,:,i)=syntdata;

end
%%
% only new version of allstat is allowed...

   [station,useornot,nsw,eww,vew,~,~,~,~] = textread('allstat.dat','%s %u %f %f %f %f %f %f %f',-1);

for i=1:nostations    %%%%%%loop over stations
      if useornot(i) == 0
          compuse(1,i) = 0;
          compuse(2,i) = 0;
          compuse(3,i) = 0;
      elseif useornot(i) == 1
          if nsw(i) == 0         %%   if weight == 0 component is not used..
             compuse(1,i) = 0;  
          else
             compuse(1,i) = 1;  
          end   

          if eww(i) == 0 
             compuse(2,i) = 0;  
          else
             compuse(2,i) = 1;  
          end   
          
          if vew(i) == 0 
             compuse(3,i) = 0;  
          else
             compuse(3,i) = 1;  
          end   
      end
end

%%
cd ..  % up one level


%% new code to compute varred per comp
k=0;
disp('Variance Reduction per component')

      fprintf(1,'%s \t\t %s \t\t %s \t\t %s\n', 'Station','NS','EW','Z')

for i=1:nostations    %%%%%%loop over stations
  
     for j=1:3                %%%%%%%%loop over components
%          disp(componentname{j})
         variance_reduction(i,j)= vared(realdataall(:,j+1,i),syntdataall(:,j+1,i),dtime);
     end   
     
fprintf(1, '\t%s \t\t %4.2f \t\t %4.2f \t\t %4.2f\n', staname{i}, variance_reduction(i,1),variance_reduction(i,2),variance_reduction(i,3))
     
end                   

% whos variance_reduction staname
% staname
%%%%%%%%%%%%%%%%%%% normalize 23/06/05

if normalized == 1

    disp('Normalized plot')

    for i=1:nostations
        for j=2:4

             maxreal(i,j)=max(abs(realdataall(:,j,i)));
             maxsynt(i,j)=max(abs(syntdataall(:,j,i)));

             realdataall(:,j,i) = realdataall(:,j,i)/max(abs(realdataall(:,j,i)));
             syntdataall(:,j,i) = syntdataall(:,j,i)/max(abs(syntdataall(:,j,i)));
             

         end
    end
    
    
else
end

%%   write varred per component in a file 
try
  cd output
  
   disp(['Saving Variance Reduction per component in ' eventid 'env_varred_info.txt file in \output folder.']);

    fid = fopen([eventid 'env_varred_info.txt'],'w');
       if ispc
          fprintf(fid,'%s \t %s \t %s \t %s\r\n', 'Station','NS','EW','Z');
       else
          fprintf(fid,'%s \t %s \t %s \t %s\n', 'Station','NS','EW','Z');
       end
    
    for i=1:nostations    %%%%%%loop over stations
        if ispc
         fprintf(fid, '%s \t\t %4.2f \t %4.2f \t %4.2f\r\n', staname{i}, variance_reduction(i,1),variance_reduction(i,2),variance_reduction(i,3));
        else
         fprintf(fid, '%s \t\t %4.2f \t %4.2f \t %4.2f\n', staname{i}, variance_reduction(i,1),variance_reduction(i,2),variance_reduction(i,3));
        end
    end                   

  fclose(fid);
  cd ..
catch
    cd ..
end


%%%%%%%%%% normalize
% realdataall=cat(3,realdataall,realdata);
% syntdataall=cat(3,syntdataall,syntdata);

%%%%%%%%%PLOTTING   
componentname=cellstr(['NS';'EW';'Z ']);

% h=figure
scrsz = get(0,'ScreenSize');

%fh=figure('Tag','Syn vs Obs','Position',[5 scrsz(4)*1/6 scrsz(3)*5/6 scrsz(4)*5/6-50], 'Name','Plotting Obs vs Syn');

fh=figure('Tag','Syn vs Obs','Position',get(0,'Screensize'), 'Name','Plotting Obs vs Syn');

set(gcf,'PaperPositionMode','auto')

mh = uimenu(fh,'Label','Export Figure');
eh1 = uimenu(mh,'Label','Convert to PNG','Callback','exportgraph(1)');
eh2 = uimenu(mh,'Label','Convert to PS','Callback','exportgraph(2)');
eh3 = uimenu(mh,'Label','Convert to EPS','Callback','exportgraph(3)');
eh4 = uimenu(mh,'Label','Convert to TIFF','Callback','exportgraph(4)');
eh5 = uimenu(mh,'Label','Convert to EMF','Callback','exportgraph(5)');
eh6 = uimenu(mh,'Label','Convert to JPG','Callback','exportgraph(6)');
eh7 = uimenu(mh,'Label','Prepare a GMT script','Callback','makegmtscript4synobsplot'); 

% create structure of handles
handles1 = guihandles(fh); 
handles1.nostations=nostations;
handles1.realdatafilename=realdatafilename;
handles1.syntdatafilename=syntdatafilename;
handles1.station=station;
handles1.useornot=useornot;
handles1.compuse=compuse;
handles1.variance_reduction=variance_reduction;
handles1.eventid=eventid;
handles1.ftime=ftime;
handles1.totime=totime;
handles1.maxmindataindex=maxmindataindex;
handles1.invband=invband;
guidata(fh, handles1);

%[100 100 scrsz(3)-200 scrsz(4)-200])
% subplot(nostations+1,3,1:3)
%%  Start making legend at top row
subplot1(nostations+1,3)

subplot1(1)
v=axis;
text( v(1), .7,['Event date-time: ' strrep(eventid,'_','\_')],'FontSize',10,'FontWeight','bold')
axis off
%%
subplot1(2)
v=axis;
text( v(1), .7,['Displacement (m).  Inversion band (Hz)  ' invband],'FontSize',10,'FontWeight','bold')
axis off
%%
subplot1(3)
          p1=plot(realdataall(:,1,1),realdataall(:,1+1,1),'k', 'LineWidth',1.5);     
          hold on
          p2=plot(syntdataall(:,1,1),syntdataall(:,1+1,1),'r' ,'LineWidth',1.);   
          hold off
          v=axis;  
text( v(1), .7,'Gray waveforms weren''t used in inversion.','Color','k','FontSize',8,'FontWeight','bold');
text( v(1), 0.5, 'Blue numbers are variance reduction','Color','k','FontSize',8,'FontWeight','bold');
                    legend('Observed','Synthetic');
                    set(p1, 'visible', 'off');
                    set(p2, 'visible', 'off');   
axis off
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Finish with legend

k=0;
for i=1:nostations    %%%%%%loop over stations
%    realdataall    8192x4x6 
     for j=1:3                %%%%%%%%loop over components
          subplot1(j+k+3);
%          set(gca,'FontSize',8)
          %%%%%%%%%%%%%%%%%%%%%%%%%%%
      if pbw == 1      %% we need b&w plot
           
          if  compuse(j,i) == 1  
          plot(realdataall(:,1,i),realdataall(:,j+1,i),'k',...
                             'LineWidth',2);      
          elseif compuse(j,i) == 0     %%% not used in inversion
          plot(realdataall(:,1,i),realdataall(:,j+1,i),...
                             'LineWidth',2,'Color',[.5,0.5,.5]);      
                       
          end                         
          hold on
%%%%%%%%%%                          h = vline(50,'k');
          if  compuse(j,i) == 1  
          plot(syntdataall(:,1,i),syntdataall(:,j+1,i),'k',...
                             'LineWidth',.8 );  
                         
          elseif compuse(j,i) == 0     %%% not used in inversion
          plot(syntdataall(:,1,i),syntdataall(:,j+1,i),...
                             'LineWidth',.8,'Color',[.5,0,0]);   
                         
 %                set(subplot(nostations+1,3,j+k+3),'Color',[.1,0.1,.1])     
                 
          end                         
          hold off
%     
      else   %%%pbw=0
          
          if  compuse(j,i) == 1  
          plot(realdataall(:,1,i),realdataall(:,j+1,i),'k',...
                             'LineWidth',1.5);      
          elseif compuse(j,i) == 0     %%% not used in inversion
          plot(realdataall(:,1,i),realdataall(:,j+1,i),...
                             'LineWidth',1.5,'Color',[.5,0.5,.5]);      
          end                         
          hold on
%%%%%%%%%%                          h = vline(50,'k');
          if  compuse(j,i) == 1  
          plot(syntdataall(:,1,i),syntdataall(:,j+1,i),'r',...
                             'LineWidth',1. );  
          elseif compuse(j,i) == 0     %%% not used in inversion
          plot(syntdataall(:,1,i),syntdataall(:,j+1,i),...
                             'LineWidth',1.,'Color',[.5,0,0]);      
          end                         
          hold off
      end   %%end pbw

      
%%          
         if uselimits == 1
                  if normalized == 1
%                     axis ([ftime totime min(realdataall(:,j+1,i)) max(realdataall(:,j+1,i)) ]) ;   
                      axis ([ftime totime -1.0 1.0 ]) ;       
                  else
                      axis([ftime totime maxmindataindex(1,2,i) maxmindataindex(1,1,i)]);
                  end
         else   %%% not use time limits
                 if normalized == 1
                     v=axis;
                     axis([v(1) v(2) -1.0 1.0 ]) ;  
                 else
                     v=axis;
                     axis([v(1) v(2) maxmindataindex(1,2,i) maxmindataindex(1,1,i)]);
                 end
         end

%%  Add text in graph 
%   AXIS SCALE.....
                
          if i==1
            title(componentname{j},...
              'FontSize',9,...
              'FontWeight','bold');
          end
          
          if i==nostations
          xlabel('Time (sec)')
          elseif i~=nostations
               set(gca,'Xtick',[-10 1000])
          end
          
          if  j==1 
            % check if we need network code
               if net_use ==0
                  y=ylabel(staname{i},'FontSize',12,'FontWeight','bold');
                    set(get(gca,'YLabel'),'Rotation',0)
                    set(y, 'Units', 'Normalized', 'Position', [-0.12, 0.5, 0]);
               else
                  %  disp(['Using ' fullstationfile ' station file'])
                    %read data in 3 arrays
                    fid  = fopen(fullstationfile,'r');
                        C= textscan(fid,'%s %f %f %s',-1);
                    fclose(fid);
                    staname_stn=C{1};netcode=C{4};
                      for ii=1:nostations
                          for jj=1:length(staname_stn)
                              if strcmp(char(staname{ii}),char(staname_stn(jj)))
                                    st_netcode(ii)=netcode(jj);
                                  %  disp(['Code for ' char(staname{ii}) ' is ' char(st_netcode(ii))])
                              else
                              end
                          end
                      end
                %  ploting
                    y=ylabel([char(staname{i}) '.' char(st_netcode(i)) ],'FontSize',12,'FontWeight','bold');
                    set(get(gca,'YLabel'),'Rotation',0);set(y, 'Units', 'Normalized', 'Position', [-0.12, 0.5, 0]);  
               end
          end

%% 
%%%%%%%%%                Normalized plotting
%%%%%%%%%          
        if normalized == 1
            if uselimits == 1
                text( ftime,  1.1, num2str(maxreal(i,j+1),'%8.2E'),'HorizontalAlignment','left','FontSize',8,'FontWeight','bold');   %%% max values
                text( totime, 1.1, num2str(maxsynt(i,j+1),'%8.2E'),'Color','r','HorizontalAlignment','right','FontSize',8,'FontWeight','bold');

               if addvarred == 1   %%%%%%%%%%  print variance                

                   text((totime-ftime)*0.05, .65, num2str(variance_reduction(i,j),'%4.2f'),'Color','b','HorizontalAlignment','left','FontSize',10,...
                      'FontWeight','bold','FontName','FixedWidth');  
               else
               end
%%%%%%%%%%%%%%%%               
            else  % not use limits
                text( min(realdataall(:,1,i)), 1.2, num2str(maxreal(i,j+1),'%8.2E'),'HorizontalAlignment','left','FontSize',8,'FontWeight','bold');  % max values
                text( max(realdataall(:,1,i)), 1.2, num2str(maxsynt(i,j+1),'%8.2E'),'Color','r','HorizontalAlignment','right','FontSize',8,'FontWeight','bold');

               if addvarred == 1   %%%%%%%%%%print variance 
                 v=axis;
                 text((v(2)-v(1))*0.95, 0.65, num2str(variance_reduction(i,j),'%4.2f'),'Color','b','HorizontalAlignment','right','FontSize',10,...
                   'FontWeight','bold','FontName','FixedWidth');  
               else
               end
               
            end
%%%%%%%%%%%%%%%%%%%%
         else    %%% not normalized
            if addvarred == 1
                if uselimits == 0
                  v=axis;
                  text(v(2)-((v(2)-v(1))*0.03), v(4)-(v(4)/5), num2str(variance_reduction(i,j),'%4.2f'),'Color','b','HorizontalAlignment','right','FontSize',10,'FontWeight','bold','FontName','FixedWidth');
                else
                  v=axis;
                  text(totime-((totime-ftime)*0.03) , v(4)-(v(4)/5), num2str(variance_reduction(i,j),'%4.2f'),'Color','b','HorizontalAlignment','right','FontSize',10,'FontWeight','bold','FontName','FixedWidth');
                end
            else
            end
        end    %%%end of Normalized  if

      end       %%%%%%%loop over components
      
       k=k+3;
       
end   %%%%%%%loop over stations

%%%%%%%%%%%%%%%%%%OUTPUT options in isl file
    fid2 = fopen('waveplotoptionsenv.isl','w');
     if normalized == 1
       if ispc  
         fprintf(fid2,'%c\r\n','1');
       else
         fprintf(fid2,'%c\n','1');
       end
     else
       if ispc  
         fprintf(fid2,'%c\r\n','0');
       else
         fprintf(fid2,'%c\n','0');
       end
     end
     
     if uselimits == 1
        if ispc 
         fprintf(fid2,'%c\r\n','1');
        else
         fprintf(fid2,'%c\n','1');
        end
     else
         if ispc
           fprintf(fid2,'%c\r\n','0');
         else
           fprintf(fid2,'%c\n','0');
         end
     end
     
     if ispc
          fprintf(fid2,'%f\r\n',ftime);
          fprintf(fid2,'%f\r\n',totime);
     else
          fprintf(fid2,'%f\n',ftime);
          fprintf(fid2,'%f\n',totime);
     end
     
     if addvarred == 1
         if ispc 
            fprintf(fid2,'%c\r\n','1');
         else
            fprintf(fid2,'%c\n','1');
         end
     else
        if ispc 
           fprintf(fid2,'%c\r\n','0');
        else
           fprintf(fid2,'%c\n','0');
        end
     end
     
     if pbw==1
        if ispc 
         fprintf(fid2,'%c\r\n','1');
        else
         fprintf(fid2,'%c\n','1');
        end
     else
        if ispc 
         fprintf(fid2,'%c\r\n','0');
        else
         fprintf(fid2,'%c\n','0');
        end
     end
     
    fclose(fid2);


mh = uimenu(fh,'Label','Export Figure');
eh1 = uimenu(mh,'Label','Convert to PNG','Callback','exportgraph(1)');
eh2 = uimenu(mh,'Label','Convert to PS','Callback','exportgraph(2)');
eh3 = uimenu(mh,'Label','Convert to EPS','Callback','exportgraph(3)');
eh4 = uimenu(mh,'Label','Convert to TIFF','Callback','exportgraph(4)');
eh5 = uimenu(mh,'Label','Convert to EMF','Callback','exportgraph(5)');
eh6 = uimenu(mh,'Label','Convert to JPG','Callback','exportgraph(6)');
eh7 = uimenu(mh,'Label','Prepare a GMT script','Callback','makegmtscript4synobsplot'); 
    

set(get(gca,'YLabel'),'Rotation',0)

%%

function flimits = findlimits4plot(data)
%we expect data in form 8192x4 1st column time 2nd NS etc...

limits(1)=max(data(:,2));
limits(2)=max(data(:,3));
limits(3)=max(data(:,4));
limits(4)=min(data(:,2));
limits(5)=min(data(:,3));
limits(6)=min(data(:,4));

flimits(1)=max(limits);
flimits(2)=min(limits);
