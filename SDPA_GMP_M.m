function [objVal,x,X,Y,INFO] = SDPA_GMP_M(A,b,c,K,accuracy)

% Call SPA-GMP from MATLAB
% TAKES SEDUMI INPUT
% Uncomment solving commands below as desired
% NOTE: NEED TO EDIT THE PATH TO sdpa_gmp ACCORDING TO YOUR SYSTEM


%% Initial checks
tstart = tic;
path2sdpagmp = '/usr/local/bin/';

% otherwise it will fail upon system command, causing matlab to crash
try 
    fprintf('SDPA-GMP executable at ')
    ls /usr/local/bin/sdpa_gmp;
catch
    fprintf('Cannot find sdpa_gmp! Change the path in SDPA_GMP_M.m\n')
    return
end

% otherwise it will fail upon system command, causing matlab to crash
try
    fprintf('SDPA-GMP parameter file: ')
    ls param.sdpa;
catch
    fprintf('Cannot find sdpa_gmp! Change the path in SDPA_GMP_M.m\n')
    return
end


%% write input file & read parameters to impoirt solution later on
inputSDPA = 'SDPA_SedumiData_Input.dat-s';
outputSDPA = 'SDPA_SedumiData_Output.out';
SedumiToSDPA(inputSDPA,A,b,c,K,accuracy);
[mDIM,nBLOCK,bLOCKsTRUCT] = read_data(inputSDPA);            % read problem in SDPA format

% Solve & dump output to sdpaOutput.log
system(['echo ',repmat('+',1,100),' >> sdpaOutput.log']);
system(['/usr/local/bin/sdpa_gmp ',inputSDPA,' ',outputSDPA,' >> sdpaOutput.log']);          % solve SDP

% %% Solve & display output to matlab screen
% system(['echo ',repmat('+',1,100)]);
% system([path2sdpagmp,'sdpa_gmp ',inputSDPA,' ',outputSDPA]);          % solve SDP


%% Import solution
[objVal,x,X,Y,INFO] = read_output(outputSDPA,mDIM,nBLOCK,bLOCKsTRUCT); % import results
INFO.runtime = toc(tstart);

%%
end