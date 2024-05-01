function ABO = readABOConstants(fid, ABO)

% Read constant section header
[ConstantHeader,Count] = fread(fid, [1,26], 'char=>char');
[CRLF,Count] = fread(fid, [1,2], 'char');
if(strcmp(ConstantHeader, 'Constants (Name = Value): ') == 0)
    error('Invalid constant section');
end;

% Read constant section
while(true)
    [VarName,Count] = fscanf(fid, '%s = ', 1);
    if(strcmp(VarName, '----------------------------------------------------------') == 1)
        break;
    elseif(Count ~= 0)
        [VarValue,Count] = fscanf(fid, '%[^\r\n]\r\n', 1);
        if(Count ~= 0)
            eval(sprintf('ABO.Constants.%s = AnalyzeConstantValue(VarValue);', VarName));
        else
            error('Invalid variable value (constant does not have a value!)');
        end;
    end;
end;

% ---------------------------------------------
% ---------------------------------------------
% ---------------------------------------------
% Finds tokens and create array/cell values
function NewValue = AnalyzeConstantValue(VarValue)

if(VarValue(1) == '"')
    NewValue = cellstr(VarValue(2:end-1));
elseif(VarValue(1) == '{')
    % Init
    ValNum = 0;
    % Remove outermost curly brackets
    ValList = VarValue(2:end-1);
    % Cycle through values
    while(true)
        % Seperate values (',' or '},')
        Sep = find(ValList==',');
        if(ValList(1) == '{')
            Curly = find(ValList=='}');
            Sep = Sep - 1;
            Sep = intersect(Sep, Curly) + 1;
        end;
        if(isempty(Sep))
            Val = ValList;
        else
            Val = ValList(1:min(Sep)-1);
        end;

        % Get, analyse and store value (or value block)
        ValNum = ValNum + 1;
        ValList = ValList(length(Val)+3:end);
        NewValue(:,ValNum) = AnalyzeConstantValue(Val);

        % Check if we are done
        if(isempty(ValList))
            break;
        end;
    end;
elseif((int8(VarValue(1)) < 48 || int8(VarValue(1)) > 57) && VarValue(1) ~= '-') % make sure it's not a number
    if(strcmp(upper(VarValue), 'ON') == 1)
        NewValue = true;
    elseif(strcmp(upper(VarValue), 'OFF') == 1)
        NewValue = false;
    else
        NewValue = cellstr(VarValue);
    end;
else
    NewValue = str2num(VarValue);
end;

