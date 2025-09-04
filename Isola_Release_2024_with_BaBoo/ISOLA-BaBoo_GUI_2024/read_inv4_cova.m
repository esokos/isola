function [sum_of_res2,sum_of_dat2,varred,datavar,no_of_data,no_of_param,no_of_DOF,misfit] = read_inv4_cova(filename)

          fid = fopen(filename);
            linetmp1=fgetl(fid);         %01 line
            linetmp2=fgetl(fid);         %01 line
              A=sscanf(linetmp1,'%e %e  %e  %e  %f');
              sum_of_res2=A(1);
              sum_of_dat2=A(2);
              varred=A(3);
              datavar=A(4);
              no_of_data=A(5);
              A=sscanf(linetmp2,'%f %f');
              no_of_param=A(1);
              no_of_DOF=A(2);
              misfit=A(3); 
          fclose(fid);