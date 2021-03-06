function [err,data,maxerr] = test(opt,oldata)


Dimension = 400;
dt = 0.008;
t = linspace(0,dt*Dimension,Dimension);
r = time2dist(t);
InputParam = [3 0.5 4 0.5 0.4];
P = rd_twogaussian(r,InputParam);

K = dipolarkernel(t,r);
DipEvoFcn = K*P;

InitialGuess = [2 0.5 5 0.3 0.5];
[FitParam,FitP] = fitparamodel(DipEvoFcn,@rd_twogaussian,r,K,InitialGuess);
err(1) = any(abs(FitP - P)>1e-5);
err = any(err);

maxerr = max(abs(FitP - P));
data = [];

if opt.Display
   figure(1),clf
   subplot(121)
   hold on
   plot(t,DipEvoFcn,'b')
   plot(t,K*FitP,'r')
   subplot(122)
   hold on
   plot(r,P,'b')
   plot(r,FitP,'r')
   
end

end