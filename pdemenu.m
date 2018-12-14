function pdemenu()
% function pdemenu()
%
% (c) 2001, Peter Brinkmann (brinkman@math.uiuc.edu)
%
% pdemenu: menu module for both heat and wave equation
%
% Usage: pdemenu;
%
% Acknowledgments:
%	- Many thanks to Robert Jerrard and Richard Laugesen for valuable
%	  feedback and suggestions.

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (http://www.gnu.org/copyleft/gpl.html).

	xvar='x';

	hld=0;
	stp=1;

	L=pi;
	T=2*L;
	c=1;

	type='wave';
	bdcond='dirichlet';
	f1='triangle(x,pi/4,5*pi/12)';
	f2='0';
	ttl=['Wave equation, c = ' num2str(c) ', ' bdcond ', u(x,0) = ' f1 ', u_t(x,0) = ' f2];

	xn=48;
	tn=48;

	x=linspace(0,L,xn+1);
	t=linspace(0,T,tn+1);

	nmax=50;

	[ef,wn]=feval(bdcond,L,nmax);
	ff1=inline(vectorize([f1 '+0*' xvar]),xvar);
	cn1=coeff(ff1,ef,wn,linspace(0,L,32*length(wn)));
	ff2=inline(vectorize([f2 '+0*' xvar]),xvar);
	cn2=coeff(ff2,ef,wn,linspace(0,L,32*length(wn)));
	u=feval(type,ef,wn,cn1,c,x,t,cn2);
	freeaxes;
	title(ttl);
	xlabel('x');
	ylabel('t');
	zlabel('u');
	mesh(x,t,u);

	fname='pdeplot';

	nn=1;
	while nn>0
		disp(' ');
		if strcmp(type,'wave')
			disp(['Wave equation:        u_tt = (' num2str(c) ')^2 u_xx, 0 < x < ' num2str(L)]);
			disp(['Boundary condition:   ' bdcond]);
			disp(['Initial displacement: u(x,0) = ' f1]);
			disp(['Initial velocity:     u_t(x,0) = ' f2]);
		else
			disp(['Heat equation:       u_t = (' num2str(c) ') u_xx, 0 < x < ' num2str(L)]);
			disp(['Length:              L = ' num2str(L)]);
			disp(['Boundary condition:  ' bdcond]);
			disp(['Initial temperature: u(x,0) = ' f1]);
		end
		disp(' ');
		try
			nn=menu('', 'Enter equation and boundary conditions', 'Enter duration, length and initial conditions', 'Plot 3D', 'Plot snapshots (t-slices)', 'Plot sections (x-slices)', 'Options', 'Save plot', 'Quit');
		catch
			nn=0;
		end
		switch nn
			case 1
				typeold=type;
				bdcondold=bdcond;
				cold=c;
				ttlold=ttl;
				try
					if choose('Type of equation: h for heat, w for wave','hw',strcmp(type,'wave'))
						type='wave';
						c=definput('Wave speed c',c);
						bdcond=definput('Boundary condition (choices include dirichlet, neumann, periodic)',bdcond);
						ttl=['Wave equation, c = ' num2str(c) ', ' bdcond ', u(x,0) = ' f1 ', u_t(x,0) = ' f2];
					else
						type='heat';
						c=definput('Thermal diffusivity k',c);
						bdcond=definput('Boundary condition (choices include dirichlet and neumann)',bdcond);
						ttl=['Heat equation, k = ' num2str(c) ', ' bdcond ', u(x,0) = ' f1];
					end

					try
						clear(ff1);
						clear(ff2);
					catch
						% do nothing
					end
					[ef,wn]=feval(bdcond,L,nmax);
					ff1=inline(vectorize([f1 '+0*' xvar]),xvar);
					cn1=coeff(ff1,ef,wn,linspace(0,L,32*length(wn)));
					ff2=inline(vectorize([f2 '+0*' xvar]),xvar);
					cn2=coeff(ff2,ef,wn,linspace(0,L,32*length(wn)));
					u=feval(type,ef,wn,cn1,c,x,t,cn2);

					freeaxes;
					title(ttl);
					xlabel('x');
					ylabel('t');
					zlabel('u');
					mesh(x,t,u);
				catch
					disp(lasterr);
					complain('Please check your settings.');
					type=typeold;
					bdcond=bdcondold;
					c=cold;
					ttl=ttlold;

					try
						clear(ff1);
						clear(ff2);
					catch
						% do nothing
					end
					[ef,wn]=feval(bdcond,L,nmax);
					ff1=inline(vectorize([f1 '+0*' xvar]),xvar);
					cn1=coeff(ff1,ef,wn,linspace(0,L,32*length(wn)));
					ff2=inline(vectorize([f2 '+0*' xvar]),xvar);
					cn2=coeff(ff2,ef,wn,linspace(0,L,32*length(wn)));
					u=feval(type,ef,wn,cn1,c,x,t,cn2);

					freeaxes;
					title(ttl);
					xlabel('x');
					ylabel('t');
					zlabel('u');
					mesh(x,t,u);
				end
			case 2
				Told=T;
				Lold=L;
				f1old=f1;
				f2old=f2;
				ttlold=ttl;
				try
					clear(ff1);
					clear(ff2);
				catch
					% do nothing
				end
				try
					T=definput('Duration T',T);
					L=definput('Length   L',L);

					if strcmp(type,'wave')
						f1=definput('Initial displacement u(x,0)',f1);
						f2=definput('Initial velocity u_t(x,0)',f2);
						ttl=['Wave equation, c = ' num2str(c) ', ' bdcond ', u(x,0) = ' f1 ', u_t(x,0) = ' f2];
					else
						f1=definput('Initial temperature distribution u(x,0)',f1);
						f2='0';
						ttl=['Heat equation, k = ' num2str(c) ', ' bdcond ', u(x,0) = ' f1];
					end

					x=linspace(0,L,xn+1);
					t=linspace(0,T,tn+1);

					try
						clear(ff1);
						clear(ff2);
					catch
						% do nothing
					end
					[ef,wn]=feval(bdcond,L,nmax);
					ff1=inline(vectorize([f1 '+0*' xvar]),xvar);
					cn1=coeff(ff1,ef,wn,linspace(0,L,32*length(wn)));
					ff2=inline(vectorize([f2 '+0*' xvar]),xvar);
					cn2=coeff(ff2,ef,wn,linspace(0,L,32*length(wn)));
					u=feval(type,ef,wn,cn1,c,x,t,cn2);

					freeaxes;
					title(ttl);
					xlabel('x');
					ylabel('t');
					zlabel('u');
					mesh(x,t,u);
				catch
					disp(lasterr);
					complain('Please check your settings.');

					L=Lold;
					T=Told;
					f1=f1old;
					f2=f2old;
					ttl=ttlold;

					x=linspace(0,L,xn+1);
					t=linspace(0,T,tn+1);

					try
						clear(ff1);
						clear(ff2);
					catch
						% do nothing
					end
					[ef,wn]=feval(bdcond,L,nmax);
					ff1=inline(vectorize([f1 '+0*' xvar]),xvar);
					cn1=coeff(ff1,ef,wn,linspace(0,L,32*length(wn)));
					ff2=inline(vectorize([f2 '+0*' xvar]),xvar);
					cn2=coeff(ff2,ef,wn,linspace(0,L,32*length(wn)));
					u=feval(type,ef,wn,cn1,c,x,t,cn2);

					freeaxes;
					title(ttl);
					xlabel('x');
					ylabel('t');
					zlabel('u');
					mesh(x,t,u);
				end
			case 3
				try
					freeaxes;
					title(ttl);
					xlabel('x');
					ylabel('t');
					zlabel('u');
					mesh(x,t,u);
				catch
					disp(lasterr);
					complain('Please check your settings.');
				end
			case 4
				try
					slideshow(x,t,u,stp,1,hld,ttl,'x','u','t =');
				catch
					disp(lasterr);
					complain('Please check your settings.');
				end
			case 5
				try
					slideshow(t,x,u',stp,1,hld,ttl,'t','u','x =');
				catch
					disp(lasterr);
					complain('Please check your settings.');
				end
			case 6
				nmaxold=nmax;
				hldold=hld;
				stpold=stp;
				xnold=xn;
				tnold=tn;
				try
					clear(ff1);
					clear(ff2);
				catch
					% do nothing
				end
				try
					nmax=definput('Max harmonic',nmax);
					if nmax~=nmaxold & xn<nmax
						xn=nmax;
					end
					xn=definput('Number of points to be plotted (x)',xn);
					tn=definput('Number of points to be plotted (t)',tn);
					hld=choose('Superimpose successive plots (y/n)','ny',hld);
					stp=choose('Plotting method','as',stp,'Enter plotting method. Enter a for animation or s for step-by-step.');
					x=linspace(0,L,xn+1);
					t=linspace(0,T,tn+1);
					[ef,wn]=feval(bdcond,L,nmax);
					try
						clear(ff1);
						clear(ff2);
					catch
						% do nothing
					end
					ff1=inline(vectorize([f1 '+0*' xvar]),xvar);
					cn1=coeff(ff1,ef,wn,linspace(0,L,32*length(wn)));
					ff2=inline(vectorize([f2 '+0*' xvar]),xvar);
					cn2=coeff(ff2,ef,wn,linspace(0,L,32*length(wn)));
					u=feval(type,ef,wn,cn1,c,x,t,cn2);
					freeaxes;
					title(ttl);
					xlabel('x');
					ylabel('t');
					zlabel('u');
					mesh(x,t,u);
				catch
					disp(lasterr);
					complain('Reverting to previous values.');
					nmax=nmaxold;
					hld=hldold;
					stp=stpold;
					xn=xnold;
					tn=tnold;
					x=linspace(0,L,xn+1);
					t=linspace(0,T,tn+1);
					[ef,wn]=feval(bdcond,L,nmax);
					try
						clear(ff1);
						clear(ff2);
					catch
						% do nothing
					end
					ff1=inline(vectorize([f1 '+0*' xvar]),xvar);
					cn1=coeff(ff1,ef,wn,linspace(0,L,32*length(wn)));
					ff2=inline(vectorize([f2 '+0*' xvar]),xvar);
					cn2=coeff(ff2,ef,wn,linspace(0,L,32*length(wn)));
					u=feval(type,ef,wn,cn1,c,x,t,cn2);
					freeaxes;
					title(ttl);
					xlabel('x');
					ylabel('t');
					zlabel('u');
					mesh(x,t,u);
				end
			case 7
				fname=exportmenu(fname);
			otherwise
				nn=0;
		end
	end

	% just ignore the next few lines; their only purpose is to make some
	% dependencies explicit
	dummy=0;
	if dummy==1
		heat;
		wave;
		dirichlet;
		neumann;
		periodic;
		cosef;
		sinef;
		periodicef;
	end

