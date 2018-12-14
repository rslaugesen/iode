function varargout = ppgui(varargin)
% function varargout = ppgui(varargin)
%
% (c) 2002, Peter Brinkmann (brinkman@math.uiuc.edu)
%
% ppgui: Graphical user interface for Iode's phase plane modules
%
% Usage:
%	fig = ppgui
%			 launch GUI.
%	ppgui('callback_name', ...)
%			 invoke the named callback.
%
% Many thanks to Richard Laugesen for valuable feedback and suggestions!

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (http://www.gnu.org/copyleft/gpl.html).

if nargin == 0  % LAUNCH GUI

	startup;

	fig = openfig(mfilename,'new');

	% Use system color scheme for figure:
	set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

	% Disable TeX for labels (because TeX doesn't handle expressions like
	% '2^sin(x)' correctly)
	set(fig,'DefaultTextCreateFcn','set(gcbo,''Interpreter'',''none'')');

	% The following strange line makes sure that clicks on line segments in
	% the plot will be received by the axes object
	set(fig,'DefaultLineCreateFcn','set(gcbo,''ButtondownFcn'',get(gca,''ButtonDownFcn''),''UIContextMenu'',get(gca,''UIContextMenu''))');

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);

	axes(handles.axes1); % Important: Send plots to axes object in figure.

	handles.id='ppgui 6.0';		% ID tag; should be updated whenever the
								% format of saved files changes

	handles.dir='';				% variables for remembering paths and files
	handles.filename='*.mat';

	handles.ppaux=[];			% handle to window for plotting coordinate
								% functions
	handles.lastpoint=[];

	% names and codes of solution methods
	handles.methods.names={'Euler','Runge-Kutta','Other','Exact'};
	handles.methods.codes={'euler','rk','',0};
	set(handles.methodmenu,'String',handles.methods.names);

	% names and codes of colors for plotting
	handles.colors.names={'Red','Green','Blue','Yellow',...
				'Black','Cyan','Magenta'};
	handles.colors.codes={'r','g','b','y','k','c','m'};
	set(handles.colormenu,'String',handles.colors.names);

	handles.vars=struct(...	% handles.vars contains mathematical data
		'tvar','t',...		% independent variable
		'xvar','x',...		% dependent variable (horizontal)
		'yvar','y',...		% dependent variable (vertical)
		'fs','-y',...		% first part of right-hand side of diffeq
		'gs','x',...		% second part of right-hand side of diffeq
		'xmin',-2,...
		'xmax',2,...
		'ymin',-2,...
		'ymax',2,...
		'tmin',0,...		% solutions are computed on [tmin,tmax],
		't0',0,...			% with initial value at t0
		'tmax',2*pi,...
		'xn',15,...			% number of arrows (horizontal)
		'yn',15,...			% number of arrows (vertical)
		'method','',...		% current method for plotting solutions
		'col','',...		% color for plotting
		'plots',[],...		% list of plots
		'ranges',[],...	% list of display parameters (for undoing zoom)
		'zoomx',2,...		% zoom factor (horizontal)
		'zoomy',2,...		% zoom factor (vertical)
		'ta0',0,...			% arbitrary functions are computed on [ta0,ta1]
		'ta1',2*pi,...
		'warn',1,...	% warning flag for exact solutions
		'methodindex',1,... % index of the current method in the pop-up menu
		'xfnct',['t*cos(t)/pi'],... % strings containing arbitrary
		'yfnct',['t*sin(t)/pi']);	% function

	choosedefaults(fig,[],handles);

	guidata(fig, handles);
	methodmenu_Callback(fig,[],handles); % initialize solution method
	handles=guidata(fig);				% update handles information
	colormenu_Callback(fig,[],handles);	% initialize color information
	handles=guidata(fig);
	setlimits(fig,[],handles,...
		handles.vars.xmin,handles.vars.xmax,...
		handles.vars.ymin,handles.vars.ymax,...
		handles.vars.xn,handles.vars.yn);		% initialize the plot
	handles=guidata(fig);

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
function varargout = axes1_ButtondownFcn(h, eventdata, handles, varargin)
% ... handles clicks on figure
	h=handles.axes1;
	if ~strcmp(get(gcf,'SelectionType'),'normal')	% left-click?
		return;
	end
	p=get(handles.axes1,'CurrentPoint');
	x0=p(1); % extract coordinates of click
	y0=p(3);

	xmin=handles.vars.xmin;
	xmax=handles.vars.xmax;
	ymin=handles.vars.ymin;
	ymax=handles.vars.ymax;

	cursor=swapcursor(handles.main,'crosshair');
	rbbox;	% allow user to drag mouse to choose box
	p=get(handles.axes1,'CurrentPoint'); % extract coordinates of
										 % mouse button release
	x1=p(1);
	y1=p(3);
	if abs(x0-x1)/(xmax-xmin)<0.02
		x1=x0;
	end
	if abs(y0-y1)/(ymax-ymin)<0.02
		y1=y0;
	end
	swapcursor(handles.main,'watch');
	try
		if strcmp(get(handles.plotonclick,'Checked'),'on') & (x0==x1) & (y0==y1)
			set(handles.x0txt,'String',num2str(x0)); % update x0
			set(handles.y0txt,'String',num2str(y0)); % update y0
			plotbutton_Callback(h,eventdata,handles,varargin); % plot solution
		elseif (x0~=x1) & (y0~=y1)
			setlimits(h,eventdata,handles,...
				min(x0,x1),max(x0,x1),...
				min(y0,y1),max(y0,y1),...
				handles.vars.xn,handles.vars.yn);
		elseif strcmp(get(handles.zoominonclick,'Checked'),'on')
			xs=(xmax-xmin)/2/handles.vars.zoomx; % 1/2 x-range of new limits
			ys=(ymax-ymin)/2/handles.vars.zoomy; % 1/2 y-range of new limits
			setlimits(h,eventdata,handles,x0-xs,x0+xs,y0-ys,y0+ys,...
				handles.vars.xn,handles.vars.yn);
		elseif strcmp(get(handles.zoomoutonclick,'Checked'),'on')
			xs=(xmax-xmin)/2*handles.vars.zoomx; % 1/2 x-range of new limits
			ys=(ymax-ymin)/2*handles.vars.zoomy; % 1/2 y-range of new limits
			setlimits(h,eventdata,handles,x0-xs,x0+xs,y0-ys,y0+ys,...
				handles.vars.xn,handles.vars.yn);
        elseif strcmp(get(handles.recenteronclick,'Checked'),'on')
			xs=(xmax-xmin)/2; % 1/2 x-range of new limits
			ys=(ymax-ymin)/2; % 1/2 y-range of new limits
			setlimits(h,eventdata,handles,x0-xs,x0+xs,y0-ys,y0+ys,...
				handles.vars.xn,handles.vars.yn);
		end
	catch
		modalerrordlg(lasterr);
	end
	swapcursor(handles.main,cursor); % back to the original mouse cursor


