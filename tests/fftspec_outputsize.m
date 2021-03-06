function [err,data,maxerr] = test(opt,olddata)

FreqAxis = linspace(-10,10,200);
t = linspace(0,1/mean(2*10)*100,100);

S = exp(-t).*cos(2*pi*5*t);
Spectrum = abs(fftshift(fft(S,2*length(S))));
[Output1] = fftspec(t,S,'Type','abs','Apodization',true);
[Output2] = fftspec(t,S,'Type','abs','Apodization',false);

error(1) = ~isvector(Output1);
error(2) = ~isvector(Output2);
err = any(error);
maxerr = max(error);
data = [];

if opt.Display
  figure,clf
  subplot(121)
  plot(t,S)
  subplot(122)
  hold on
  plot(FreqAxis,Spectrum)
  plot(FrequencyAxis,Output1)
end

end