% Upper Bound - Van der Pol oscillator
% Computes an upper bound for the energy x^2+y^2 for a stochastic van der pol
% oscillator. For more details, see
%
% G. Fantuzzi, D. Goluskin, D. Huang, S. I. Chernyshenko, "Bounds for
% deterministic and stochastic dynamical systems using sum-of-squares
% optimization", SIAM Journal on Applied Dynamical Systems, 15(4), 1962–1988.
%
% Compare to simulation data
% Only add noise to the acceleration - physically consistent!
%
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

% --------------------
% Housekeeping
% --------------------
clear; 
yalmip('clear')

% --------------------
% Useful variables
% --------------------
solver = 'sdpa-gmp';
verb = 1;
muVals   = [4];
degPvals = [6];
epsvals  = [0];     % change 0 to a nonzero value to add 

% ----------------------
% The actual computation
% ----------------------
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
                            'sos.newton',0,...
                            'sos.congruence',0,...
                            'verbose',verb,...
                            'savesolveroutput',1,...
                            'savesolverinput',1,...
                            'cachesolvers',1);
        opts.sdpt3.maxit = 200;
        [sol,v,Q,res] = solvesos(sos(ineq),U,opts,[U;Pc]);
        fprintf('\nUpper bound: U = %f\n\n',value(U));
        Uvals(n,m)=value(U);
        
        
    end
end