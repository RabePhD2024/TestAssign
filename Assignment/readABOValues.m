function ABO = readABOValues(fid, ABO)

% Read values section
RefValuesHeader = [];
for(ColNum = 1:length(ABO.Variables))
    % Create the values section header line
    RefValuesHeader = [RefValuesHeader, ' ', ABO.Variables{ColNum}];
end;
RefValuesHeader = RefValuesHeader(2:end);

% Read values section header
[ValuesHeader,Count] = fread(fid, [1,length(RefValuesHeader)], 'char=>char');
[CRLF,Count] = fread(fid, [1,2], 'char');
if(strcmp(ValuesHeader, RefValuesHeader) == 0)
    error('Invalid variable section');
end;

% Use CSV read to read values (faster than by hand)
Data = fread(fid, inf);
csvfid = fopen('tmp.dat','w');
fwrite(csvfid, Data);
fclose(csvfid);
Values = dlmread('tmp.dat');
delete('tmp.dat');

% Save values
for(ColNum = 1:length(ABO.Variables))
    ABO.Values{ColNum} = Values(:,ColNum);
end;

