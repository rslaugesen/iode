function varargout = pdegui(varargin)
% function varargout = pdegui(varargin)
%
% (c) 2002, Peter Brinkmann (brinkman@math.uiuc.edu)
%
% pdegui: Graphical user interface for Iode's PDEs modules
%
% Usage:
%	fig = pdegui
%			 launch GUI.
%	pdegui('callback_name', ...)
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

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	axes(handles.axes1);

	global numtol;
	handles.numtol=numtol;	% numerical tolerance; numerical values smaller
							% than handles.numtol will be treated as 0

	handles.id='pdegui 4.0';	% ID tag; should be updated whenever the
								% format of saved files changes

	handles.dir='';				% variables for remembering paths and files
	handles.filename='*.mat';

	handles.u0lab='[handles.vars.uvar ''('' handles.vars.xvar '', 0) = '' handles.vars.f1 ]';
	handles.u0primelab='['',   '' handles.vars.uvar ''_'' handles.vars.tvar '' ('' handles.vars.xvar '', 0) = '' handles.vars.f2 ]';

	handles.vars=struct(...
		'xvar','x',...					% first independent variable
		'tvar','t',...					% second independent variable
		'uvar','u',...					% dependent variable
		'L',pi,...						% plot solutions on [0,L]x[0,T]
		'T',4*pi,...
		'c',0.5,...						% wave speed/thermal diffusivity
		'type','wave',...				% type of equation
		'bdcond','dirichlet',...		% type of boundary condition
		'f1','triangle(x,pi/4,5*pi/12)',...	% initial displacement
		'f2','0',...					% initial velocity (if appropriate)
		'xn',48,...						% number of plot points (x-direction)
		'tn',48,...						% number of plot points (t-direction)
		'nmax',60,...					% max harmonic for series approx.
		'ind',1,...						% index for drawing slices
        'xx',[],...						% lists of coordinates for plotting
        'tt',[],...
        'uu',[],...
		'ttl1','[handles.vars.uvar ''_{'' handles.vars.tvar handles.vars.tvar ''} = '' num2str(handles.vars.c) ''^2 '' handles.vars.uvar ''_{'' handles.vars.xvar handles.vars.xvar ''} ,   '' handles.vars.uvar ''(0, '' handles.vars.tvar '') = '' handles.vars.uvar ''('' num2str(handles.vars.L) '', '' handles.vars.tvar '') = 0'']',...
		'ttl2a',handles.u0lab,...
		'ttl2b',handles.u0primelab,...
		'ttl','',...
		'nopts',480);	% number of plot points for plotting slices
			% ttl1: text representing equation and boundary conditions
			% ttl2a: text representing initial position u(x,0)=f1(x)
			% ttl2b: text representing initial velocity u_t(x,0)=f2(x)
			% ttl: title of figure, with first line equal to eval(ttl1) and
			% second line equal to [eval(ttl2a) eval(ttl2b)]
			%
			% ttl2a will always be equal to handles.u0lab.
			% ttl2b will be '''''' (i.e., eval(ttl2b)='') when dealing with
			% the heat equation, and it is handles.u0primelab when dealing
			% with the wave equation and others.
			%
			% The value of ttl1 looks completely cryptic, but it's easy
			% enough to figure out if you just copy this value into the
			% Matlab window and see what it evaluates to. The values of
			% ttl1, ttl2a, and ttl2b look terrible, but they provide a
			% rather simple way of keeping the titles up to date when the
			% variable names change.

	guidata(fig,handles);

	update(fig,[],handles);
	handles=guidata(fig);

	axes(handles.axes1);
	view(34,42);	% makes sure that t-axis points rightwards

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
function varargout = coordtxt_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.coordtxt.
	try
		t0=eval(get(handles.coordtxt,'String'));
		ind1=max(find(handles.plots.timeaxis<=t0));
		ind2=min(find(handles.plots.timeaxis>=t0));
		if ind1==ind2
			handles.plots.ind=ind1;
		else
			handles.plots.timeaxis=[handles.plots.timeaxis(1:ind1),...
				t0,handles.plots.timeaxis(ind2:end)];
			if isempty(ind2)
				handles.plots.ind=ind1+1;
			else
				handles.plots.ind=ind2;
			end
		end
	catch
		modalerrordlg(lasterr);
	end
	guidata(h,handles);
	plotslice(h,eventdata,handles);


% --------------------------------------------------------------------
function varargout = decbutton_Callback(h, eventdata, handles, varargin)
% ... decreases index of slive in view
	handles.plots.ind=handles.plots.ind-1;
	plotslice(h,eventdata,handles);