% --------------------------------------------------------------------
function varargout = unzoom(h, eventdata, handles, varargin)
% ... replaces current ranges previous ranges
	if size(handles.vars.ranges,1)>1
		setlimits(h,eventdata,handles,...
			handles.vars.ranges(2,1),handles.vars.ranges(2,2),...
			handles.vars.ranges(2,3),handles.vars.ranges(2,4),...
			handles.vars.xn,handles.vars.yn);
		handles=guidata(h);
		handles.vars.ranges=handles.vars.ranges(3:end,:);
		guidata(h,handles);
	else
		modalerrordlg('Unable to undo zoom!');
	end


% --------------------------------------------------------------------
function varargout = erasesolution(h, eventdata, handles, varargin)
% ... erases the most recent solution
	if length(handles.vars.plots)>0
		handles.vars.plots=handles.vars.plots(1:end-1);
		guidata(h,handles);
		replot(h,eventdata,handles,varargin);
	else
		modalerrordlg('No solutions left to erase!');
	end


% --------------------------------------------------------------------
function varargout = solvebutton_Callback(h, eventdata, handles, varargin)
% ... displays or hides exact solution
	if get(handles.solvebutton,'Value') % toggle button status?
		if ~confirmexact(h,eventdata,handles,varargin)
			set(handles.solvebutton,'Value',0);
			return;
		end
		handles=guidata(h);
		cursor=swapcursor(handles.main,'watch');
		try
			[f,g]=dsolve(['D' handles.vars.xvar '=' handles.vars.fs],...
					['D' handles.vars.yvar '=' handles.vars.gs],...
					handles.vars.tvar);
			if isempty(f)
				error('Unable to compute exact solution!');
			end
			set(handles.exactsolution1,'String',...
				[handles.vars.xvar '(' handles.vars.tvar ')=' char(f)]);
			set(handles.exactsolution2,'String',...
				[handles.vars.yvar '(' handles.vars.tvar ')=' char(g)]);
		catch
			set(handles.exactsolution1,'String',...
				'Unavailable');
			set(handles.exactsolution2,'String',...
				'');
			modalerrordlg(lasterr);
		end
		swapcursor(handles.main,cursor);
	else % toggle button is off
		set(handles.exactsolution1,'String','');
		set(handles.exactsolution2,'String','');
	end


