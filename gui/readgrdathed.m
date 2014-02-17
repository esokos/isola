function [nc,nfreq,tl,aw,nr,ns,xl,ikmax,uconv,fref]=readgrdathed(file)

 fid  = fopen(file,'r');
     linetmp=fgetl(fid);               %01 line
  
     linetmp=fgetl(fid);          
     nc=sscanf(linetmp,'nc=%u',1);      %02 line
     
     linetmp=fgetl(fid);              %01 line
     nfreq=sscanf(linetmp,'nfreq=%u',1);       %02 line
     
     linetmp=fgetl(fid);              %01 line
     tl=sscanf(linetmp,'tl=%f',1);       %02 line
     
     linetmp=fgetl(fid);              %01 line
     aw=sscanf(linetmp,'aw=%f',1);       %02 line     
     
     linetmp=fgetl(fid);              %01 line
     nr=sscanf(linetmp,'nr=%u',1);       %02 line         
     
     linetmp=fgetl(fid);              %01 line
     ns=sscanf(linetmp,'ns=%u',1);       %02 line          
     
     linetmp=fgetl(fid);              %01 line
     xl=sscanf(linetmp,'xl=%f',1);       %02 line      
     
     linetmp=fgetl(fid);              %01 line
     ikmax=sscanf(linetmp,'ikmax=%u',1);       %02 line           
     
     linetmp=fgetl(fid);              %01 line
     uconv=sscanf(linetmp,'uconv=%e',1);       %02 line   
     
     linetmp=fgetl(fid);              %01 line
     fref=sscanf(linetmp,'fref=%f',1);       %02 line         
     
     fclose(fid);
     
     
     
     
     