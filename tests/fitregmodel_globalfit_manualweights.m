function [err,data,maxerr] = test(opt,olddata)

Ntime1 = 100;
Ndist = 200;

dt = 0.008;
t1 = linspace(0,dt*Ntime1,Ntime1);
[~,rmin,rmax] = time2dist(t1);
r = linspace(rmin,rmax,Ndist);

P = rd_twogaussian(r,[2,0.3,4,0.3,0.5]);

K1 = dipolarkernel(t1,r);
S1 = K1*P;
noise = whitegaussnoise(length(S1),0.03);
S1 = S1 + noise;

Ntime2 = 200;
t2 = linspace(0,dt*Ntime2,Ntime2);
K2 = dipolarkernel(t2,r);
S2 = K2*P;
noise = whitegaussnoise(length(S2),0.05);
S2 = S2 + noise;

Ntime3 = 300;
t3 = linspace(0,dt*Ntime3,Ntime3);
K3 = dipolarkernel(t3,r);
S3 = K3*P;
noise = whitegaussnoise(length(S3),0.1);
S3 = S3 + noise;


%Set optimal regularization parameter (found numerically lambda=0.13)
regparam = 2;

Ss = {S1,S2,S3};
Ks = {K1,K2,K3};

Result = fitregmodel(Ss,Ks,r,'tikhonov',regparam,'Solver','fnnls','GlobalWeights',[0.4 0.5 0.1]);

err = any(isnan(Result));
err = any(err);
data = [];
maxerr = 0;

end