function flag=confirmexact(h,eventdata,handles,varargin)
	flag=1;
	if ~handles.vars.warn
		return;
	end
	yesbtn='Yes';
	alwaysyesbtn='Yes, and don''t ask me again';
	nobtn='No';
	switch questdlg({['Computing exact solutions may take a long time. ' ...
			'Do you want to proceed?']},'Confirm exact solution',...
			yesbtn,alwaysyesbtn,nobtn,nobtn),
		case alwaysyesbtn,
			handles.vars.warn=0;
			guidata(h,handles);
		case nobtn
			flag=0;
	end


% --------------------------------------------------------------------
function varargout = methodmenu_Callback(h, eventdata, handles, varargin)
% ... extracts method information from pop-up menu

	% extract code of newly chosen method
	idx=get(handles.methodmenu,'Value');
	method=handles.methods.codes{idx};

	if method==0 & ~confirmexact(h,eventdata,handles,varargin)
		set(handles.methodmenu,'Value',handles.vars.methodindex);
		return;
	end
	handles=guidata(h);

	if ~ischar(method) | ~strcmp(method,'')
		handles.vars.method=method;
		handles.vars.methodindex=idx;
		set(handles.altmethod,'String','');
	else	% User chose 'Other'
		if ischar(handles.vars.method)
			method=handles.vars.method;
		end
		s=inputdlg('Enter method (without .m extension)',...
			'Enter method',1,{method});
		if length(s)>0
			if exist(s{1})
				handles.vars.method=s{1};
				handles.vars.methodindex=idx;
				set(handles.altmethod,'String',handles.vars.method);
			else
				modalerrordlg([s{1} ' does not exist.']);
				set(handles.methodmenu,'Value',handles.vars.methodindex);
			end
		else
			set(handles.methodmenu,'Value',handles.vars.methodindex);
		end
	end
	guidata(h,handles);


% --------------------------------------------------------------------
function varargout = colormenu_Callback(h, eventdata, handles, varargin)
% ... extracts color information from pop-up menu

	% extract code of newly chosen color
	handles.vars.col=handles.colors.codes{get(handles.colormenu,'Value')};
	guidata(h,handles);


% --------------------------------------------------------------------
function varargout = plotbutton_Callback(h, eventdata, handles, varargin)
% ... plots solutions
	cursor=swapcursor(handles.main,'watch');
	try
		x0=eval(get(handles.x0txt,'String'));	% look up x0
		y0=eval(get(handles.y0txt,'String'));	% look up y0
		hh=eval(get(handles.stepsize,'String')); % look up step size

		plotit(h,handles.vars.method,handles.vars.col,...
			handles,x0,y0,...
			handles.vars.tmin, handles.vars.t0,handles.vars.tmax,...
			hh,'','');
		handles=guidata(h);
		
		% handles.vars.plots contains a list of plots.
		% Plots are represented by a struct containing fields like
		% t0, x0, step size, etc.
		% handles.vars.plots is needed for saving and replotting.
		n=length(handles.vars.plots)+1;
		handles.vars.plots(n).tmin=handles.vars.tmin;
		handles.vars.plots(n).t0=handles.vars.t0;
		handles.vars.plots(n).tmax=handles.vars.tmax;
		handles.vars.plots(n).x0=x0;
		handles.vars.plots(n).y0=y0;
		handles.vars.plots(n).hh=hh;
		handles.vars.plots(n).method=handles.vars.method;
		handles.vars.plots(n).col=handles.vars.col;
		handles.vars.plots(n).xfnct=''; % fields for arbitrary functions
		handles.vars.plots(n).yfnct=''; % blank in this case

		guidata(h,handles);
	catch
		modalerrordlg(lasterr);
	end
	swapcursor(handles.main,cursor);


