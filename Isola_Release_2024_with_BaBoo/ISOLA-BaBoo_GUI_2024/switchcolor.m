function switchcolor(gcbo,EventData,staname,new_OT) %handles)

point=get(gcbo,'userdata');  button = get(gcf,'selectiontype');
   
   switch button
      case 'normal'  % select left click
       %% Check if stime.isl file exists
          cur_stime=[char(staname(point)) 'stime.isl'];

          if exist(cur_stime,'file')
                disp('found')
                 % Open and check against given event time
                    [sta,dd,mmm,yyyy,jul,HH,MM,SS] = textread(cur_stime,'%s%s%s%s%s%s%s%s');
                 % build time vector  
                 tmp=[char(dd) '-' char(mmm) '-' char(yyyy) ' ' char(HH) ':' char(MM) ':' char(SS)];
                 ST=datevec(datenum(tmp,'dd-mmm-yyyy HH:MM:SS.FFF'));  % 
                 
                % compare with OTnew  etime(t2, t1)
                 CRtime=etime(ST,new_OT);
                 
                 if CRtime > 0   % problem
                    h=errordlg('Station cannot be used. Data for this station start after new OT (OT-taper).You must provide data files with longer pre-event time or change taper length (in EventInfo).','Error'); 
                    uiwait(h);
                 else            % ok we can select station
                    set(gcbo,'MarkerFaceColor','g')
                    disp(['Selected '  char(staname(point))])  
                 end

          else
                h=errordlg([ cur_stime  ' file was not found in run folder.'],'Error'); 
                uiwait(h);
          end
       
       
      case 'alt'     % remove right click
          set(gcbo,'MarkerFaceColor','r')
          disp(['Removed '   char(staname(point))])
          
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
%  end  
  
end