% --------------------------------------------------------------------
function varargout = incbutton_Callback(h, eventdata, handles, varargin)
% ... increases index of slice in view
	handles.plots.ind=handles.plots.ind+1;
	plotslice(h,eventdata,handles);


% --------------------------------------------------------------------
function varargout = plottxu(h, eventdata, handles, varargin)
% ... plots 3-dimensional representation of solution
	Sp=max(max(max(handles.vars.uu)));
	Sm=min(min(min(handles.vars.uu)));
	S=(Sp-Sm)/8;

	axes(handles.axes1);
	fixaxes([min(handles.vars.xx),max(handles.vars.xx),...
			min(handles.vars.tt),max(handles.vars.tt),...
			Sm-S-handles.numtol,Sp+S+handles.numtol]);

	surf(handles.vars.xx,handles.vars.tt,handles.vars.uu);
	xlabel(handles.vars.xvar);
	ylabel(handles.vars.tvar);
	zlabel(handles.vars.uvar);
	title(handles.vars.ttl);
	rotate3d on;
	grid on;


% --------------------------------------------------------------------
function varargout = tslicebutton_Callback(h, eventdata, handles, varargin)
% ... plots slices for given t
	set(handles.tslicebutton,'Value',1.0);
	set(handles.xslicebutton,'Value',0.0);

	initslices(h,eventdata,handles);


% --------------------------------------------------------------------
function varargout = xslicebutton_Callback(h, eventdata, handles, varargin)
% ... plots slices for given x
	set(handles.tslicebutton,'Value',0.0);
	set(handles.xslicebutton,'Value',1.0);

	initslices(h,eventdata,handles);


% --------------------------------------------------------------------
function varargout = initslices(h, eventdata, handles)
% ... initializes the second plot
	set(handles.tslicebutton,'String',...
		['Plot ' handles.vars.tvar '-snapshots']);
	set(handles.xslicebutton,'String',...
		['Plot ' handles.vars.xvar '-sections']);
	if get(handles.tslicebutton,'Value')
		set(handles.coordlabel,'String',...
			['Current ' handles.vars.tvar '-coordinate']);
		plotaxis=linspace(0,handles.vars.L,handles.vars.nopts+1);
		timeaxis=handles.vars.tt;
		xlab=handles.vars.xvar;
		ylab=handles.vars.uvar;
		col='r';
	elseif get(handles.xslicebutton,'Value')
		set(handles.coordlabel,'String',...
			['Current ' handles.vars.xvar '-coordinate']);
		plotaxis=linspace(0,handles.vars.T,handles.vars.nopts+1);
		timeaxis=handles.vars.xx;
		xlab=handles.vars.tvar;
		ylab=handles.vars.uvar;
		col='b';
	end

	handles.plots=struct('ind',1,...	% save details of solution is
		'plotaxis',plotaxis,...			% auxiliary structure for plotting
		'timeaxis',timeaxis,...
		'xlab',xlab,...
		'ylab',ylab,...
		'col',col);

	Sp=max(max(max(handles.vars.uu)));
	Sm=min(min(min(handles.vars.uu)));
	S=(Sp-Sm)/8;

	axes(handles.axes2);
	fixaxes([min(plotaxis),max(plotaxis),...
		Sm-S-handles.numtol,Sp+S+handles.numtol]);
	grid on;
	guidata(h,handles);
	plotslice(h,eventdata,handles);


% --------------------------------------------------------------------
function varargout = plotslice(h, eventdata, handles, varargin)
% ... plots the current slice
	axes(handles.axes2);
	view(0,90);
	if handles.plots.ind<1
		handles.plots.ind=1;
	elseif handles.plots.ind>length(handles.plots.timeaxis)
		handles.plots.ind=length(handles.plots.timeaxis);
	end
	guidata(h,handles);
	t0=handles.plots.timeaxis(handles.plots.ind);
	set(handles.coordtxt,'String',... % update current t/x value
		num2str(t0));

	if get(handles.tslicebutton,'Value')
		func=feval(handles.vars.type,handles.vars.ef,handles.vars.wn,...
			handles.vars.cn1,handles.vars.c,...
			handles.plots.plotaxis,t0,handles.vars.cn2);
	elseif get(handles.xslicebutton,'Value')
		func=feval(handles.vars.type,handles.vars.ef,handles.vars.wn,...
			handles.vars.cn1,handles.vars.c,...
			t0,handles.plots.plotaxis,handles.vars.cn2);
	end

	cla;
	plot(handles.plots.plotaxis,func,handles.plots.col); % plot current slice
	xlabel(handles.plots.xlab);
	ylabel(handles.plots.ylab);

	% The next two lines are sort of redundant, but without
	% them the 3D plot won't rotate at the EWS labs.
	% Don't blame the messenger...
	axes(handles.axes1);
	rotate3d on