% --------------------------------------------------------------------
function varargout = continueplot(h, eventdata, handles, varargin)
% ... continues solutions forwards
	if isempty(handles.lastpoint)
		modalerrordlg('Unable to continue plot!');
		return;
	end
	cursor=swapcursor(handles.main,'watch');
	try
		t0=handles.lastpoint(1);
		x0=handles.lastpoint(2);
		y0=handles.lastpoint(3);
		hh=eval(get(handles.stepsize,'String')); % look up step size
		tmax=t0+handles.vars.tmax-handles.vars.tmin;
		plotit(h,handles.vars.method,handles.vars.col,...
			handles,x0,y0,t0,t0,tmax,...
			hh,'','');
		handles=guidata(h);

		n=length(handles.vars.plots)+1;
		handles.vars.plots(n).tmin=t0;
		handles.vars.plots(n).t0=t0;
		handles.vars.plots(n).tmax=tmax;
		handles.vars.plots(n).x0=x0;
		handles.vars.plots(n).y0=y0;
		handles.vars.plots(n).hh=hh;
		handles.vars.plots(n).method=handles.vars.method;
		handles.vars.plots(n).col=handles.vars.col;
		handles.vars.plots(n).xfnct='';
		handles.vars.plots(n).yfnct='';

		guidata(h,handles);
	catch
		modalerrordlg(lasterr);
	end
	swapcursor(handles.main,cursor);

% --------------------------------------------------------------------
function varargout = openmenu_Callback(h, eventdata, handles, varargin)
% ... restores settings from file
	[fn,dir]=uigetfile([handles.dir handles.filename]);
	if ischar(fn) % if the user didn't click on 'Cancel'
		cursor=swapcursor(handles.main,'watch');

		backup=handles.vars;% remember current settings in case
							% something goes wrong

		handles.dir=dir;		% remember file name and path
		handles.filename=fn;

		try
			load([dir fn]);
			try		% make sure that the file was saved by the right version
				if ~strcmp(id,handles.id)
					error('Wrong or outdated file type for this module!');
				end
			catch
				error('Wrong or outdated file type for this module!');
			end
			handles.vars=tmp;
			guidata(h,handles);
			replot(h,eventdata,handles,varargin);
			handles=guidata(h);
			set(handles.solvebutton,'Value',sb);

			tmpwarn=handles.vars.warn;
			handles.vars.warn=0;
			solvebutton_Callback(h,eventdata,handles,varargin);
			handles=guidata(h);
			handles.vars.warn=tmpwarn;
			guidata(h,handles);

			set(handles.methodmenu,'Value',mn);
			set(handles.altmethod,'String',am);
			set(handles.stepsize,'String',stps);
			set(handles.colormenu,'Value',cm);
			set(handles.x0txt,'String',x0);
			set(handles.y0txt,'String',y0);
			set(handles.caption,'String',cap);
			set(handles.plotonclick,'Checked',pc);
			set(handles.zoomoutonclick,'Checked',zoc);
			set(handles.zoominonclick,'Checked',zic);
			set(handles.recenteronclick,'Checked',rec);
		catch % restore old settings if something goes wrong
			modalerrordlg(lasterr);
			handles.vars=backup;
			guidata(h,handles);
			replot(h,eventdata,handles,varargin);
		end
		swapcursor(handles.main,cursor);
	end


% --------------------------------------------------------------------
function varargout = savemenu_Callback(h, eventdata, handles, varargin)
% ... saves current settings to a file
	[fn,dir]=uiputfile([handles.dir handles.filename]);
	if ischar(fn)	% if the user didn't click on 'Cancel'
		handles.dir=dir;		% remember file name and path
		handles.filename=fn;
		guidata(h,handles);

		cursor=swapcursor(handles.main,'watch');
		id=handles.id;
		tmp=handles.vars;
		sb=get(handles.solvebutton,'Value');
		mn=get(handles.methodmenu,'Value');
		am=get(handles.altmethod,'String');
		stps=get(handles.stepsize,'String');
		cm=get(handles.colormenu,'Value');
		x0=get(handles.x0txt,'String');
		y0=get(handles.y0txt,'String');
		cap=get(handles.caption,'String');
		pc=get(handles.plotonclick,'Checked');
		zoc=get(handles.zoomoutonclick,'Checked');
		zic=get(handles.zoominonclick,'Checked');
		rec=get(handles.recenteronclick,'Checked');
		try
			save([dir fn],'id','tmp','sb','mn','am','stps','cm','x0','y0','cap','pc','zoc','zic','rec');
		catch
			modalerrordlg(lasterr);
		end
		swapcursor(handles.main,cursor);
	end


% --------------------------------------------------------------------
function varargout = replot(h, eventdata, handles, varargin)
% ... replots all solutions currently on the screen
	cursor=swapcursor(handles.main,'watch');
	try
		initplot(h,eventdata,handles,varargin);
		handles=guidata(h);
		for i=1:length(handles.vars.plots) % loop over list of plots...
			plotit(h,handles.vars.plots(i).method,handles.vars.plots(i).col,...
				handles,...
				handles.vars.plots(i).x0,handles.vars.plots(i).y0,...
				handles.vars.plots(i).tmin,handles.vars.plots(i).t0,...
				handles.vars.plots(i).tmax,handles.vars.plots(i).hh,...
				handles.vars.plots(i).xfnct,handles.vars.plots(i).yfnct);
					 % ... and plot each one
			handles=guidata(h);
		end
	catch
		modalerrordlg(lasterr);
	end
	swapcursor(handles.main,cursor);


