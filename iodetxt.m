function iodetxt()
% function iodetxt()
%
% (c) 2001, Peter Brinkmann (brinkman@math.uiuc.edu)
%
% iodetxt: a simple text menu for Iode
%
% Usage: iodetxt;

% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

	disp('$Id: iodetxt.m,v 1.6 2003-02-11 22:38:58+01 brinkman Exp $')
	disp('Copyright (c) 2001, Peter Brinkmann (brinkman@math.uiuc.edu)')
	disp('This program is distributed in the hope that it will be useful,')
	disp('but WITHOUT ANY WARRANTY; without even the implied warranty of')
	disp('MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the')
	disp('GNU General Public License for more details.')
	disp(' ');

	global isoctave;
	global ismatlab;

	try
		if isoctave
			disp('Running under Octave.');
		elseif ismatlab
			disp('Running under Matlab.');
			disp(' ');
			disp('*****************************************************');
			disp('* This is the text-based user interface of Iode.    *');
			disp('* If you were expecting to see the graphical user   *');
			disp('* interface, then chances are that something went   *');
			disp('* wrong with the initialization of Matlab. You may  *');
			disp('* be able to correct this by removing the file or   *');
			disp('* directory .matlab from your home directory before *');
			disp('* restarting Matlab and Iode.                       *');
			disp('*****************************************************');
		else
			error('Wrong directory!');
		end
	catch
		complain('Wrong directory!');
		disp('Please quit out of Octave or Matlab and cd into your');
		disp('Iode directory before restarting Octave or Matlab.');
		return;
	end

	n=1;
	while n>0
		disp(' ');
		disp(' ');
		try
			n=menu('Iode Main Menu','Direction fields','Phase planes','Second order linear ODEs','Fourier series','Partial differential equations','Purge temporary files','Quit');
		catch
			n=0;
		end
		switch n
			case 1
				dfmenu;
			case 2
				ppmenu;
			case 3
				mvmenu;
			case 4
				fsmenu;
			case 5
				pdemenu;
			case 6
				try
					purge_tmp_files;
				catch
					complain('Unable to purge temporary files!');
				end
			otherwise
				n=0;
		end
	end
