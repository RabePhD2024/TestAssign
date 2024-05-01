clear all;
close all;

addpath('readABO');
addpath('ComplexOptimiser');
% Initial guess of the design variables
% First eleven are Knee Angles, last eleven are Hip Angles
xInit = [ -115, -115, -115, -95, -40, -20, -15, -35, -25, -10, -15,  -15, -15, -15, -20, -30, -10, 25, 55, 70, 85, 90];

Options.m = length(xInit); % Number of design variables
Options.n = 4*Options.m+1; % Number of elements in the population. 2*m+1 is minimum. Higher is recommended

LowerBoxLimit = -20.0; % Lower bound on the box that the initial poputation is randomly created within 
UpperBoxLimit = 20.0; % Upper bound on the box that the initial poputation is randomly created within

% The same upper bound is used for all design variables. If it is desired
% to different bounds for each design variable, this must be changed.
for i=1:length(xInit)
    Options.BoxSize(i,1) = LowerBoxLimit;
    Options.BoxSize(i,2) = UpperBoxLimit;
end

Options.convergence.criteria = 0.001*ones(length(xInit),1); % Convergence criteria for the design variables.

Options.n_r = 4; % Number of repetitions a new solutions is allowed to remain the worst before it is replaced with a new random point
Options.k = 1.3; % the distance projected accross the centroid. 1.3 is recommended.

Options.PenaltyFactor = 1000.0;

Options.MaxSteps = 100000; % Maximum number of iterations

[qOpt,fOpt, exitflag] = ComplexOptimiser(@(x) ObjectiveFunction(x), xInit, [] , Options)
