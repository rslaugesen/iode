function [efcns,wn]=mixednd(L,n)
% function [efcns,wn]=mixednd(L,n)
%
% (c) 2002, Peter Brinkmann (brinkman@math.uiuc.edu)
%
% mixednd: finds eigenfunctions and eigenvalues for
%	mixed Neumann-Dirichlet boundary conditions
% 
% Usage: [ef,wn]=mixednd(pi,25)
% 
% Parameters:
%   L: max value in interval [0,L]
%   n: number of eigenvalues to be computed
%   
% Return values:
%   efcns: name of function that computes eigenfunctions
%   wn: column vector of square roots of eigenvalues

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (http://www.gnu.org/copyleft/gpl.html).

	efcns='cosef';	            % define eigenfunctions, see cosef.m
	wn=(2*(1:n)-1)'*pi/(2*L);	% define eigenvalues
