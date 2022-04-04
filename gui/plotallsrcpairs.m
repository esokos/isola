function ok = plotallsrcpairs

% it will read all pairs from sel_pairs.dat
% then it will call get_src_pair

fid = fopen('.\timefunc\sel_pairs.dat');
C = textscan(fid, '%f %f %f %f %f %f %f');
fclose(fid);

source1=C{1,1};source2=C{1,2};

% now call  get_src_pair
 figure
 hold
    for ii=1:length(source1)
        
        disp(['Plotting pair ' num2str(source1(ii)) '  '  num2str(source2(ii))])
        
          [x1,y1,x2,y2] = get_src_pair2(source1(ii),source2(ii));
        
%% plot
                    %        plot(x1,y1,'b')
                     %       plot(x2,y2,'g')
                            plot(x2,y1+y2,'r')      
        
    end

ok=1;