% auxiliary function for plotting
function plotit(h,method,col,handles,x0,y0,tmin,t0,tmax,hh,xfnct,yfnct)
	pause(0);	% This line appears to solve the freezing problem that
				% otherwise occurs when right-clicking while a callback
				% is being processed.
	ttm=t0:-hh:tmin;
	ttp=t0:hh:tmax;
	tt=[fliplr(ttm) ttp(2:end)];
	if length(tt)<2
		error('Step size too large!');
	elseif ~ischar(method)
		if method==0	% plot exact solution?
			[ff,gg]=dsolve(['D' handles.vars.xvar '=' handles.vars.fs],...
				['D' handles.vars.yvar '=' handles.vars.gs],...
				[handles.vars.xvar '(' num2str(t0) ')=' num2str(x0)],...
				[handles.vars.yvar '(' num2str(t0) ')=' num2str(y0)],...
				handles.vars.tvar);
			if isempty(ff)
				error('Unable to compute exact solution!');
			end
			xx=double(subs(ff,sym(handles.vars.tvar),tt));
			yy=double(subs(gg,sym(handles.vars.tvar),tt));
			plot(xx,yy,col);
			ppaux('plotcoords',handles.ppaux,tt,[xx;yy],col);
			handles.lastpoint=[tt(end),xx(end),yy(end)];
		elseif method==1	% plot arbitrary function?
			eval([handles.vars.tvar '=tt;']);
			eval([handles.vars.xvar '=(' xfnct ')+0*' handles.vars.tvar ';']);
			eval([handles.vars.yvar '=(' yfnct ')+0*' handles.vars.tvar ';']);
			eval(['plot(' handles.vars.xvar ',' handles.vars.yvar ',col);']);
			eval(['ppaux(''plotcoords'',handles.ppaux,' handles.vars.tvar ...
				',[' handles.vars.xvar ';' handles.vars.yvar '],col);']);
			handles.lastpoint=eval(['[' handles.vars.tvar '(end),' ...
				handles.vars.xvar '(end),' ...
				handles.vars.yvar '(end)]']);
		end
	elseif length(method)>0	% plot numerical solution?
		clear(method);	% Make sure to use latest version of method.
						% Without this line, one would have to restart
						% this GUI every time the method file is updated.
		xyc=trajplot(handles.auxfn,[x0;y0],ttm,method,col);
		ppaux('plotcoords',handles.ppaux,ttm,xyc,col);

		xyc=trajplot(handles.auxfn,[x0;y0],ttp,method,col);
		ppaux('plotcoords',handles.ppaux,ttp,xyc,col);

		handles.lastpoint=[ttp(end),xyc(1,end),xyc(2,end)];
	else
		error('Please choose a numerical method first.');
	end
	guidata(h,handles);


% --------------------------------------------------------------------
function varargout = clearmenu_Callback(h, eventdata, handles, varargin)
% ... clear all plots
	cursor=swapcursor(handles.main,'watch');
	try
		resetplot(h,eventdata,handles,varargin);
	catch
		modalerrordlg(lasterr);
	end
	swapcursor(handles.main,cursor);


% --------------------------------------------------------------------
function varargout = enterdemenu_Callback(h, eventdata, handles, varargin)
% ... lets the user enter differential equations
	inp=inputdlg({...
		['Function f(' handles.vars.xvar ', ' handles.vars.yvar ')'],...
		['Function g(' handles.vars.xvar ', ' handles.vars.yvar ')']},...
		'Enter differential equation',1,...
		{handles.vars.fs,handles.vars.gs});
	if length(inp)>0 % proceed if user didn't click on 'Cancel'

		backup=handles.vars;
			% save current setting in case something goes wrong

		cursor=swapcursor(handles.main,'watch');
		try
			handles.vars.fs=inp{1};
			handles.vars.gs=inp{2};
			guidata(h,handles);
			resetplot(h,eventdata,handles,varargin);

			set(handles.solvebutton,'Value',0);
			solvebutton_Callback(h,eventdata,handles,varargin);
		catch % restore old settings if something goes wrong
			modalerrordlg(lasterr);
			handles.vars=backup;
			guidata(h,handles);
			replot(h,eventdata,handles,varargin);
		end
		swapcursor(handles.main,cursor);
	end


