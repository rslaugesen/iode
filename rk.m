function xc=rk(fs,x0,tc);
% function xc=rk(fs,x0,tc);
%
% (c) 2001, Peter Brinkmann (brinkman@math.uiuc.edu)
%
% rk: computes numerical solutions of initial value problems of the form
%	dx/dt=f(t,x), x(t0)=x0 (where t0=tc(1))
% using Runge-Kutta. x and f can be scalars or vertical vectors of the
% same dimension.
%
% Usage: x=rk(inline('x.*y','x','y'), 2.5, 0:0.01:1);
%
% Parameters:
%	fs: an inline function f(t,x), or a string containing the name of
%		of such a function
%		(see .octaverc for the implementation of inline functions under
%		Octave)
%		The function given by fs must be of the form f(x,t) and return
%		the value of f when evaluated at (x,t). The function should be
%		able to deal with vector input, i.e., the code should use the
%		vectorized operators .*, ./, etc., instead of *, /, etc. A string
%		that may contain nonvectorized operators can be fed through the
%		function vectorize in order to achieve this.
%	x0: initial coordinate (or vector of initial coordinates; the dimension
%		of x0 must match the dimension of the values computed by fs);
%	tc: a row vector of t-coordinates, indexed from 1
%
% Returns:
%	xc: row vector of x-coordinates of the solution, indexed from 1
%		(or a matrix of coordinates when solving a system of
%		differential equations)
%
% Notes on indexing:
% matlab and octave start indexing arrays from 1, and so the initial
% element of the array xc is xc(1). This is unfortunate because people
% usually denote the initial x-value for the differential equation by x0,
% so that x0=xc(1).

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (http://www.gnu.org/copyleft/gpl.html).

	x=x0;
	xc=[x0];	% so that xc(1)=x0

	for i=1:(length(tc)-1)
		h=tc(i+1)-tc(i);
		k1=feval(fs,tc(i),x);
		k2=feval(fs,tc(i)+h/2,x+k1*h/2);
		k3=feval(fs,tc(i)+h/2,x+k2*h/2);
		k4=feval(fs,tc(i)+h,x+k3*h);
		x=x+h*(k1+2*k2+2*k3+k4)/6;
		xc=[xc,x];
	end;
