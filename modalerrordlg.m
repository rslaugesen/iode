function modalerrordlg(msg,ttl,dlgtype)
% function modalerrordlg(msg,ttl,dlgtype)
%
% (c) 2002, Peter Brinkmann (brinkman@math.uiuc.edu)
%
% modalerrordlg: creates a modal error dialog and waits until the user
%	closes the dialog
%
% Usage example: modalerrordlg('Error message','Title');
%
% Parameters:
%	msg: error message
%	ttl: (optional) title; defaults to 'Error Dialog'
%	dlgtype: (optional) type of dialog; defaults to 'error'

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (http://www.gnu.org/copyleft/gpl.html).

	if nargin<2
		ttl='Error Dialog';
	end
	if nargin<3
		dlgtype='error';
	end

	uiwait(msgbox(msg,ttl,dlgtype,'modal'));

