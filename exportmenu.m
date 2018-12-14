function [fn,ex]=exportmenu(fname,ext)
% function [fn,ex]=exportmenu(fname,ext)
%
% (c) 2001, Peter Brinkmann (brinkman@math.uiuc.edu)
%
% exportmenu: a little menu for exporting plots
%
% Usage: exportmenu(default_file_name,default_extension)
% The default extension is optional.
%
% Returns: The file name and extension entered by the user
%
% Convention: The extension determines the function that gets called
% when exporting plots, e.g., 'foo.eps' will be saved as encapsulated
% PostScript, using 'export2eps'.

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (http://www.gnu.org/copyleft/gpl.html).

	if nargin<2
		ext='eps';
	end

	fn=definput('File name (without extension)',fname);
	ex=definput('Extension',ext);

	ff=[fn '.' ex];
	cmd=['export2' ex];
	disp(['Saving plot to ' ff ' with ' cmd]);
	try
		feval(cmd,ff);
	catch
		complain(['Cannot export with extension ' ex '!']);
	end

	% just ignore the next few lines; their only purpose is to make some
	% dependencies explicit
	dummy=0;
	if dummy==1
		export2eps;
		export2fig;
		export2gif;
		export2png;
	end

