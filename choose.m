function n=choose(s,lst,def,intro)
% function n=choose(s,lst,def,intro)
%
% (c) 2001, Peter Brinkmann (brinkman@math.uiuc.edu)
%
% choose: Allows users to choose from a list of one-character options
%
% Usage: n=choose('Quit (y/n)','ny',default_value,'introductory line')
%
% Parameters:
%	s: prompt for user
%	lst: string of one-character options, e.g., 'ny' for yes/no
%	def: (optional) default index
%	intro: (optional) introductory text
%
% Returns:
%	n: The index of the option chosen by the user; e.g., if lst=='ny',
%	then 0 means 'n', and 1 means 'y'
%
% Warning: Indices start at 0, not at 1, as in C but not in Matlab.`
% The reason for this is that I want to be able to use the results
% as boolean values, e.g., if the list of options is 'ny', then I
% want 'n' to evaluate to false.

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (http://www.gnu.org/copyleft/gpl.html).

	if nargin>3
		disp(intro);
	end
	if nargin>2 & def>=0 & def<length(lst)
		def=lst(def+1);
	else
		def=lst(1);
	end

	flag=1;
	while flag
		try
			ch=input([s ' [' def '] '],'s');
		catch
			ch=def;
		end
		if length(ch)==0
			ch=def;
		end
		n=findstr(lst,ch);
		if n & length(ch)==1
			n=n-1;
			flag=0;
		else
			complain('Bad input!');
		end
	end
