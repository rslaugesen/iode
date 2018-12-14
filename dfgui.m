function varargout = dfgui(varargin)
% function varargout = dfgui(varargin)
%
% (c) 2002, Peter Brinkmann (brinkman@math.uiuc.edu)
%
% dfgui: Graphical user interface for Iode's direction fields modules
%
% Usage:
%	fig = dfgui
%			 launch GUI
%	dfgui('callback_name', ...)
%			 invoke the named callback
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

	% The following strange line makes sure that clicks on line segments in
	% the plot will be received by the axes object
	set(fig,'DefaultLineCreateFcn','set(gcbo,''ButtondownFcn'',get(gca,''ButtonDownFcn''),''UIContextMenu'',get(gca,''UIContextMenu''))');

	% Disable TeX for labels (because TeX doesn't handle expressions like
	% '2^sin(x)' correctly)
	set(fig,'DefaultTextCreateFcn','set(gcbo,''Interpreter'',''none'')');

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);

	axes(handles.axes1); % Important: Send plots to the axes in our figure

    handles.id='dfgui 6.0';		% ID tag; should be updated whenever the
								% format of saved files changes

	handles.dir='';				% variables for remembering paths and files
	handles.filename='*.mat';

	% names and codes of solution methods
	handles.methods.names={'Euler','Runge-Kutta','Other','Exact'};
	handles.methods.codes={'euler','rk','',0};
	set(handles.methodmenu,'String',handles.methods.names);

	% names and codes of colors for plotting
	handles.colors.names={'Red','Green','Blue','Yellow',...
				'Black','Cyan','Magenta'};
	handles.colors.codes={'r','g','b','y','k','c','m'};
	set(handles.colormenu,'String',handles.colors.names);

	handles.vars=struct(...
		'tvar','x',...			% name of independent variable
		'xvar','y',...			% name of dependent variable
		'fs',['sin(y-x)'],...	% right-hand side of diffeq
		'xdot',inline('0'),...	% dummy value for inline function
		'tmin',-pi,...			% display parameters
		'tmax',pi,...
		'xmin',-pi,...
		'xmax',pi,...
		'tn',15,...	% number of line segments (horizontal)
		'xn',15,...	% number of line segments (vertical)
		'nopts',1000,... % number of plot points for arbitrary functions
		'method','',...
		'col','',...
		'warn',1,...	% warning flag for exact solutions
		'methodindex',1,... % index of the current method in the pop-up menu
		'plots',[],...	% list of plots (for saving and replotting)
		'ranges',[],...	% list of display parameters (for undoing zoom)
		'zoomt',2,...	% zoom factor (horizontal)
		'zoomx',2,...	% zoom factor (vertical)
		'afs',['exp(x)']);	% string containing arbitrary function

	choosedefaults(fig,[],handles);

	guidata(fig, handles);
	methodmenu_Callback(fig,[],handles);% initialize mathematical information
	handles=guidata(fig);		% need to update handles information
	colormenu_Callback(fig,[],handles); % unitialize plotting color
	handles=guidata(fig);			% store new handles information
	setlimits(fig,[],handles,...
		handles.vars.tmin,handles.vars.tmax,...
		handles.vars.xmin,handles.vars.xmax,...
		handles.vars.tn,handles.vars.xn);		% initialize the plot
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
% ... handles clicks in the figure
	h=handles.axes1;
	if ~strcmp(get(gcf,'SelectionType'),'normal')	% left-click?
		return;
	end
	p=get(handles.axes1,'CurrentPoint');
	t0=p(1);	% extract coordinates of click
	x0=p(3);

	tmin=handles.vars.tmin;
	tmax=handles.vars.tmax;
	xmin=handles.vars.xmin;
	xmax=handles.vars.xmax;

	cursor=swapcursor(handles.main,'crosshair');
	rbbox;	% allow user to drag mouse to choose box
	p=get(handles.axes1,'CurrentPoint'); % extract coordinates of
										 % mouse button release
	t1=p(1);
	x1=p(3);
	if abs(t0-t1)/(tmax-tmin)<0.02
		t1=t0;
	end
	if abs(x0-x1)/(xmax-xmin)<0.02
		x1=x0;
	end
	swapcursor(handles.main,'watch');
	try
		if strcmp(get(handles.plotonclick,'Checked'),'on') & (t0==t1) & (x0==x1)
			set(handles.t0txt,'String',num2str(t0)); % update t0
			set(handles.x0txt,'String',num2str(x0)); % update x0
			plotbutton_Callback(h,eventdata,handles,varargin); % plot solution
		elseif (t0~=t1) & (x0~=x1)
			setlimits(h,eventdata,handles,min(t0,t1),max(t0,t1),...
				min(x0,x1),max(x0,x1),...
				handles.vars.tn,handles.vars.xn);
		elseif strcmp(get(handles.zoominonclick,'Checked'),'on')
			ts=(tmax-tmin)/2/handles.vars.zoomt; % 1/2 t-range of new limits
			xs=(xmax-xmin)/2/handles.vars.zoomx; % 1/2 x-range of new limits
			setlimits(h,eventdata,handles,t0-ts,t0+ts,x0-xs,x0+xs,...
				handles.vars.tn,handles.vars.xn);
		elseif strcmp(get(handles.zoomoutonclick,'Checked'),'on')
			ts=(tmax-tmin)/2*handles.vars.zoomt; % 1/2 t-range of new limits
			xs=(xmax-xmin)/2*handles.vars.zoomx; % 1/2 x-range of new limits
			setlimits(h,eventdata,handles,t0-ts,t0+ts,x0-xs,x0+xs,...
				handles.vars.tn,handles.vars.xn);
		elseif strcmp(get(handles.recenteronclick,'Checked'),'on')
			ts=(tmax-tmin)/2; % 1/2 t-range of new limits
			xs=(xmax-xmin)/2; % 1/2 x-range of new limits
			setlimits(h,eventdata,handles,t0-ts,t0+ts,x0-xs,x0+xs,...
				handles.vars.tn,handles.vars.xn);
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
			handles.vars.tn,handles.vars.xn);
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
% ... shows or hides exact solution
	if get(handles.solvebutton,'Value') % toggle button status?
		if ~confirmexact(h,eventdata,handles,varargin)
			set(handles.solvebutton,'Value',0);
			return;
		end
		handles=guidata(h);
		cursor=swapcursor(handles.main,'watch');
		try
			f=dsolve(['D' handles.vars.xvar '=' handles.vars.fs],...
				handles.vars.tvar);
			if isempty(f)
				error('Unable to compute exact solution!');
			end
			set(handles.exactsolution,'String',...
				[handles.vars.xvar '(' handles.vars.tvar ')=' char(f)]);
		catch
			set(handles.exactsolution,'String',...
				'Unavailable');
			modalerrordlg(lasterr);
		end
		swapcursor(handles.main,cursor);
	else % toggle button is off
		set(handles.exactsolution,'String','');
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
		t0=eval(get(handles.t0txt,'String'));	% look up t0
		x0=eval(get(handles.x0txt,'String'));	% look up x0
		hh=eval(get(handles.stepsize,'String')); % look up step size

		plotit(handles.vars.method,handles.vars.col,handles,...
			t0,x0,hh,'');
		
		% handles.vars.plots contains a list of plots
		% Plots are represented by a struct containing fields like
		% t0, x0, step size, etc.
		% handles.vars.plots is needed for saving and replotting
		n=length(handles.vars.plots)+1;
		handles.vars.plots(n).t0=t0;
		handles.vars.plots(n).x0=x0;
		handles.vars.plots(n).hh=hh;
		handles.vars.plots(n).method=handles.vars.method;
		handles.vars.plots(n).col=handles.vars.col;
		handles.vars.plots(n).afs=''; % field for arbitrary functions

		guidata(h,handles);
	catch
		modalerrordlg(lasterr);
	end
	swapcursor(handles.main,cursor);


