function fsmenu()
% function fsmenu()
%
% (c) 2001, Peter Brinkmann (brinkman@math.uiuc.edu)
%
% fsmenu: A text menu for slideshows involving Fourier series
%
% Usage: fsmenu;
%
% Note: The menu allows the user to change the names of independent and
% dependent variables. In order to avoid conflicts between those names
% and the names of internal variables, we adopt the convention that user
% defined variable names can only have one letter, whereas internal
% variable names have to have at least two letters.
%
% Acknowledgments:
%	- Many thanks to Robert Jerrard and Richard Laugesen for valuable
%	  feedback and suggestions.

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (http://www.gnu.org/copyleft/gpl.html).

	global numtol;	% numerical tolerance

	xvar='x';
	fn=['sign(' xvar ')'];
	ff=inline(vectorize([fn '+0*' xvar]),xvar);

	x0=-pi;
	x1=pi;
	xn=500;
	nmin=0;
	nmax=25;
	hld=0;
	stp=1;

	fname='fsplot';

	L=(x1-x0)/2;
	xx=linspace(x0-L,x1+L,2*xn+1);
	xp=mp(x0,x1,xx);
	fp=feval(ff,xp);
	[an,bn,abn]=fs(ff,x0,x1,nmax);
	ps=partialsum(L,an,bn,xx);
	Sr=(max(abn)-min([min(an),min(bn)]))/2+numtol;
	slideshow(xx,[0:nmax],ps,0,1,1,['f(' xvar ') = ' fn ' for ' num2str(x0) ' <= ' xvar ' < ' num2str(x1) ', extended periodically'],xvar,'','top harmonic:',nmax+1,nmax+1,'r',fp,'b');

	nn=1;
	while nn>0
		disp(' ');
		disp(' ');
		try
			nn=menu(['f(' xvar ') = ' fn ' for ' num2str(x0) ' <= ' xvar ' < ' num2str(x1) ', extended periodically'], 'Enter function', 'Plot partial sums', 'Plot errors', 'Show A_n', 'Show B_n', 'Show C_n=sqrt(A_n^2+B_n^2)','Options', 'Save plot', 'Quit');
		catch
			nn=0;
		end
		switch nn
			case 1
				xvarold=xvar;
				fnold=fn;
				x0old=x0;
				x1old=x1;
				try
					xvar=definput('Enter letter for independent variable',xvar);
					fn=definput('Enter function',fn);
					try
						% Under Octave, we need to clear the current inline
						% function xdot, or else the inline hack from .octaverc
						% will leak memory. Under Matlab, the next line will
						% cause an exception.
						clear(ff);
					catch
						% do nothing;
					end
					ff=inline(vectorize([fn '+0*' xvar]),xvar);
					x0=definput([xvar '0'],x0);
					x1=definput([xvar '1'],x1);
					L=(x1-x0)/2;
					xx=linspace(x0-L,x1+L,2*xn+1);
					xp=mp(x0,x1,xx);
					fp=feval(ff,xp);
					[an,bn,abn]=fs(ff,x0,x1,nmax);
					ps=partialsum(L,an,bn,xx);
					Sr=(max(abn)-min([min(an),min(bn)]))/2+numtol;
					slideshow(xx,[0:nmax],ps,0,1,1,['f(' xvar ') = ' fn ' for ' num2str(x0) ' <= ' xvar ' < ' num2str(x1) ', extended periodically'],xvar,'','top harmonic:',nmax+1,nmax+1,'r',fp,'b');
				catch
					disp(lasterr);
					complain('Reverting to previous values.');
					xvar=xvarold;
					fn=fnold;
					try
						clear(ff);
					catch
						% do nothing;
					end
					ff=inline(vectorize([fn '+0*' xvar]),xvar);
					x0=x0old;
					x1=x1old;
					L=(x1-x0)/2;
					xx=linspace(x0-L,x1+L,2*xn+1);
					xp=mp(x0,x1,xx);
					fp=feval(ff,xp);
					[an,bn,abn]=fs(ff,x0,x1,nmax);
					ps=partialsum(L,an,bn,xx);
					Sr=(max(abn)-min([min(an),min(bn)]))/2+numtol;
					slideshow(xx,[0:nmax],ps,0,1,1,['f(' xvar ') = ' fn ' for ' num2str(x0) ' <= ' xvar ' < ' num2str(x1) ', extended periodically'],xvar,'','top harmonic:',nmax+1,nmax+1,'r',fp,'b');
				end
			case 2
				try
					slideshow(xx,[0:nmax],ps,stp,1,hld,['f(' xvar ') = ' fn ' for ' num2str(x0) ' <= ' xvar ' < ' num2str(x1) ', extended periodically'],xvar,'','top harmonic:',nmin+1,nmax+1,'r',fp,'b');
				catch
					disp(lasterr);
					complain('Please check your settings.');
				end
			case 3
				try
					slideshow(xx,[0:nmax],meshgrid(fp,[0:nmax])-ps,stp,0,hld,['Error plot: f(' xvar ') = ' fn ' for ' num2str(x0) ' <= ' xvar ' < ' num2str(x1) ', extended periodically'],xvar,'','top harmonic:',nmin+1,nmax+1,'r');
				catch
					disp(lasterr);
					complain('Please check your settings.');
				end
			case 4
				fixaxes([0,nmax+1,min(an(2:(nmax+1)))-Sr,max(abn(2:(nmax+1)))+Sr]);
				plot([0,nmax+1],[0,0]);
				title(['f(' xvar ') = ' fn ' for ' num2str(x0) ' <= ' xvar ' < ' num2str(x1) ', plot of A_n for 1 <= n <= ' num2str(nmax)]);
				bar(an(2:(nmax+1)));
			case 5
				fixaxes([0,nmax+1,min(bn(2:(nmax+1)))-Sr,max(abn(2:(nmax+1)))+Sr]);
				plot([0,nmax+1],[0,0]);
				title(['f(' xvar ') = ' fn ' for ' num2str(x0) ' <= ' xvar ' < ' num2str(x1) ', plot of B_n for 1 <= n <= ' num2str(nmax)]);
				bar(bn(2:(nmax+1)));
			case 6
				fixaxes([0,nmax+1,min(abn(2:(nmax+1)))-Sr,max(abn(2:(nmax+1)))+Sr]);
				plot([0,nmax+1],[0,0]);
				title(['f(' xvar ') = ' fn ' for ' num2str(x0) ' <= ' xvar ' < ' num2str(x1) ', plot of C_n for 1 <= n <= ' num2str(nmax)]);
				bar(abn(2:(nmax+1)));
			case 7
				nminold=nmin;
				nmaxold=nmax;
				xnold=xn;
				stpold=stp;
				try
					nmin=definput('Initial top harmonic for plotting',nmin);
					nmax=definput('Max harmonic                     ',nmax);
					if nmax~=nmaxold & xn<4*nmax
						xn=4*nmax;
					end
					xn=definput('Number of points to be plotted   ',xn);
					hld=choose('Superimpose successive plots (y/n)','ny',hld);
					stp=choose('Plotting method','as',stp,'Enter plotting method. Enter a for animation or s for step-by-step.');
					L=(x1-x0)/2;
					xx=linspace(x0-L,x1+L,2*xn+1);
					xp=mp(x0,x1,xx);
					fp=feval(ff,xp);
					[an,bn,abn]=fs(ff,x0,x1,nmax);
					ps=partialsum(L,an,bn,xx);
					Sr=(max(abn)-min([min(an),min(bn)]))/2+numtol;
				catch
					disp(lasterr);
					complain('Reverting to previous values.');
					nmin=nminold;
					nmax=nmaxold;
					xn=xnold;
					stp=stpold;
					L=(x1-x0)/2;
					xx=linspace(x0-L,x1+L,2*xn+1);
					xp=mp(x0,x1,xx);
					fp=feval(ff,xp);
					[an,bn,abn]=fs(ff,x0,x1,nmax);
					ps=partialsum(L,an,bn,xx);
					Sr=(max(abn)-min([min(an),min(bn)]))/2+numtol;
				end
			case 8
				fname=exportmenu(fname);
			otherwise
				nn=0;
		end
	end
