function export2png(fn)
% function export2png(fn)
%
% (c) 2001, Peter Brinkmann (brinkman@math.uiuc.edu)
%
% export2png: a little method for exporting plots to png
%
% Usage: export2png(file_name)

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (http://www.gnu.org/copyleft/gpl.html).

	global isoctave;
	if isoctave
		prs=setstr(39);
		eval('gset terminal png color');
		eval(['gset output ' prs fn prs]);
		eval('replot');
		if isunix
			eval('gset terminal x11');
		else
			eval('gset terminal windows');
		end
	else
		complain('export2png not (yet) implemented for matlab!');
		disp('To export plots, go to the File menu in the graphics');
		disp('window and choose the Export item.');
		disp(' ');
	end