% --------------------------------------------------------------------
function varargout = displaymenu_Callback(h, eventdata, handles, varargin)
% ... changes display settings
	inp=inputdlg({[handles.vars.xvar 'min'],[handles.vars.xvar 'max'],...
		[handles.vars.yvar 'min'],[handles.vars.yvar 'max'],...
		['Number of line segments (horizontal)'],...
		['Number of line segments (vertical)']},...
		'Change display parameters',1,...
		{num2str(handles.vars.xmin),num2str(handles.vars.xmax),...
		num2str(handles.vars.ymin),num2str(handles.vars.ymax),...
		num2str(handles.vars.xn),num2str(handles.vars.yn)});
	if length(inp)>0 % proceed if user didn't click on 'Cancel'

		backup=handles; % save current settings in case something goes wrong

		try
			xmin=eval(inp{1});
			xmax=eval(inp{2});
			ymin=eval(inp{3});
			ymax=eval(inp{4});
			xn=eval(inp{5});
			yn=eval(inp{6});
		catch
			modalerrordlg(lasterr);
			return
		end
		if xmin>=xmax
			modalerrordlg([handles.vars.xvar 'min must be smaller than ' ...
					handles.vars.xvar 'max!']);
			return
		end
		if ymin>=ymax
			modalerrordlg([handles.vars.yvar 'min must be smaller than ' ...
					handles.vars.yvar 'max!']);
			return
		end
		if xn<2 | yn<2
			modalerrordlg(['Number of line segments must be at least 2']);
			return
		end
		cursor=swapcursor(handles.main,'watch');
		try % change limits
			setlimits(h,eventdata,handles,xmin,xmax,ymin,ymax,xn,yn)
		catch % restore old limits if something goes wrong
			modalerrordlg(lasterr);
			handles.vars=backup;
			setlimits(h,eventdata,handles,...
				handles.vars.xmin,handles.vars.xmax,...
				handles.vars.ymin,handles.vars.ymax,...
				handles.vars.xn,handles.vars.yn);
		end
		swapcursor(handles.main,cursor);
	end


% --------------------------------------------------------------------
function varargout = plotintmenu_Callback(h, eventdata, handles, varargin)
% ... changes plot duration settings
	inp=inputdlg({[handles.vars.tvar 'min'],[handles.vars.tvar '0'],...
		[handles.vars.tvar 'max']},...
		'Change plot duration',1,...
		{num2str(handles.vars.tmin),num2str(handles.vars.t0),...
		num2str(handles.vars.tmax)});
	if length(inp)>0 % proceed if user didn't click on 'Cancel'
		try
			tmin=eval(inp{1});
			t0=eval(inp{2});
			tmax=eval(inp{3});
			if tmin>=tmax
				error([handles.vars.tvar 'min must be smaller than ' ...
						handles.vars.tvar 'max!']);
			end
			if (t0>tmax) | (t0<tmin)
				error([handles.vars.tvar '0 must be in [' ...
						handles.vars.tvar 'min, ' ...
						handles.vars.tvar 'max]!']);
			end
			handles.vars.tmin=tmin;
			handles.vars.t0=t0;
			handles.vars.tmax=tmax;
			guidata(h,handles);
			replot(h,eventdata,handles,varargin);
		catch
			modalerrordlg(lasterr);
		end
	end


function varargout = setlimits(h,eventdata,handles,xmin,xmax,ymin,ymax,xn,yn)
% ... changes the display parameters and updates the figure
	handles.vars.xmin=xmin;
	handles.vars.xmax=xmax;
	handles.vars.ymin=ymin;
	handles.vars.ymax=ymax;
	handles.vars.ranges=[xmin,xmax,ymin,ymax;handles.vars.ranges];

	handles.vars.xn=xn;
	handles.vars.yn=yn;
	guidata(h,handles);
	initplot(h,eventdata,handles);
	replot(h,eventdata,handles);


function varargout=choosedefaults(h,eventdata,handles,varargin)
% ... chooses reasonable defaults for step size and initial values
	set(handles.stepsize,'String',...
		num2str(10^round(log10((handles.vars.tmax-handles.vars.tmin)/100))));
	set(handles.x0txt,'String',...
		num2str((handles.vars.xmax+handles.vars.xmin)/2));
	set(handles.y0txt,'String',...
		num2str((handles.vars.ymax+handles.vars.ymin)/2));


