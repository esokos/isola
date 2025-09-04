function [] = Stereonet(trdv,plgv,intrad,sttype)
%Stereonet plots an equal angle or equal area stereonet of unit radius
%in any view direction
%
%   USE: Stereonet(trdv,plgv,intrad,stttype)
%
%   trdv = trend of view direction
%   plgv = plunge of view direction
%   intrad = interval in radians between great or small circles 
%   sttype = An integer indicating the type of stereonet. 0 for equal angle,
%            and 1 for equal area
%
%   NOTE: All angles should be entered in radians
%
%   Example: To plot an equal area stereonet at 10 deg intervals in a
%   default view direction type:
%
%   Stereonet(0,90*pi/180,10*pi/180,1);
%
%   To plot the same stereonet but with a view direction of say: 235/42,
%   type:
%
%   Stereonet(235*pi/180,42*pi/180,10*pi/180,1);
%
%   Stereonet uses functions Pole, GeogrToView, SmallCircle and GreatCircle
%
%MATLAB script written by Nestor Cardozo for the book Structural 
%Geology Algorithms by Allmendinger, Cardozo, & Fisher, 2011. If you use
%this script, please cite this as "Cardozo in Allmendinger et al. (2011)"

% Some constants
east = pi/2.0;
west = 3.0*east;

% Plot stereonet reference circle
r = 1.0; % radius of stereonet
TH = (0:1:360)*pi/180; % polar angle, range 2 pi, 1 degree increment
[X,Y] = pol2cart(TH,r); % cartesian coordinates of reference circle
plot(X,Y,'k'); % plot reference circle
axis ([-1 1 -1 1]); % size of stereonet
axis equal; axis off; % equal axes, no axes
hold on; % hold plot

% Number of small circles
nCircles = pi/(intrad*2.0);

% Small circles
% Start at the North
trd = 0.0;
plg = 0.0;
% If view direction is not the default (trd=0,plg=90), transform line to
% view direction
if trdv ~= 0.0 || plgv ~= east
    [trd,plg] = GeogrToView(trd,plg,trdv,plgv);
end
% Plot small circles
for i=1:nCircles
    coneAngle = i*intrad;
    [path1,path2,np1,np2] = SmallCircle(trd,plg,coneAngle,sttype);
  %  plot(path1(1:np1,1),path1(1:np1,2),'b');
   % if np2 > 0
   %     plot(path2(1:np2,1),path2(1:np2,2),'b');
   % end
end

% Great circles
for i=0:nCircles*2
    %Western half
    if i <= nCircles
        % Pole of great circle
        trd = west;
        plg = i*intrad;
    %Eastern half
    else
        % Pole of great circle
        trd = east;
        plg = (i-nCircles)*intrad;
    end
    % If pole is vertical, shift it a little bit
    if plg == east
        plg = plg * 0.9999;
    end
    % If view direction is not the default (trd=0,plg=90), transform line to
    % view direction
    if trdv ~= 0.0 || plgv ~= east
        [trd,plg] = GeogrToView(trd,plg,trdv,plgv);
    end
    % Compute plane from pole
    [strike,dip] = Pole(trd,plg,0);
    % Plot great circle
    path = GreatCircle(strike,dip,sttype);
 %   plot(path(:,1),path(:,2),'b');
end

hold off; %release plot

end