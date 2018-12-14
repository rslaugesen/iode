function varargout = iodegui(varargin)
% function varargout = iodegui(varargin)
%
% (c) 2002, Peter Brinkmann (brinkman@math.uiuc.edu)
%
% iodegui Application M-file for iodegui.fig
%    fig = iodegui launch iodegui GUI.
%    iodegui('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 18-Jan-2003 00:51:17

if nargin == 0  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');
	startup;

	% Use system color scheme for figure:
	set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

	% Disable TeX for labels (because TeX doesn't handle expressions like
	% '2^sin(x)' correctly)
	set(fig,'DefaultTextCreateFcn','set(gcbo,''Interpreter'',''none'')');

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);

	handles.vars.allguis=[];

	guidata(fig,handles);

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
function varargout = dfbutton_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.dfbutton.
	handles.vars.allguis=[handles.vars.allguis,dfgui];
		% open new window and append its handle
		% to the list of dependent windows
	guidata(h,handles);


% --------------------------------------------------------------------
function varargout = ppbutton_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.ppbutton.
	handles.vars.allguis=[handles.vars.allguis,ppgui];
	guidata(h,handles);


% --------------------------------------------------------------------
function varargout = mvbutton_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.pushbutton3.
	handles.vars.allguis=[handles.vars.allguis,mvgui];
	guidata(h,handles);


% --------------------------------------------------------------------
function varargout = fsbutton_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.fsbutton.
	handles.vars.allguis=[handles.vars.allguis,fsgui];
	guidata(h,handles);


% --------------------------------------------------------------------
function varargout = pdebutton_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.pdebutton.
	handles.vars.allguis=[handles.vars.allguis,pdegui];
	guidata(h,handles);


% --------------------------------------------------------------------
function varargout = main_CloseRequestFcn(h, eventdata, handles, varargin)
% Stub for CloseRequestFcn of the figure handles.main.
	flag=0;
	for i=1:length(handles.vars.allguis)
		try
			dummy=guihandles(handles.vars.allguis(i));
				% this will cause an error if handles.vars.allguis(i)
				% has been closed
			flag=1; % raise flag if there is an open dependent window
		end
	end

	if flag
		inp=questdlg(...
			{'Closing the main window will close all Iode windows.',...
			'Do you wish to proceed?'},'Exit dialog',...
			'Yes','No','No');
		if strcmp(inp,'Yes')
			delete(handles.main);
		end
	else
		delete(handles.main);
	end


function varargout = closewindow(h,eventdata,handles,varargin);
% ... DeleteFcn of handles.main
	for i=1:length(handles.vars.allguis)
		try
			delete(handles.vars.allguis(i));
		end
	end
	delete(handles.main);			% close main window

