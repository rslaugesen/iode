function varargout = fsgui(varargin)
% function varargout = fsgui(varargin)
%
% (c) 2002, Peter Brinkmann (brinkman@math.uiuc.edu)
%
% fsgui: Graphical user interface for Iode's Fourier series modules
%
% Usage:
%	fig = fsgui
%			 launch GUI.
%	fsgui('callback_name', ...)
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

	global numtol;
	handles.numtol=numtol;	% numerical tolerance; numerical values smaller
							% than handles.numtol will be treated as 0

	handles.id='fsgui 3.0';		% ID tag; should be updated whenever the
								% format of saved files changes

	handles.dir='';				% variables for remembering paths and files
	handles.filename='*.mat';

	handles.barwidth=0.9;	% width of bars for plot of coefficients

	handles.vars=struct(...
		'xvar','x',...				% label of independent variable
		'fn',['sign(x)'],...		% string containing target function
		'an',[],...					% Fourier coefficients A_n
		'bn',[],...					% Fourier coefficients B_n
		'abn',[],...				% absolute Fourier coefficients
		'x0',-pi,...				% function defined on [x0,x1]
		'x1',pi,...
		'xn',500,...			% plot xn points
		'afs','1/n');			% arbitrary function for comparison feature

	partialsumsbutton_Callback(fig,[],handles); % init display w/ partial sums

	handles=guidata(fig);

	guidata(fig, handles);

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
function varargout = partialsumsbutton_Callback(h, eventdata, handles, varargin)
% ... updates radio buttons and menus and displays partial sums and error plots
	set(handles.partialsumsbutton,'Value',1.0);
	set(handles.plotcoeffbutton,'Value',0.0);
	set(handles.plotcnbutton,'Value',0.0);
	set(handles.compfuncmenu,'Enable','off');
	set(handles.displaymenu,'Enable','on');
	replot(h, eventdata, handles, varargin);


% --------------------------------------------------------------------
function varargout = plotcoeffbutton_Callback(h, eventdata, handles, varargin)
% ... updates radio buttons and menus and displays Fourier coefficients
	set(handles.partialsumsbutton,'Value',0.0);
	set(handles.plotcoeffbutton,'Value',1.0);
	set(handles.plotcnbutton,'Value',0.0);
	set(handles.compfuncmenu,'Enable','off');
	set(handles.displaymenu,'Enable','off');
	replot(h, eventdata, handles, varargin);


% --------------------------------------------------------------------
function varargout = plotcnbutton_Callback(h, eventdata, handles, varargin)
% ... updates radio buttons and menus
%  and displays absolute Fourier coefficients
	set(handles.partialsumsbutton,'Value',0.0);
	set(handles.plotcoeffbutton,'Value',0.0);
	set(handles.plotcnbutton,'Value',1.0);
	set(handles.compfuncmenu,'Enable','on');
	set(handles.displaymenu,'Enable','off');
	replot(h, eventdata, handles, varargin);


% --------------------------------------------------------------------
function varargout = topharmonic_Callback(h, eventdata, handles, varargin)
% ... updates top harmonic for plotting
	try
		n=round(eval(get(handles.topharmonic,'String')));
		if n>=0
			set(handles.topharmonic,'String',num2str(n));
		else
			error('Top harmonic must be nonnegative!');
		end
	catch
		modalerrordlg(lasterr);
		set(handles.topharmonic,'String','0');
	end
	replot(h, eventdata, handles, varargin);


% --------------------------------------------------------------------
function varargout = decharmonic_Callback(h, eventdata, handles, varargin)
% ... decreases top harmonic for plotting
	try
		n=round(eval(get(handles.topharmonic,'String'))-1);
		if n<0
			n=0;
		end
	catch
		modalerrordlg(lasterr);
		n=0;
	end
	set(handles.topharmonic,'String',num2str(n));
	replot(h, eventdata, handles, varargin);


% --------------------------------------------------------------------
function varargout = incharmonic_Callback(h, eventdata, handles, varargin)
% ... increases top harmonic for plotting
	try
		n=round(eval(get(handles.topharmonic,'String'))+1);
		if n<0
			n=0;
		end
	catch
		modalerrordlg(lasterr);
		n=0;
	end
	set(handles.topharmonic,'String',num2str(n));
	replot(h, eventdata, handles, varargin)


