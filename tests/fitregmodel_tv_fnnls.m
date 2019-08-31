function [err,data,maxerr] = test(opt,olddata)

%=======================================
% Check Tikhonov regularization
%=======================================

Dimension = 200;
dt = 0.008;
t = linspace(0,dt*Dimension,Dimension);
r = time2dist(t);
Distribution = rd_onegaussian(r,[3,0.5]);

K = dipolarkernel(t,r);
DipEvoFcn = K*Distribution;

%Set optimal regularization parameter (found numerically lambda=0.13)
RegParam = 1e-3;
RegMatrix = regoperator(Dimension,3);
TikhResult1 = fitregmodel(DipEvoFcn,K,r,RegMatrix,'tv',RegParam,'Solver','fnnls');

err = any(abs(TikhResult1 - Distribution)>2e-2);

maxerr = max(abs(TikhResult1 - Distribution));

data = [];

if opt.Display
 	figure(8),clf
    hold on
    plot(r,Distribution,'k') 
    plot(r,TikhResult1,'r')
    axis tight
end

end