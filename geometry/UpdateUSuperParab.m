% By Paulo Abelha (p.abelha at abdn ac uk )
% based on [PiluFisher95] Pilu, Maurizio, and Robert B. Fisher.
% �Equal-distance sampling of superellipse models.� DAI RESEARCH PAPER (1995)
% 
% Update u for a superparaboloid
function [ R ] = UpdateUSuperParab( a, epsilon, u, D_ )
    R = (D_/epsilon) * sqrt(1/((u^2*(epsilon-1))+a^2));
end