% --------------------------------------------------------------------
function varargout = openmenu_Callback(h, eventdata, handles, varargin)
% ... restores information from files
	[fn,dir]=uigetfile([handles.dir handles.filename]);
	if ischar(fn)	% proceed if user didn't click on 'Cancel'
		cursor=swapcursor(handles.main,'watch'); % wait cursor

		backup=handles.vars;	% save current settings in case
								% they have to be restored
		handles.dir=dir;		% remember file name and path
		handles.filename=fn;

		try
			load([dir fn]);
			try	% check whether the file was saved by the right version
				if ~strcmp(id,handles.id)
					error('Wrong or outdated file type for this module!');
				end
			catch
				error('Wrong or outdated file type for this module!');
			end
			handles.vars=tmp;	 % extract settings from data from file
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
			set(handles.t0txt,'String',t0);
			set(handles.x0txt,'String',x0);
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
	if ischar(fn) % proceed if user didn't choose 'Cancel'
		cursor=swapcursor(handles.main,'watch');

		handles.dir=dir;		% remember file name and path
		handles.filename=fn;
		guidata(h,handles);

		id=handles.id;
		tmp=handles.vars;
		sb=get(handles.solvebutton,'Value');
		mn=get(handles.methodmenu,'Value');
		am=get(handles.altmethod,'String');
		stps=get(handles.stepsize,'String');
		cm=get(handles.colormenu,'Value');
		t0=get(handles.t0txt,'String');
		x0=get(handles.x0txt,'String');
		cap=get(handles.caption,'String');
		pc=get(handles.plotonclick,'Checked');
		zoc=get(handles.zoomoutonclick,'Checked');
		zic=get(handles.zoominonclick,'Checked');
		rec=get(handles.recenteronclick,'Checked');
		try
			save([dir fn],'id','tmp','sb','mn','am','stps','cm','t0','x0','cap','pc','zoc','zic','rec');
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
			plotit(handles.vars.plots(i).method,handles.vars.plots(i).col,...
				handles,handles.vars.plots(i).t0,...
				handles.vars.plots(i).x0,handles.vars.plots(i).hh,...
				handles.vars.plots(i).afs); % ... and plot each one
		end
	catch
		modalerrordlg(lasterr);
	end
	swapcursor(handles.main,cursor);


