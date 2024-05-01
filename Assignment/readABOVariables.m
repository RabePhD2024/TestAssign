function ABO = readABOVariables(fid, ABO)

% Read variable section header
[VariableHeader,Count] = fread(fid, [1,26], 'char=>char');
[CRLF,Count] = fread(fid, [1,2], 'char');
if(strcmp(VariableHeader, 'Variables (Column# Name): ') == 0)
    error('Invalid variable section');
end;

% Read variable section
ColNames{1} = [];
while(true)
    [Column,Count] = fscanf(fid, '%s\r\n', 1);
    if(strcmp(Column, '----------------------------------------------------------') == 1)
        break;
    elseif(Count ~= 0)
        [ColNum,Count] = sscanf(Column, 'col%i ');
        if(Count == 0)
            error(sprintf('Invalid column number detected: %s', Column));
        end;
        [ColName,Count] = fscanf(fid,'%s\r\n', 1);
        if(Count == 0)
            error(sprintf('Invalid column name detected: %s', ColName));
        end;
        ColNames(ColNum+1) = cellstr(ColName);
    end;
end;
ABO.Variables = ColNames;
