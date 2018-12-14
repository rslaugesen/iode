function xc=solplot(fs,x0,tc,method,col);
% function xc=solplot(fs,x0,tc,method,col);
%
% (c) 2001, Peter Brinkmann (brinkman@math.uiuc.edu)
%
% solplot: plots solutions of initial value problems of the form
%	dx/dt=f(t,x), x(t0)=x0. (note: t0=tc(0))
%
% Usage: solplot(inline('x.*y','x','y'),3,0:0.01:1,'rk');
%
% Parameters:
%	fs: an inline function f(t,x), or a string containing the name of
%		such a function
%		(see .octaverc for the implementation of inline functions under Octave
%	tc: a row vector of t-coordinates
%	x0: initial x-coordinate
%	method: optional string indicating the method to be used
%		(e.g., Euler, Runge-Kutta,...)
%		The method has to be a function of the form
%			method(fs,x0,tc)
%		where fs is a string containing the name of the function f(t,x),
%		x0 is the initial value, and tc is a range of arguments, e.g.,
%		linspace(0,pi,100).
%	col: optional string indicating the color of the graph
%		(method argument is required when using col)
%
% Returns:
%	xc: row vector of x-coordinates of solution

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (http://www.gnu.org/copyleft/gpl.html).

	if nargin<5
		col='r';
	end;

	if nargin<4
		method='rk';
	end;

	xc=feval(method,fs,x0,tc);
	plot(tc,xc,col);
