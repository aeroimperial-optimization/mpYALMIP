function uninstall_sdpa_gmp(varargin)

% UNINSTALL_SDPA_GMP
%
% UNINSTALL_SDPA_GMP removes support for the multiple-precision SDPA-GMP solver 
% from YALMIP, resetting it to its original state.


% ----------------------------------------------------------------------- %
%        Author:    Giovanni Fantuzzi
%                   Department of Aeronautics
%                   Imperial College London
%       Created:    23/08/2016
%
%     Copyright (C) 2016  Giovanni Fantuzzi
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
% ----------------------------------------------------------------------- %

% ----------------------------------------------------------------------- %
% WINDOWS USERS NOT SUPPORTED
% ----------------------------------------------------------------------- %
if ispc
    error('SDPA-GMP currently can only be compiled on UNIX systems. Sorry!')
end


% ----------------------------------------------------------------------- %
% REMOVE UTILS FROM MATLAB PATH
% ----------------------------------------------------------------------- %
rmpath([pwd,filesep,'utils',filesep]);
savepath;

% ----------------------------------------------------------------------- %
% REMOVE SDPA-GMP CALLER FUNCTION FROM YALMIP/solvers/
% ----------------------------------------------------------------------- %
fpath = fileparts(which('callsdpagmp'));
success = movefile([fpath,filesep,'callsdpagmp.m'],[pwd,filesep,'callsdpagmp.m']);
if ~success;
    error('Could not remove callsdpagmp.m from YALMIP.')
end

% ----------------------------------------------------------------------- %
% REMOVE SDPA-GMP FROM LIST OF SUPPORTED SOLVERS
% ----------------------------------------------------------------------- %
fname = which('definesolvers');
delete(fname);

% reinstall backup copy of the original YALMIP file
fpath = fileparts(fname);
success = movefile([fpath,filesep,'definesolvers_original.m'],fname);
if ~success;
    error('Could not restore the original copy of definesolvers.m')
end


% ----------------------------------------------------------------------- %
% RESET PATH TO EXECUTABLE
% ----------------------------------------------------------------------- %
A = regexp( fileread('callsdpagmp.m'), '\n', 'split');
for i = 1:length(A)
    if ~isempty(regexp(A{i},'path2sdpagmp =', 'once'))
        A{i} = 'path2sdpagmp = ''<set-by-installer>'';';
        break
    end
end
fid = fopen('callsdpagmp.m', 'w');
fprintf(fid, '%s\n', A{:});
fclose(fid);

% ----------------------------------------------------------------------- %
% CLEAR YALMIP CACHED SOLVERS
% ----------------------------------------------------------------------- %
clear('compileinterfacedata.m')

end