% --------------------------------------------------------------------
function varargout = openmenu_Callback(h, eventdata, handles, varargin)
% ... restores settings from a file
	[fn,dir]=uigetfile([handles.dir handles.filename]);
	if ischar(fn)
		csr=swapcursor(handles.main,'watch');
		backup=handles.vars;

		handles.dir=dir;		% remember file name and path
		handles.filename=fn;

		try
			load([dir fn]);
			try
				if ~strcmp(id,handles.id)
					error('Wrong or outdated file type for this module!');
				end
			catch
				error('Wrong or outdated file type for this module!');
			end
			handles.vars=tmp;
			set(handles.tslicebutton,'Value',tsl);
			set(handles.xslicebutton,'Value',xsl);
			set(handles.caption,'String',cap);
			guidata(h,handles);
			initplots(h,eventdata,handles);
		catch
			modalerrordlg(lasterr);
			handles.vars=backup;
			guidata(h,handles);
			initplots(h,eventdata,handles);
		end
		swapcursor(handles.main,csr);
	end


% --------------------------------------------------------------------
function varargout = savemenu_Callback(h, eventdata, handles, varargin)
% ... saves settings to a file
	[fn,dir]=uiputfile([handles.dir handles.filename]);
	if ischar(fn)
		handles.dir=dir;		% remember file name and path
		handles.filename=fn;
		guidata(h,handles);

		id=handles.id;
		tmp=handles.vars;
		tsl=get(handles.tslicebutton,'Value');
		xsl=get(handles.xslicebutton,'Value');
		cap=get(handles.caption,'String');
		try
			save([dir fn],'id','tmp','tsl','xsl','cap');
		catch
			modalerrordlg(lasterr);
		end
	end


