function kmlStruct = kmz2struct(filename)
    [~,~,ext] = fileparts(filename);

    if strcmpi(ext,'.kmz')
        userDir = fullfile( ...
            char(java.lang.System.getProperty('user.home')), ...
            '.kml2struct');
        if ~exist(userDir,'dir')
            mkdir(userDir);
        end
        unzip(filename, userDir);

        files = dir(fullfile(userDir, '**', '*.kml'));
        N = length(files);
        kmlStructs = cell([1 N]);
        for i = 1:length(files)
            kmlStructs{i} = readKMLfile( ...
                fullfile(files(i).folder, files(i).name));
        end
        kmlStruct = vertcat(kmlStructs{:});

        rmdir(userDir,'s');
    else
        kmlStruct = readKMLfile(filename);
    end
end
function kmlStruct = readKMLfile(filename)
    xDoc = xmlread(filename);
    start =  xDoc.item(0).item(1);

    % Handle Styles :<
    Styles = start.getElementsByTagName('Style');
    stylehash = containers.Map('KeyType','char','ValueType','Any');
    for j = 0:Styles.getLength-1
        idxml = Styles.item(j).getAttributes.getNamedItem('id');
        if ~isempty(idxml)
            id = char(idxml.getTextContent);
            [pointcolor,linecolor,polycolor] = parseStyle(Styles.item(j));
            stylehash(id) = struct('pointcolor',pointcolor,'linecolor',linecolor,'polycolor',polycolor);
        end
    end
    StyleMaps = start.getElementsByTagName('StyleMap');
    for j = 0:StyleMaps.getLength-1
        id = char(StyleMaps.item(j).getAttributes.getNamedItem('id').getTextContent);
        keys = StyleMaps.item(j).getElementsByTagName('key');
        index = 0;
        for k = 0:keys.getLength-1
            found = strcmp(char(keys.item(k).getTextContent),'normal');
            if found; index = k; break; end
        end
        styleUrl = char(keys.item(index).getParentNode.getElementsByTagName('styleUrl').item(0).getTextContent);
        stylehash(id) = stylehash(styleUrl(2:end));
    end

    kmlStruct = recursive_kml2struct(start,'',stylehash);
end
function kmlStruct = recursive_kml2struct(folder_element,folder,stylehash)

    % Find number of placemarks and name of folder
    name = 'none';
    number_placemarks = 0;
    for i = 0:folder_element.getLength()-1
        if strcmp(folder_element.item(i).getNodeName,'Placemark')
            number_placemarks = number_placemarks + 1;
        elseif strcmp(folder_element.item(i).getNodeName,'name')
            name = char(folder_element.item(i).getTextContent);
        end
    end
    if strcmpi(folder_element.getNodeName,'Folder')
        folder = [folder '/' name];
    end

    % Find Placemark Data
    count = 1;
    kmlStructs = cell([1 number_placemarks]);
    for i = 0:folder_element.getLength()-1
        current = folder_element.item(i);
        NodeName = current.getNodeName;
        if strcmpi(NodeName,'Folder')
            kmlStructs{count} = recursive_kml2struct(current,folder,stylehash);
            count = count + 1;
        elseif strcmpi(NodeName,'Placemark')
            kmlStructs{count} = parsePlacemark(current,folder,stylehash);
            count = count + 1;
        end
    end
    kmlStruct = horzcat(kmlStructs{:});
