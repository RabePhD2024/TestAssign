function [f] = ObjectiveFunction(x)

ReturnValOnError = 10000000.0;
PenaltyFactor = 1000.0;

% Write the file with b-spline parameters
fp = fopen('C:\Users\151716\OneDrive\Desktop\PhD_Course\Assignment_Lorenza_Lupo\Model\input_data.any','w+');
fprintf(fp,'AnyFloat KneeAngles = {{');
for i = 1:(length(x)/2-1)
  fprintf(fp,'%.13f, ',x(i));    % I'm writing for three times the same angle to assure the stationarity of the knee
end
fprintf(fp,'%.13f}*pi/180};\n',x(length(x)/2));

% Hip Angles
fprintf(fp,'AnyFloat HipAngles = {{');
for i = (length(x)/2+1):(length(x)-1)
  fprintf(fp,'%.13f, ',x(i));    % I'm writing for three times the same angle to assure the stationarity of the hip
end
fprintf(fp,'%.13f}*pi/180};',x(end));

fclose(fp);

% % Execute the model
[status,result] = system('"C:\Users\151716\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\AnyBody 8.0\AnyBodyConsole 8.0 .lnk" /m C:\Users\151716\OneDrive\Desktop\PhD_Course\Assignment_Lorenza_Lupo\Model\ExeMacro.anymcr')

% check for error
error_check = strfind(result,'ERROR')

if error_check > 0
    f = ReturnValOnError;
    return;
end

% Collecting Data
Data = readABO('C:\Users\151716\OneDrive\Desktop\PhD_Course\Assignment_Lorenza_Lupo\Model\Output.txt');

t = cell2mat(Data.Values(1));
VelX = cell2mat(Data.Values(2));
PosX = cell2mat(Data.Values(5));
M = cell2mat(Data.Values(8));

% objective function
f=0;
ceq_tmp = zeros(6,1);

% Parameters
MaxHipAngle = 120;
MinHipAngle = -30;
MaxKneeAngle = 0;
MinKneeAngle = -150;
Stat_Tolerance = 0.1;


% Check on the knee and hip angles
% Knee

if min(x(1:length(x)/2)) < MinKneeAngle 
    ceq_tmp(1) = -(min(x(1:length(x)/2)) - MinKneeAngle);  % I want to penalize the deviation from MinKneeAngle
end

if max(x(1:length(x)/2)) > MaxKneeAngle 
    ceq_tmp(2) = max(x(1:length(x)/2)) - MaxKneeAngle;
end

% Hip
if max(x(length(x)/2+1:length(x))) > MaxHipAngle
    ceq_tmp(3) = max(x(length(x)/2+1:length(x))) - MaxHipAngle;     % I want to penalize the deviation from MaxHipAngle
end

if min(x(length(x)/2+1:length(x))) < MinHipAngle
    ceq_tmp(4) = -(min(x(length(x)/2+1:length(x))) - MinKneeAngle);
end


% Check on the maximum activation to be less then 1
                     
if max(M)>1
    ceq_tmp(5) = sqrt(max(M)^2-1);      % I want to penalize the deviation from 100% of activity
end

% Check the stationary condition
% Knee
 for i = 2:3
    dif = abs(x(1)-x(i));
    if dif > Stat_Tolerance
        ceq_tmp(6) = ceq_tmp(6) + dif;  % i want that the first 3 angles remain almost the same. I penalize a deviation from 0.1 degrees
    end
 end  

 % Hip 
 for i=13:14
    dif = abs(x(length(x)/2+1)-x(i));
    if dif > Stat_Tolerance
        ceq_tmp(6) = ceq_tmp(6) + dif;
    end
 end

% Maximum velocity computation
flag=0;
max_vel = 0;

for j=1:(length(t)-1)
    if PosX(j)<0 && PosX(j+1)>0 && flag==0           % I'm assuming that the ball is in a position proximal to x = 0
        max_vel = (abs(VelX(j))+abs(VelX(j+1)))/2;   % Taking the maximum velocity as the average between the velocities in the moments in time in which I am expecting to hit the ball
        flag=1;
    end
end

f = - max_vel + PenaltyFactor*max(ceq_tmp)^2;


end

