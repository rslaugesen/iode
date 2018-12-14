function varargout = ppaux(varargin)
% function varargout = ppaux(varargin)
%
% (c) 2002, Peter Brinkmann (brinkman@math.uiuc.edu)
%
% Auxiliary GUI for plotting coordinate functions from ppgui.
%
% ppaux Application M-file for ppaux.fig
%    fig = ppaux launch ppaux GUI.
%    ppaux('callback_name', ...) invoke the named callback.

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (http://www.gnu.org/copyleft/gpl.html).

% Last Modified by GUIDE v2.5 12-Feb-2010 13:55:19

if nargin == 0  % LAUNCH GUI

	ax=gca;		% remember current axes

	fig = openfig(mfilename,'new');

	% Use system color scheme for figure:
	set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

	% Disable TeX for labels (because TeX doesn't handle expressions like
	% '2^sin(x)' correctly)
	set(fig,'DefaultTextCreateFcn','set(gcbo,''Interpreter'',''none'')');

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);

	axes(ax);	% return to previous axes setting

	if nargout > 0
		varargout{1} = fig;
	end

elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

	try
		[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
	catch
		disp(lasterr);
	end

end


%| ABOUT CALLBACKS:
%| GUIDE automatically appends subfunction prototypes to this file, and 
%| sets objects' callback properties to call them through the FEVAL 
%| switchyard above. This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, EVENTDATA, HANDLES, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the 
%| callback type separated by '_', e.g. 'slider2_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.slider2. This
%| structure is created at GUI startup using GUIHANDLES and stored in
%| the figure's application data using GUIDATA. A copy of the structure
%| is passed to each callback.  You can store additional information in
%| this structure at GUI startup, and you can change the structure
%| during callbacks.  Call guidata(h, handles) after changing your
%| copy to replace the stored original so that subsequent callbacks see
%| the updates. Type "help guihandles" and "help guidata" for more
%| information.
%|
%| VARARGIN contains any extra arguments you have passed to the
%| callback. Specify the extra arguments by editing the callback
%| property in the inspector. By default, GUIDE sets the property to:
%| <MFILENAME>('<SUBFUNCTION_NAME>', gcbo, [], guidata(gcbo))
%| Add any extra arguments after the last argument, before the final
%| closing parenthesis.



% --------------------------------------------------------------------
function varargout = printmenu_Callback(h, eventdata, handles, varargin)
	try
		printdlg('-crossplatform',handles.main);
	catch
		errordlg(lasterr);
	end


% --------------------------------------------------------------------
function varargout = printpreviewmenu_Callback(h, eventdata, handles, varargin)
% ... calls print preview
	try
		printpreview(handles.main);
	catch
		modalerrordlg(lasterr);
	end


% --------------------------------------------------------------------
function init(h,lims,tlab,xlab,ylab,ttl)
	try
		handles=guidata(h);

		ax=gca;					% remember current axes

		axes(handles.tx);		% prepare axes in this window
		fixaxes([0 1 lims(1:2)]);
		grid on;
		axis 'auto x'
		xlabel(tlab);
		ylabel(xlab);
		title(['Plot of ' xlab ' vs. ' tlab ' for ' ttl]);

		axes(handles.ty);
		fixaxes([0 1 lims(3:4)]);
		grid on;
		axis 'auto x'
		xlabel(tlab);
		ylabel(ylab);
		title(['Plot of ' ylab ' vs. ' tlab ' for ' ttl]);

		axes(handles.txy);
		fixaxes([lims 0 1]);
		rotate3d on
		grid on;
		axis 'auto z'
		view(37.5,30);
		xlabel(xlab);
		ylabel(ylab);
		zlabel(tlab);
		title(['Plot of ' xlab ', ' ylab ' vs. ' tlab ' for ' ttl]);

		axes(ax);				% return to previous axes
	end


% --------------------------------------------------------------------
function plotcoords(h,t,xy,col)
	try
		handles=guidata(h);

		ax=gca;					% remember current axes

		axes(handles.tx);
		plot(t,xy(1,:),col);

		axes(handles.ty);
		plot(t,xy(2,:),col);

		axes(handles.txy);
		plot3(xy(1,:),xy(2,:),t,col);
		rotate3d on		% In theory, this line is redundant, but in practice
						% 3D plots won't rotate without it at the EWS labs...

		axes(ax);				% back to previous axes
	end
