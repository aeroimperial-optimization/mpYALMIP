% Example: solving an SDP calling SDPA_GMP
% Problem: prove stability of linear dynamical system (sdptutorial.m in YALMIP)
%
% First part: use YALMIP throughout
% Second part: solve problem using data in Sedumi format

clear; yalmip('clear');

% PROBLEM

A = [-1 2 0;-3 -4 1;0 0 -2];
P = sdpvar(3,3);
F = [P >= 0, A'*P+P*A <= 0, trace(P)==1];
obj = P(1,1);
opts = sdpsettings('verbose',1,'solver','sedumi','cachesolvers',1);

% YALMIP SOLUTION...
fprintf('%s\n',repmat('+',1,50))
fprintf('YALMIP solution (optimize):\n')
sol = optimize(F,obj,opts);
Pfeas = value(P)
optVal = value(obj)

% SDPA-GMP SOLUTION VIA YALMIP
% YALMIP will ignore the solver specified in opts!
% Easy to recover original variables...
fprintf('%s\n',repmat('+',1,50))
opts = sdpsettings(opts,'solver','sdpa-gmp');
fprintf('SDPA-GMP solution with YALMIP:\n');
sol = optimize(F,obj,opts);
Pfeas = value(P)
optVal = value(obj)