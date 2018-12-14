function W=wave(efcns,wn,cn1,c,x,t,cn2)
% function W=wave(efcns,wn,cn1,c,x,t,cn2)
%
% (c) 2002, Peter Brinkmann (brinkman@math.uiuc.edu)
%
% wave: computes series solutions of the wave equation u_xx=c^2u_tt
%
% Usage: W=wave('sinef', (1:3)', [.5;-1;3.4], 1, 0:0.1:pi, 0:0.1:5, [0;0;0])
%
% Parameters:
%   efcns: string containing the name of the function that computes
%		eigenfunctions, or inline function
%   wn: column vector of square roots of eigenvalues
%   cn1: column vector of coefficients in series expansion of initial position
%   c: speed of light
%   x: row vector of x-values
%   t: row vector of t-values
%   cn2:(optional) column vector of coefficients in series expansion of initial
%		velocity (default is 0*cn1)
%
% Return values:
%   W: rectangular grid of values of the solution u(x,t)

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (http://www.gnu.org/copyleft/gpl.html).

	global numtol;	% numerical tolerance

	if nargin<7
		cn2=0*cn1;
	end
	if nargin<8
		linflag=0;
	end

	nm=min([length(wn),length(cn1),length(cn2)]);

	[xx,tt]=meshgrid(x,t);
	W=0*xx;
	for i=1:nm
		W=W+cn1(i)*feval(efcns,wn(i),xx,i).*cos(wn(i)*c*tt);
		if abs(wn(i))>=numtol
			W=W+cn2(i)*feval(efcns,wn(i),xx,i).*sin(wn(i)*c*tt)/(c*wn(i));
		else % deal with t-linear term for 0th eigenvalue
			W=W+cn2(i)*feval(efcns,wn(i),xx,i).*tt;
		end
	end
