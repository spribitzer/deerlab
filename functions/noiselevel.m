%
% NOISELEVEL Estimate the noise level (standard deviation)
%
%   level = NOISELEVEL(S)
%   Returns the standard deviation estimation of the noise in the signal S.
%   The estimation is done from the last quarter of the signal.
%
%   level = NOISELEVEL(S,M)
%   Returns the standard deviation estimation of the noise in the signal S.
%   The estimation is done from the last M-points of the N-point signal.
%

% This file is a part of DeerLab. License is MIT (see LICENSE.md). 
% Copyright(c) 2019: Luis Fabregas, Stefan Stoll, Gunnar Jeschke and other contributors.


function Level = noiselevel(S,M)

validateattributes(S,{'numeric'},{'2d','nonempty'})
%Get signal length
N = length(S);

%Validate input
if nargin<2 || isempty(M)
    %Extract the piece of signal to estimate
    M = 1/5*N;
else
    validateattributes(M,{'numeric'},{'scalar','nonempty','nonnegative'})
end
if M>N
    error('Second argument cannot be longer than the length of the signal.')
end

%Extract the piece of signal to estimate
idx = ceil(N-M):N;
idx = idx.';
Cutoff = S(idx);

%Fit a line to remove possible oscillation fragment
opts = optimset('MaxFunEvals',50000, 'MaxIter',10000);
lineparam = fminsearch(@(x)norm(x(1) + x(2)*idx  - Cutoff)^2,rand(2,1),opts);
linearfit = lineparam(1)+ lineparam(2)*idx;
Cutoff = Cutoff - linearfit;

%Estimate the noise level
Cutoff = Cutoff - mean(Cutoff);
Level = std(Cutoff);

end