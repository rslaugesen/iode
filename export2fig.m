function export2fig(fn)
% function export2fig(fn)
%
% (c) 2001, Peter Brinkmann (brinkman@math.uiuc.edu)
%
% export2fig: a little method for exporting plots to fig
%
% Usage: export2fig(file_name)

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (http://www.gnu.org/copyleft/gpl.html).

	global isoctave;
	if isoctave
		prs=setstr(39);
		eval('gset terminal fig color');
		eval(['gset output ' prs fn prs]);
		eval('replot');
		if isunix
			eval('gset terminal x11');
		else
			eval('gset terminal windows');
		end
	else
		complain('export2fig not (yet) implemented for matlab!');
		disp('To export plots, go to the File menu in the graphics');
		disp('window and choose the Export item.');
		disp(' ');
	end