% auxiliary function for plotting
function plotit(method,col,handles,t0,x0,hh,afs)
	pause(0);	% This line appears to solve the freezing problem that
				% otherwise occurs when right-clicking while a callback
				% is being processed.
	if ~ischar(method)
		if method==0	% plot exact solution?
			ff=dsolve(['D' handles.vars.xvar '=' handles.vars.fs],...
				[handles.vars.xvar '(' num2str(t0) ')=' num2str(x0)],...
				handles.vars.tvar);
			if isempty(ff)
				error('Unable to compute exact solution!');
			end
			tt=linspace(handles.vars.tmin,handles.vars.tmax,...
				handles.vars.nopts);
			xx=double(subs(ff,sym(handles.vars.tvar),tt));
			plot(tt,xx,col);
		elseif method==1	% plot arbitrary function?
			eval([handles.vars.tvar ...
				'=linspace(handles.vars.tmin,handles.vars.tmax,handles.vars.nopts);']);
			eval([handles.vars.xvar '=(' afs ')+0*' handles.vars.tvar ';']);
			eval(['plot(' handles.vars.tvar ',' handles.vars.xvar ',col)']);
		end
	elseif length(method)>0	% plot numerical solution?
		clear(method);	% Make sure to use latest version of method.
						% Without this line, one would have to restart
						% this GUI every time the method file is updated.
		if t0<handles.vars.tmax
			solplot(handles.vars.xdot,x0,(t0:hh:handles.vars.tmax+hh),...
				method,col);	% plot from t0 to handles.vars.tmax
		end
		if t0>handles.vars.tmin
			solplot(handles.vars.xdot,x0,(t0:-hh:handles.vars.tmin-hh),...
				method,col);	% plot from t0 down to handles.vars.tmin
		end
	else
		error('Please choose a numerical method first!');
	end	 


% --------------------------------------------------------------------
function varargout = clearmenu_Callback(h, eventdata, handles, varargin)
% ... clears all plots
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
	inp=inputdlg(...
		{['Function f(' handles.vars.tvar ', ' handles.vars.xvar ')']},...
		'Enter differential equation',1,{handles.vars.fs});
	if length(inp)>0	% proceed if user didn't click on 'Cancel'
		backup=handles.vars;
			% save current settings in case something goes wrong

		cursor=swapcursor(handles.main,'watch');
		try
			handles.vars.fs=inp{1};
			guidata(h,handles);
			resetplot(h,eventdata,handles,varargin);

			set(handles.solvebutton,'Value',0);
			solvebutton_Callback(h,eventdata,handles,varargin);
		catch	 % restore old settings if something goes wrong
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
	inp=inputdlg({[handles.vars.tvar 'min'],[handles.vars.tvar 'max'],...
        [handles.vars.xvar 'min'],[handles.vars.xvar 'max'],...
		['Number of line segments (horizontal)'],...
		['Number of line segments (vertical)']},...
		'Change display parameters',1,...
		{num2str(handles.vars.tmin),num2str(handles.vars.tmax),...
		num2str(handles.vars.xmin),num2str(handles.vars.xmax),...
		num2str(handles.vars.tn),num2str(handles.vars.xn)});
	if length(inp)>0	% proceed if user didn't click on 'Cancel'

		backup=handles.vars; % remember current settings

		try
			tmin=eval(inp{1});
			tmax=eval(inp{2});
			xmin=eval(inp{3});
			xmax=eval(inp{4});
			tn=eval(inp{5});
			xn=eval(inp{6});
		catch
			modalerrordlg(lasterr);
			return
		end
		if tmin>=tmax
			modalerrordlg([handles.vars.tvar 'min must be smaller than ' ...
				handles.vars.tvar 'max!']);
			return
		end
		if xmin>=xmax
			modalerrordlg([handles.vars.xvar 'min must be smaller than ' ...
				handles.vars.xvar 'max!']);
			return
		end
		if tn<2 | xn<2
			modalerrordlg(['Number of line segments must be at least 2']);
			return
		end
		cursor=swapcursor(handles.main,'watch');
		try % change limits
			setlimits(h,eventdata,handles,tmin,tmax,xmin,xmax,tn,xn);
		catch % restore old limits if something goes wrong
			modalerrordlg(lasterr);
			handles.vars=backup;
			setlimits(h,eventdata,handles,...
				handles.vars.tmin,handles.vars.tmax,...
				handles.vars.xmin,handles.vars.xmax,...
				handles.vars.tn,handles.vars.xn);
		end
		swapcursor(handles.main,cursor);
	end


