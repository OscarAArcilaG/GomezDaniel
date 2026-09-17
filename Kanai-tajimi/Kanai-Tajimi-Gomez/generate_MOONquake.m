function [T,GA,ss_eq] = generate_MOONquake(Tmax,dt,fg,zg,one_on,plot_on,f1,z1,cc,w_1,w_2)

% function [T,GA] = generate_quake(Tmax,dt,fg,zg,one_on,plot_on,f1,z1);
%
%	This function will generate a earthquake using the 
%  Kanai-Tajimi model. 
%
%  INPUTS: 
%    Tmax,dt = time length and time step of the generated earthquake
%    fg,zg   = Characteristics of the ground (fg is in Hz)
%    one_on  = 1 to normalize earthquake output to 1
%              0 to do no normalization (default)
%    plot_on = 1 to plot filter transfer function (0 = no plot, default)
%    f1,z1   = Characteristics of low frequency cutoff 
%
%  OUTPUTS: 
%    T  = time vector for earthquake
%    GA = ground acceleration vector for earthquake 
%    ss_eq = state space system representing filter

%	Written by: 	S.J. Dyke 3/15/97
%	Last update:	9/27/00
%	Modified by: 	D. Gomez  9/13/17



% INPUTS 
if isempty(Tmax),Tmax = 30; end		% duration of earthquake
if isempty(dt),  dt = 0.001; end		% time 

% NUMBER OF POINTS IN RECORD/ SET UP WINDOWS
n  = ceil(Tmax/dt);	      % number of points in acceleration record
% n1 = round((n-1)/10);	% length of first window
% n2 = round((n-1)/8);	   % length of second window
% n1 = round((n-1)/18);	% length of first window
% n2 = round((n-1)/6);	   % length of second window
n1 = round((n-1)/w_1);	% length of first window
n2 = round((n-1)/w_2);	   % length of second window

n3 = n-n1-n2;		      % length of third window

% GENERATE NORMALLY DISTRIBUTED RANDOM DATA
rng('default');
RanAcc = randn(1,n);	   % random data
Time   = [0:dt:Tmax];	% associated time vector

if length(RanAcc)~=length(Time)
    Time = Time(1:end-1);
end

% FORM KANAI-TAJIMI EARTHQUAKE SPECTRUM 
switch nargin
case {4}
   one_on = 0;
   wg    = fg*2*pi;
   numeq	= [2*zg*wg wg^2];
   deneq	= [1 2*zg*wg wg^2];
   
case {5} 
   plot_on = 0;
   wg    = fg*2*pi;
   numeq	= [2*zg*wg wg^2];
   deneq	= [1 2*zg*wg wg^2];
   
case {6}
   wg    = fg*2*pi;
   numeq	= [2*zg*wg wg^2];
   deneq	= [1 2*zg*wg wg^2];

case {11}
   wg    = fg*2*pi;  w1 = f1*2*pi;
   numeq	= conv([2*zg*wg wg^2],[w1^2 0 0]);
   deneq	= conv([1 2*zg*wg wg^2],[1 2*z1*w1 w1^2]);

otherwise
   error('There is a problem with your arguments.')
   
end

% RUN SIMULATION TO GENERATE FILTERED WHITE NOISE 
[Aeq,Beq,Ceq,Deq]	= tf2ss(numeq,deneq);
ss_eq = ss(Aeq,Beq,Ceq,Deq);
[GA]  = lsim(ss_eq,RanAcc,Time);

% PLOT TRANSFER FUNCTION
if plot_on==1;
   fvec = [0:.01:fg*3];
   [mag,ph] = bode(ss_eq,2*pi*fvec);
   figure;subplot(211)
   semilogx(fvec,20*log10(squeeze(mag))), grid on
   title('Filter used to generate data')
   ylabel('Magnitude (dB)')
   xlabel('Frequency (Hz)')
   xlim([.01 1/dt])
end

% APPLY WINDOWING FUNCTIONS TO SIGNAL
t1  = ([1:n1]/n1).^2;
t2  = ones(1,n2);
t3  = exp(-cc*[1:n3]/n3);
WIN = [t1(:) ; t2(:) ; t3(:)];
GA  = GA.*WIN;
T   = Time; 
% plot(T,WIN)
% ylim([0 1.5]), grid on

if (nargin>4),
	if (one_on==1),
	GA = GA/max(abs(GA));	% normalize so max = 1; 
	end
end

if plot_on==1;
   subplot(212)
   plot(T,GA)
   title('Moonquake Record Generated')
   xlabel('Time (sec)')
   ylabel('Acceleration')
end

