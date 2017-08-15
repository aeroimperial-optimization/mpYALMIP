function [objVal,x,X,Y,INFO]=sdpagmp(mDIM,nBLOCK,bLOCKsTRUCT,c,F,...
                                     x0,X0,Y0,OPTION)
%
% Compute the solution of standard SDP.
% At the moment x0, X0 and Y0 are ignored as inputs. They are technically
% optional as inputs (as well as options).
%               
% [objVal,x,X,Y,INFO] = sdpagmp(mDIM,nBLOCK,bLOCKsTRUCT,c,F,
%                               x0,X0,Y0,OPTION);
%
% <INPUT>
% - mDIM       : integer   ; number of primal variables
% - nBLOCK     : integer   ; number of blocks of F
% - bLOCKsTRUCT: vector    ; represetns the block structure of F
% - c          : vector    ; coefficient vector
% - F          : cell array; coefficient matrices
% - x0,X0,Y0   : cell array; initial point
% - OPTION     : structure ; options
% 
% <OUTPUT>
% - objVal: [objValP objValD]; optimal value of P and D
% - x     : vector           ; optimal solution
% - X,Y   : cell arrray      ; optimal solutions
% - INFO  : structure        ; infomation of the solution
% 

% SDPAGMP.m Call SDPA-GMP from YALMIP
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
t = cputime; 

if (nargin < 5 || nargin > 9)
  error('incorrect number of input arguments')
elseif nargin == 5
  % make initial points empty
  x0=[]; X0=[]; Y0=[];
  % load default parameters
  OPTION=sdpsettings;
elseif nargin == 6
  % use OPTION given by arguments
  OPTION = x0;
  % make initial points empty
  x0=[];X0=[];Y0=[];
elseif nargin == 8
  % make initial points empty
  x0=[];X0=[];Y0=[];
  % load default parameters
  OPTION=sdpsettings;
elseif nargin == 9
  % make initial points empty
  x0=[];X0=[];Y0=[];
end
ops=OPTION;

% If it exists, file param.sdpa will override anything written in options
% (for back compatibility), but otherwise a param.sdpa file will be created
% from the information in options and then deleted in the end.
cleanup = 0;
if ~exist([pwd,filesep,'param.sdpa'],'file')
    cleanup = 1;
    % write it with default parameters, otherwise failure!
    fID = fopen([pwd,filesep,'param.sdpa'],'w');
    fprintf(fID,'%s     unsigned int    maxIteration;           \n',int2str(ops.maxIteration));
    fprintf(fID,'%s     double          0.0 < epsilonStar;      \n',num2str(ops.epsilonStar));
    fprintf(fID,'%s     double          0.0 < lambdaStar;       \n',num2str(ops.lambdaStar));
    fprintf(fID,'%s     double          1.0 < omegaStar;        \n',num2str(ops.omegaStar));
    fprintf(fID,'%s     double          lowerBound;             \n',num2str(ops.lowerBound));
    fprintf(fID,'%s     double          upperBound;             \n',num2str(ops.upperBound));
    fprintf(fID,'%s     double          0.0 <= betaStar <  1.0; \n',num2str(ops.betaStar));
    fprintf(fID,'%s     double          0.0 <= betaBar  <  1.0, betaStar <= betaBar;\n',num2str(ops.betaBar));
    fprintf(fID,'%s     double          0.0 < gammaStar <  1.0; \n',num2str(ops.gammaStar));
    fprintf(fID,'%s     double          0.0 < epsilonDash;      \n',num2str(ops.epsilonDash));
    fprintf(fID,'%s     precision                               \n',int2str(ops.precision));
    fclose(fID);
end

% Export to SDPA-GMP, solve in shell and import results
%Name of input and output files.
inputSDPA  = 'sdpagmp_in.dat-s';
outputSDPA = 'sdpagmp_out.out';
path2sdpagmp = ops.path2sdpagmp;

% Write SDPA-GMP input file
gensdpagmpfile(inputSDPA,mDIM,nBLOCK,bLOCKsTRUCT,c,F);

% Run command in system
if ispc %For PCs via Bash on Ubuntu on Windows (called through cmd)
    pwdbash = strrep(pwd,'\','/');
    pwdbash = strrep(pwdbash,' ','\ ');
    pwdbash = strcat(replaceBetween(pwdbash,1,2,strcat('/mnt/',lower(extractBefore(pwdbash,2)))),'/');
    inputPC = [pwdbash,inputSDPA];
    outputPC = [pwdbash,outputSDPA];
    paramsPC = [pwdbash,'param.sdpa'];
    bashcommand = [path2sdpagmp,'sdpa_gmp -ds ',inputPC,' -o ',outputPC,' -p ',paramsPC];
    if strcmp(ops.print,'no')
        bashcommand = [bashcommand,' >> ',pwdbash,'sdpagmp.log'];
    end
    cmdcommand=['bash -c "',bashcommand,'" &'];
    %Solve SDP
    system(cmdcommand);
else %For UNIX and Macs
    shellcommand=[path2sdpagmp,'sdpa_gmp -ds ',inputSDPA,' -o ',outputSDPA,' -p param.sdpa'];
    if strcmp(ops.print,'no')
        system(['echo ',repmat('+',1,100),' >> sdpagmp.log']);
        %Solve SDP
        shellcommand=[shellcommand,' >> sdpagmp.log'];
        system(shellcommand);
    else
        system(['echo ',repmat('+',1,100)]);
        %Solve SDP
        system(shellcommand);
    end
end

%To prevent weird bug before importing, it is better to pause the
%computation for 1 second. Otherwise the import could be random. This bug
%has been detected at least in Windows machines.
pause(1);

% Import result
[objVal,x,X,Y,INFO] = sdpagmp_read_output(outputSDPA,mDIM,nBLOCK,full(bLOCKsTRUCT));

% Clean up tmp files created in this directory
delete(inputSDPA);
delete(outputSDPA);
if cleanup
    delete('param.sdpa');
end

INFO.cpusec = cputime-t;


























