function [hrv,TrialSource] = readinv3sub(subno)
%fix(subno)
%SUB_TABLE=readtable('.\invert\inv3.dat','Delimiter',' ','FileType','text','MultipleDelimsAsOne',1,'HeaderLines',0); 
%SUB_TABLE=readtable('.\invert\inv3.dat','Delimiter'," ",'LeadingDelimitersRule','ignore','FileType','delimitedtext','HeaderLines',0,'ConsecutiveDelimitersRule','join');

fid=fopen('.\invert\inv3.dat'); C=textscan(fid,'%f %f %f %f %f %f %f %f'); fclose(fid);

SUB_TABLE = array2table(cell2mat(C));

SUB_TABLE.Properties.VariableNames =["Var1", "Time_dt","Var3","Var4","Var5","Var6","Var7","Var8"];

sel_sub=SUB_TABLE(subno,:);

tmpA=sel_sub(:,3:end);

hrv(1)=tmpA.Var3;
hrv(2)=tmpA.Var4;
hrv(3)=tmpA.Var5;
hrv(4)=tmpA.Var6;
hrv(5)=tmpA.Var7;
hrv(6)=tmpA.Var8;

TrialSource=sel_sub.Var1
 
end