end
function kmlStruct = parsePlacemark(element,folder,stylehash)
    namexml = element.getElementsByTagName('name').item(0);
    if ~isempty(namexml)
        name = char(namexml.getTextContent);
    else
        name = 'Unknown';
    end
    if ~isempty(element.getElementsByTagName('description').item(0))
        description = char(element.getElementsByTagName('description').item(0).getTextContent);
    end

    % Try to find Style
    styleUrl = element.getElementsByTagName('styleUrl').item(0);
    if ~isempty(styleUrl)
        id = char(styleUrl.getTextContent);
        s = stylehash(id(2:end));
        pointcolor = s.pointcolor;linecolor = s.linecolor;polycolor = s.polycolor;
    else
        [pointcolor,linecolor,polycolor] = parseStyle(element);
    end

    number_features = element.getElementsByTagName('coordinates').getLength();
    kmlStructs = cell([1 number_features]);
    count = 1;

    % Handle Points
    points = element.getElementsByTagName('Point');
    for i = 0:points.getLength()-1
        coords = char(points.item(i).getElementsByTagName('coordinates').item(0).getTextContent);
        [Lat,Lon] = parseCoordinates(coords);

        kmlStructs{count}.Geometry = 'Point';
        kmlStructs{count}.Name = name;
        if exist('description','var')
            kmlStructs{count}.Description = description;
        else
            kmlStructs{count}.Description = '';
        end
        kmlStructs{count}.Lon = Lon;
        kmlStructs{count}.Lat = Lat;
        kmlStructs{count}.BoundingBox = [min(Lon) min(Lat);max(Lon) max(Lat)];
        kmlStructs{count}.Folder = folder;
        kmlStructs{count}.Color = pointcolor;
        count = count + 1;
    end

    % Handle Polygons
    polygons = element.getElementsByTagName('Polygon');
    for i = 0:polygons.getLength()-1
        coords = char(polygons.item(i).getElementsByTagName('coordinates').item(0).getTextContent);
        [Lat,Lon] = parseCoordinates(coords);

        kmlStructs{count}.Geometry = 'Polygon';
        kmlStructs{count}.Name = name;
        if exist('description','var')
            kmlStructs{count}.Description = description;
        else
            kmlStructs{count}.Description = '';
        end
        kmlStructs{count}.Lon = [Lon;NaN]';
        kmlStructs{count}.Lat = [Lat;NaN]';
        kmlStructs{count}.BoundingBox = [min(Lon) min(Lat);max(Lon) max(Lat)];
        kmlStructs{count}.Folder = folder;
        kmlStructs{count}.Color = polycolor;
        count = count + 1;
    end

    % Handle Lines
    lines = element.getElementsByTagName('LineString');
    for i = 0:lines.getLength()-1
        coords = char(lines.item(i).getElementsByTagName('coordinates').item(0).getTextContent);
        [Lat,Lon] = parseCoordinates(coords);

        kmlStructs{count}.Geometry = 'Line';
        kmlStructs{count}.Name = name;
        if exist('description','var')
            kmlStructs{count}.Description = description;
        else
            kmlStructs{count}.Description = '';
        end
        kmlStructs{count}.Lon = Lon';
        kmlStructs{count}.Lat = Lat';
        kmlStructs{count}.BoundingBox = [min(Lon) min(Lat);max(Lon) max(Lat)];
        kmlStructs{count}.Folder = folder;
        kmlStructs{count}.Color = linecolor;
        count = count + 1;
    end

    % Compile answers
    kmlStruct = horzcat(kmlStructs{:});
end

function [Lat,Lon] = parseCoordinates(string)
    coords = str2double(regexp(string,'[,\s]+','split'));
    coords(isnan(coords)) = [];
    [m,n] = size(coords);
    if length(coords) == sum(string==',') * 2
        coords = reshape(coords,2,m*n/2)';
    else
        coords = reshape(coords,3,m*n/3)';
    end
    if license('test', 'map_toolbox')
        [Lat, Lon] = poly2ccw(coords(:,2),coords(:,1));
    else
        Lat=coords(:,2);
        Lon=coords(:,1);
    end
end
function [pointcolor,linecolor,polycolor] = parseStyle(element)
    % Try to find Style
    try
        pointcolorhex = char(element.getElementsByTagName('IconStyle').item(0).getElementsByTagName('color').item(0).getTextContent);
        pointcolor = hex2rgb_kmlwrapper(pointcolorhex);
    catch
        pointcolor = [0.6758    0.8438    0.8984];
    end
    try
        linecolorhex = char(element.getElementsByTagName('LineStyle').item(0).getElementsByTagName('color').item(0).getTextContent);
        linecolor = hex2rgb_kmlwrapper(linecolorhex);
    catch
        linecolor = [0.6758    0.8438    0.8984];
    end
    try
        polycolorhex = char(element.getElementsByTagName('PolyStyle').item(0).getElementsByTagName('color').item(0).getTextContent);
        polycolor = hex2rgb_kmlwrapper(polycolorhex);
    catch
        polycolor = [0.6758    0.8438    0.8984];
    end
