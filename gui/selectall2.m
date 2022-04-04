function selectall2(gcbo,EventData,staname,new_OT)
disp('This is selectall2.m  11/12/2020')
%%
%OT vs Data time checkbox option
%h=findobj(gcf,'Tag','checkDOT'); chkdataOT=get(h,'Value');
%%
sel_sta=findobj('Marker','square');

if length(sel_sta) > 21

    errordlg(['You are trying to select '  num2str(length(sel_sta)) ' stations, but maximum number of stations in ISOLA is 21'],'!! Error !!')

else
%%
  for i=1:length(sel_sta)
    point=get(sel_sta(i),'userdata'); cur_stime=[char(staname(point)) 'stime.isl'];
    
 %   if   chkdataOT == 0 
          if exist([pwd '\' cur_stime],'file')
                disp(['Found '  cur_stime])
                 % Open and check against given event time
                    [sta,dd,mmm,yyyy,jul,HH,MM,SS] = textread(cur_stime,'%s%s%s%s%s%s%s%s');
                 % build time vector  
                 tmp=[char(dd) '-' char(mmm) '-' char(yyyy) ' ' char(HH) ':' char(MM) ':' char(SS)];
                 ST=datevec(datenum(tmp,'dd-mmm-yyyy HH:MM:SS.FFF'));  % 
                 
                % compare with OTnew  etime(t2, t1)
                 CRtime=etime(ST,new_OT);
                 if CRtime > 0   % problem
                   % h=errordlg([ char(staname(point)) 'Station cannot be used. Data for this station start after new OT (OT-taper).You must provide data files with longer pre-event time or change taper length (in EventInfo).'],'Error'); 
                   % new approach issue warning!!
                    h=warndlg([ char(staname(point)) ' - Data for this station start after Origin Time.'],'Warning'); 
                    uiwait(h);
                    % disp([char(staname(point))  ' was NOT selected'])  
                    set(sel_sta(i), 'MarkerFaceColor','g')
                    disp(['Selected '  char(staname(point))])  
                 
                 else            % ok we can select station
                    set(sel_sta(i), 'MarkerFaceColor','g')
                    disp(['Selected '  char(staname(point))])  
                 end

          else
              
              choice=questdlg([ cur_stime  ' file was not found in run folder. Data Preparation needs this file.  Select it ?'],...
                  'Time file',...
                  'Yes','No','No');
             
            switch  choice
              case 'No'
                  % do nothing
                  disp('Not selected')
              case 'Yes'
                  % select it
                    set(sel_sta(i), 'MarkerFaceColor','g')
                    disp(['Selected '  char(staname(point))])                     
            end
              
%                 h=warndlg([ cur_stime  ' file was not found in run folder. Data Preparation needs this file.'],'Warning'); 
%                 uiwait(h);
          end
%     else   % don't check the stime.isl
% 
%         disp('  ')
%         disp('Origin time check is disabled')
%         disp('  ')
%                 set(sel_sta(i), 'MarkerFaceColor','g')
%                 disp(['Selected '  char(staname(point))])   
%     end
%     % set(sel_sta(i), 'MarkerFaceColor','g')

  end % end of for loop
       
end
