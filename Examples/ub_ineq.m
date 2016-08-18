function ineq = ub_ineq(vars,f,phi,U,V,e)

% Set inequality for upper bound

% extract variables
x = vars(1); y = vars(2);

% gradients
gP = jacobian(V.P,[x,y])';
gZ = jacobian(V.Z,[x,y])';

% Laplacians
% multiply by 0 to add noise only to y variable...
g2P = 0*jacobian(gP(1),x) + jacobian(gP(2),y);
g2Z = 0*jacobian(gZ(1),x) + jacobian(gZ(2),y);

% inequality
if class(V.Z)=='sdpvar'
    ineq = e*(e+V.Z)^2*g2P + e*(e+V.Z)*V.a*g2Z - e*V.a*(gZ'*gZ);
    ineq = ineq + (e+V.Z)^2*(f'*gP + phi - U) + V.a*(e+V.Z)*(f'*gZ);
elseif class(V.Z)=='double'
    ineq = e*g2P + f'*gP + phi - U;
else
    error('Don''t know what to do!')
end

ineq = -ineq;
end