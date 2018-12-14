% This new version deletes a line that causes errors in Matlab 2014b and
% above. Unsure if there are any repercussions to commenting out this line. 
% Further testing is needed.

% Sara M. Clifton, Nov. 18 2018, sara (dot) clifton43 (at) gmail (dot) com

function freeaxes
% function freeaxes
%
% (c) 2002, Peter Brinkmann (brinkman@math.uiuc.edu)
%
% freeaxes: Clears the plot and enables autoscaling in a way
%		that works for both Octave and Matlab

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (http://www.gnu.org/copyleft/gpl.html).

	global ismatlab;
	global isoctave;

	if ismatlab
		hold off;
		cla;

		% The following lines are a hack around a labeling bug
		% of Matlab. The eval statements are necessary because
		% Octave 2.0.16 won't read this file without them.
		eval('a=get(gca,{''Title'',''XLabel'',''YLabel'',''ZLabel''});');

% begin SMC changes 11/18/18
% error is in line below - try deleting? 		
        %eval('delete(a{:});');
% works! not sure what the hack was trying to fix, but looks ok to me 
% end SMC changes 11/18/18

		eval('axis auto;');
	elseif isoctave
		hold off;
		cla;
		axis;
	end

