function ok = pl3d(file1,file2)
close all

% read fcenters.dat
load(file1)

x=fcenters(:,2);
y=fcenters(:,1);
z=fcenters(:,3);

plot3(x,y,-z,'o')
grid on;axis square;xlabel('Easting (km)');ylabel('Northing (km)')
rotate3d on
hold
% plot the origin as star
 plot3(-3,-3,-1,'d','MarkerSize',10,'MarkerFaceColor','g')
%plot3(-5,-5,-5,'d','MarkerSize',10,'MarkerFaceColor','g')

%% plot the rectangles in 3D
   fid = fopen(file2);
     
     tline = fgets(fid);
      % get the Z value
      idx = strfind(tline, 'Z');

      rect_idx=1;
      zvalue(rect_idx)=str2double(tline(idx+1:end));
      
    while ischar(tline)
              A=fscanf(fid,'%f %f %f',[3,inf]);
              AA(:,:,rect_idx)=A';

              rect_idx=rect_idx+1;
        
        tline = fgets(fid);
        idx = strfind(tline, 'Z');zvalue(rect_idx)=str2double(tline(idx+1:end));
    end

   fclose(fid);


   %% plot
   %      AA(:,:,4);
        colorvalue=zvalue(1:end-1);
        nrect=length(colorvalue);
       
         
        
        for ii=1:nrect
           zz=AA(:,3,ii);
           fill3(AA(:,2,ii),AA(:,1,ii),-zz,colorvalue(ii),'EdgeColor',[0,0,0],'LineWidth',1)
            
        end
     axis equal 
colorbar   
   ok=1;
   
   
