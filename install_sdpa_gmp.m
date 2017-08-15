function install_sdpa_gmp(varargin)

% INSTALL_SDPA_GMP
%
% INSTALL_SDPA_GMP adds support for the multiple-precision SDPA-GMP solver to
% YALMIP. With no input arguments, it is assumed that the executable sdpa_gmp
% is installed in the location
%
% /usr/local/bin
%
% If this is not the case, you can specify the path to the executable by calling
% INSTALL_SDPA_GMP(PATH2EXE), where PATH2EXE is a string specifying the path to
% the sdpa_gmp executable.


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
% CHECK IF YALMIP IS INSTALLED
% ----------------------------------------------------------------------- %
% Copied and edited from yalmiptest.m, YALMIP
detected = which('yalmip.m','-all');
if isa(detected,'cell') && ~isempty(detected)
    if length(detected)>1
        disp('You seem to have multiple installations of YALMIP in your path:');
        disp(detected)
        disp('Please correct this, then run the installation again.');
        return
    end
else
    error(['A working version of YALMIP is required.\n '...
        'Please correct this, then run the installation again.']);
end


% ----------------------------------------------------------------------- %
% CHECK INPUTS
% ----------------------------------------------------------------------- %
if nargin == 0
    PATH2EXE = fileparts('/usr/local/bin/');%Assumes sdpa_gmp in /usr/local/bin/
elseif nargin == 1 && ischar(varargin{1})
    PATH2EXE = fileparts(varargin{1});
elseif nargin == 1 && ~ischar(varargin{1})
    error('Input must be a string specifying the path to the sdpa_gmp executable.')
else
    error('Too many inputs!')
end

