function iode()
% function iode()
%
% (c) 2001, Peter Brinkmann (brinkman@math.uiuc.edu)
%
% iode: a simple function that calls the graphical user interface of Iode
%	if possible and resorts to the text based interface if necessary
%
% Usage: iode;
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

	disp('$Id: iode.m,v 1.31 2003-02-11 22:38:58+01 brinkman Exp $')
	disp('Copyright (c) 2001, Peter Brinkmann (brinkman@math.uiuc.edu)')
	disp('This program is distributed in the hope that it will be useful,')
	disp('but WITHOUT ANY WARRANTY; without even the implied warranty of')
	disp('MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the')
	disp('GNU General Public License for more details.')
	disp(' ');

	try
		iodegui;	% this will cause an error in old versions of Matlab
	catch
		iodetxt;	% if the GUI fails, use the text menu instead
	end

