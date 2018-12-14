function complain(msg,intro)
% function complain(msg,intro)
%
% (c) 2001, Peter Brinkmann (brinkman@math.uiuc.edu)
%
% complain: Print a message surrounded by empty lines and beep.
%
% Parameters:
%	msg: message (typically an error message)
%	intro: introductory words, e.g., 'Exception!'. Defaults to 'Error:'
%		when missing.

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (http://www.gnu.org/copyleft/gpl.html).

	if nargin<2
		msg=['Error: ' msg];
	else
		msg=[intro ' ' msg];
	end

	beep;
	disp(msg);
	disp(' ');

