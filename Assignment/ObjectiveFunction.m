function [f] = ObjectiveFunction(x)

ReturnValOnError = 10000000.0;
PenaltyFactor = 1000.0;

% Write the file with b-spline parameters
fp = fopen('C:\Users\raeann\Downloads\AnyBody Folder\Assignment/InputData.any','w+');
fprintf(fp,'AnyFloat DriverData = {{');
for i=1:(length(x)/2-1)
  fprintf(fp,'%.13f,',x(i));
end
fprintf(fp,'%.13f},{',x(length(x)/2));


fprintf(fp,'AnyFloat DriverData = {{');
for i=length(x)/2+1:(length(x)-1)
  fprintf(fp,'%.13f,',x(i));
end
fprintf(fp,'%.13f},{',x(end));

fclose(fp);

 % Execute the model
[status,result] = system(['"C:\Program Files\AnyBody Technology\AnyBody.8.0\AnyBodyCon.exe" /m ExeMacro.anymcr']);

% check for error
error_check = strfind(result,'ERROR');

if error_check > 0
    f = ReturnValOnError;
    return;
end

Data = readABO('C:\Users\raeann\Downloads\AnyBody Folder\Assignment/Output.txt');

t = cell2mat(Data.Values(1));
FootPosX=cell2mat(Data.Values(2));
FootVelX=cell2mat(Data.Values(5));
MaxMusAct=cell2mat(Data.Values(8));
HipAngle=cell2mat(Data.Values(9));
KneeAngle = cell2mat(Data.Values(10));


% further joint boundaries
% We set the Joint angle parameters as follows
MaxHipAngle = 120;
MinHipAngle = -30;
MaxKneeAngle = 0;
MinKneeAngle = -150;


% objective function
f = 0;
MaximumVel=0;
AnyArray_Temproray= zeros(6,1);

for j=2:length(t)
    if FootPosX(j)>0 && FootPosX(j+1)<0           
        f=-max(FootVelX(j-1));
    else
        f=ReturnValOnError;
    end
end

% further joint boundaries
% We set the Joint angle parameters as follows
HipFlexion = 120;
HipExtension = 30;
KneeFlexion = 150
KneeExtension= 0;


if min(HipAngle)<-HipFlexion*(pi/180)
    f = f + PenaltyFactor*(-min(HipAngle)^2);
end

if max(HipAngle)>HipExtension*(pi/180)
    f = f + PenaltyFactor*(-max(HipAngle)^2);
end 

if min(KneeAngle)<-KneeFlexion*(pi/180)
    f = f + PenaltyFactor*(min(KneeAngle)^2);
end 

if max(KneeAngle)>KneeExtension
    f = f + PenaltyFactor*(max(KneeAngle)^2);
end 


if max(MaxMusAct)>1
    f = f + PenaltyFactor*max(MaxMusAct);
end



