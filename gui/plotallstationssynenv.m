function plotallstationssynenv(nostations,staname,uselimits,ftime,totime)
%%%%%prepare filenames  
%%% we keep fixed that data will be e.g. evrfil.dat
%%% and synthetics will be               evrsyn.dat

for i=1:nostations
    syntdatafilename{i}=[staname{i} 'syn.dat'];
end

syntdatafilename=syntdatafilename';

% whos staname syntdatafilename
        
%%%%%%%%%NOW WE KNOW FILENAMES AND WE CAN PLOT .....
%%%%%%%%%go in invert first
try
    
  cd env_amp_inv
%%%%%%%%%%%initialize data matrices
syntdataall=zeros(8192,4); 
maxmindataindex=zeros(1,2,nostations);

%%%%open data files and read data
for i=1:nostations
    
fid2  = fopen(syntdatafilename{i},'r');
        b=fscanf(fid2,'%f %f %f %f',[4 inf]);
        syntdata=b';
fclose(fid2);

syntdataall=cat(3,syntdataall,syntdata);
end

     %%%% return to isola
     cd ..
catch
    cd ..
end

syntdataall=syntdataall(:,:,2:nostations+1);
% 
for i=1:nostations
  maxmindataindex(:,:,i)=findlimits4plot(syntdataall(:,:,i)); 
end

componentname=cellstr(['NS';'EW';'Z ']);

%%%%%%%%%PLOTTING   
scrsz = get(0,'ScreenSize');
figure('Position',[100 100 scrsz(3)-200 scrsz(4)-200])
          
          subplot(nostations+1,3,1);
          axis off
          
          subplot(nostations+1,3,2);
          plot(syntdataall(:,1,1),syntdataall(:,2,1)-0.0003,'Visible','off')
                         title('Synthetic data displacement (m)','FontSize',12,'FontWeight','bold')
          axis off
          
          subplot(nostations+1,3,3);
          axis off

k=0;
for i=1:nostations    %%%%%%loop over stations

    for j=1:3                %%%%%%%%loop over components
          subplot(nostations+1,3,j+k+3);
          plot(syntdataall(:,1,i),syntdataall(:,j+1,i),'k','LineWidth',1);  
          % h = vline(50,'k');
          
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