function varargout = setlimits(h,eventdata,handles,tmin,tmax,xmin,xmax,tn,xn)
% ... changes the display parameters and updates the figure
	handles.vars.tmin=tmin;
	handles.vars.tmax=tmax;
	handles.vars.xmin=xmin;
	handles.vars.xmax=xmax;
	handles.vars.ranges=[tmin,tmax,xmin,xmax;handles.vars.ranges];

	handles.vars.tn=tn;
	handles.vars.xn=xn;

	guidata(h,handles);
	replot(h,eventdata,handles);


% --------------------------------------------------------------------
function varargout=choosedefaults(h,eventdata,handles,varargin)
% ... chooses reasonable default values for step size and initial values
	set(handles.stepsize,'String',...
		num2str(10^round(log10((handles.vars.tmax-handles.vars.tmin)/100))));
	set(handles.t0txt,'String',...
		num2str((handles.vars.tmax+handles.vars.tmin)/2));
	set(handles.x0txt,'String',...
		num2str((handles.vars.xmax+handles.vars.xmin)/2));


% --------------------------------------------------------------------
function varargout = plotarbfunction_Callback(h, eventdata, handles, varargin)
% ... plots arbitrary functions
	try
		s=inputdlg(['Enter a function of ' handles.vars.tvar],...
            'Plot arbitrary function',1,{handles.vars.afs});
		if length(s)>0	% proceed if user didn't choose 'Cancel'
			afs=vectorize(s{1});	% extract function entered by user
			hh=eval(get(handles.stepsize,'String')); % extract step size
			plotit(1,handles.vars.col,handles,0,0,hh,afs);
			n=length(handles.vars.plots)+1;
			handles.vars.plots(n).t0=0;
			handles.vars.plots(n).x0=0;
			handles.vars.plots(n).hh=hh;
			handles.vars.plots(n).method=1;
			handles.vars.plots(n).col=handles.vars.col;
			handles.vars.plots(n).afs=afs;
			handles.vars.afs=s{1};
	
			guidata(h,handles);
		end
	catch
		modalerrordlg(lasterr);
	end


% --------------------------------------------------------------------
function varargout = resetplot(h,eventdata,handles,varargin)
% ... clears the figure
	handles.vars.plots=[]; % clear list of plots
	guidata(h,handles);
	initplot(h,eventdata,handles,varargin);


% --------------------------------------------------------------------
function varargout = initplot(h,eventdata,handles,varargin)
% ... initializes the display
	handles.vars.xdot=inline(vectorize(...
		['(' handles.vars.fs ')+0*' handles.vars.xvar]),...
		handles.vars.tvar,handles.vars.xvar);
	guidata(h,handles);
	tc=linspace(handles.vars.tmin,handles.vars.tmax,handles.vars.tn);
	xc=linspace(handles.vars.xmin,handles.vars.xmax,handles.vars.xn);
	df(handles.vars.xdot,tc,xc,handles.vars.tvar,handles.vars.xvar,...
		['d' handles.vars.xvar '/d' handles.vars.tvar ' = ' handles.vars.fs]);

	set(handles.t0prompt,'String',[handles.vars.tvar '0 = ']);	% update labels
	set(handles.x0prompt,'String',[handles.vars.xvar '0 = ']);


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
		{num2str(handles.vars.zoomt),num2str(handles.vars.zoomx)});
	if length(s)>0 % proceed if user didn't click on 'Cancel'
		try
			zoomt=eval(s{1});
			zoomx=eval(s{2});
			if zoomt>1 & zoomx>1
				handles.vars.zoomt=zoomt;
				handles.vars.zoomx=zoomx;
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
	inp=inputdlg({'Independent variable','Dependent variable'},...
		'Relabel variables',1,{handles.vars.tvar,handles.vars.xvar});
	if length(inp)>0
		backup=handles.vars;
		try
			handles.vars.fs=subvars(handles.vars.fs,...
				{handles.vars.tvar,handles.vars.xvar},inp);
			handles.vars.afs=subvars(handles.vars.afs,...
				{handles.vars.tvar,handles.vars.xvar},inp);
			handles.vars.tvar=inp{1};
			handles.vars.xvar=inp{2};
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

