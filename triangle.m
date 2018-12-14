function f=triangle(x,a,b,m)
% function f=triangle(x,a,b,m)
%
% (c) 2001, Peter Brinkmann (brinkman@math.uiuc.edu)
%
% triangle: piecewise linear function that 
%       - returns 0 for x<a or x>b
%       - has a maximum of 1 at x=m
%
% Note: This only makes sense for a<m<b,
% but the function does _not_ check this.
%
% The argument m is optional and defaults to (a+b)/2.

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (http://www.gnu.org/copyleft/gpl.html).

    if nargin<4
        m=(a+b)/2;
    end

	f=(x>a).*(x<=m).*(x-a)/(m-a)+(x>m).*(x<b).*(b-x)/(b-m);
