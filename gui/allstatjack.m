function [a]=allstatjack(nstations,njack)

table=ones(nstations*3,1);

indx=randsample(1:nstations*3,njack);

table(indx)=0;
a=reshape(table,nstations,3);
