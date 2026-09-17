function [tt_o,out_o,MQ_opt,W_opt,fs,PSD_opt,psd_ox] = generate_MOONquake_OPT(tt,WIN,fm,MQ_n,fg,zg,one_on,fil_num,p)

    global  z1_opt f1_opt amp_opt
    
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

%%%%%%%%%%%%%%%%%%%%%%%%%%

% zg_opt = p(1);
z1_opt  = p(1);
f1_opt  = p(2);
amp_opt = p(3);

% INPUTS 
% if isempty(Tmax),Tmax = 30; end		% duration of earthquake
% if isempty(dt),  dt = 0.001; end		% time 

% NUMBER OF POINTS IN RECORD/ SET UP WINDOWS
% % n1 = round((n-1)/10);	% length of first window
% % n2 = round((n-1)/8);	   % length of second window
% % n1 = round((n-1)/18);	% length of first window
% % n2 = round((n-1)/6);	   % length of second window

% n  = ceil(Tmax/dt);	      % number of points in acceleration record
% n1 = round((n-1)/w_1_opt);	% length of first window
% n2 = round((n-1)/w_2_opt);	   % length of second window

% n3 = n-n1-n2;		      % length of third window

% GENERATE NORMALLY DISTRIBUTED RANDOM DATA
Time   = [0:1/fm:tt(end)];	% associated time vector
rng('default');
RanAcc = randn(1,length(Time));	   % random data

if length(RanAcc)~=length(Time)
    Time = Time(1:end-1);
end

% FORM KANAI-TAJIMI EARTHQUAKE SPECTRUM 
   wg    = fg*2*pi;  w1 = f1_opt*2*pi;
   numeq	= conv([2*zg*wg wg^2],[w1^2 0 0]);
   deneq	= conv([1 2*zg*wg wg^2],[1 2*z1_opt*w1 w1^2]);

% RUN SIMULATION TO GENERATE FILTERED WHITE NOISE 
[Aeq,Beq,Ceq,Deq]	= tf2ss(numeq,deneq);
ss_eq = ss(Aeq,Beq,Ceq,Deq);
[GA]  = lsim(ss_eq,RanAcc,Time);

out_o  = GA.*WIN;
tt_o   = Time; 
% 

% out_o = out_o/max(abs(out_o));	% normalize so max = 1; 
% [MQ_opt, W_opt] = envelope_MQ(tt,MQ,12000,'y');

[Win,~] = envelope(out_o,fil_num,'peak');
W_opt = Win/max(abs(Win));	% normalize so max = 1;
MQ_opt = out_o/max((out_o));	% normalize so max = 1;

%%  Freq. domain comparison
nfft = 2^12;
noverlap = nfft/2;
window = nfft;
% MQ_raw_n = MQ_raw(:,2)/max((MQ_raw(:,2)));	% normalize so max = 1;
[psd_ox,f] = spectrum(MQ_n,nfft,noverlap,window,fm);

% nfft = 2^12;
% noverlap = nfft/2;
% window = nfft;
[PSD_opt,fs] = spectrum(amp_opt*MQ_opt,nfft,noverlap,window,fm);

% figure(44)
% semilogx(f,db(psd_ox(:,1)),'b','linewidth',2);grid on, hold on
% semilogx(fs,db(PSD_opt(:,1)),'r','linewidth',2);grid on, hold on
% xlim([.1 1])




