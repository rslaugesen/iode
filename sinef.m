function f=sinef(ww,x,i)
% function f=sinef(ww,x,i)
%
% (c) 2002, Peter Brinkmann (brinkman@math.uiuc.edu)
%
% sinef: an implementation of the interface for eigenfunctions suitable
%	for use with coeff.m
%
% Note that these eigenfunctions do _not_ need to be normalized because
% the module coeff.m takes care of this.
%
% Usage: ef=sinef(2,linspace(0,pi,30),3);
%
% Parameters:
%   ww: square root of eigenvalue or column vector of roots of eigenvalues
%   x: scalar, or row vector or matrix of x-values
%   i: index or column vector of indices indicating the location of the
%		entry or entries of ww in the list of all eigenvalues
%
% In order to conform to the interface for eigenfunctions, a function must
% return a meaningful value whenever the product ww*x is defined. This is
% the case
%	- if ww is a scalar and x is anything, or
%	- if x is a scalar and ww is anything, or
%	- if both ww and x are vectors.
% Note that in the third case, the product ww*x is the outer product of two
% vectors. If you are writing a sophisticated function whose result doesn't
% just depend on ww*n but on the index i as well, then you need to make
% sure that the outer product case is handled correctly.
%
% Return values:
%   f: sin(ww*x)

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (http://www.gnu.org/copyleft/gpl.html).

	f=sin(ww*x);
