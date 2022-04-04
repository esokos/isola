function plotallstationsRealenv(nostations,staname,uselimits,ftime,totime)
%%%%%prepare filenames  
%%% we keep fixed that data will be e.g. evrfil.dat
%%% and synthetics will be               evrsyn.dat

for i=1:nostations
    realdatafilename{i}=[staname{i} 'fil.dat'];
end

realdatafilename=realdatafilename';
    
%%%%%%%%%NOW WE KNOW FILENAMES AND WE CAN PLOT .....
 
try
  cd env_amp_inv

%%%%%%%%%%%initialize data matrices
realdataall=zeros(8192,4);    %%%% 8192 points  fixed....
maxmindataindex=zeros(1,2,nostations);

%%%%open data files and read data
for i=1:nostations
    
fid1  = fopen(realdatafilename{i},'r');
        a=fscanf(fid1,'%f %f %f %f',[4 inf]);
        realdata=a';
fclose(fid1);

realdataall=cat(3,realdataall,realdata);
end

%%%%%%%%%go back to isola
 cd ..
 
catch
    cd ..
end

realdataall=realdataall(:,:,2:nostations+1);

for i=1:nostations
  maxmindataindex(:,:,i)=findlimits4plot(realdataall(:,:,i));
end

componentname=cellstr(['NS';'EW';'Z ']);

%%%%%%%%%PLOTTING   
scrsz = get(0,'ScreenSize');
figure('Position',[100 100 scrsz(3)-200 scrsz(4)-200])

%% Ploting
subplot1(nostations+1,3)  % initialize all plots
%          subplot(nostations+1,3,1);
subplot1(1) 
          axis off
%          subplot(nostations+1,3,2);
subplot1(2) 
           plot(realdataall(:,1,1),realdataall(:,2,1),'Visible','off')
                         title('Real data displacement (m)','FontSize',12,'FontWeight','bold')
          axis off
%          subplot(nostations+1,3,3);
subplot1(3) 
          axis off
          
%%          
k=0;
for i=1:nostations    %%%%%%loop over stations
%    realdataall    8192x4x6 
     for j=1:3   %%%%%%%%loop over components
          %subplot(nostations+1,3,j+k+3);
          subplot1(j+k+3);
          
          plot(realdataall(:,1,i),realdataall(:,j+1,i),'k','LineWidth',1);   
          %%%%%  h = vline(50,'k');
          v=axis;
          axis([v(1) v(2) maxmindataindex(1,2,i) maxmindataindex(1,1,i)]);
      
          if i==1
            title(componentname{j},'FontSize',12,'FontWeight','bold');
          end
          if i==nostations
            xlabel('Time (s)')
          end
          if  j==1 
            ylabel(staname{i},'FontSize',12,'FontWeight','bold');
          end
          
                if uselimits == 1
                    axis ([ftime totime maxmindataindex(1,2,i) maxmindataindex(1,1,i) ])
                else
                end
     end
    
     k=k+3;
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
