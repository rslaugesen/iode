function f=hat(x,a,b)
% function f=hat(x,a,b)
%
% (c) 2001, Peter Brinkmann (brinkman@math.uiuc.edu)
%
% hat: returns 1 for a<x<b, 0 otherwise
%
% Note: This only makes sense for a<b, but hat does _not_ check this.

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (http://www.gnu.org/copyleft/gpl.html).

	f=(x>a).*(x<b);
