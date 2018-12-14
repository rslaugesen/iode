function tc=mp(t0,t1,t)
% function tc=mp(t0,t1,t)
%
% (c) 2001, Peter Brinkmann (brinkman@math.uiuc.edu)
%
% mp: A helper function for creating periodic functions;
%		the composition of a function f with mp will be
%		periodic with period t1-t0, and f(mp(t))=f(t)
%		if t0<=t<t1.

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (http://www.gnu.org/copyleft/gpl.html).

	P=t1-t0;
	tc=t-t0;
	tc=rem(rem(tc,P)+P,P);	% funny looking hack for
							% dealing with negative numbers
	tc=tc+t0;
