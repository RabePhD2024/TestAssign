function ABO = readABOHeader(fid, ABO);

% Header is at beginning of file
status = fseek(fid, 0, 'bof');
if(status ~=0)
    error(ferror(fid));
end;

% READ HEADER
% Read identification
[ID,Count] = fscanf(fid, '---- %s %s %s ---------------------------------\r\n', 3);
if(Count == 0 || strcmp(ID, 'AnyBodyOutputFile') == 0)
    error('File is not an Anybodybody Output File (ABO)');
end;

% Read study information
[Study,Count] = fscanf(fid, 'Study: %s\r\n', 1);
ABO.Study = cellstr(Study);

% Read operation
[Operation,Count] = fscanf(fid, 'Operation: %s\r\n', 1);
ABO.Operation = cellstr(Operation);

% Read seperator
[Seperator,Count] = fread(fid, [1,58], 'char=>char');
[CRLF,Count] = fread(fid, [1,2], 'char');
if(strcmp(Seperator, '----------------------------------------------------------') == 0)
    error('Invalid seperator detected');
end;
