function f=bump(x,a,b,m)
% function f=bump(x,a,b,m)
%
% (c) 2001, Peter Brinkmann (brinkman@math.uiuc.edu)
%
% bump: C^1 function that
%		- returns 0 for x<a or x>b
%		- has a maximum of 1 at x=m
%		- is strictly monotone between a and m as well as m and b
%
% Note: This only makes sense for a<m<b,
% but bump does _not_ check this.
%
% The argument m is optional and defaults to (a+b)/2.

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (http://www.gnu.org/copyleft/gpl.html).

	if nargin<4
		m=(a+b)/2;
	end

	f=(x>a).*(x<=m).*(ones(size(x))+cos((x-a)*pi/(m-a)-pi*ones(size(x))))/2+(x>m).*(x<b).*(ones(size(x))+cos((x-m)*pi/(b-m)))/2;
