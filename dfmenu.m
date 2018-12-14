function dfmenu()
% function dfmenu()
%
% (c) 2001, Peter Brinkmann (brinkman@math.uiuc.edu)
%
% dfmenu: text menu for df and friends.
%
% Usage: dfmenu;
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

	tvar='x';
	xvar='y';
	fs=['sin(' tvar '-' xvar ')'];
	xdot=inline(vectorize(['(' fs ')+0*' xvar]),tvar,xvar);

	tmin=-pi;
	tmax=pi;
	xmin=-pi;
	xmax=pi;
	tn=15;
	xn=15;
	tc=linspace(tmin,tmax,tn);
	xc=linspace(xmin,xmax,xn);

	t0=(tmin+tmax)/2;
	x0=(xmin+xmax)/2;
	hh=0.1;
	method='rk';
	col='r';

	fnct=['exp(' tvar ')'];

	fname='dfplot';

	df(xdot,tc,xc,tvar,xvar,['d',xvar,'/d',tvar,'=',fs]);

	nn=1;
	while nn>0
		disp(' ');
		disp(' ');
		disp(['d',xvar,'/d',tvar,'=',fs,', options=(',method,', ',num2str(hh),')']);
		disp(' ');
		try
			nn=menu('', 'Enter equation', 'Enter display parameters', 'Plot numerical solution', 'Change numerical solver', 'Plot arbitrary function', 'Clear plots', 'Save plot', 'Quit');
		catch
			nn=0;
		end
		switch nn
			case 1
				fold=fs;
				tvarold=tvar;
				xvarold=xvar;
				try
					tvar=definput('Enter letter for independent variable',tvar);
					xvar=definput('Enter letter for dependent variable  ',xvar);
					fs=definput('Function',fs,['Enter function f(',tvar,',',xvar,')']);
					try
						% Under Octave, we need to clear the current inline
						% function xdot, or else the inline hack from .octaverc
						% will leak memory. Under Matlab, the next line will
						% cause an exception.
						clear(xdot);
					catch
						% do nothing;
					end
					xdot=inline(vectorize(['(' fs ')+0*' xvar]),tvar,xvar);
					df(xdot,tc,xc,tvar,xvar,['d',xvar,'/d',tvar,'=',fs]);
				catch
					disp(lasterr);
					complain('Reverting to previous function.');
					fs=fold;
					tvar=tvarold;
					xvar=xvarold;
					try
						clear(xdot);
					catch
						% do nothing;
					end
					xdot=inline(vectorize(['(' fs ')+0*' xvar]),tvar,xvar);
					df(xdot,tc,xc,tvar,xvar,['d',xvar,'/d',tvar,'=',fs]);
				end
			case 2
				tminold=tmin;
				tmaxold=tmax;
				xminold=xmin;
				xmaxold=xmax;
				tnold=tn;
				xnold=xn;
				try
					tmin=definput([tvar,'min'],tmin);
					tmax=definput([tvar,'max'],tmax);
					if tmin>=tmax
						complain([tvar,'min has to be smaller than ',tvar,'max! Reverting to previous values.']);
						tmin=tminold;
						tmax=tmaxold;
					end
					xmin=definput([xvar,'min'],xmin);
					xmax=definput([xvar,'max'],xmax);
					if xmin>=xmax
						complain([xvar,'min has to be smaller than ',xvar,'max! Reverting to previous values.']);
						xmin=xminold;
						xmax=xmaxold;
					end
					tn=definput('Number of line segments (horizontal)',tn);
					if tn<2
						complain([tvar,'n has to be larger than 1! Reverting to previous value.']);
						tn=tnold;
					end
					xn=definput('Number of line segments (vertical)  ',xn);
					if xn<2
						complain([xvar,'n has to be larger than 1! Reverting to previous values.']);
						xn=xnold;
					end
				catch
					complain('Reverting to previous values.');
					tmin=tminold;
					tmax=tmaxold;
					xmin=xminold;
					xmax=xmaxold;
					tn=tnold;
					xn=xnold;
				end
				if (t0<tmin) | (t0>tmax)
					t0=(tmin+tmax)/2;
				end
				if (x0<xmin) | (x0>xmax)
					x0=(xmin+xmax)/2;
				end
				tc=linspace(tmin,tmax,tn);
				xc=linspace(xmin,xmax,xn);
				try
					df(xdot,tc,xc,tvar,xvar,['d',xvar,'/d',tvar,'=',fs]);
				catch
					disp(lasterr);
					complain('Please check your settings.');
				end
			case 3
				told=t0;
				xold=x0;
				try
					t0=definput([tvar,'0'],t0,['Enter initial ',tvar,'-value']);
					if t0<tmin | t0>tmax
						complain('Value out of range! Reverting to previous value.');
						t0=told;
					end
				catch
					t0=told;
				end
				try
					x0=definput([xvar,'(',num2str(t0),')'],x0,['Enter initial ',xvar,'-value']);
					if x0<xmin | x0>xmax
						complain('Value out of range! Reverting to previous value.');
						x0=xold;
					end
				catch
					x0=xold;
				end
				try
					colold=col;
					col=definput('Color',col,'Enter color. Options include r (red), b (blue), g (green), m (magenta).');
				catch
					col=colold;
				end
				disp(['Plotting solution through (', num2str(t0),', ',num2str(x0),')']);
				try
					clear(method);% Make sure to use latest version of method.
							% Without this line, one would have to restart
							% this GUI every time the method file is updated.
					solplot(xdot,x0,(t0:hh:tmax),method,col);
					solplot(xdot,x0,(t0:(-hh):tmin),method,col);
				catch
					disp(lasterr);
					complain('Please check your settings.');
				end
			case 4
				methodold=method;
				oldhh=hh;
				try
					method=definput('Numerical method',method,'Enter numerical method. Choices include euler and rk.');
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
					fnct=definput(['Function ',xvar,'(',tvar,')'],fnct);
					eval([tvar,'=linspace(tmin,tmax,1000);']);
					eval([xvar,'=' vectorize([fnct '+ 0*' tvar]) ';']);
					col=definput('Color',col,'Enter color. Options include r (red), b (blue), g (green), m (magenta).');
	
					eval(['plot(',tvar,',',xvar,',col)']);
				catch
					disp(lasterr);
					complain('Please check your input.');
					fnct=fnold;
					col=colold;
				end
			case 6
				try
					df(xdot,tc,xc,tvar,xvar,['d',xvar,'/d',tvar,'=',fs]);
				catch
					disp(lasterr);
					complain('Please check your settings.');
				end
			case 7
				fname=exportmenu(fname);
			otherwise
				nn=0;
		end
	end

	% just ignore the next few lines; their only purpose is to make some
	% dependencies explicit
	dummy=0;
	if dummy==1
		euler;
		rk;
	end

