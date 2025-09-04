function varargout = gtrack(newVarName,titleFmt)
% GTRACK Track mouse position and show coordinates in figure title.
% 
% 	GTRACK Activates GTRACK. Once it is active the mouse position is
% 	constantly tracked and printed on the figure title. A left-click will
% 	print the coordinates in the command line and store them. Clicking the
% 	mouse right button deactivates GTRACK.
% 
% USAGE
% 	gtrack() tracks the mouse and prints coordinates in the command line.
% 
% 	clickData = gtrack() will return the click positions in clickData using
% 	UIWAIT. Matlab will be in wait mode until the user finishes clicking.
% 
% 	gtrack('newVar') tracks the mouse and creates a new variable in the
% 	base workspace called 'newVar' with the click coordinates. This mode
% 	does not use UIWAIT.
%
%	gtrack([],titleFormat) uses titleFormat as the format string for
%	printing the mouse coordinates in the title.
%
%
% 2007 Jose F. Pina, Portugal
% http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=15099
% 
% REVISION 
%	23-05-2007	- created
%	30-05-2007	- fixed case matches, nested functions instead of globals,
%				  improved output modes
%	31-05-2007	- added option to choose coordinates format
%
% CREDITS
%	initial version - based on GTRACE
%	http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=3832&objectType=file
% 	Furi Andi Karnapi and Lee Kong Aik, DSP Lab, School of EEE, Nanyang Technological University
% 	Singapore, March 2002
%
%	improved version - thanks for the hints to John D'Errico
%   http://www.mathworks.com/matlabcentral/fileexchange/loadAuthor.do?objectType=author&objectId=801347


% default format for printing coordinates in title
if nargin<2,	titleFmt = '%13.5f';		end

% get current figure event functions
currFcn = get(gcf, 'windowbuttonmotionfcn');
currFcn2 = get(gcf, 'windowbuttondownfcn');
currTitle = get(get(gca, 'Title'), 'String');

% add data to figure handles
handles = guidata(gca);
if (isfield(handles,'ID') & handles.ID==1)
	disp('gtrack is already active.');
	return;
else
	handles.ID = 1;
end
handles.currFcn = currFcn;
handles.currFcn2 = currFcn2;
handles.currTitle = currTitle;
handles.theState = uisuspend(gcf);
guidata(gca, handles);

% set event functions 
set(gcf,'Pointer','crosshair');
set(gcf, 'windowbuttonmotionfcn', @gtrack_OnMouseMove);        
set(gcf, 'windowbuttondownfcn', @gtrack_OnMouseDown);          

% declare variables
xInd = 0;
yInd = 0;
clickData = [];	

% set output mode
if nargout,	
	uiMode = 'uiwait';		% use UIWAIT and return to clickData
	uiwait;
elseif nargin && isvarname(newVarName)	% dont'e use UIWAIT and assign in caller 
	uiMode = 'nowait';				% workspace to variable newVarName
else
	uiMode = 'noreturn';	% dont't use UIWAIT and don't return results (print only)
end


%% --- nested functions ---------------------------------------------------

%% mouse move callback
function gtrack_OnMouseMove(src,evnt)

% get mouse position
pt = get(gca, 'CurrentPoint');
xInd = pt(1, 1);
yInd = pt(1, 2);

% check if its within axes limits
xLim = get(gca, 'XLim');	
yLim = get(gca, 'YLim');
if xInd < xLim(1) | xInd > xLim(2)
	title('Out of X limit');	
	return;
end
if yInd < yLim(1) | yInd > yLim(2)
	title('Out of Y limit');
	return;
end

% update figure title
try
    [xInd,yInd] =m_xy2ll(xInd,yInd);
    
	title(['X = ' num2str(xInd,titleFmt) ', Y = ' num2str(yInd,titleFmt)]);

    % possibility of wrong format strings...
catch
	gtrack_Off()
	error('GTRACK: Error printing coordinates. Check that you used a valid format string.')
end

end


%% mouse click callback
function gtrack_OnMouseDown(src,evnt)

% if left button, terminate
if strcmp(get(gcf,'SelectionType'),'alt')
	gtrack_Off
	return
end

% else add click to clickData
  %  [xInd,yInd] =m_xy2ll(xInd,yInd);

clickData(end+1).x = xInd;
clickData(end).y = yInd;

fprintf('X = %f   Y = %f\n',xInd,yInd);

end


%% terminate callback
function gtrack_Off(src,evnt)

% restore default figure properties
handles = guidata(gca);
set(gcf, 'windowbuttonmotionfcn', handles.currFcn);
set(gcf, 'windowbuttondownfcn', handles.currFcn2);
set(gcf,'Pointer','arrow');
title(handles.currTitle);
uirestore(handles.theState);
handles.ID=0;
guidata(gca,handles);

% if there are outputs to assign do so
switch uiMode
	case 'uiwait'	% data return as output argument (clickData)
		varargout{1} = clickData;
		uiresume,
	case 'nowait'	% data assigned in base workspace as new variable
		assignin('base',newVarName,clickData);
		fprintf('Variable %s assigned with click data.\n',newVarName);
	case 'noreturn'
					% nothing to return
end

end

%% --- end nested functions -----------------------------------------------

end % end everything