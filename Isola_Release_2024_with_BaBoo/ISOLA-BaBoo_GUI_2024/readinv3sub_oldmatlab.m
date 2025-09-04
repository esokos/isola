function [hrv,TrialSource] = readinv3sub(subno)
%fix(subno)
SUB_TABLE=readtable('.\invert\inv3.dat','Delimiter',' ','FileType','text','MultipleDelimsAsOne',1,'HeaderLines',0); 
sel_sub=SUB_TABLE(subno,:);

tmpA=sel_sub(:,3:end);

hrv(1)=tmpA.Var3;
hrv(2)=tmpA.Var4;
hrv(3)=tmpA.Var5;
hrv(4)=tmpA.Var6;
hrv(5)=tmpA.Var7;
hrv(6)=tmpA.Var8;

TrialSource=sel_sub.Var1;
 
end

