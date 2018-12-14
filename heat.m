function T=heat(efcns,wn,cn,k,x,t,dummy)
% function T=heat(efcns,wn,cn,k,x,t,dummy)
%
% (c) 2002, Peter Brinkmann (brinkman@math.uiuc.edu)
%
% heat: computes series solutions of the heat equation u_xx=ku_t
%
% Usage: T=heat('cosef', (0:3)', [.5;-1;-2;3.4], 1, 0:0.1:pi, 0:0.1:5)
%
% Parameters:
%	efcns: string containing the name of a function that computes
%		eigenfunctions, or an inline function
%	wn: a column vector of square roots of eigenvalues
%	cn: a column vector of coefficients in series expansion of initial
%		temperature distribution
%	k: thermal diffusivity
%	x: row vector of x-values
%	t: row vector of t-values
%	dummy: (optional) dummy parameter to make sure that heat.m takes as many
%		parameters as wave.m (just to make Matlab happy...)
%
% Return values:
%	T: rectangular grid of values of the solution u(x,t)

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (http://www.gnu.org/copyleft/gpl.html).

	nm=min([length(wn),length(cn)]);

	[xx,tt]=meshgrid(x,t);
	T=0*xx;
	for i=1:nm
		T=T+cn(i)*feval(efcns,wn(i),xx,i).*exp(-wn(i)^2*k*tt);
	end
