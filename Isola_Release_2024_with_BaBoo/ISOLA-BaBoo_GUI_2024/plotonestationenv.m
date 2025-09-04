function plotonestationenv(stationname,normalized,ftime,totime,uselimits,normsynth)

%%%%%prepare filenames  
%%% we keep fixed that data will be e.g. evrfil.dat
%%% and synthetics will be               evrsyn.dat

    realdatafilename=[stationname 'fil.dat'];
    syntdatafilename=[stationname 'syn.dat'];
 
%%%%%%%%%%%initialize data matrices
realdata=zeros(8192,4);   
syntdata=zeros(8192,4); 

try
    
%%%go in invert
 cd env_amp_inv

%%%%open data files and read data
fid1  = fopen(realdatafilename,'r');
fid2  = fopen(syntdatafilename,'r');

        a=fscanf(fid1,'%f %f %f %f',[4 inf]);
        realdata=a';
        b=fscanf(fid2,'%f %f %f %f',[4 inf]);
        syntdata=b';

maxmin_onedataindex=findlimits4plot(realdata);    %%% find data limits for plotting  ... June 2010 
        
fclose(fid1);
fclose(fid2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% go back to isola

cd ..

catch
        helpdlg('Error in file plotting. Check if all files exist');
    cd ..
end

% whos realdata
% realdata(1:10,2)
%%%%%%%%%%%%%%%%%%% normalize 23/06/05
%% old type
% if normalized == 1
% 
%     disp('Normalized plot')
% 
%     for i=2:4
%         maxreal(i)=max(abs(realdata(:,i)));
%         maxsynt(i)=max(abs(syntdata(:,i)));
% 
%         realdata(:,i) = realdata(:,i)/max(abs(realdata(:,i)));
%         syntdata(:,i) = syntdata(:,i)/max(abs(syntdata(:,i)));
%     
%     end
%     
% else
% end
%%%%%%%%%%%%%%%%%%% normalize  realdata=zeros(8192,4); 
if normalized == 1
   disp('Normalized plot. Using normalization per component ')
        for j=2:4
             maxreal(j)=max(abs(realdata(:,j)));
             maxsynt(j)=max(abs(syntdata(:,j)));
        end
             [maxreal4sta,index_real]=max(maxreal); % maximum per station per component
             [maxsynt4sta,index_synt]=max(maxsynt); % maximum per station per component for synthetic data

        for j=2:4  
            
             realdata(:,j) = realdata(:,j)/maxreal4sta;
             
             if normsynth==1
                    syntdata(:,j) = syntdata(:,j)/maxsynt4sta;
             else
                    syntdata(:,j) = syntdata(:,j)/maxreal4sta;
             end
        end
        
else
end

%%%%%%%%%PLOTTING   
componentname=cellstr(['NS';'EW';'Z ']);


figure


for j=1:3                %%%%%%%%loop over components
         
          subplot(3,1,j);
          plot(realdata(:,1),realdata(:,j+1),'k', 'LineWidth', 1.5);
          hold on
%%%%%%%           h = vline(50,'k');
          plot(syntdata(:,1),syntdata(:,j+1),'r', 'LineWidth', 1.5);
          hold off
%           legend('Real','Synthetic',1); 
          ylabel('Displacement (m)','FontSize',11)
        
          if  j==1 
          title(stationname,...
              'FontSize',12,...
              'FontWeight','bold');
          legend('Real','Synthetic'); 
          end
          
          if  j==3 
          xlabel('Time (Sec)','FontSize',11)
          end
          
%           %%%% Normalized plotting
%           if normalized == 1
%           %      text( 10, 0.7, num2str(maxreal(j+1)));
%                % text( 10, 0.5, num2str(maxsynt(j+1)),'Color','r');
%                 v=axis
%                 axis([v(1) v(2) -1.0 1.0 ]) ;  
%                 legend('Real','Synthetic'); 
%           else
%                legend('Real','Synthetic'); 
%           end      
 
         %%%%%%%%%%%%%%%
     if uselimits == 1
              
              if normalized == 1
%                     axis ([ftime totime min(realdataall(:,j+1,i)) max(realdataall(:,j+1,i)) ]) ;   
                      axis ([ftime totime -1.0 1.0 ]) ;       
                      text( totime-10  ,  -0.7   , componentname{j},'FontSize',11,'FontWeight','bold');
                      
                      if index_real==(j+1)
                       text( totime+5, 0, num2str(maxreal(j+1),'%8.2e'),'FontSize',11,'FontWeight','bold');
                      else
                      end
                      
                      if normsynth==1
                          if index_synt==(j+1)
                              text( totime+5, -0.5, num2str(maxsynt(j+1),'%8.2e'),'Color','r','FontSize',11,'FontWeight','bold');
                          else
                          end
                      else
                      end
                      
              else
                      %%which is larger smaller..?? synth or real..!!
                         if min(realdata(:,j+1)) <= min(syntdata(:,j+1))
                             yli1=min(realdata(:,j+1));
                         else
                             yli1=min(syntdata(:,j+1));
                         end
                         
                         if max(realdata(:,j+1)) >= max(syntdata(:,j+1))
                             yli2=max(realdata(:,j+1));
                         else
                             yli2=max(syntdata(:,j+1));
                         end
%                          
                      axis([ftime totime maxmin_onedataindex(2) maxmin_onedataindex(1)]);
%                      axis ([ftime totime yli1 yli2 ])
 
                      text( totime-10  ,   yli1+(yli2/3)      , componentname{j},'FontSize',11,'FontWeight','bold');

              end
     else
              if normalized ==1 
                v=axis; 
                axis([v(1) v(2) -1.0 1.0 ]) ;  
                text( v(2)-10  ,  -0.7   , componentname{j},'FontSize',11,'FontWeight','bold');
                
                if index_real==(j+1)
                   text( v(2)+5   , 0, num2str(maxreal(j+1),'%8.2e'),'FontSize',11,'FontWeight','bold');
                else
                end
                  
                if normsynth==1
                    if index_synt==(j+1)
                        text( totime+5, -0.5, num2str(maxsynt(j+1),'%8.2e'),'Color','r','FontSize',11,'FontWeight','bold');
                    else
                    end
                else
                end
                
              else
                v=axis;
                text( max(realdata(:,1)) - (max(realdata(:,1))*0.05)   ,  min(realdata(:,j+1)) - (min(realdata(:,j+1))*0.5)   , componentname{j},'FontSize',11,'FontWeight','bold');
                axis([v(1) v(2) maxmin_onedataindex(2) maxmin_onedataindex(1)]);
              end
             
     end
         
     
             set(gca,'fontsize',11)
             set(gca,'linewidth',1.5)
     
     
end   %%% main loop over components

 
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
