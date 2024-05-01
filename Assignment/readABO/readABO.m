%
% AUTHOR :
%  Jean-Olivier Racine (joracine@gmail.com)
%  Laboratoire d'imagerie et d'orthopedie (LIO)
%  École de technologie supérieure (ÉTS)
%  http://lio.etsmtl.ca
%
% DESCRIPTION :
%  Reads AnyBody Output Files (ABO) and stores the data into a ABO
%  structure that contans different sections.
%
% SYNOPSIS :
%  [ABO] = readABO(Filename)
%
% INPUT :
%  Filename is the full path to the ABO file that must be read.
%
% OUTPUT :
%  The ABO structure contains:
%   - Filename is the ABO filename and path.
%   - Study contains the path (Anybody) to the study which generated the
%     file.
%   - Operation contains the path (Anybody) to the operation which
%     generated the file.
%   - Constants contains all constant values in the search path specified.
%     The structure of the Constants struct reflex the Anybody structure
%     (Main.Model.[...])
%   - Variables is a list (cell) of all the variables (fields) that are
%     time dependant in the order in which they are listed in the values
%     section.
%   - Values contains all time dependant variables with each cell being a
%     column.
%
% MATLAB VERSION
%  matlab R14 7.01.24704 (SP1)

% ------------------------------------------------------------------
% CHANGELOG :
%  1.00  2007-07-16  joracine  Original version.
%  1.01  2007-07-17  joracine  Corrected small issue with 'Off' values.
%  1.02  2007-07-17  joracine  Fixed issues with values that arent numeric
%                              nor strings (internal enums) being
%                              translated as empty matrices.
%  1.03  2007-07-30  joracine  Corrected a bug with arrays starting with a
%                              negative value. And general maintenance of
%                              part of the code.
%
% TODO :
%  - Make multi-column cells in the values section, representing data
%    organization.
%  - Add C3D format option.
%
% ------------------------------------------------------------------
function ABO = readABO(Filename)

% OPEN FILE
[fid, errmsg] = fopen(Filename, 'r', 'l');
if(~isempty(errmsg))
    error(errmsg);
end;

% READ Anybody Output (ABO) FILE
ABO.Filename = cellstr(Filename);
ABO = readABOHeader(fid, ABO);
ABO = readABOConstants(fid, ABO);
ABO = readABOVariables(fid, ABO);
ABO = readABOValues(fid, ABO);

% CLOSE FILE
try
    fclose(fid);
catch
    error(ferror(fid));
end;
