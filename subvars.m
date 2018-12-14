function s=subvars(s0,v0,v1)
% function s=subvars(s0,v0,v1)
%
% (c) 2001, Peter Brinkmann (brinkman@math.uiuc.edu)
%
% subvar: substitutes variables an expression
%
% Usage example: subvar('sin(x*y)',{'x','y'},{'a','b'}) yields 'sin(a*b)'
%
% Parameters:
%	s0: expression
%	v0: cell array of old variables
%	v1: cell array of new variables
%
% Returns:
%	s: s0 with all occurrences of v0{1} replaced by v1{1}, v0{2} replaced
%		by v1{2}, etc.
%
% Having separate functions (subvar,subvars) is a little awkward, but
% this is necessary for Octave compatibility: subvar works with Octave,
% but subvars currently doesn't since it relies on cell arrays. Since
% subvar is necessary for some Octave menu modules, it has to work
% with Octave.

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (http://www.gnu.org/copyleft/gpl.html).

	i=round(rand(1)*10000);
	tmpvar=sprintf('tmpvar%d',i);
	while findstr(s0,tmpvar) & length(s0)>length(tmpvar)
		i=i+1;
		tmpvar=sprintf('tmpvar%d',i);
	end

	N=length(v0);
	vtmp={};
	for i=1:N
		vtmp{i}=sprintf('%s%d',tmpvar,i);
	end

	s=s0;
	for i=1:N
		s=subvar(s,v0{i},vtmp{i});
	end
	for i=1:N
		s=subvar(s,vtmp{i},v1{i});
	end