% Check it is actually the correct location
if ispc
    pwdbash=strrep(pwd,'\','/');
    pwdbash=strrep(pwdbash,' ','\ ');
    pwdbash=strcat(replaceBetween(pwdbash,1,2,strcat('/mnt/',lower(extractBefore(pwdbash,2)))),'/');
    bashcommand=['[ -f ',PATH2EXE,'/sdpa_gmp ] && touch ',pwdbash,'1.txt || :'];
    cmdcommand=['bash -c "' bashcommand '" &'];
    system(cmdcommand);
    existfile=exist('1.txt','file');
    if existfile==2
        delete('1.txt');
    end
else
    existfile=exist([PATH2EXE,filesep,'sdpa_gmp'],'file');
end
if existfile~=2
    str=['Cannot find the sdpa_gmp executable at the directory ''',PATH2EXE,'/''. '];
    str=[str,'Please make sure you call install_sdpa_gmp(''/path/to/sdpa/gmp/''), where '];
    str=[str,'/path/to/sdpa/gmp/ is a UNIX-based path to either the sdpa_gmp executable '];
    str=[str,'itself or to the directory, ending with ''/'', where the sdpa_gmp executable lies.'];
    error(str);
end

% ----------------------------------------------------------------------- %
% ADD SDPA-GMP CALLER FUNCTION TO YALMIP/solvers/
% ----------------------------------------------------------------------- %
fpath = fileparts(which('definesolvers'));
success = movefile('callsdpagmp.m',[fpath,filesep,'callsdpagmp.m']);
if ~success
    str='Could not copy callsdpagmp.m to the correct location. ';
    str=[str,'Did you by any chance already run install_sdpa_gmp.m? '];
    str=[str,'Try running uninstall_sdpa_gmp.m and then install_sdpa_gmp.m again.'];
    error(str);
end


% ----------------------------------------------------------------------- %
% ADD SDPA-GMP TO LIST OF SUPPORTED SOLVERS
% ----------------------------------------------------------------------- %
% Add solver definition to definesolvers.m
fname = which('definesolvers');

% Make a backup copy of the original YALMIP file
fpath = fileparts(fname);
success = copyfile(fname,[fpath,filesep,'definesolvers_original.m']);
if ~success
    error('Could not back up the file definesolvers.m');
end

% Add the information to definesolvers.m
fid = fopen(fname,'a+'); fprintf(fid,'\n\n');
fprintf(fid,'%% %% ***************************************\n');
fprintf(fid,'%% %% DEFINE SDPA-GMP AS A SOLVER - ADDED BY \n');
fprintf(fid,'%% %% install_sdpa_gmp                       \n');
fprintf(fid,'%% %% ***************************************\n');
fprintf(fid,'solver(i) = sdpsolver;                       \n');
fprintf(fid,'solver(i).tag     = ''SDPA_GMP'';            \n');
fprintf(fid,'solver(i).version = '''';                    \n');
fprintf(fid,'solver(i).checkfor= {''sdpagmp.m''};         \n');
fprintf(fid,'solver(i).call    = ''callsdpagmp'';         \n');
fprintf(fid,'solver(i).constraint.equalities.linear = 0;  \n');
fprintf(fid,'i = i+1;                                     \n');
fclose(fid);

% Add solver definition (and options) to sdpsettings.m
fname = which('sdpsettings');
A = regexp( fileread(fname), '\n', 'split');

% Make a backup copy of the original YALMIP file
fpath = fileparts(fname);
success = movefile(fname,[fpath,filesep,'sdpsettings_original.m']);
if ~success
    error('Could not back up the file sdpsettings.m');
end

% Add the information to sdpsettings.m
for i = 1:length(A)
    substr='options.sdpa ='; 
    if ~isempty(regexp(A{i},substr,'once'))
        A(i+5:end+3) = A(i+2:end);
        A{i+2} = sprintf(' ');
        A{i+3} = sprintf('    options.sdpa_gmp = setup_sdpa_gmp_options;');
        A{i+4} = sprintf('    Names = appendOptionNames(Names,options.sdpa_gmp,''sdpa_gmp'');');
        continue
    end
    substr='sdpa.isSymmetric ='; 
    if ~isempty(regexp(A{i},substr,'once'))
        A(i+15:end+14) = A(i+1:end);
        A{i+1} = sprintf(' ');
        A{i+2} = sprintf('function sdpa_gmp = setup_sdpa_gmp_options');
        A{i+3} = sprintf('sdpa_gmp.maxIteration = 200 ;');
        A{i+4} = sprintf('sdpa_gmp.epsilonStar = 1.0E-25;');
        A{i+5} = sprintf('sdpa_gmp.lambdaStar  = 1.0E6  ;');
        A{i+6} = sprintf('sdpa_gmp.omegaStar  = 2.0 ;');
        A{i+7} = sprintf('sdpa_gmp.lowerBound  = -1.0E25  ;');
        A{i+8} = sprintf('sdpa_gmp.upperBound  = 1.0E25  ;');
        A{i+9} = sprintf('sdpa_gmp.betaStar  = 0.1  ;');
        A{i+10} = sprintf('sdpa_gmp.betaBar  = 0.2 ;');
        A{i+11} = sprintf('sdpa_gmp.gammaStar  = 0.7 ;');
        A{i+12} = sprintf('sdpa_gmp.epsilonDash  = 1.0E-25 ;');
        A{i+13} = sprintf('sdpa_gmp.precision = 200 ;');
        A{i+14} = sprintf('sdpa_gmp.path2sdpagmp = ''%s'' ;',[PATH2EXE,'/']);
        break
    end
end

fid = fopen(fname, 'w');
fprintf(fid, '%s\n', A{:});
fclose(fid);

% ----------------------------------------------------------------------- %
% ADD UTILS TO MATLAB PATH
% ----------------------------------------------------------------------- %
addpath([pwd,filesep,'utils',filesep]);
savepath;


% ----------------------------------------------------------------------- %
% CLEAR YALMIP CACHED SOLVERS
% ----------------------------------------------------------------------- %
clear('compileinterfacedata.m')


% ----------------------------------------------------------------------- %
% RUN MEX
% ----------------------------------------------------------------------- %
cd utils;
mex -silent -largeArrayDims sdpagmp_read_output.cpp
cd ..;

end