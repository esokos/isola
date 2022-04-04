function ok = htmlexport(evt_id,origin,lat,lon,depth,mw,Mo)

folder=evt_id;

filename=[evt_id '_MTsol.html'];

inv1=[evt_id '_inv1.png'];best=[evt_id '_best.png'];corr=[evt_id '_corr01.png'];wave=[evt_id '_wave.png'];

evt_title=['Moment Tensor Solution for EventID' evt_id]; 

%% prepare a html file
fid=fopen(filename,'w');

fprintf(fid,'%s\r\n', ['<HTML><HEAD><BASE TARGET="blank"><title>' evt_title  '</title></HEAD><BODY BGCOLOR="#FFFFFF"><left><table border="0" width="100%" bgcolor="#FF2F2F" bordercolor="#FFFFFF" bordercolorlight="#FFFFFF" bordercolordark="#FFFFFF" height="22"><tr><td width="100%" height="16" align="left"><strong><font color="#FFFFFF">' evt_title '</font></strong></td></tr></table></center><div align="left"><table border="0" width="100%">']); 
fprintf(fid,'%s\r\n', '<tr>');

fprintf(fid,'%s\r\n', '<td width="20%" bgcolor="#008080"><p align="center">');
fprintf(fid,'%s\r\n', ['<a href=' ''''  inv1 '''' '><img src= ' ''''  inv1 '''' 'alt=''Inversion Results -Click for a larger version'' height=''145'' width=''145'' ><font color="#FFFFFF"><br><small>Inversion Results</font></small></a></font></td> ']);
fprintf(fid,'%s\r\n','<td width="20%" bgcolor="#008080"><p align="center">');
    
fprintf(fid,'%s\r\n', ['<a href=' ''''  corr '''' '><img src= ' '''' corr '''' 'alt=''Correlation Results - Click for a larger version'' height=''145'' width=''145''><font color="#FFFFFF"><br><small>Correlation Results</font></small></a></font></td>']);
fprintf(fid,'%s\r\n','<td width="20%" bgcolor="#008080"><p align="center">');

fprintf(fid,'%s\r\n', ['<a href=' ''''  wave '''' '><img src=' ''''  wave  '''' 'alt=''Fit Results - Click for a larger version'' height=''145'' width=''145''><font color="#FFFFFF"><br><small>Fit Results</font></small></a></font></td>']);
fprintf(fid,'%s\r\n','<td width="40%" bgcolor="#008080"><div align="left"><table border="0" width="100%" height="170">');

fprintf(fid,'%s\r\n','<tr>');
fprintf(fid,'%s\r\n',['<td width="100%" height="19"><strong><font color="#FFFFFF">Centroid Time: </strong>&nbsp ' origin ' &nbsp (GMT)</font> </td>']);
fprintf(fid,'%s\r\n','</tr>');

fprintf(fid,'%s\r\n','<tr>');
fprintf(fid,'%s\r\n',['<td width="100%" height="19"><strong><font color="#FFFFFF">Centroid Latitude:</strong>&nbsp ' lat ' </font> </td>']);
fprintf(fid,'%s\r\n','</tr>');

fprintf(fid,'%s\r\n','<tr>');
fprintf(fid,'%s\r\n',['<td width="100%" height="19"><strong><font color="#FFFFFF">Centroid Longitude:</strong>&nbsp ' lon ' </font></td>']);
fprintf(fid,'%s\r\n','</tr>');

fprintf(fid,'%s\r\n','<tr>');
fprintf(fid,'%s\r\n',['<td width="100%" height="19"><strong><font color="#FFFFFF">Centroid Depth:</strong>&nbsp ' depth ' Km</font></td>']);
fprintf(fid,'%s\r\n','</tr>');

fprintf(fid,'%s\r\n','<tr>');
fprintf(fid,'%s\r\n',['<td width="100%" height="19"><strong><font color="#FFFFFF">Mw:</strong>&nbsp ' mw '</font></td>']);
fprintf(fid,'%s\r\n','</tr>');

fprintf(fid,'%s\r\n','<tr>');
fprintf(fid,'%s\r\n',['<td width="100%" height="19"><strong><font color="#FFFFFF">Mo:</strong>&nbsp ' Mo ' Nm</font></td>']);
fprintf(fid,'%s\r\n','</tr>');

fprintf(fid,'%s\r\n','</table></div></td></tr></table></div><br>');
 
fprintf(fid,'%s\r\n',['<pre><img src=' ''''   best '''' 'width=''1024'' height=''768''></br>']);

fclose(fid);


%% output to table
%tablefilename=['MTsolTable.txt'];
%fid=fopen(tablefilename,'a');

%  fprintf(fid,'%s %s %s %s %s %s\r\n',origin,lat,lon,depth,mw,Mo)
 
%fclose(fid);

ok=1;
end

