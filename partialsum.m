function f=partialsum(L,an,bn,t,nmax)
% function f=partialsum(L,an,bn,t,nmax)
%
% (c) 2001, Peter Brinkmann (brinkman@math.uiuc.edu)
%
% partialsum: evaluates partial sums of Fourier series.
%
% Usage: f=partialsum(pi,0,[3,2,1],[-1,5,1],linspace(-pi,pi,100),3);
%
% Parameters:
%	L: half period
%	an, bn: column vectors of Fourier coefficients
%	t: row vector of t-values
%	nmax: (optional) maximal summation index
%
% Returns:
%	f: grid of partial sums evaluated at t, i.e.,
%		f(i,:)= (i-1)th partial sum evaluated at t

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (http://www.gnu.org/copyleft/gpl.html).

	global isoctave;

	nm=min([length(an),length(bn)]);
	if nargin>5
		if nmax<nm
			nm=nmax;
		end
	end

	[tt,ii]=meshgrid(t,(1:nm));

	if isoctave
		% The next two lines are needed because under Octave,
		% an(ii) is a vector, not a matrix.
		aa=reshape(an(ii),nm,length(t));
		bb=reshape(bn(ii),nm,length(t));
	else
		% Under Matlab, an(ii) is a matrix, as it should be.
		aa=an(ii);
		bb=bn(ii);
	end

	ti=tt.*(ii-1)*pi/L;
	f=cumsum(aa.*cos(ti)+bb.*sin(ti));

