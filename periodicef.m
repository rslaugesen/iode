function f=periodicef(ww,x,i)
% function f=periodicef(ww,x,i)
%
% (c) 2002, Peter Brinkmann (brinkman@math.uiuc.edu)
%
% periodicef: an implementation of the interface for eigenfunctions as
%	described in cosef.m
%
% Usage: ef=periodicef(2,linspace(0,pi,30),5);
%
% Parameters:
%   ww: square root of eigenvalue or column vector of roots of eigenvalues
%   x: scalar, or row vector or matrix of x-values
%   i: index or column vector of indices indicating the location of the
%		entry or entries of ww in the list of all eigenvalues
%
% Return values:
%   f: a row of f corresponding to index j and eigenvalue w_j
%		cos(w_j*x) if j is odd, and sin(w_j*x) if j is even

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (http://www.gnu.org/copyleft/gpl.html).

	ii=rem(i,2)*ones(size(x));	% ii is a matrix with a row of ones of the
			% same length as x for each odd entry of i, and a row of zeros
			% for each even entry of i; it is the same size as ww*x;
			% ii will serve as a mask for cosine values, while ~ii will
			% serve as a mask for sine values
	f=ii.*cos(ww*x)+(~ii).*sin(ww*x);	% f is a matrix with a row of
			% cosine values for each odd entry of i, and a row of sine
			% entries for each even entry of i

