function plotonestationrealenv(stationname,uselimits,ftime,totime)

%%%%%prepare filenames  
%%% we keep fixed that data will be e.g. evrfil.dat
%%% and synthetics will be               evrsyn.dat

realdatafilename=[stationname 'fil.dat'];
%%%%%%%%%%%initialize data matrices
realdata=zeros(8192,4);   

%%%go in invert
 cd env_amp_inv

%%%%open data files and read data
fid1  = fopen(realdatafilename,'r');
        a=fscanf(fid1,'%f %f %f %f',[4 inf]);
        realdata=a';
fclose(fid1);

maxmin_onedataindex=findlimits4plot(realdata); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% go back to isola
cd ..
componentname=cellstr(['NS';'EW';'Z ']);
%%%%%%%%%PLOTTING   
figure

     for j=1:3                %%%%%%%%loop over components
         
          subplot(3,1,j);
          plot(realdata(:,1),realdata(:,j+1));
%           legend('Real Data',1); 
%%%%%          h = vline(50,'k');
          if  j==1 
          title(stationname,...
              'FontSize',12,...
              'FontWeight','bold');
          end
          if  j==3 
          xlabel('Time (s)')
          ylabel('Displacement (m)')
          end
          
          if uselimits == 1
	        axis ([ftime totime maxmin_onedataindex(2) maxmin_onedataindex(1) ]);
               
          else
   	        v=axis; 
	        axis ([v(1) v(2) maxmin_onedataindex(2) maxmin_onedataindex(1) ]);
          end

     end
    
     
     
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


