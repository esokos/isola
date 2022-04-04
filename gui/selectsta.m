function selectsta(gcbo,EventData,staname,new_OT) %handles)
disp('This is selectsta.m')
disp('11/12/2020')
disp('Max stations=21')

point=get(gcbo,'userdata'); button = get(gcf,'selectiontype');
%OT vs Data time checkbox option
%% h=findobj(gcf,'Tag','checkDOT'); chkdataOT=get(h,'Value');
%%
sel_sta=get(gcf,'userdata');
%%
switch button
  case 'normal'  % select left click
%       if   chkdataOT == 0 
       %% Check if stime.isl file exists
          cur_stime=[char(staname(point)) 'stime.isl'];

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
                 %   h=errordlg('Station cannot be used. Data for this station start after new OT (OT-taper).You must provide data files with longer pre-event time or change taper length (in EventInfo).','Error'); 
                 %   uiwait(h);
                    h=warndlg(['Station  ' char(staname(point)) ' - Data for this station start after Origin Time.'],'Warning'); 
                    uiwait(h);
                    
                    set(gcbo,'MarkerFaceColor','g')
                    disp(['Selected '  char(staname(point))])  
                       sel_sta=sel_sta+1;
                         set(gcf,'UserData',sel_sta);
                         if sel_sta > 21
                              errordlg('Maximum number of stations is 21','!! Error !!')
                         end
                 else            % ok we can select station
                    set(gcbo,'MarkerFaceColor','g')
                    disp(['Selected '  char(staname(point))])  
                       sel_sta=sel_sta+1;
                         set(gcf,'UserData',sel_sta);
                         if sel_sta > 21
                              errordlg('Maximum number of stations is 21','!! Error !!')
                         end
                    
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
                    set(gcbo,'MarkerFaceColor','g')
                    disp(['Selected '  char(staname(point))])  
                       sel_sta=sel_sta+1;
                         set(gcf,'UserData',sel_sta);
                         if sel_sta > 21
                              errordlg('Maximum number of stations is 21','!! Error !!')
                         end                      
            end
              
              
%                 h=warndlg([ cur_stime  ' file was not found in run folder. Data Preparation needs this file.'],'Warning'); 
%                 uiwait(h);
                
          end
          
%% this is disabled now..          
%        else
%            disp('OT vs Data start time check is disabled')
%            set(gcbo,'MarkerFaceColor','g')
%            disp(['Selected '  char(staname(point))])  
%             sel_sta=sel_sta+1;
%             set(gcf,'UserData',sel_sta);
%             
%             if sel_sta >= 21
%                 errordlg('Maximum number of stations is 21','!! Error !!')
%             end
%  
%        end
       
  case 'alt'     % remove right click
          set(gcbo,'MarkerFaceColor','r')
          disp(['Removed '   char(staname(point))])
            sel_sta=sel_sta-1;
            set(gcf,'UserData',sel_sta);
          
  otherwise    
           disp('Press either Left or Right mouse button')
end
   
  %set(hdd(point),'userdata',9999)
%  for j=1:numel(X) 
%      
%      cl=get(hdd(j),'MarkerFaceColor');
%      
%      if cl(1)==0
%          col='g';
%      else
%          col='r';
%      end
%   %   disp(['Point ' num2str(j) ' color ' col])
%      
%      
end  
  

