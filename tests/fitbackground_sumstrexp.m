function [err,data,maxerr] = test(opt,olddata)

%======================================================
% Exponential background fit
%======================================================

t = linspace(0,5,100);
d = 3;

k = 0.5;
k2 = 0.2;
bckg = 0.4*exp(-(k*t).^(d/3)) + 0.6*exp(-(k2*t).^(d/3));
k = 1;
k2 = 0.6;
bckg2 = 0.4*exp(-(k*t).^(d/3)) + 0.6*exp(-(k2*t).^(d/3));
k = 1.5;
k2 = 2;
bckg3 = 0.4*exp(-(k*t).^(d/3)) + 0.6*exp(-(k2*t).^(d/3));

data2fit = bckg(1:end);
data2fit2 = bckg2(1:end);
data2fit3 = bckg3(1:end);

tstart = t(20);

fit = fitbackground(data2fit,t,@td_sumstrexp,tstart);
fit2 = fitbackground(data2fit2,t,@td_sumstrexp,tstart);
fit3 = fitbackground(data2fit3,t,@td_sumstrexp,tstart);

err(1) = any(abs(fit - bckg)>2e-3);
err(2) = any(abs(fit2 - bckg2)>2.5e-3);
err(3) =  any(abs(fit3 - bckg3)>2.5e-3);
err = any(err);
maxerr = max(abs(fit - bckg));
data = [];

if opt.Display
  figure,clf
  subplot(131)
  plot(t,bckg,t,fit)
  subplot(132)
  plot(t,bckg2,t,fit2)
  subplot(133)
  plot(t,bckg3,t,fit3)
end

end