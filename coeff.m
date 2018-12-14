function cn=coeff(fcns,efcns,wn,x)
% function cn=coeff(fcns,efcns,wn,x)
%
% (c) 2002, Peter Brinkmann (brinkman@math.uiuc.edu)
%
% coeff: computes coefficients of series expansions with respect to
%	some system of orthogonal functions
%
% Usage: cn=coeff(inline('sign(x)','x'),'sinef',(1:5)'*pi,linspace(-1,1,100));
%
% Parameters:
%   fcns: inline function of one variable to be developed into a series,
%		or a string containing the name of the function to be used
%		(see .octaverc for the implementation of inline functions under
%		Octave)
%   efncs: a function that computes some system of orthogonal eigenfunctions,
%		given by a string containing the name or by an inline function
%		Note that these eigenfunctions do not need to be normalized because
%		coeff.m takes care of normalization.
%   wn: column vector of square roots of eigenvalues
%   x: row vector of x-values
%
% Return values:
%   cn: column vector of coefficients of fcns with respect to the system
%		given by efcns and wn, computed with the trapezoidal rule
%
% The usage example computes the first five terms of the Fourier sine
% series of the function sign(x) on the interval [-1,1]. The function
% passed in the parameter efcns must conform to a certain interface that
% is described in the file cosef.m. Examples of functions conforming
% to the interface include cosef.m and sinef.m.
%
% The coefficients cn are approximated using the trapezoidal rule. The
% vector x indicates where the function fcns will be evaluated. It
% does not have to be evenly spaced. In general, the quality of the
% approximation will depend upon the number of points in x.

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (http://www.gnu.org/copyleft/gpl.html).

	global numtol;

	N=length(wn);
	f=ones(N,1)*feval(fcns,x);	% f is a matrix with N rows, each of which
								% is equal to feval(fcns,x)
	ef=feval(efcns,wn,x,(1:N)');% ef is a matrix whose i-th row is the
								% i-th eigenfunction evaluated at x
	nrm=trapsum(x,ef.*ef);		% nrm is a column vector whose i-th entry
								% is the integral of the square of the i-th
								% eigenfunction
	nrm=nrm+(nrm<numtol);		% replace 0 entries by 1 in order to
								% avoid division by 0
	cn=trapsum(x,f.*ef)./nrm;	% now compute the coefficients

