function install_sdpa_gmp(varargin)

% INSTALL_SDPA_GMP
%
% INSTALL_SDPA_GMP adds support for the multiple-precision SDPA-GMP solver to
% YALMIP. With no input arguments, it is assumed that the executable sdpa_gmp
% is installed in the standard location
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
% ----------------------------------------------------------------------- %

% ----------------------------------------------------------------------- %
% WINDOWS USERS NOT SUPPORTED
% ----------------------------------------------------------------------- %
if ispc
    error('SDPA-GMP currently can only be compiled on UNIX systems. Sorry!')
end


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
    PATH2EXE = '/usr/local/bin';
elseif nargin == 1 && ischar(varargin{1})
    PATH2EXE = fileparts(varargin{1});
    % Check it is actually the correct location
    try
        ls([PATH2EXE,filesep,'sdpa_gmp']);
    catch
        error('Cannot find the sdpa_gmp executable at the specified location!')
    end
elseif nargin == 1 && ~ischar(varargin{1})
    error('Input must be a string specifying the path to the sdpa_gmp executable.')
else
    error('Too many inputs!')
end


% ----------------------------------------------------------------------- %
% SET PATH TO EXECUTABLE
% ----------------------------------------------------------------------- %
A = regexp( fileread('callsdpagmp.m'), '\n', 'split');
A{4} = sprintf('path2sdpagmp = ''%s'';',[PATH2EXE,filesep]);
fid = fopen('callsdpagmp.m', 'w');
fprintf(fid, '%s\n', A{:});
fclose(fid);


% ----------------------------------------------------------------------- %
% ADD SDPA-GMP TO LIST OF SUPPORTED SOLVERS
% ----------------------------------------------------------------------- %
fname = which('definesolvers');

% make a backup copy of the original YALMIP file
fpath = fileparts(fname);
success = copyfile(fname,[fpath,filesep,'definesolvers_original.m']);
if ~success;
    error('Could not back up the file definesolvers.m')
end

% Add solver definition to definesolvers.m
fid = fopen(fname,'a+'); fprintf(fid,'\n\n');
fprintf(fid,'%% %% ***************************************\n');
fprintf(fid,'%% %% DEFINE SDPA-GMP AS A SOLVER - ADDED BY \n');
fprintf(fid,'%% %% install_sdpa_gmp                       \n');
fprintf(fid,'%% %% ***************************************\n');
fprintf(fid,'solver(i) = sdpsolver;                       \n');
fprintf(fid,'solver(i).tag     = ''SDPA-GMP'';            \n');
fprintf(fid,'solver(i).version = '''';                   \n');
fprintf(fid,'solver(i).checkfor= {''sdpam.m''};           \n');
fprintf(fid,'solver(i).call    = ''callsdpagmp'';         \n');
fprintf(fid,'solver(i).constraint.equalities.linear = 0;  \n');
fprintf(fid,'i = i+1;                                     \n');
fclose(fid);


% ----------------------------------------------------------------------- %
% ADD SDPA-GMP CALLER FUNCTION TO YALMIP/solvers/
% ----------------------------------------------------------------------- %
fpath = fileparts(which('callsdpa'));
success = movefile('callsdpagmp.m',[fpath,filesep,'callsdpagmp.m']);
if ~success;
    error('Could not copy callsdpagmp.m to the correct location.')
end


% ----------------------------------------------------------------------- %
% ADD UTILS TO MATLAB PATH
% ----------------------------------------------------------------------- %
addpath([pwd,filesep,'utils/']);
savepath;


% ----------------------------------------------------------------------- %
% CLEAR YALMIP CACHED SOLVERS
% ----------------------------------------------------------------------- %
clear('compileinterfacedata.m')


% ----------------------------------------------------------------------- %
% RUN MEX
% ----------------------------------------------------------------------- %
cd utils;
mex -silent sdpagmp_read_output.cpp
cd ..;
end