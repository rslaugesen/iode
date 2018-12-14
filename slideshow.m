function slideshow(x,y,f,step,fix,hld,ttl,xlab,ylab,tlab,nmin,nmax,col,f2,col2);
% function slideshow(x,y,f,step,fix,hld,ttl,xlab,ylab,tlab,nmin,nmax,col,f2,col2);
%
% (c) 2001, Peter Brinkmann (brinkman@math.uiuc.edu)
%
% slideshow: shows successive slices of a grid of values
%
% Usage: slideshow(0:0.1:1,0:0.1:1,f,1,1,0,'title','x','y','g');
%
% Parameters:
%	x: row vector of x-values
%	y: row vector of y-values
%	f: grid of values f(x,y)
%
% Optional parameters:
%	step: nonzero value means step-by-step, 0 means animation (default 1)
%	fix: nonzero value indicates fixed axes (default 1)
%	hld: nonzero value indicates that successive plots are superimposed
%			(default 0)
%	ttl: title string (default 'no title')
%	xlab: label of x-axis (default ' ')
%	ylab: label of y-axis (default ' ')
%	tlab: label of t-axis (default ' ')
%		This is the time axis of the slide show.
%	nmin: index of initial slide (default 1)
%	nmax: index of terminal slide (default length(y))
%	col: color of plot (default 'r')
%	f2: row vector of values f(x) to be plotted on every slide (default [])
%	col2: color of plot of f2 (default 'b')

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (http://www.gnu.org/copyleft/gpl.html).

	global numtol;	% numerical tolerance; numerical values smaller
					% than numtol will be treated as 0

	if nargin<4
		step=1;
	end
	if nargin<5
		fix=1;
	end
	if nargin<6
		hld=0;
	end
	if nargin<7
		ttl='no title';
	end
	if nargin<8
		xlab=' ';
	end
	if nargin<9
		ylab=' ';
	end
	if nargin<10
		tlab=' ';
	end
	if nargin<11
		nmin=1;
	end
	if nargin<12
		nmax=length(y);
	end
	if nargin<13
		col='r';
	end
	if nargin<14
		f2=[];
	end
	if nargin<15
		col2='b';
	end

	if fix | hld
		Sp=max(max(max(f)));
		Sm=min(min(min(f)));
		S=(Sp-Sm)/4+numtol;
		fixaxes([min(x),max(x),Sm-S,Sp+S]);
	else
		freeaxes;
		cla;
	end

	cmd=1;
	i=nmin;
	while cmd & i<=nmax
		if (~hld) & fix
			fixaxes([min(x),max(x),Sm-S,Sp+S]);
		end;
		xlabel(xlab);
		ylabel(ylab);
		title([ttl ', ' tlab ' ' num2str(y(i))]);
		if length(f2)==0
			plot(x,f(i,:),col);
		else
			plot(x,f2,col2,x,f(i,:),col);
		end
		if step
			cmd=choose('f: forward, b: back, q: quit ','qfb',cmd,['Currently at ' tlab ' ' num2str(y(i))]);
			switch cmd
				case 1
					if i<nmax
						i=i+1;
					else
						complain(['Cannot go beyond ' tlab ' ' num2str(y(i)) '.']);
					end
				case 2
					if i>1
						i=i-1;
					else
						complain(['Cannot go below ' tlab ' ' num2str(y(i)) '.']);
					end
			end
		else
			pause(0.2);
			i=i+1;
		end;
	end;
