function ppmenu()
% function ppmenu()
%
% (c) 2001, Peter Brinkmann (brinkman@math.uiuc.edu)
%
% ppmenu: text menu for df and friends.
%
% Usage: ppmenu;
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

	global numtol;	% numerical tolerance

	xvar='x';
	yvar='y';
	tvar='t';
	fs=['-' yvar];
	gs=xvar;

	ffs=subvar(vectorize([fs '+0*' xvar]),xvar,'xyc(1,:)');
	ffs=subvar(ffs,yvar,'xyc(2,:)');
	ggs=subvar(vectorize([gs '+0*' xvar]),xvar,'xyc(1,:)');
	ggs=subvar(ggs,yvar,'xyc(2,:)');
	auxfn=inline(['[' ffs ';' ggs ']'],tvar,'xyc');

	xfnct=[tvar '*cos(' tvar ')/pi'];
	yfnct=[tvar '*sin(' tvar ')/pi'];
	ta0=0;
	ta1=2*pi;

	xmin=-2;
	xmax=2;
	ymin=-2;
	ymax=2;
	xn=15;
	yn=15;
	xx=linspace(xmin,xmax,xn);
	yy=linspace(ymin,ymax,yn);

	x0=(xmin+2*xmax)/3;
	y0=(ymin+ymax)/2;
	t0=0;
	t1=2*pi;
	method='rk';
	hh=0.1;
	col='r';

	fname='ppplot';

	pp(auxfn,xx,yy,xvar,yvar,['d' xvar '/d' tvar ' = ' fs ', d' yvar '/d' tvar ' = ' gs],'b',1,t0);

	nn=1;
	while nn>0
		disp(' ');
		disp(' ');
		disp(['d' xvar '/d' tvar ' = ' fs]);
		disp(['d' yvar '/d' tvar ' = ' gs]);
		disp(' ');
		disp(['options=(',method,', ',num2str(hh),')']);
		disp(' ');
		try
			nn=menu('', 'Enter functions', 'Enter display parameters', 'Plot numerical solution', 'Change numerical solver', 'Plot arbitrary trajectory', 'Clear plot', 'Save plot', 'Quit');
		catch
			nn=0;
		end
		try
			switch nn
				case 1
					xvarold=xvar;
					yvarold=yvar;
					tvarold=tvar;
					fxold=fs;
					gxold=gs;
					try
						tvar=definput('Enter letter for independent variable ',tvar);
						xvar=definput('Enter letter for dependent variable (horizontal)',xvar);
						yvar=definput('Enter letter for dependent variable (vertical)  ',yvar);
						fs=definput(['F(' xvar ',' yvar ')'],fs);
						gs=definput(['G(' xvar ',' yvar ')'],gs);
						ffs=subvar(vectorize([fs '+0*' xvar]),xvar,'xyc(1,:)');
						ffs=subvar(ffs,yvar,'xyc(2,:)');
						ggs=subvar(vectorize([gs '+0*' xvar]),xvar,'xyc(1,:)');
						ggs=subvar(ggs,yvar,'xyc(2,:)');
						try
							clear(auxfn);
						catch
							% do nothing
						end
						auxfn=inline(['[' ffs ';' ggs ']'],tvar,'xyc');
						pp(auxfn,xx,yy,xvar,yvar,['d' xvar '/d' tvar ' = ' fs ', d' yvar '/d' tvar ' = ' gs],'b',1,t0);
					catch
						disp(lasterr);
						complain('Reverting to previous values.');
						xvar=xvarold;
						yvar=yvarold;
						tvar=tvarold;
						fs=fxold;
						gs=gxold;
						ffs=subvar(vectorize([fs '+0*' xvar]),xvar,'xyc(1,:)');
						ffs=subvar(ffs,yvar,'xyc(2,:)');
						ggs=subvar(vectorize([gs '+0*' xvar]),xvar,'xyc(1,:)');
						ggs=subvar(ggs,yvar,'xyc(2,:)');
						try
							clear(auxfn);
						catch
							% do nothing
						end
						auxfn=inline(['[' ffs ';' ggs ']'],tvar,'xyc');
						pp(auxfn,xx,yy,xvar,yvar,['d' xvar '/d' tvar ' = ' fs ', d' yvar '/d' tvar ' = ' gs],'b',1,t0);
					end
				case 2
					xminold=xmin;
					xmaxold=xmax;
					yminold=ymin;
					ymaxold=ymax;
					xnold=xn;
					ynold=yn;
					t0old=t0;
					try
						xmin=definput([xvar 'min'],xmin);
						xmax=definput([xvar 'max'],xmax);
						if xmax<=xmin
							complain('Reverting to previous value.');
							xmin=xminold;
							xmax=xmaxold;
						end
						ymin=definput([yvar 'min'],ymin);
						ymax=definput([yvar 'max'],ymax);
						if ymax<=ymin
							complain('Reverting to previous value.');
							ymin=yminold;
							ymax=ymaxold;
						end
						t0=definput(['Initial ' tvar '-coordinate'],t0);
						xn=definput('Number of line segments (horizontal)',xn);
						yn=definput('Number of line segments (vertical)  ',yn);
						if (xn<2) | (yn<2)
							complain('Number of segments must be a least two! Reverting to previous values.');
							xn=xnold;
							yn=ynold;
						end
						xx=linspace(xmin,xmax,xn);
						yy=linspace(ymin,ymax,yn);
						pp(auxfn,xx,yy,xvar,yvar,['d' xvar '/d' tvar ' = ' fs ', d' yvar '/d' tvar ' = ' gs],'b',1,t0);
						if (x0<xmin) | (x0>xmax)
							x0=(xmin+xmax)/2;
						end
						if (y0<ymin) | (y0>ymax)
							y0=(ymin+ymax)/2;
						end
					catch
						complain('Reverting to previous values.');
						xmin=xminold;
						xmax=xmaxold;
						ymin=yminold;
						ymax=ymaxold;
						xn=xnold;
						yn=ynold;
						t0=t0old;
						xx=linspace(xmin,xmax,xn);
						yy=linspace(ymin,ymax,yn);
						pp(auxfn,xx,yy,xvar,yvar,['d' xvar '/d' tvar ' = ' fs ', d' yvar '/d' tvar ' = ' gs],'b',1,t0);
					end
				case 3
					x0old=x0;
					y0old=y0;
					t1old=t1;
					colold=col;
					clear(method);	% Make sure to use latest version of method.
							% Without this line, one would have to restart
							% this GUI every time the method file is updated.
					try
						x0=definput([xvar '0'],x0);
						y0=definput([yvar '0'],y0);
						t1=definput([tvar '-duration of plot'],t1);
						col=definput('Color',col,'Enter color. Options include r (red), b (blue), g (green), m (magenta).');
						tc=(t0:hh*sign(t1):(t0+t1));
						xyc=trajplot(auxfn,[x0;y0],tc,method,col);
						xc=xyc(1,:);
						yc=xyc(2,:);
					catch
						disp(lasterr);
						complain('Please check your input.');
						x0=x0old;
						y0=y0old;
						t1=t1old;
						col=colold;
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
						if hh<numtol
							complain('Value too small! Reverting to previous value.');
							hh=oldhh;
						end
					catch
						complain('Reverting to previous values.');
						method=methodold;
						hh=oldhh;
					end
				case 5
					xfnctold=xfnct;
					yfnctold=yfnct;
					ta0old=ta0;
					ta1old=ta1;
					colold=col;
					try
						xfnct=definput(['Function ' xvar '(' tvar ')'],xfnct);
						yfnct=definput(['Function ' yvar '(' tvar ')'],yfnct);
						ta0=definput(['Initial  ' tvar '-value'],ta0);
						ta1=definput(['Terminal ' tvar '-value'],ta1);
						col=definput('Color',col,'Enter color. Options include r (red), b (blue), g (green), m (magenta).');
						eval([tvar '=(ta0:hh:ta1);']);
						eval(['xc=(' vectorize(xfnct) ')+0*' tvar ';']);
						eval(['yc=(' vectorize(yfnct) ')+0*' tvar ';']);
						plot(xc,yc,col);
					catch
						disp(lasterr);
						complain('Please check your input.');
						xfnct=xfnctold;
						yfnct=yfnctold;
						ta0=ta0old;
						ta1=ta1old;
						col=colold;
					end
				case 6
					pp(auxfn,xx,yy,xvar,yvar,['d' xvar '/d' tvar ' = ' fs ', d' yvar '/d' tvar ' = ' gs],'b',1,t0);
				case 7
					fname=exportmenu(fname);
				otherwise
					nn=0;
			end
		catch
			% do nothing
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