% --------------------------------------------------------------------
function varargout = openmenu_Callback(h, eventdata, handles, varargin)
% ... restores settings from a file

	[fn,dir]=uigetfile([handles.dir handles.filename]);
	if ischar(fn) % proceed if user didn't choose 'Cancel'
		csr=swapcursor(handles.main,'watch');

		% save current settings in case something goes wrong
		backup=handles.vars;
		thold=get(handles.topharmonic,'String');

		handles.dir=dir;		% remember file name and path
		handles.filename=fn;

		try
			load([dir fn]);
			try % make sure that the file was saved by the right version
				if ~strcmp(id,handles.id)
					error('Wrong or outdated file type for this module!');
				end
			catch
				error('Wrong or outdated file type for this module!');
			end
			handles.vars=tmp;
			guidata(h,handles);
			set(handles.topharmonic,'String',th);
			update(h,eventdata,handles,...
				eval(get(handles.topharmonic,'String')));
			handles=guidata(h);
			set(handles.showcompfuncmenu,'Checked',cmpf);
			set(handles.caption,'String',cap);
			if ps
				partialsumsbutton_Callback(h,eventdata,handles,varargin);
			elseif cob
				plotcoeffbutton_Callback(h,eventdata,handles,varargin);
			elseif cn
				plotcnbutton_Callback(h,eventdata,handles,varargin);
			else
				replot(h,eventdata,handles,varargin);
			end
		catch % restore old settings
			modalerrordlg(lasterr);
			handles.vars=backup;
			guidata(h,handles);
			set(handles.topharmonic,'String',eval(thold));
			replot(h,eventdata,handles,varargin);
		end
		swapcursor(handles.main,csr);
	end


% --------------------------------------------------------------------
function varargout = savemenu_Callback(h, eventdata, handles, varargin)
% ... saves current settings to a file
	[fn,dir]=uiputfile([handles.dir handles.filename]);
	if ischar(fn) % proceed if user didn't choose 'Cancel'
		handles.dir=dir;		% remember file name and path
		handles.filename=fn;
		guidata(h,handles);

		id=handles.id;
		tmp=handles.vars;
		ps=get(handles.partialsumsbutton,'Value');
		cob=get(handles.plotcoeffbutton,'Value');
		cn=get(handles.plotcnbutton,'Value');
		th=get(handles.topharmonic,'String');
		cmpf=get(handles.showcompfuncmenu,'Checked');
		cap=get(handles.caption,'String');
		try
			save([dir fn],'id','tmp','ps','cob','cn','th','cmpf','cap');
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
function varargout = functionmenu_Callback(h, eventdata, handles, varargin)
% ... changes function and interval
	inp=inputdlg({['Function f(' handles.vars.xvar ')'],...
		'Left end of period interval',...
		'Right end of period interval'},...
		'Enter function',1,...
		{handles.vars.fn,num2str(handles.vars.x0),num2str(handles.vars.x1)});
	if length(inp)>0 % proceed if user didn't choose 'Cancel'

		backup=handles.vars;	% save current settings in case
								% something goes wrong

		csr=swapcursor(handles.main,'watch');
		try
			x0=eval(inp{2});
			x1=eval(inp{3});
			if x0>=x1
				error('Lower bound must be smaller than upper bound');
			end
			handles.vars.x0=x0;
			handles.vars.x1=x1;
			handles.vars.fn=inp{1};
			update(h,eventdata,handles,...
				eval(get(handles.topharmonic,'String')));
			handles=guidata(h);
		catch
			modalerrordlg(lasterr);
			handles.vars=backup;
			guidata(h,handles);
		end
		replot(h,eventdata,handles,varargin);
		swapcursor(handles.main,csr);
	end


% --------------------------------------------------------------------
function varargout = displaymenu_Callback(h, eventdata, handles, varargin)
% ... changes display parameters
	inp=inputdlg('Enter number of points to be plotted',...
		'Change plot resolution',1,{num2str(handles.vars.xn)});
	if length(inp)>0 % proceed if user didn't choose 'Cancel'

		backup=handles.vars; % remember current settings

		csr=swapcursor(handles.main,'watch');
		try
			xn=round(eval(inp{1}));
			if xn<2
				modalerrordlg('Number of plot points must be at least 2!');
				return
			else
				handles.vars.xn=xn;
				guidata(h,handles);
				update(h,eventdata,handles,...
					eval(get(handles.topharmonic,'String')));
				handles=guidata(h);
				replot(h,eventdata,handles,varargin);
			end
		catch
			modalerrordlg(lasterr);
			handles.vars=backup;
			guidata(h,handles);
			replot(h,eventdata,handles,varargin);
		end
		swapcursor(handles.main,csr);
	end


