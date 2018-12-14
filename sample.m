function m=sample(tc,xc)
% function m=sample(tc,xc)
%
% (c) 2002, Peter Brinkmann (brinkman@math.uiuc.edu)
%
% sample: an illustration of the interface for df.m, euler.m, and rk.m
%
% This function isn't called by any module of Iode; it merely serves
% as an example of how to implement a function that'll work with the
% numerical solver modules euler.m and rk.m, as well as the direction
% field module df.m.
%
% For example, an interactive session with df.m and rk.m might go as follows:
%	octave:1> df('sample',linspace(-pi,pi,15),linspace(-pi,pi,15));
%	octave:2> tc=linspace(-pi,pi,100);
%	octave:3> xc=rk('sample',1,tc);
%	octave:4> hold on;
%	octave:5> plot(tc,xc);
% This session creates a direction field using this function and computes
% and plots a numerical solution with x(-pi)=0.5.

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (http://www.gnu.org/copyleft/gpl.html).

	m=sin(xc.*tc);	% Note that we're using the vectorized operator .* here

