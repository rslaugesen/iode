function [efcns,wn]=periodic(L,n)
% function [efcns,wn]=periodic(L,n)
%
% (c) 2002, Peter Brinkmann (brinkman@math.uiuc.edu)
%
% periodic: finds eigenfunctions and eigenvalues for
%	 periodic boundary conditions
% 
% Usage: [ef,wn]=periodic(pi,25)
% 
% Parameters:
%   L: max value in interval [0,L]
%   n: number of eigenvalues to be computed
%   
% Return values:
%   efcns:	name of function that computes eigenfunctions, see periodicef.m
%   wn: column vector of square roots of eigenvalues
%
% Each nonzero eigenvalue appears twice in wn. The eigenfunction periodicef.m
% receives an eigenvalue w as well as its index i in wn, and it returns
% cos(wx) if i is odd, sin(wx) if i is even.

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (http://www.gnu.org/copyleft/gpl.html).

	efcns='periodicef';
	wn=round(0:0.5:n)'*2*pi/L;	% round(0:0.5:n)=[0,1,1,2,2,...,n,n]