% --------------------------------------------------------------------
function varargout = replot(h, eventdata, handles, varargin)
% ... redraws the picture according to values of radio buttons
	csr=swapcursor(handles.main,'watch');
	try
		nmax=eval(get(handles.topharmonic,'String'));
		if nmax+1>length(handles.vars.an)	% do we need to compute coefficients?
			update(h,eventdata,handles,nmax);
			handles=guidata(h);
		end

		if get(handles.partialsumsbutton,'Value') % plot partial sums?
			axes(handles.axes1);
			fixaxes([handles.vars.xrange,handles.vars.yrange]);
			grid on;
			set(plot(handles.vars.xx,handles.vars.fp),'Color',[0 0 0.7]);
			plot(handles.vars.xx,handles.vars.ps(nmax+1,:),'r');
			% Note that handles.vars.ps(nmax+1,:) is the nmax-th partial sum.

			title(['f(' handles.vars.xvar ') = ' handles.vars.fn ' for ' ...
				num2str(handles.vars.x0) ' <= ' handles.vars.xvar ' < ' ...
				num2str(handles.vars.x1) ', extended periodically']);
			xlabel(handles.vars.xvar);
			ylabel('');

			axes(handles.axes2);
			ep=handles.vars.fp-handles.vars.ps(nmax+1,:);
			Sm=min(ep);
			Sp=max(ep);
			S=(Sp-Sm)/8;
			fixaxes([handles.vars.xrange,...
				Sm-S-handles.numtol,Sp+S+handles.numtol]);
			grid on;
			set(plot(handles.vars.xx,ep),'Color',[0 0.35 1]);
			title(['Error plot: f(' handles.vars.xvar ') - (partial sum) ']);
			xlabel(handles.vars.xvar);
			ylabel('');
		elseif get(handles.plotcoeffbutton,'Value') % plot coefficients?
			if nmax<1	% rule out nmax=0 so as not to create confusion with
						% our treatment of the coefficient a0
				nmax=1;
			end
			axes(handles.axes1);
			fixaxes([0,nmax+1,handles.vars.anrange]);
			grid off;
			bar(1:nmax,handles.vars.an(2:(nmax+1)),handles.barwidth,'b');
			title(['A_n for n>0: Fourier coefficients of f(' ...
					handles.vars.xvar ') = ' handles.vars.fn  ' for ' ...
                num2str(handles.vars.x0) ' <= ' handles.vars.xvar ' < ' ...
                num2str(handles.vars.x1)]);
			xlabel('n');
			ylabel('');

			axes(handles.axes2);
			fixaxes([0,nmax+1,handles.vars.bnrange]);
			grid off;
			bar(1:nmax,handles.vars.bn(2:(nmax+1)),handles.barwidth,'b');
			title(['B_n for n>0: Fourier coefficients of f(' ...
				handles.vars.xvar ') = ' handles.vars.fn  ' for ' ...
                num2str(handles.vars.x0) ' <= ' handles.vars.xvar ' < ' ...
                num2str(handles.vars.x1)]);
			xlabel('n');
			ylabel('');
		elseif get(handles.plotcnbutton,'Value') % plot absolute coefficients?
			if nmax<1	% see previous case
				nmax=1;
			end

			axes(handles.axes1);
			fixaxes([0,nmax+1,handles.vars.abnrange]);
			grid off;
			bar(1:nmax,handles.vars.abn(2:(nmax+1)),handles.barwidth,'b');
			title(['C_n for n>0: Absolute Fourier coefficients of f(' ...
					handles.vars.xvar ') = ' handles.vars.fn]);
			xlabel('n');
			ylabel('');

			cmpflag=strcmp(get(handles.showcompfuncmenu,'Checked'),'on');

			axes(handles.axes2);
			if cmpflag		% show comparison function?
				n=(1:nmax)';
				cmpfunc=eval(vectorize(handles.vars.afs));
				qq=handles.vars.abn(2:(nmax+1))./cmpfunc;
				Sp=max(0,max(qq));
				Sm=min(0,min(qq));
				S=(Sp-Sm)/8;
				fixaxes([0,nmax+1,...
					Sm-S-handles.numtol,...
					Sp+S+handles.numtol]);
				grid off;
				bar(1:nmax,qq,handles.barwidth,'c');
				title(['Ratio C_n / (' handles.vars.afs ') for n>0']);
				xlabel('n');
				ylabel('');
			else
				freeaxes;
			end
		end
		guidata(h,handles);
	catch
		modalerrordlg(lasterr);
	end
	swapcursor(handles.main,csr);


