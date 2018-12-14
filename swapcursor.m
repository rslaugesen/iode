function oldcursor=swapcursor(fig,newcursor)
% function oldcursor=swapcursor(fig,newcursor)
%
% (c) 2002, Peter Brinkmann (brinkman@math.uiuc.edu)
%
% swapcursor: auxiliary function for Matlab GUIs
%
% This function sets the mouse pointer of fig to newcursor and returns
% the previous pointer type.
% 
% Example:
% function varargout = some_Callback(h,eventdata,handles,varargin)
%     ...
%     tmp=swapcursor(handles.figure,'watch');
%     try
%         ...some lengthy computation...
%     catch
%         ...
%     end
%     swapcursor(handles.figure,tmp);
%
% The idea is to replace the mouse pointer by a little watch or hour glass
% while a lengthy computation is in progress. I recommend enclosing the
% computation in a try-catch-end clause to make sure that the cursor will
% always be restored to its original form.

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (http://www.gnu.org/copyleft/gpl.html).

	oldcursor=get(fig,'Pointer');
	set(fig,'Pointer',newcursor);

