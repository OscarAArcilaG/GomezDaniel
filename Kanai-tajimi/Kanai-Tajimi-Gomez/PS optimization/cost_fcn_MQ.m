function obj = cost_fcn_MQ(p)

    global MQ MQ_n MQ_opt WIN W_opt psd_ox tt fm fs PSD_opt time ug_synt f_g z_g f1 z1 one_on fil_n plot_on w_1 w_2 cont lb ub opti vidObj
% simulate model
%     [tt_o, out_y] = PID_simulate(p);
 [time, ~,MQ_opt ,W_opt,fs,PSD_opt,psd_ox] = generate_MOONquake_OPT(tt,WIN,fm,MQ_n,f_g,z_g,one_on,fil_n,p);

%     figure
%     plot(tt,MQ_n,'k'), hold on, grid on
%     plot(tt,WIN,'linewidth',2.5,'color',.6*ones(1,3))
%     plot(tt,MQ_opt,'b')
%     plot(tt,W_opt,'color','c','linewidth',2)

 
% calculate objective
[f_i] = find(fs>0.1);
[f_j] = find(fs<1);

   obj_t = goodnessOfFit(W_opt,WIN,'NRMSE'); 
   obj_t = abs(obj_t-1);

   obj_f = goodnessOfFit(db(PSD_opt(f_i(1):f_j(end),1)),db(psd_ox(f_i(1):f_j(end),1)),'NRMSE'); 
   obj_f = abs(obj_f-1);
   
   obj = .5*obj_t + .5*obj_f;
   
% opti.z_g(cont) = p(1); 
opti.z1(cont)  = p(1); 
opti.f1(cont)  = p(2); 
opti.amp(cont)  = p(3);

figure(1)
clf(1)
subplot(3,4,[1:3 5:7])
    plot(tt,MQ_n,'k'), hold on, grid on
p1 =plot(tt,WIN,'linewidth',2.5,'color',.6*ones(1,3));
    plot(tt,MQ_opt,':','color',[0.8500    0.3300    0.1000])
p2 =plot(tt,W_opt,'color','c','linewidth',2);
axis([0 tt(end) -1.2 1.2])
legend([p1 p2],{'Desired','Optimized'},'location','northeast')
ylabel('Acceleration, [DU]','fontsize',12)
xlabel('Time [sec]')

subplot(3,4,[9])
plot([1:cont],opti.z1,'.'), hold on, grid on
axis([0 cont lb(1) ub(1)])
ylabel('\zeta_h')

subplot(3,4,[10])
plot([1:cont],opti.f1,'.'), hold on, grid on
axis([0 cont lb(2) ub(2)])
ylabel('f_h [Hz]')

subplot(3,4,[11])
plot([1:cont],opti.amp,'.'), hold on, grid on
axis([0 cont lb(3) ub(3)])
ylabel('gain [-]')

subplot(3,4,[4 8])
semilogx([f_i f_i],[-1000 1000],'k--'), hold on, semilogx([f_j f_j],[-1000 1000],'k--'),
semilogx(fs,db(psd_ox(:,1)),'color',.6*ones(1,3),'linewidth',2);grid on, hold on
semilogx(fs,db(PSD_opt(:,1)),'color','c','linewidth',2);
axis([.1 2 -60 20])
ylabel('Amp. [dB]')
xlabel('Freq. [Hz]')

% subplot(3,3,9)
% plot([1:cont],opti.f1,'.'), hold on, grid on
% ylim([lb(3) ub(3)])
% ylabel('f_h [Hz]')
cont = cont +1;
   

%%%%%%%%%%%%%%%%%
currFrame = getframe(gcf);
writeVideo(vidObj,currFrame);
%%%%%%%%%%%%%%%%