% --------------------------------------------------------------------
function varargout = printmenu_Callback(h, eventdata, handles, varargin)
% ... prints the current window
	try
		printdlg('-crossplatform',handles.main);
	catch
		modalerrordlg(lasterr);
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
function varargout = equationmenu_Callback(h, eventdata, handles, varargin)
% ... lets the user enter the type of equation and boundary conditions
	switch menu('Choose type of equation','Wave','Heat','Other','Cancel')
		case 1	% wave equation
			eq='wave';
			ttl1='[handles.vars.uvar ''_{'' handles.vars.tvar handles.vars.tvar ''} = '' num2str(handles.vars.c) ''^2 u_{'' handles.vars.xvar handles.vars.xvar ''} ,   ';
			handles.vars.ttl2b=handles.u0primelab;
		case 2	% heat equation
			eq='heat';
			ttl1='[handles.vars.uvar ''_'' handles.vars.tvar '' = '' num2str(handles.vars.c) '' '' handles.vars.uvar ''_{'' handles.vars.xvar handles.vars.xvar ''} ,   ';
			handles.vars.ttl2b='''''';
		case 3	% hook for equations other than heat or wave
			handles.vars.ttl2b=handles.u0primelab;
			inp=inputdlg('Enter name of module (without .m extension)',...
				'Enter equation',1,{handles.vars.type});
			if length(inp)>0
				if exist(inp{1})
					clear(inp{1});
					eq=inp{1};
					ttl1=['[''' inp{1} ',   coefficient: '' num2str(handles.vars.c) '' ,   '];
				else
					modalerrordlg([inp{1} ' does not exist!']);
					return
				end
			else
				return
			end
		otherwise	% user chose 'Cancel'
			return;
	end

	switch menu('Choose boundary conditions',...
		'Dirichlet','Neumann','Mixed DN','Mixed ND','Periodic','Other','Cancel')
		case 1	% Dirichlet case
			bdc='dirichlet';
			ttl1=[ttl1 ''' handles.vars.uvar ''(0, '' handles.vars.tvar '') = '' handles.vars.uvar ''('' num2str(handles.vars.L) '', '' handles.vars.tvar '') = 0'']'];
		case 2	% Neumann case
			bdc='neumann';
			ttl1=[ttl1 ''' handles.vars.uvar ''_'' handles.vars.xvar ''(0, '' handles.vars.tvar '') = '' handles.vars.uvar ''_'' handles.vars.xvar ''('' num2str(handles.vars.L) '', '' handles.vars.tvar '') = 0'']'];
		case 3	% Mixed Dirichlet-Neumann case
			bdc='mixeddn';
			ttl1=[ttl1 ''' handles.vars.uvar ''(0, '' handles.vars.tvar '') = 0, '' handles.vars.uvar ''_'' handles.vars.xvar ''('' num2str(handles.vars.L) '', '' handles.vars.tvar '') = 0'']'];
		case 4	% Mixed Neumann-Dirichlet case
			bdc='mixednd';
			ttl1=[ttl1 ''' handles.vars.uvar ''_'' handles.vars.xvar ''(0, '' handles.vars.tvar '') = 0, '' handles.vars.uvar ''('' num2str(handles.vars.L) '', '' handles.vars.tvar '') = 0'']'];
		case 5	% periodic case
			bdc='periodic';
			ttl1=[ttl1 ''' handles.vars.uvar ''(0, '' handles.vars.tvar '') = '' handles.vars.uvar ''('' num2str(handles.vars.L) '', '' handles.vars.tvar ''),   '' handles.vars.uvar ''_'' handles.vars.xvar ''(0,'' handles.vars.tvar '') = '' handles.vars.uvar ''_'' handles.vars.xvar ''('' num2str(handles.vars.L) '', '' handles.vars.tvar '')'']'];
		case 6	% hook for other boundary conditions
			inp=inputdlg('Enter name of module (without .m extension)',...
				'Enter equation',1,{handles.vars.bdcond});
			if length(inp)>0
				if exist(inp{1})
					clear(inp{1});
					bdc=inp{1};
					ttl1=[ttl1 bdc ', length: '' num2str(handles.vars.L) ]'];
				else
					modalerrordlg([inp{1} ' does not exist!']);
					return
				end
			else
				return
			end
		otherwise	% user chose 'Cancel'
			return
	end

	backup=handles.vars;
	csr=swapcursor(handles.main,'watch');
	try
		handles.vars.type=eq;
		handles.vars.bdcond=bdc;
		handles.vars.ttl1=ttl1;
		update(h,eventdata,handles);
		handles=guidata(h);
	catch
		modalerrordlg(lasterr);
		handles.vars=backup;
		guidata(h,handles);
		initplots(h,eventdata,handles);
	end
	swapcursor(handles.main,csr);


% --------------------------------------------------------------------
function varargout = bdvalmenu_Callback(h, eventdata, handles, varargin)
% ... lets the user change length, duration, and boundary values
	if strcmp(handles.vars.type,'heat')
		inp=inputdlg({'Thermal diffusivity k',[handles.vars.xvar '-Length'],...
			[handles.vars.tvar '-Duration'],...
			'Initial temperature function'},...
			'Enter parameters and initial data',1,...
			{num2str(handles.vars.c),num2str(handles.vars.L),...
			num2str(handles.vars.T),handles.vars.f1});
		if length(inp)==0
			return
		end
	else
		inp=inputdlg({'Coefficient c (wave speed)',...
			[handles.vars.xvar '-Length'],...
			[handles.vars.tvar '-Duration'],...
			'Initial displacement','Initial velocity'},...
			'Enter parameters and initial data',1,...
			{num2str(handles.vars.c),num2str(handles.vars.L),...
			num2str(handles.vars.T),handles.vars.f1,handles.vars.f2});
		if length(inp)==0
			return
		end
	end
	backup=handles.vars;
	csr=swapcursor(handles.main,'watch');
	try
		c=eval(inp{1});
		L=eval(inp{2});
		if L<=0
			modalerrordlg('Length must be positive!');
			return
		end
		T=eval(inp{3});
		if T<=0
			modalerrordlg('Duration must be positive!');
			return
		end
		handles.vars.c=c;
		handles.vars.L=L;
		handles.vars.T=T;
		handles.vars.f1=inp{4};
		if length(inp)>4
			handles.vars.f2=inp{5};
		else
			handles.vars.f2='0';
		end
		update(h,eventdata,handles);
		handles=guidata(h);
	catch
		handles.vars=backup;
		guidata(h,handles);
		initplots(h,eventdata,handles);
		modalerrordlg(lasterr);
	end
	swapcursor(handles.main,csr);


% --------------------------------------------------------------------
function varargout = displaymenu_Callback(h, eventdata, handles, varargin)
% ... lets the user change display parameters
	inp=inputdlg({['Number of grid points (' handles.vars.xvar '-axis)'],...
		['Number of grid points (' handles.vars.tvar '-axis)'],...
		'Top harmonic in series approximation',...
		'Number of plot points (snapshots/slices)'},...
		'Change resolution',1,...
		{num2str(handles.vars.xn),num2str(handles.vars.tn),...
		 num2str(handles.vars.nmax),num2str(handles.vars.nopts)});
	if length(inp)>0
		csr=swapcursor(handles.main,'watch');
		backup=handles.vars;
		try
			xn=round(eval(inp{1}));
			tn=round(eval(inp{2}));
			nmax=round(eval(inp{3}));
			nopts=round(eval(inp{4}));
			if xn<1 | tn<1
				modalerrordlg('Number of plot points must be at least one!')
				return
			end
			if nmax<0
				modalerrordlg('Top harmonic must be nonnegative!')
				return
			end
			if nopts<1
				modalerrordlg('Number of plot points must be at least one!')
				return
			end
			handles.vars.xn=xn;
			handles.vars.tn=tn;
			handles.vars.nmax=nmax;
			handles.vars.nopts=nopts;
			update(h,eventdata,handles);
			handles=guidata(h);
		catch
			modalerrordlg(lasterr);
			handles.vars=backup;
			guidata(h,handles);
			initplots(h,eventdata,handles);
		end;
		swapcursor(handles.main,csr);
	end


function varargout=update(h,eventdata,handles,varargin)
% ... updates the current solution, i.e., computes coefficients for
% series expansions and such
	csr=swapcursor(handles.main,'watch');
	[ef,wn]=feval(handles.vars.bdcond,handles.vars.L,handles.vars.nmax);
		% ef=list of eigenfunctions, wn=list of eigenvalues

	ff1=inline(vectorize([handles.vars.f1 '+0*' handles.vars.xvar]),...
		handles.vars.xvar);
	ff2=inline(vectorize([handles.vars.f2 '+0*' handles.vars.xvar]),...
		handles.vars.xvar);

	cn1=coeff(ff1,ef,wn,linspace(0,handles.vars.L,32*length(wn)));
	cn2=coeff(ff2,ef,wn,linspace(0,handles.vars.L,32*length(wn)));

	handles.vars.xx=linspace(0,handles.vars.L,handles.vars.xn+1);
	handles.vars.tt=linspace(0,handles.vars.T,handles.vars.tn+1);
	handles.vars.uu=feval(handles.vars.type,ef,wn,cn1,handles.vars.c,...
		handles.vars.xx,handles.vars.tt,cn2);

	handles.vars.ttl={eval(handles.vars.ttl1),'',...
		[eval(handles.vars.ttl2a) eval(handles.vars.ttl2b)]};

	handles.vars.ef=ef;
	handles.vars.wn=wn;
	handles.vars.cn1=cn1;
	handles.vars.cn2=cn2;

	guidata(h,handles);
	initplots(h,eventdata,handles);
	swapcursor(handles.main,csr);


function varargout = initplots(h,eventdata,handles,varargin)
	plottxu(h,eventdata,handles);
	initslices(h,eventdata,handles);


function varargout = captionmenu_Callback(h,eventdata,handles,varargin)
	inp=inputdlg('Enter caption','Enter caption',1,...
		{get(handles.caption,'String')});
	if length(inp)>0
		set(handles.caption,'String',inp{1});
	end


function varargout = changevarmenu_Callback(h,eventdata,handles,varargin)
	inp=inputdlg({'First independent variable',...
		'Second independent variable',...
		'Dependent variable'},...
		'Relabel variables',1,...
		{handles.vars.xvar,handles.vars.tvar,handles.vars.uvar});
	if length(inp)>0
		backup=handles.vars;
		try
			handles.vars.f1=subvars(handles.vars.f1,...
				{handles.vars.xvar,handles.vars.tvar,handles.vars.uvar},inp);
			handles.vars.f2=subvars(handles.vars.f2,...
				{handles.vars.xvar,handles.vars.tvar,handles.vars.uvar},inp);
			handles.vars.xvar=inp{1};
			handles.vars.tvar=inp{2};
			handles.vars.uvar=inp{3};
			guidata(h,handles);
			update(h,eventdata,handles,varargin);
		catch
			handles.vars=backup;
			guidata(h,handles);
			update(h,eventdata,handles,varargin);
			modalerrordlg(lasterr);
		end
	end


function dummy()
% auxiliary function that never gets called; it merely contains calls
% to functions that would otherwise be hidden in eval statements; the
% idea is to get all dependencies when using depfun
	heat;
	wave;
	dirichlet;
	neumann;
    mixeddn;
    mixednd;
	periodic;
	cosef;
	sinef;
	periodicef;