function varargout=update(h,eventdata,handles,nmax)
% ... computes Fourier coefficients and such
	ff=inline(vectorize([handles.vars.fn '+0*' handles.vars.xvar]),...
			handles.vars.xvar);

	handles.vars.L=(handles.vars.x1-handles.vars.x0)/2; % half interval
	handles.vars.xx=linspace(handles.vars.x0-handles.vars.L,...
		handles.vars.x1+handles.vars.L,2*handles.vars.xn+1); % plot points
	handles.vars.xp=mp(handles.vars.x0,handles.vars.x1,handles.vars.xx);
		% xp=plot points renormalized to interval [x0,x1]

	handles.vars.fp=feval(ff,handles.vars.xp); % function f evaluated at xp
	[handles.vars.an,...
	 handles.vars.bn,handles.vars.abn]=fs(ff,... % compute Fourier coeffs
		handles.vars.x0,handles.vars.x1,nmax+25);
	handles.vars.ps=partialsum(handles.vars.L,...
		handles.vars.an,handles.vars.bn,handles.vars.xx);% compute partial sums

	% the remaining lines compute display parameters
	N=length(handles.vars.an);
	Sp=max([0,max(handles.vars.an(2:N))]);
	Sm=min([0,min(handles.vars.an(2:N))]);
	S=(Sp-Sm)/8;
	handles.vars.anrange=[Sm-S-handles.numtol,Sp+S+handles.numtol];
	% We need to add/subtract the numerical tolerance here in order
	% not to have an empty y-range if all coefficients are 0.

	Sp=max([0,max(handles.vars.bn(2:N))]);
	Sm=min([0,min(handles.vars.bn(2:N))]);
	S=(Sp-Sm)/8;
	handles.vars.bnrange=[Sm-S-handles.numtol,Sp+S+handles.numtol];

	Sp=max([0,max(handles.vars.abn(2:N))]);
	Sm=min([0,min(handles.vars.abn(2:N))]);
	S=(Sp-Sm)/8;
	handles.vars.abnrange=[Sm-S-handles.numtol,Sp+S+handles.numtol];

	Sp=max(max(max(handles.vars.ps)));
	Sm=min(min(min(handles.vars.ps)));
	S=(Sp-Sm)/8;
	handles.vars.xrange=[min(handles.vars.xx),max(handles.vars.xx)];
	handles.vars.yrange=[Sm-S-handles.numtol,Sp+S+handles.numtol];

	guidata(h,handles);


% --------------------------------------------------------------------
function varargout = captionmenu_Callback(h,eventdata,handles,varargin)
% ... lets the user enter a caption for entire window
	inp=inputdlg('Enter caption','Enter caption',1,...
		{get(handles.caption,'String')});
	if length(inp)>0
		set(handles.caption,'String',inp{1});
	end


% --------------------------------------------------------------------
function varargout = showcompfuncmenu_Callback(h, eventdata, handles, varargin)
% ... toggles menu for displaying comparison function
	if strcmp(get(handles.showcompfuncmenu,'Checked'),'on')
		set(handles.showcompfuncmenu,'Checked','off');
	else
		set(handles.showcompfuncmenu,'Checked','on');
	end
	replot(h, eventdata, handles, varargin);


% --------------------------------------------------------------------
function varargout = entercompfuncmenu_Callback(h, eventdata, handles, varargin)
% ... lets the user enter a comparison function
	inp=inputdlg('Function g(n)','Enter function for comparison',...
		1,{handles.vars.afs});
	if length(inp)==0
		return
	end

	afs=inp{1};
	try	% check whether answer is syntactically correct
		n=[1:100];
		dummy=eval(vectorize(afs));
	catch
		modalerrordlg(lasterr);
		return
	end

	handles.vars.afs=afs;
	set(handles.showcompfuncmenu,'Checked','on');

	guidata(h,handles);
	replot(h, eventdata, handles, varargin);


function varargout = changevarmenu_Callback(h,eventdata,handles,varargin)
	inp=inputdlg({'Independent variable'},'Relabel variables',1,...
		{handles.vars.xvar});
	if length(inp)>0
		backup=handles.vars;
		try
			handles.vars.fn=subvars(handles.vars.fn,...
				{handles.vars.xvar},inp);
			handles.vars.xvar=inp{1};
			guidata(h,handles);
			update(h,eventdata,handles,...
				eval(get(handles.topharmonic,'String')));
			handles=guidata(h);
			replot(h,eventdata,handles,varargin);
		catch
			handles.vars=backup;
			guidata(h,handles);
			replot(h,eventdata,handles,varargin);
			modalerrordlg(lasterr);
		end
	end

