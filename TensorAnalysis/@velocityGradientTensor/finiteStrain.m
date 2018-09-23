function [fe, qe, F] = finiteStrain(L,n)
% derive finte strain axes and magnitudes
% after n-steps (in strain rate units of L)
% using the solution of Provost et al.2014 doi:10.1029/2001JB001734
%
% Input
%  L        -  velocityGradientTensor
%  n        -  time step in units of strainrate*2 of L
%
% Output
%  fe       - finite strain ellipsoid axis directions (vector3d)
%  qe       - length of ellipse axes
%

D = expm(L.matrix * n); % deforamtion "matrix"
F = D*D'; % Finger tensor
[U,S,~] = svd(F); 
fe = vector3d(U);
qe = sqrt(diag(S));

end

