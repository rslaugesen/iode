function handle = doctool(s)
% function handle = doctool(s)
%
% (c) 2002 Peter Brinkmann, brinkman@math.uiuc.edu

% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

	if ischar(s)
		handle = openfig(s,'new');
		set(handle,'Color',get(0,'defaultUicontrolBackgroundColor'));
	else
		try
			eval(['helpwin ' get(s,'String') ';']);
		catch
			errordlg(lasterr);
		end
	end

