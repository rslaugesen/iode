function s=subvar(s0,v0,v1)
% function s=subvar(s0,v0,v1)
%
% (c) 2001, Peter Brinkmann (brinkman@math.uiuc.edu)
%
% subvar: substitutes a variable for another in an expression
%
% Usage example: subvar('sin(i)','i','x') yields 'sin(x)'
%
% Parameters:
%	s0: expression
%	v0: old variable
%	v1: new variable
%
% Returns:
%	s: s0 with all occurrences of v0 replaced by v1
%
% v0 must be a variable name. v1 can be almost anything, but the user is
% responsible for proper use of parentheses. For instance, if v1 is a
% sum, then it is wise to enclose it in parentheses. subvar will _not_ do
% this automatically.
%
% Note that subvar parses the expression s0 and only replaces occurrences
% of the _variable_ v0 by v1. In particular, it doesn't blindly substitute
% the string v1	for any substring v0.
%
% Although this function behaves much like Matlab's subs function, I had
% to reimplement this because (a) Octave has no such substitute function,
% and (b) the subs function automatically encloses v1 in parentheses,
% which is undesirable for the purposes of Iode.

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (http://www.gnu.org/copyleft/gpl.html).

	if length(s0)<length(v0)
		s=s0;
		return
	end

	global isoctave;
	if isoctave
		r=toascii(s0);
	else
		r=s0;
	end

	alphanum=(r>=65 & r<=90) | (r>=97 & r<=122) | (r>=48 & r<=57) | (r==95);
	pos=findstr(s0,v0);
	N=length(s0);
	n=length(v0);

	j0=1;
	s='';
	for i=1:length(pos)
		j=pos(i);
		if ((j<2) | ~alphanum(max(1,j-1))) & ((j+n>N) | ~alphanum(min(N,j+n)))
			s=[s s0(j0:j-1) v1];
			j0=j+n;
		end
	end
	s=[s s0(j0:N)];
