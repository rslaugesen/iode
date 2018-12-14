function z=trapsum(x,y)
% function z=trapsum(x,y)
%
% (c) 2002, Peter Brinkmann (brinkman@math.uiuc.edu)
%
% trapsum: compute integrals using the trapezoidal rule
%
% Parameters:
%    x: (row) vector of x-values (may be nonuniformly spaced!) or
%		matrix of x-values where each row is a vector of x-values
%    y: (row) vector or matrix of y-values of the same width as x
%
% Returns:
%    z: integral of y(x), computed using the trapezoidal rule
%		z is a scalar if x and y are vectors, and it is a column
%		vector if x and y are matrices (the i-th entry of z in
%		this case is the integral of the i-th row of y integrated
%		over the i-th row of x)
%		
%
% Note: Although Matlab knows the trapezoidal rule, Octave doesn't, so that
% I had to reimplement it for Iode.
%
% Usage example:	x=linspace(0,1,100);
%					z=trapsum(x,x.*x);

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (http://www.gnu.org/copyleft/gpl.html).

	dx=ones(size(y,1),1)*diff(x);
	len=size(y,2);
	f=y(:,1:len-1)+y(:,2:len);
	z=0.5*sum((f.*dx)')';	% this twofold transposition is a bit awkward,
							% but it's necessary since Octave only sums
							% over columns, not over rows