% --------------------------------------------------------------------
function varargout = closeppaux(h, eventdata, handles, varargin)
% DeleteFcn
	try
		delete(handles.ppaux);
	end


% --------------------------------------------------------------------
function varargout = plotarbfunction_Callback(h, eventdata, handles, varargin)
% ... plots arbitrary functions
	try
		s=inputdlg({[handles.vars.xvar '(' handles.vars.tvar ')'],...
					[handles.vars.yvar '(' handles.vars.tvar ')'],...
					[handles.vars.tvar ' ranges from...'],'... to...',...
					'Step size'},...
			'Plot arbitrary curve',1,...
			{handles.vars.xfnct,handles.vars.yfnct,...
			num2str(handles.vars.ta0),num2str(handles.vars.ta1),...
			get(handles.stepsize,'String')});
		if length(s)>0 % proceed if user didn't choose cancel
			xfnct=vectorize(s{1}); % extract function entered by user
			yfnct=vectorize(s{2});
			ta0=eval(s{3});		% extract interval [ta0,ta1]
			ta1=eval(s{4});
			hh=eval(s{5}); % extract step size
			plotit(h,1,handles.vars.col,handles,0,0,ta0,0,ta1,hh,xfnct,yfnct);
			handles=guidata(h);

			% add current information to list of plots
			n=length(handles.vars.plots)+1;
			handles.vars.plots(n).x0=0;
			handles.vars.plots(n).y0=0;
			handles.vars.plots(n).tmin=ta0;
			handles.vars.plots(n).t0=0;
			handles.vars.plots(n).tmax=ta1;
			handles.vars.plots(n).hh=hh;
			handles.vars.plots(n).method=1;
			handles.vars.plots(n).col=handles.vars.col;
			handles.vars.plots(n).xfnct=xfnct;
			handles.vars.plots(n).yfnct=yfnct;

			% make current information the default
			handles.vars.xfnct=s{1};
			handles.vars.yfnct=s{2};
			handles.vars.ta0=ta0;
			handles.vars.ta1=ta1;
	
			guidata(h,handles);
		end
	catch
		modalerrordlg(lasterr);
	end


% --------------------------------------------------------------------
function varargout = resetplot(h,eventdata,handles,varargin)
% ... clears the figure
	handles.vars.plots=[]; % clear list of plots
	handles.lastpoint=[];
	guidata(h,handles);
	initplot(h,eventdata,handles,varargin);


% --------------------------------------------------------------------
function varargout = initplot(h,eventdata,handles,varargin)
% initializes the display

	% First, substitute variable names: replace xvar, yvar by
	% xyc(1,:) and xyc(2,:).
	fs=subvar(vectorize([handles.vars.fs '+0*' handles.vars.xvar]),...
			handles.vars.xvar,'xyc(1,:)');
	fs=subvar(fs,handles.vars.yvar,'xyc(2,:)');
	gs=subvar(vectorize([handles.vars.gs '+0*' handles.vars.xvar]),...
			handles.vars.xvar,'xyc(1,:)');
	gs=subvar(gs,handles.vars.yvar,'xyc(2,:)');

	% Now define [fs;gs] as an inline function.
	handles.auxfn=inline(['[' fs ';' gs ']'],handles.vars.tvar,'xyc');
	guidata(h,handles);

	xc=linspace(handles.vars.xmin,handles.vars.xmax,handles.vars.xn);
	yc=linspace(handles.vars.ymin,handles.vars.ymax,handles.vars.yn);
	ttl=['d' handles.vars.xvar '/d' handles.vars.tvar ' = ' handles.vars.fs,...
		', d' handles.vars.yvar '/d' handles.vars.tvar ' = ' ...
		handles.vars.gs];
	pp(handles.auxfn,xc,yc,handles.vars.xvar,handles.vars.yvar,ttl,'b',1,...
		handles.vars.t0);

	ppaux('init',...
		handles.ppaux,...
		[handles.vars.xmin, handles.vars.xmax,...
		handles.vars.ymin, handles.vars.ymax],...
		handles.vars.tvar,handles.vars.xvar,handles.vars.yvar,ttl);

	set(handles.x0prompt,'String',[handles.vars.xvar '0 = ']); % update labels
	set(handles.y0prompt,'String',[handles.vars.yvar '0 = ']);


% --------------------------------------------------------------------
function varargout = prmenu_Callback(h, eventdata, handles, varargin)
% ... prints the current window
	try
		printdlg('-crossplatform',handles.main);
	catch
		modalerrordlg(lasterr);
	end