end
function [ rgb] = hex2rgb_kmlwrapper(hex)
    rgb = hex2rgb(hex([7 8 5 6 3 4]));
end
function [ rgb ] = hex2rgb(hex,range)
% hex2rgb converts hex color values to rgb arrays on the range 0 to 1.
%
%
% * * * * * * * * * * * * * * * * * * * *
% SYNTAX:
% rgb = hex2rgb(hex) returns rgb color values in an n x 3 array. Values are
%                    scaled from 0 to 1 by default.
%
% rgb = hex2rgb(hex,256) returns RGB values scaled from 0 to 255.
%
%
% * * * * * * * * * * * * * * * * * * * *
% EXAMPLES:
%
% myrgbvalue = hex2rgb('#334D66')
%    = 0.2000    0.3020    0.4000
%
%
% myrgbvalue = hex2rgb('334D66')  % <-the # sign is optional
%    = 0.2000    0.3020    0.4000
%
%
% myRGBvalue = hex2rgb('#334D66',256)
%    = 51    77   102
%
%
% myhexvalues = ['#334D66';'#8099B3';'#CC9933';'#3333E6'];
% myrgbvalues = hex2rgb(myhexvalues)
%    =   0.2000    0.3020    0.4000
%        0.5020    0.6000    0.7020
%        0.8000    0.6000    0.2000
%        0.2000    0.2000    0.9020
%
%
% myhexvalues = ['#334D66';'#8099B3';'#CC9933';'#3333E6'];
% myRGBvalues = hex2rgb(myhexvalues,256)
%    =   51    77   102
%       128   153   179
%       204   153    51
%        51    51   230
%
% HexValsAsACharacterArray = {'#334D66';'#8099B3';'#CC9933';'#3333E6'};
% rgbvals = hex2rgb(HexValsAsACharacterArray)
%
% * * * * * * * * * * * * * * * * * * * *
% Chad A. Greene, April 2014
%
% Updated August 2014: Functionality remains exactly the same, but it's a
% little more efficient and more robust. Thanks to Stephen Cobeldick for
% the improvement tips. In this update, the documentation now shows that
% the range may be set to 256. This is more intuitive than the previous
% style, which scaled values from 0 to 255 with range set to 255.  Now you
% can enter 256 or 255 for the range, and the answer will be the same--rgb
% values scaled from 0 to 255. Function now also accepts character arrays
% as input.
%
% * * * * * * * * * * * * * * * * * * * *
% See also rgb2hex, dec2hex, hex2num, and ColorSpec.
%
% Copyright (c) 2014, Chad Greene
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
%
% * Redistributions of source code must retain the above copyright notice, this
%   list of conditions and the following disclaimer.
%
% * Redistributions in binary form must reproduce the above copyright notice,
%   this list of conditions and the following disclaimer in the documentation
%   and/or other materials provided with the distribution
% * Neither the name of The University of Texas at Austin nor the names of its
%   contributors may be used to endorse or promote products derived from this
%   software without specific prior written permission.
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
% Input checks:
assert(nargin>0&nargin<3,'hex2rgb function must have one or two inputs.')
if nargin==2
    assert(isscalar(range)==1,'Range must be a scalar, either "1" to scale from 0 to 1 or "256" to scale from 0 to 255.')
end%% Tweak inputs if necessary:
if iscell(hex)
    assert(isvector(hex)==1,'Unexpected dimensions of input hex values.')

    % In case cell array elements are separated by a comma instead of a
    % semicolon, reshape hex:
    if isrow(hex)
        hex = hex';
    end

    % If input is cell, convert to matrix:
    hex = cell2mat(hex);
end
if strcmpi(hex(1,1),'#')
    hex(:,1) = [];
end
if nargin == 1
    range = 1;
end
% Convert from hex to rgb:
switch range
    case 1
        rgb = reshape(sscanf(hex.','%2x'),3,[]).'/255;
    case {255,256}
        rgb = reshape(sscanf(hex.','%2x'),3,[]).';

    otherwise
        error('Range must be either "1" to scale from 0 to 1 or "256" to scale from 0 to 255.')
end
end
