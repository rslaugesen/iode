function n=definput(s,def,intro)
% function n=definput(s,def,intro)
%
% (c) 2001, Peter Brinkmann (brinkman@math.uiuc.edu)
%
% definput: Input function with defaults.
%
% Usage: n=definput('prompt',default_value,'introductory line')
%
% Parameters:
%	s: prompt for user
%	def: (optional) default value
%	intro: (optional) introductory text
%
% Returns:
%	n: value entered by user (same type as default)

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (http://www.gnu.org/copyleft/gpl.html).

	if nargin>2
		disp(intro);
	end
	if nargin<2
		n=input([s ' ']);
	else
		if isstr(def)
			n=input([s ' [' def '] '],'s');
		else
			n=input([s ' = [' num2str(def) '] ']);
		end
		if length(n)==0
			n=def;
		end
	end
