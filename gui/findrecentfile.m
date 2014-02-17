function file=findrecentfile(filelist)
%format shortg
files=dir(filelist);

% length(files)

C = clock;
 

 for i=1:length(files)
     [Y(i), M(i), D(i), H(i), MN(i), S(i)] = datevec(files(i).datenum);
 
      e(i) = etime(C,[Y(i), M(i), D(i), H(i), MN(i), S(i)]);
 
 end


 
[C,I] = min(e);

file = files(I).name