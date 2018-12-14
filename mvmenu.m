function mvmenu()
% function mvmenu()
%
% (c) 2001, Peter Brinkmann (brinkman@math.uiuc.edu)
%
% mvmenu: text menu for 2nd order linear ODEs
%
% Usage: mvmenu;
%
% Note: The menu allows the user to change the names of independent and
% dependent variables. In order to avoid conflicts between those names
% and the names of internal variables, we adopt the convention that user
% defined variable names can only have one letter, whereas internal
% variable names have to have at least two letters.
%
% Acknowledgments:
%	- Many thanks to Robert Jerrard and Richard Laugesen for valuable
%	  feedback and suggestions.

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (http://www.gnu.org/copyleft/gpl.html).

	xvar='x';
	yvar='yy';
	tvar='t';

	auxfn='';

	prs=setstr(39);
	fnct=['exp(' tvar ')'];
	fts=['cos(2*' tvar ')'];
	mm='1';
	kk='1';
	cc='0.5';

	tmin=-2*pi;
	tmax=2*pi;
	xmin=-5;
	xmax=5;

	t0=(tmin+tmax)/2;
	x0=(xmin+xmax)/2;
	dx0=1;
	hh=0.1;
	eval([tvar '=linspace(tmin,tmax,1000);']);
	method='rk';
	col='r';
	dcol='b';

	fname='mvplot';

	fixaxes([tmin,tmax,xmin,xmax]);
	title(['(',mm,')',xvar,prs,prs,' + (',cc,')',xvar,prs,' + (',kk,')',xvar,' = ',fts]);
	xlabel(tvar);
	ylabel(xvar);
	eval(['plot(' tvar ',' vectorize([fts '+ 0*' tvar]) ',dcol);']);


	nn=1;
	while nn>0
		disp(' ');
		disp(' ');
		disp(['(',mm,')',xvar,prs,prs,' + (',cc,')',xvar,prs,' + (',kk,')',xvar,' = ',fts]);
		disp(' ');
		disp(['options=(',method,', ',num2str(hh),')']);
		disp(' ');
		try
			nn=menu('', 'Enter differential equation', 'Enter domain and range', 'Plot numerical solution', 'Change numerical solver', 'Plot arbitrary function', 'Clear plots', 'Save plot', 'Quit');
		catch
			nn=0;
		end
		switch nn
			case 1
				fold=fts;
				mold=mm;
				cold=cc;
				kold=kk;
				tvarold=tvar;
				xvarold=xvar;
				try
					tvar=definput('Enter letter for independent variable',tvar);
					xvar=definput('Enter letter for dependent variable  ',xvar);
					disp(' ');
					disp(['Enter equation of the form m',xvar,prs,prs,' + c',xvar,prs,' + k',xvar,' = f(',tvar,')']);
					fts=definput('f = ',fts,['Enter function f(',tvar,')']);
					mm=definput('m = ',mm,'Enter coefficient m');
					cc=definput('c = ',cc,'Enter coefficient c');
					kk=definput('k = ',kk,'Enter coefficient k');
					fixaxes([tmin,tmax,xmin,xmax]);
					eval([tvar '=linspace(tmin,tmax,1000);']);
					title(['(',mm,')',xvar,prs,prs,' + (',cc,')',xvar,prs,' + (',kk,')',xvar,' = ',fts]);
					xlabel(tvar);
					ylabel(xvar);
					eval(['plot(' tvar ',' vectorize([fts '+ 0*' tvar]) ',dcol);']);
				catch
					disp(lasterr);
					complain('Reverting to previous function.');
					tvar=tvarold;
					xvar=xvarold;
					fts=fold;
					mm=mold;
					cc=cold;
					kk=kold;
					fixaxes([tmin,tmax,xmin,xmax]);
					title(['(',mm,')',xvar,prs,prs,' + (',cc,')',xvar,prs,' + (',kk,')',xvar,' = ',fts]);
					xlabel(tvar);
					ylabel(xvar);
					eval(['plot(' tvar ',' vectorize([fts '+ 0*' tvar]) ',dcol);']);
				end
			case 2
				tminold=tmin;
				tmaxold=tmax;
				xminold=xmin;
				xmaxold=xmax;
				try
					tmin=definput([tvar 'min'],tmin,['Enter minimal ' tvar '-value']);
					tmax=definput([tvar 'max'],tmax,['Enter maximal ' tvar '-value']);
					if tmin>=tmax
						complain('Reverting to previous values.');
						tmin=tminold;
						tmax=tmaxold;
					end
					xmin=definput([xvar 'min'],xmin,['Enter minimal ' xvar '-value']);
					xmax=definput([xvar 'max'],xmax,['Enter maximal ' xvar '-value']);
					if xmin>=xmax
						complain('Reverting to previous values.');
						xmin=xminold;
						xmax=xmaxold;
					end
				catch
					complain('Reverting to previous values.');
					tmin=tminold;
					tmax=tmaxold;
				end
				if (t0<tmin) | (t0>tmax)
					t0=(tmin+tmax)/2;
				end
				if (x0<xmin) | (x0>xmax)
					x0=(xmin+xmax)/2;
				end
				fixaxes([tmin,tmax,xmin,xmax]);
				eval([tvar '=linspace(tmin,tmax,1000);']);
				eval(['plot(' tvar ',' vectorize([fts '+ 0*' tvar]) ',dcol);']);
			case 3
				told=t0;
				xold=x0;
				dxold=dx0;
				colold=col;
				try
					t0=definput([tvar '0'],t0,['Enter initial ' tvar '-value']);
					if t0<tmin | t0>tmax
						complain('Value out of range! Reverting to previous value.');
						t0=told;
					end
				catch
					t0=told;
				end
				try
					x0=definput([xvar '(',num2str(t0),')'],x0,['Enter initial ' xvar '-value']);
					if x0<xmin | x0>xmax
						complain('Value out of range! Reverting to previous value.');
						x0=xold;
					end
				catch
					x0=xold;
				end
				try
					dx0=definput([xvar,prs,'(',num2str(t0),')'],dx0,['Enter initial ',xvar,prs,'-value']);
					col=definput('Color',col,'Enter color. Options include r (red), b (blue), g (green), m (magenta).');
				catch
					dx0=dxold;
					col=colold;
				end
				try
					clear(method);	% Make sure to use latest version of method.
							% Without this line, one would have to restart
							% this GUI every time the method file is updated.
					fs=yvar;
					gs=['(' fts ')/(' mm ')-(' kk ')/(' mm ')*' xvar '-(' cc ')/(' mm ')*' yvar];

					ffs=subvar(vectorize(fs),xvar,'xyc(1,:)');
					ffs=subvar(ffs,yvar,'xyc(2,:)');
					ggs=subvar(vectorize(gs),xvar,'xyc(1,:)');
					ggs=subvar(ggs,yvar,'xyc(2,:)');

					try
						clear(auxfn);
					catch
						% do nothing
					end
					auxfn=inline(['[' ffs ';' ggs ']'],tvar,'xyc');

					tc=(t0:hh:tmax);
					xyc=feval(method,auxfn,[x0;dx0],tc);
					plot(tc,xyc(1,:),col);
					tc=(t0:(-hh):tmin);
					xyc=feval(method,auxfn,[x0;dx0],tc);
					plot(tc,xyc(1,:),col);
				catch
					disp(lasterr);
					complain('Please check your settings.');
				end
			case 4
				methodold=method;
				oldhh=hh;
				try
					method=definput('Numerical method',method,'Options include euler, rk.');
					if exist(method)
						methodold=method;
					else
						complain(['Method ',method,' does not exist. Reverting to previous value.']);
						method=methodold;
					end
					hh=definput('Step size',hh);
					if hh<(tmax-tmin)/10000
						complain('Value too small! Reverting to previous value.');
						hh=oldhh;
					end
					oldhh=hh;
				catch
					complain('Reverting to previous values.');
					method=methodold;
					hh=oldhh;
				end
			case 5
				fnold=fnct;
				colold=col;
				try
					fnct=definput(['Function ' xvar '(' tvar ')'],fnct);
					eval([tvar '=linspace(tmin,tmax,1000);']);
					col=definput('Color',col,'Enter color. Options include r (red), b (blue), g (green), m (magenta).');
					eval(['plot(' tvar ',' vectorize([fnct '+ 0*' tvar]) ',col);']);

				catch
					disp(lasterr);
					complain('Please check your input.');
					fnct=fnold;
					col=colold;
				end
			case 6
				fixaxes([tmin,tmax,xmin,xmax]);
				title(['(',mm,')',xvar,prs,prs,' + (',cc,')',xvar,prs,' + (',kk,')',xvar,' = ',fts]);
				xlabel(tvar);
				ylabel(xvar);
				eval(['plot(' tvar ',' vectorize([fts '+ 0*' tvar]) ',dcol);']);

			case 7
				fname=exportmenu(fname);
			otherwise
				nn=0;
		end
	end
	try
		clear(auxfn);
	catch
		% do nothing
	end

	% just ignore the next few lines; their only purpose is to make some
	% dependencies explicit
	dummy=0;
	if dummy==1
		euler;
		rk;
	end

