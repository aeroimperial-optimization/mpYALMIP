% Upper Bound - Van der Pol
% Compare to simulation data
% Only add noise to the acceleration - physically consistent!

clear; yalmip('clear')
solver = 'sdpa-gmp';
verb = 1;

muVals = [1];
degPvals = [12];
epsvals = 0*muVals;


for m = 1:length(degPvals)
    for n = 1:length(muVals)
        
        e = epsvals(n);
        mu = muVals(n);
        degP = degPvals(m);
        fprintf('%s\n%s\n',repmat('#',1,85),repmat('*',1,85));
        fprintf('CASE: epsilon = %f, degP =  %i\n',e,degP);
        fprintf('%s\n%s\n',repmat('*',1,85),repmat('#',1,85));
        
        % Set up problem
        yalmip('clear')
        sdpvar x y U
        [P,Pc] = polynomial([x,y],degP,1);
        f = [y; mu*(1-x^2)*y-x];        % VdP dynamics
        phi = x^2+y^2;                  % quantity to bound

        % gradient & Laplacian
        % multiply by 0 to add noise only to y variable
        gP = jacobian(P,[x,y])';
        g2P = 0*jacobian(gP(1),x) + jacobian(gP(2),y);
        
        % inequality
        ineq = U - e*g2P - f'*gP - phi;

        % Setup SOS problem to minimize U
        opts = sdpsettings('solver',solver,...
                            'sos.newton',1,...
                            'sos.congruence',1,...
                            'verbose',verb,...
                            'savesolveroutput',1,...
                            'cachesolvers',1);
        opts.sdpt3.maxit = 200;
        [sol,v,Q,res] = solvesos(sos(ineq),U,opts,[U;Pc]);
        fprintf('\nUpper bound: U = %f\n\n',value(U));
        Uvals(n,m)=value(U);
        
        
    end
end

hold on; plot(muVals,Uvals)