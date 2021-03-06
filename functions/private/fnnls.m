%FNNLS	Fast non-negative least-squares algorithm.
%
% 	Adapted from NNLS by Mathworks, Inc. and fnnls by R. Bro 5-7-96
%
%	x = fnnls(AtA,Atb) solves the problem min ||b - Ax|| if
%  	AtA = A'*A and Atb = A'*b.
%
%	A default tolerance of TOL = MAX(SIZE(AtA)) * NORM(AtA,1) * EPS
%	  is used for deciding when elements of x are less than zero.
%	  This can be overridden with x = fnnls(AtA,Atb,TOL).
%
%	[x,w] = fnnls(AtA,Atb) also returns dual vector w where
%	  w(i) < 0 where x(i) = 0 and w(i) = 0 where x(i) > 0.

% For the FNNLS algorithm, see
%   R. Bro, S. De Jong
%   A Fast Non-Negativity-Constrained Least Squares Algorithm
%   Journal of Chemometrics 11 (1997) 393-401
% The algorithm FNNLS is based on is from
%   Lawson and Hanson, "Solving Least Squares Problems", Prentice-Hall, 1974.

function [x,w,passive,flag] = fnnls(AtA,Atb,x0,tol,verbose)

if nargin<5 || isempty(verbose)
    verbose = 'off';
    allowedInput = {'off','final','iter-detailed'};
    verbose = validatestring(verbose,allowedInput);
end
unsolvable = false;
count = 0;

% Provide starting vector if not given.
if (nargin<3) || isempty(x0)
    x0 = zeros(size(AtA,2),1);
end

% Calculate tolerance if not given.
if (nargin<4)
    tol = 10*eps*norm(AtA,1)*max(size(AtA));
end
N = numel(x0);

Atbt = Atb.';
AtAt = AtA.';

x = x0;
passive = x>0; % positive/passive set (points where constraint is not active)
x(~passive) = 0;
w = Atb - AtA*x; % negative gradient of error functional 0.5*||A*x-y||^2

outIteration = 0;
maxIterations = 5*N;

if strcmp(verbose,'iter-detailed')
    fprintf('%15s%15s%13s\n','Outer Iter',' Inner Iter','Fun Eval')
end

% Outer loop: Add variables to positive set if w indicates that fit can be improved.
while any(w>tol) && any(~passive)
    outIteration =   outIteration + 1;
    % Add the most promising variable (with largest w) to positive set.
    [~,t] = max(w);
    passive(t) = true;
    iIteration = 0;
    
    % Solve unconstrained problem for new augmented positive set.
    % This gives a candidate solution with potentially new negative variables.
    x_ = zeros(N,1);
    x_(passive) = Atbt(passive)/AtAt(passive,passive);
    % Inner loop: Iteratively eliminate negative variables from candidate solution.
    while any((x_<=tol) & passive) && (iIteration<maxIterations)
        
        iIteration = iIteration + 1;
        
        % Calculate maximum feasible step size and do step.
        negative = (x_<=tol) & passive;
        alpha = min(x(negative)./(x(negative)-x_(negative)));
        x = x + alpha*(x_-x);
        
        % Remove all negative variables from positive set.
        passive(x<tol) = false;
        
        % Solve unconstrained problem for reduced positive set.
        x_ = zeros(N,1);
        x_(passive) = Atbt(passive)/AtAt(passive,passive);
    end
    
    % Accept non-negative candidate solution and calculate w.
    if all(x == x_)
        count = count + 1;
    else
        count = 0;
    end
    if count > 5
        unsolvable = true;
        break;
    end
    x = x_;
    
    w = Atb - AtA*x;
    w(passive) = -inf;
    if strcmp(verbose,'iter-detailed')
        fprintf('%10i%15i%20.4e\n',outIteration,iIteration,max(w))
    end
end

if unsolvable
    flag = -2;
elseif any(~passive)
    flag = 1;
elseif w>tol
    flag = -1;
else
    flag = 0;
end

if strcmp(verbose,'final') || strcmp(verbose,'iter-detailed')
    if unsolvable
        fprintf('Optimization stopped because the solution cannot be further changed. \n')
    elseif any(~passive)
        fprintf('Optimization stopped because the active set has been completely emptied. \n')
    elseif w>tol
        fprintf('Optimization stopped because the gradient (w) is inferior than the tolerance value TolFun = %.6e. \n',tol)
    end
end


