function xyc=trajplot(fgs,xy0,tc,method,col);
% function xyc=trajplot(fgs,xy0,tc,method,col);
%
% (c) 2001, Peter Brinkmann (brinkman@math.uiuc.edu)
%
% trajplot: plots solutions of initial value problems of the form
%	dx/dt=f(x,y),
%	dy/dt=g(x,y),
%	x(t0)=x0,
%	y(t0)=y0.
%
% Usage: trajplot(inline('[xy(1,:)+xy(2,:);xy(1,:)-xy(2,:)]','t','xy'),
%			[3;2.5],linspace(0,1,10));
%
% Parameters:
%	fs: inline function or string, see pp.m for details
%		(see .octaverc for the implementation of inline functions under
%		Octave)
%	xy0: initial value [x0;y0]
%	tc: a row vector of t-coordinates
%	method: (optional) string indicating numerical method
%       The method has to be a function of the form method(fs,xy0,tc)
%       where fgs is a string containing the names of the function that
%		computes (f;g)
%       xy0=(x0,y0) is the initial value, and tc is a range of arguments,
%		e.g., linspace(0,pi,100).
%	col: (optional) string indicating color of plot (method is
%		required when using col)
%
% Returns:
%	xyc: matrix of xy-coordinates of solution

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (http://www.gnu.org/copyleft/gpl.html).

	if nargin<5
		col='r';
	end;

	if nargin<4
		method='rk';
	end;

	xyc=feval(method,fgs,xy0,tc);
	plot(xyc(1,:),xyc(2,:),col);
