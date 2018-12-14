function pp(fgs,xx,yy,xlab,ylab,ttl,col,clrscr,t0);
% function pp(fgs,xx,yy,xlab,ylab,ttl,col,clrscr,t0);
%
% (c) 2001, Peter Brinkmann (brinkman@math.uiuc.edu)
%
% pp: plots phase portraits for systems of differential equations of the form
%	dx/dt=f(t,x,y)
%	dy/dt=g(t,x,y)
% In most cases, f and g will not depend on t, but if they do, one can
% specifiy the time t=t0 for which the phase portrait is evaluated.
%
% Usage: pp(inline('[xy(1,:)+xy(2,:);xy(1,:)-xy(2,:)]','t','xy'),0:1:9,-8:1:8);
%
% Parameters:
%	fgs: inline function F that computes [f(x,y);g(x,y)], or a string
%		containing the name of such a function
%		(see .octaverc for the implementation of inline functions under
%		Octave)
%		This function F must be of the form F=F(t,xy), where t is a time
%		parameter that is ignored by pp but necessary for compatibility
%		with other modules of Iode. The parameter xy is a 2xN matrix
%		whose first row is a vector of x-coordinates, and its second
%		row is a vector of y-coordinates, i.e., x=xy(1,;), and y=xy(2,:).
%	xx: a row vector of x-coordinates
%	yy: a row vector of y-coordinates (not necessarily the same length as xx)
%	xlab,ylab,ttl: label of horizontal/vertical axis, title of plot (optional)
%	col: optional string indicating the color of line segments
%   clrscr: optional flag indicating whether pp is supposed to clear
%       the screen and set 'ishold' to 1 before plotting its direction field.
%       Default is 1.
%	t0: optional number indicating the time t=t0 for which the phase portrait
%		is evaluated; defaults to 0

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (http://www.gnu.org/copyleft/gpl.html).

	if nargin<7
		col='b';
	end
	if nargin<8
		clrscr=1;
	end
	if nargin<9
		t0=0;
	end

	if clrscr
		fixaxes([min(xx),max(xx),min(yy),max(yy)]);
	end

	if nargin>3
		xlabel(xlab);
	end
	if nargin>4
		ylabel(ylab);
	end
	if nargin>5
		title(ttl);
	end

	sx=length(xx);
	sy=length(yy);

	[x,y]=meshgrid(xx,yy);
	x=x(:)';
	y=y(:)';

	dx=(xx(sx)-xx(1))/(sx-1);
	dy=(yy(sy)-yy(1))/(sy-1);

	if dx<dy
		dd=dx;
	else
		dd=dy;
	end;

	ff=feval(fgs,t0*ones(size(x)),[x;y]);	% compute direction of arrows
	xdot=ff(1,:);
	ydot=ff(2,:);

	idx=find(isfinite(xdot) & isfinite(ydot));	% and throw away those that
	xdot=xdot(idx);							% aren't defined
	ydot=ydot(idx);
	x=x(idx);
	y=y(idx);

	q=(dd/3)*sqrt(1+xdot.^2+ydot.^2).^-1;
	xc=[x-q.*xdot;x+q.*xdot;x-(q/3).*(0.5*xdot+ydot)];
	yc=[y-q.*ydot;y+q.*ydot;y+(q/3).*(xdot-0.5*ydot)];

	plot(xc,yc,col);
