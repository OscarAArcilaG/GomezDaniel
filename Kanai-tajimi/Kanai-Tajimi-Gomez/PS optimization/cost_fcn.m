function obj = cost_fcn(p)
    global Xc tt cont lb ub opti vidObj
% simulate model
    [tt_o, out_y] = PID_simulate(p);
    % calculate objective
%     obj =  sum((abs(out_y-Xc)).^2);
   obj = goodnessOfFit(out_y,Xc,'NRMSE'); 
   obj = abs(obj-1);
    
opti.Kp(cont) = p(1); 
opti.Ki(cont) = p(2); 
% opti.Kd(cont) = p(3); 
opti.Tf(cont) = p(3); 

figure(1)
clf(1)
subplot(3,2,[1:4])
plot(tt,Xc,'color','k','linewidth',1.5), grid on, hold on
plot(tt,out_y,'color','r','linewidth',1.5)
axis([4.5 5.5 0 5])
legend('Desired','Optimized','location','northwest')
ylabel('Response, [mm]')

subplot(3,2,5)
plot([1:cont],opti.Kp,'.'), hold on, grid on
ylim([lb(1) ub(1)])
ylabel('K_p')

subplot(3,2,6)
plot([1:cont],opti.Ki,'.'), hold on, grid on
ylim([lb(2) ub(2)])
ylabel('K_i')

% subplot(3,3,9)
% plot([1:cont],opti.Tf,'bo-'), hold on, grid on
% ylim([lb(3) ub(3)])
cont = cont +1;
   

% %%%%%%%%%%%%%%%%%
% currFrame = getframe(gcf);
% writeVideo(vidObj,currFrame);
% %%%%%%%%%%%%%%%%
