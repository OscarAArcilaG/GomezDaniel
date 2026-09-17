function [tt_o, out_y] = PID_simulate(p)

global fm tt dt sys_A Kp_GA Ki_GA Kd_GA Tf_GA 
%% 
% The plant
%%%%%%%%%%%%%%%%%%%%%%%%%
z_a = [    ];
p_a = 100*[...
  -0.6000 + 4.19198i
  -0.6000 - 4.109198i
  -1.7141 + 2.1876i
  -1.7141 - 2.1876i
  -0.8533 + 0.0000i
];
k_a = 11.46830e+11;

[num_a, den_a] = zp2tf(z_a,p_a,k_a);
sys_A = tf(num_a,den_a);
%%%%%%%%%%%%%%%%%%%%%%%%%%

Kp_GA  = p(1);
Ki_GA  = p(2);
% Kd_GA  = p(3);
Tf_GA  = p(3);


dt = 1/fm;
% t = 0:dt:5;
% damp(sys_str);


%  open('MDOF_subs_sim')
opt = simset('FixedStep',dt,'Solver','ode4'); % Set integrator opt.
[tto,y2] = sim('PID_optim',[0 tt(end)],opt);


% BL = .00000*randn(1,length(t));
out_y = out_str.signals.values;
tt_o = out_str.time;

% close_system MDOF_subs_sim

% figure(1)
% plot(tt,y_f,'color','k','linewidth',2.5), hold on, grid on
% plot(tt,out_y)
