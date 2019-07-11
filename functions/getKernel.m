function [Kernel,DistanceAxis] = getKernel(dimension,TimeStep,rmin,rmax,Background)

OldPrecision = digits(30); 

if ~exist('TimeStep','var') || isempty(TimeStep)
    TimeStep = 8;
end

%Numerical dipolar frequency at 1 nm for g=ge
ny0 = 52.04; 
%Convert time step to miliseconds
TimeStep = round(TimeStep)/1000;

if ~exist('rmin','var') || isempty(rmin)
    rmin = (4*TimeStep*ny0/0.85)^(1/3); 
end

if ~exist('rmax','var') || isempty(rmax)
    rmax = 6*(dimension*TimeStep/2)^(1/3);
end

%Numerical angular dipolar frequency at 1 nm for g=ge
w0 = 2*pi*ny0; 
%Construct time and distance axes
TimeAxis = linspace(0,(dimension-1)*TimeStep,dimension);
DistanceAxis=linspace(rmin,rmax,dimension);
%Get vector of dipolar frequencies
wdd=w0./(DistanceAxis.^3); 
wdd = wdd';
%Allocate products for speed
wddt = wdd*TimeAxis;
kappa = sqrt(6*wddt/pi);
%Compute Fresnel integrals of 0th order
C = fresnelC(kappa);
S = fresnelS(kappa);

%Compute dipolar kernel
Kernel = sqrt(pi./(wddt*6)).*(cos(wddt).*C + sin(wddt).*S);
%Replace undefined Fresnel NaN value at time zero
Kernel(:,1) = 1; 

%If given, build the background into the kernel
if nargin>4 && ~isempty(Background)
    if iscolumn(Background)
        Background = Background';
    end
    Kernel = Kernel + (1/Background(1) - 1);
    Kernel = Kernel.*repmat(Background,dimension,1);
end

%Transpose
Kernel = Kernel';

%Return to old precision settings
digits(OldPrecision);

return