% --------------------------------------------------------------------
function varargout = prprmenu_Callback(h, eventdata, handles, varargin)
% ... calls print preview
	try
		printpreview(handles.main);
	catch
		modalerrordlg(lasterr);
	end


% --------------------------------------------------------------------
function varargout = plotcoordmenu_Callback(h, eventdata, handles, varargin)
% ... opens a window for plotting coordinate functions
	try
		guidata(handles.ppaux);	% This line will _not_ cause an error if
								% handles.ppaux is a valid plotting window
		modalerrordlg('Plotting window is already open!');
	catch	% if an error occurred, we need to open a new window
		handles.ppaux=ppaux;
		guidata(h,handles);
		replot(h,eventdata,handles,varargin);
	end


function varargout = plotonclick_Callback(h,eventdata,handles,varargin)
	set(handles.plotonclick,'Checked','on');
	set(handles.zoominonclick,'Checked','off');
	set(handles.zoomoutonclick,'Checked','off');
	set(handles.recenteronclick,'Checked','off');


function varargout = zoominonclick_Callback(h,eventdata,handles,varargin)
	set(handles.plotonclick,'Checked','off');
	set(handles.zoominonclick,'Checked','on');
	set(handles.zoomoutonclick,'Checked','off');
	set(handles.recenteronclick,'Checked','off');


function varargout = zoomoutonclick_Callback(h,eventdata,handles,varargin)
	set(handles.plotonclick,'Checked','off');
	set(handles.zoominonclick,'Checked','off');
	set(handles.zoomoutonclick,'Checked','on');
	set(handles.recenteronclick,'Checked','off');


function varargout = recenteronclick_Callback(h,eventdata,handles,varargin)
	set(handles.plotonclick,'Checked','off');
	set(handles.zoominonclick,'Checked','off');
	set(handles.zoomoutonclick,'Checked','off');
	set(handles.recenteronclick,'Checked','on');


function varargout = changezoom_Callback(h,eventdata,handles,varargin)
	s=inputdlg({'Enter horizontal zoom factor',...
				'Enter vertical zoom factor'},'Zoom factors',1,...
		{num2str(handles.vars.zoomx),num2str(handles.vars.zoomy)});
	if length(s)>0 % proceed if user didn't click on 'Cancel'
		try
			zoomx=eval(s{1});
			zoomy=eval(s{2});
			if zoomx>1 & zoomy>1
				handles.vars.zoomx=zoomx;
				handles.vars.zoomy=zoomy;
				guidata(h,handles);
			else
				modalerrordlg('Zoom factors must be greater than 1!');
			end
		catch
			modalerrordlg(lasterr);
		end
	end


function varargout = captionmenu_Callback(h,eventdata,handles,varargin)
	inp=inputdlg('Enter caption','Enter caption',1,...
		{get(handles.caption,'String')});
	if length(inp)>0
		set(handles.caption,'String',inp{1});
	end


function varargout = changevarmenu_Callback(h,eventdata,handles,varargin)
	inp=inputdlg({'Independent variable','Dependent variable #1',...
		'Dependent variable #2'},'Relabel variables',1,...
		{handles.vars.tvar,handles.vars.xvar,handles.vars.yvar});
	if length(inp)>0
		backup=handles.vars;
		try
			handles.vars.fs=subvars(handles.vars.fs,...
				{handles.vars.tvar,handles.vars.xvar,handles.vars.yvar},inp);
			handles.vars.gs=subvars(handles.vars.gs,...
				{handles.vars.tvar,handles.vars.xvar,handles.vars.yvar},inp);
			handles.vars.xfnct=subvars(handles.vars.xfnct,...
				{handles.vars.tvar,handles.vars.xvar,handles.vars.yvar},inp);
			handles.vars.yfnct=subvars(handles.vars.yfnct,...
				{handles.vars.tvar,handles.vars.xvar,handles.vars.yvar},inp);
			handles.vars.tvar=inp{1};
			handles.vars.xvar=inp{2};
			handles.vars.yvar=inp{3};
			guidata(h,handles);
			replot(h,eventdata,handles,varargin);

			set(handles.solvebutton,'Value',0);
			solvebutton_Callback(h,eventdata,handles,varargin);
		catch
			handles.vars=backup;
			guidata(h,handles);
			replot(h,eventdata,handles,varargin);
			modalerrordlg(lasterr);
		end
	end


function dummy()
% auxiliary function that never gets called; it merely contains calls
% to functions that would otherwise be hidden in eval statements; the
% idea is to get all dependencies when using depfun
	euler;
	rk;

