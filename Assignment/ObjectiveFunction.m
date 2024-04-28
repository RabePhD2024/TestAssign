function [f] = ObjectiveFunction(x)

ReturnValOnError = 10000000.0;
PenaltyFactor = 1000.0;

% Write the file with b-spline parameters
fp = fopen('InputData.any','w+');
fprintf(fp,'AnyFloat DriverData = {{');
for i=1:(length(x)/2-1)
  fprintf(fp,'%.13f,',x(i));
end
fprintf(fp,'%.13f},{',x(length(x)/2));
for i=length(x)/2+1:(length(x)-1)
  fprintf(fp,'%.13f,',x(i));
end
fprintf(fp,'%.13f},{',x(length(x)));

for i=length(x)+1:length(x)+length(x)/2-1
  fprintf(fp,'0.0,');
end
fprintf(fp,'0.0}};');

fclose(fp);

fprintf(fp,'%.13f,',x(1)); % Write Hip angle
fprintf(fp,'}}; \n ');



fprintf(fp,'AnyFloat DriverData_Knee = {{');
fprintf(fp,'%.13f,',x(2)); % Write Hip angle
fprintf(fp,'}};');
fclose(fp);


% % Execute the model
[status,result] = system(['"C:\Program Files\AnyBody Technology\AnyBody.8.0\AnyBodyCon.exe" /m ExeMacro.anymcr']);

% check for error
error_check = strfind(result,'ERROR');

if error_check > 0
    f = ReturnValOnError;
    return;
end

Data = readABO('../Output.txt');

t = cell2mat(Data.Values(1));
Foot_x=cell2mat(Data.Values(2));
Foot_y=cell2mat(Data.Values(3));
Vel = cell2mat(Data.Values(4));

% objective function
f = -max(Vel);
end

