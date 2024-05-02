clear all;
close all;
MaxHipAngle = 120;
MinHipAngle = -30;
MaxKneeAngle = 0;
MinKneeAngle = -150;

addpath('readABO');
addpath('ComplexOptimiser');

% Initial guess of the design variables
xInit = [-25*(pi/180),-20*(pi/180),-15*(pi/180),-10*(pi/180),-5*(pi/180),0*(pi/180),5*(pi/180),10*(pi/180),15*(pi/180),20*(pi/180),-115*(pi/180),-90*(pi/180),-65*(pi/180),-40*(pi/180),-15*(pi/180),0*(pi/180),0*(pi/180),0*(pi/180),0*(pi/180),0*(pi/180),0*(pi/180),0*(pi/180)];

Options.m = length(xInit); % Number of design variables
Options.n = 10*Options.m+1; % Number of elements in the population. 2*m+1 is minimum. Higher is recommended

LowerBoxLimit_HipBoundaries = -MaxHipAngle*(pi/180); % Lower bound on the box that the initial poputation is randomly created within 
UpperBoxLimit_HipBoundaries = -MinHipAngle*(pi/180); % Upper bound on the box that the initial poputation is randomly created within

LowerBoxLimit_KneeBoundaries = MinKneeAngle*(pi/180); % Lower bound on the box that the initial poputation is randomly created within 
UpperBoxLimit_KneeBoundaries = MaxKneeAngle*(pi/180); % Upper bound on the box that the initial poputation is randomly created within

% The same upper bound is used for all design variables. If it is desired
% to different bounds for each design variable, this must be changed.

for i = 1:length(xInit)
    if i <= length(xInit)/2
        Options.BoxSize(i,1) = LowerBoxLimit_HipBoundaries;
        Options.BoxSize(i,2) = UpperBoxLimit_HipBoundaries;
    else
        Options.BoxSize(i,1) = LowerBoxLimit_KneeBoundaries;
        Options.BoxSize(i,2) = UpperBoxLimit_KneeBoundaries;
    end
end

Options.convergence.criteria = 0.001*ones(length(xInit),1); % Convergence criteria for the design variables.

Options.n_r = 4; % Number of repetitions a new solutions is allowed to remain the worst before it is replaced with a new random point
Options.k = 1.3; % the distance projected accross the centroid. 1.3 is recommended.

Options.MaxSteps = 10000; % Maximum number of iterations

[qOpt,fOpt, exitflag] = ComplexOptimiser(@(x) ObjectiveFunction(x),xInit,[],Options)