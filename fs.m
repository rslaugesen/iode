function [an,bn,abn]=fs(fcns,t0,t1,n,N)
% function [an,bn,abn]=fs(fcns,t0,t1,n,N)
%
% (c) 2001, Peter Brinkmann (brinkman@math.uiuc.edu)
%
% fs: computes coefficients of Fourier series
%
% Usage: [an,bn,abn]=fs(inline('sign(x)+abs(x)','x'),-1,1,100);
%
% Parameters:
%	fcns: inline function of one variable to be developed into a Fourier
%		series, or a string containing the name of a function of one variable
%		(see .octaverc for the implementation of inline functions under
%		Octave)
%	t0, t1: end points of one period
%	n: number of terms to compute
%	N: (optional) number of points in [t0,t1] at which fcns gets
%		evaluated when computing integrals, defaults to 64*n
%
% Return values:
%	an, bn: column vectors of coefficients of Fourier series
%	abn: absolute value of an+i*bn
%
% Note: The treatment of the coefficient a0 differs from the textbook
% (Edwards-Penney), but it's much cleaner from the point of view of
% software design. The book uses a 0th eigenfunction of 1/2, while
% we use a 0th eigenfunction of 1.

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (http://www.gnu.org/copyleft/gpl.html).

	if nargin<5
		N=64*n;
	end

	L=(t1-t0)/2;
	t=linspace(t0,t1,max(128,N));
	wn=(0:n)'*pi/L;

	an=coeff(fcns,'cosef',wn,t);
	bn=coeff(fcns,'sinef',wn,t);
	abn=sqrt(an.*an+bn.*bn);

