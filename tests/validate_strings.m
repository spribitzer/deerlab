function [err,data,maxerr] = test(opt,olddata)

t = linspace(0,4,200);
r = time2dist(t);

Parameters.regparam = linspace(0.1,1,5);
Parameters.type = {'tikh','tv'};

if opt.Display
    f = figure(1); clf;AxisHandle = axes(f);
else
    AxisHandle = [];
end

[meanOut,stdOut] = validate(@myfitting,Parameters,'AxisHandle',AxisHandle);

err = false;
data = [];
maxerr = -3;

if opt.Display
        cla
        hold on
        plot(r,meanOut,'b','LineWidth',1)
        f = fill([r fliplr(r)] ,[meanOut.'+stdOut.' fliplr(meanOut.'-stdOut.')],...
            'b','LineStyle','none');
        f.FaceAlpha = 0.5;
        hold('off')
        axis('tight')
        grid('on')
        box('on')
end

end


function Pfit = myfitting(param)
M = 200;
t = linspace(0,4,M);
r = time2dist(t);

P = rd_onegaussian(r,[4,0.3]);
K = dipolarkernel(t,r);
S = K*P;
S = dipolarsignal(t,r,P,'noiselevel',0.05);

order = 2;
L = regoperator(M,order);
regparam = param.regparam;
Pfit = fitregmodel(S,K,r,L,param.type,regparam);

end