function gap = findgap

[C,~]=readstationfile;
all_azim=sort(C{4},'descend');
difazm=abs(diff(all_azim));

lastfirst=all_azim(end)-all_azim(1);

if lastfirst < 0
    lastfirst = 360 + lastfirst;
end
    
    
difazmTotal=[difazm ;lastfirst];


gap=max(difazmTotal);