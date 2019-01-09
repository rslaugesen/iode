% install.m: generic installation script, customized for Iode
%
% (c) 2004, Peter Brinkmann (brinkman@math.uiuc.edu)

warning off MATLAB:MKDIR:DirectoryExists

title='IODE';
filename='master.zip';
fileurl='https://github.com/rslaugesen/iode/archive/master.zip';

disp(' ');
disp(' ');
disp([title ' Installation Script']);
disp(' ');
disp('Copyright (c) 2004, Peter Brinkmann (brinkman@math.uiuc.edu)')
disp('This program is distributed in the hope that it will be useful,')
disp('but WITHOUT ANY WARRANTY; without even the implied warranty of')
disp('MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the')
disp('GNU General Public License for more details.')
disp(' ');
disp(' ');
disp(['Your current working directory is ' pwd '.']);
disp(['Please choose an installation directory for ' title '. If you']);
disp(['simply hit Return, ' title ' will be installed in your current']);
disp('working directory. If you want to stop the installation,');
disp('hit Ctrl-C.');
disp(' ');

p=input(['Enter ' title ' installation directory (e.g., my_' ...
		lower(title) '): '],'s');
disp(' ');

if length(p)>0
	disp(['Creating directory ' p '.']);
	mkdir(p);
	disp('...done.');
	if exist(filename)
		disp(['Copying zip archive to directory ' p '.']);
		copyfile(filename,p);
		disp('...done.');
	end
	cd(p);
end

if ~exist(filename)
	disp(['Downloading ' title ' archive.']);
	try
		websave(filename,fileurl);    % Matlab recommends using websave here.
	catch
		urlwrite(fileurl,filename);   % No websave? Use urlwrite instead.
	end
	disp('...done.');
else
	disp(['Using local copy of ' title ' archive.'])
end

disp(['Unpacking ' title ' archive.']);
unzip(filename);
cd('iode-master');
disp('...done.');
disp(' ');
disp('Installation complete.');
disp(' ');
disp(['Your ' title ' base directory is ' pwd '.']);

clear;
rehash;
try
	startup;
catch
	% do nothing
end

