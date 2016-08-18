% Upper Bound - Van der Pol
% Compare to simulation data
% Only add noise to the acceleration - physically consistent!

clear; yalmip('clear')
solver = 'sedumi';
verb = 1;

muVals = [1:0.5:5];
degVvals = [12];
epsvals = 0*muVals;


for m = 1:length(degVvals)
    for n = 1:length(muVals)
    
    e = epsvals(n);
    mu = muVals(n);
    degV = degVvals(m);
    fprintf('%s\n%s\n',repmat('#',1,85),repmat('*',1,85));
    fprintf('CASE: epsilon = %f, degP =  %i\n',e,degV);
    fprintf('%s\n%s\n',repmat('*',1,85),repmat('#',1,85));
    
    % Set up problem
    yalmip('clear')
    sdpvar x y U
    [P,Pc] = polynomial([x,y],degV,1);
    f = [y; mu*(1-x^2)*y-x];        % VdP dynamics
    phi = x^2+y^2;                  % quantity to bound
    V.P = P;                        % polynomial part of V
    V.Z = 1;                        % no log part needed!
   
    
    % Set up SOS problem
    ineq = ub_ineq([x,y],f,phi,U,V,e);
    F = [sos(ineq)]; 
    obj = U;                               % Minimise U
    pars = [U;Pc];
    opts = sdpsettings('solver',solver,...
                       'sos.newton',1,...
                       'sos.congruence',1,...
                       'verbose',verb,...
                       'savesolveroutput',1,...
                       'cachesolvers',1);
    opts.sdpt3.maxit = 200;
    [sol,v,Q,res] = solvesos_SDPAgmp(F,obj,opts,pars);
    fprintf('\nUpper bound: U = %f\n\n',value(U));
    Uvals(n,m)=value(U);

    
    end    
end

hold on; plot(muVals,Uvals)
