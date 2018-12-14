function df(fs,tt,xx,tlab,xlab,ttl,col,clrscr);
% function df(fs,tt,xx,tlab,xlab,ttl,col,clrscr);
%
%  (c) 2001, Peter Brinkmann (brinkman@math.uiuc.edu)
%
% df: plots direction fields for differential equations of the form
%	dx/dt=f(t,x).
%
% Usage example: df(inline('x.*y','x','y'),0:0.1:2,0:0.2:3);
%
% Parameters:
%	fs: an inline function f(t,x) defining the direction field, or string
%		containing the name of a function of (t,x)
%		(see .octaverc for the implementation of inline functions under
%		Octave)
%	tt: a row vector of t-coordinates
%	xx: a row vector of x-coordinates
%	tlab,xlab,ttl: label for t-axis and x-axis, title of plot
%	col: optional string indicating the color of the line segments
%	clrscr: optional flag indicating whether df is supposed to clear
%		the screen and set 'ishold' to 1 before plotting its direction field.
%		Default is 1.

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (http://www.gnu.org/copyleft/gpl.html).
%

	if nargin<7
		col='b';
	end;
	if nargin<8
		clrscr=1;
	end

	st=length(tt);
	sx=length(xx);

	[x,t]=meshgrid(xx,tt);		% create a grid of x and t-coordinates
	x=x(:)';					% then turn it into a vector
	t=t(:)';					% for plotting purposes

	dt=(tt(st)-tt(1))/(st-1);	% horizontal step size
	dx=(xx(sx)-xx(1))/(sx-1);	% vertical step size

	xdot=feval(fs,t,x);			% compute slopes

	idx=find(isfinite(xdot));		% find indices of finite (i.e., defined) slopes
	xdot=xdot(idx);				% throw away undefined slopes
	x=x(idx);					% as well as corresponding coordinates
	t=t(idx);

	% the following lines choose a vector of scaling factors q
	% such that a line segment of length q sits nicely in its allotted box
	q1=(dt/4)*ones(size(xdot));
	q2=(dx/4)*(max((dx/dt)*ones(size(xdot)),abs(xdot)).^-1);
	q=min(q1,q2);

	tc=[t-q;t+q];				% finally, compute end points
	xc=[x-q.*xdot;x+q.*xdot];	% of line segments

	if clrscr
		fixaxes([min(tt),max(tt),min(xx),max(xx)]);
	end

	if nargin>3
		xlabel(tlab);
	end
	if nargin>4
		ylabel(xlab);
	end
	if nargin>5
		title(ttl);
	end

	plot(tc,xc,col);
