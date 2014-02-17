function out = rotA(ns,ew,rotA)

ew=ew+rotA;
ns=ns+rotA;
ew2=[ew 1];
ns2=[ns 1]; 

[a,b]=pol2cart(deg2rad(ns2(1)),ns2(2));
[c,d]=pol2cart(deg2rad(ew2(1)),ew2(2));

f=figure;
ha=axes;

h1=compass(ha,a,b,'r');
set(h1,'LineWidth',5);
hold;
h2=compass(ha,c,d,'b');
set(h2,'LineWidth',5);
hold off
set(gca,'View',[-90 90],'YDir','reverse');

editplot(f,ha)
drawnow

out=1;


function editplot(f,ha)

set(0,'ShowHiddenHandles','on');

%setting the position of compass to top right corner of figure
%set(ha,'Position',[0.75 0.75 0.20 0.20]);
%getting text handles
ht=findall(f,'Type','Text');

%finding the text that should be replaced by direction labels
ht1=findall(ht,'String','0');
ht2=findall(ht,'String','30');
ht3=findall(ht,'String','60');
ht4=findall(ht,'String','90');
ht5=findall(ht,'String','120');
ht6=findall(ht,'String','150');
ht7=findall(ht,'String','180');
ht8=findall(ht,'String','210');
ht9=findall(ht,'String','240');
ht10=findall(ht,'String','270');
ht11=findall(ht,'String','300');
ht12=findall(ht,'String','330');

set(ht,'String','');

%setting the direction labels
set(ht1,'String','0');
set(ht2,'String','30');
set(ht3,'String','60');
set(ht4,'String','90');
set(ht5,'String','120');
set(ht6,'String','150');
set(ht7,'String','180');
set(ht8,'String','210');
set(ht9,'String','240');
set(ht10,'String','270');
set(ht11,'String','300');
set(ht12,'String','330');
