function output = rd_randcoil(r,param)
%
% RD_RANDCOIL Random-coil model for an unfolded peptide/protein
%
%   info = RD_RANDCOIL
%   Returns an (info) structure containing the specifics of the model.
%
%   P = RD_RANDCOIL(r,param)
%   Computes the N-point model (P) from the N-point distance axis (r) according to 
%   the paramteres array (param). The required parameters can also be found 
%   in the (info) structure. The end-to-end distance distribution is approximated 
%   by a Gaussian coil with proper mean distance, which is good for
%   sufficiently large N.
%   See: N. C. Fitzkee, G. D. Rose, PNAS 2004, 101(34), 12497-12502
%
% PARAMETERS
% name      symbol default lower bound upper bound
% --------------------------------------------------------------------------
% param(1)  N      50      2              1000    number of residues between labels, including labeled residues
% param(2)  nu     0.602   0.33           1       scaling exponent
% --------------------------------------------------------------------------
%

% This file is a part of DeerLab. License is MIT (see LICENSE.md). 
% Copyright(c) 2019: Luis Fabregas, Stefan Stoll, Gunnar Jeschke and other contributors.

R0 = 0.198; % 1.98 � per residue
nParam = 2;

if nargin~=0 && nargin~=2
    error('Model requires two input arguments.')
end

if nargin==0
    %If no inputs given, return info about the parametric model
    info.model  = 'Random-coil model';
    info.nparam  = nParam;
    info.parameters(1).name = 'Chain members N';
    info.parameters(1).range = [2 1000];
    info.parameters(1).default = 50;
    info.parameters(1).units = '';
    
    info.parameters(2).name = ['Scaling exponent',char(957)];
    info.parameters(2).range = [0.33 1];
    info.parameters(2).default = 0.602;
    info.parameters(2).units = '';
    
    output = info;
    return
end
    
    %If user passes them, check that the number of parameters matches the model
    if length(param)~=nParam
        error('The number of input parameters does not match the number of model parameters.')
    end
    
    %Parse input axis
    if ~iscolumn(r)
        r = r.';
    end

    SquareDist = 6*(R0*param(1)^param(2))^2; %mean square end-to-end distance from radius of gyration
    normFact = 3/(2*pi*SquareDist)^(3/2); % normalization prefactor
    ShellSurf = 4*pi*r.^2; % spherical shell surface
    Gaussian = exp(-3*r.^2/(2*SquareDist));
    Distribution = normFact*ShellSurf.*Gaussian;
    
    %Normalize integral
    Distribution = Distribution/sum(Distribution)/mean(diff(r));
    output = Distribution;

return

