% Example: solving an SDP calling SDPA_GMP
% Problem: prove stability of linear dynamical system (sdptutorial.m in YALMIP)
%
% First part: use YALMIP throughout
% Second part: solve problem using data in Sedumi format

clear; yalmip('clear');

%% PROBLEM

A = [-1 2 0;-3 -4 1;0 0 -2];
P = sdpvar(3,3);
F = [P >= 0, A'*P+P*A <= 0, trace(P)==1];
obj = P(1,1);
opts = sdpsettings('verbose',0,'solver','sedumi','cachesolvers',1);

%% YALMIP SOLUTION...
fprintf('%s\n',repmat('+',1,50))
fprintf('YALMIP solution (optimize):\n')
sol = optimize(F,obj,opts);
Pfeas = value(P)
optVal = value(obj)

%% SDPA-GMP SOLUTION VIA YALMIP
% YALMIP will ignore the solver specified in opts!
% Easy to recover original variables...
fprintf('%s\n',repmat('+',1,50))
fprintf('SDPA-GMP solution with YALMIP (solvesdp_SDPAgmp):\n')
sol = solvesdp_SDPAgmp(F,obj,opts);
Pfeas = value(P)
optVal = value(obj)

%% SDPA-GMP SOLUTION VIA SEDUMI INPUT
fprintf('%s\n',repmat('+',1,50))
fprintf('SDPA-GMP solution with YALMIP (solvesdp_SDPAgmp):\n')
[mod,recmod] = export(F,obj,opts);      % export to Sedumi data...
mod.K.q = []; mod.K.r = [];             % otherwise SedumiToSDPA will complain...only ok if these fields are 0 though!
[objVal,x,X,Y,INFO] = SDPA_GMP_M(mod.A,mod.b,mod.C,mod.K,'%16.16g');      % solve problem
assign(recover(recmod.used_variables),x);
Pfeas = value(P)
optVal = value(obj)