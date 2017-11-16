function grad = fun_compute_grad_TPWFP_Real(z, y, Params, A, At, Masks, n1_LR, n2_LR, fmaskpro)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% By Liheng Bian, Jan. 5th, 2016
% Adapted from the code samples from http://web.stanford.edu/~yxchen/TWF/code.html

% Inputs:
% z: spatial spectrum of the sample
% y: captured low resolution images
% Params: algorithm parameters
% Masks: L * 2 (each row indicates the location of the left-upper pixel of the LR image in Fourier space)
% n1_LR, n2_LR: pixels in each dimension of the low resolution images
% ini_flag: initialization flag (-1: upsample version of the Low resolution image; 0: all zeros)
% fmaskpro: pupil function

% Outputs:
% grad: gradient of TPWFP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n1 = Params.n1;
n2 = Params.n2;

m = Params.m;
yz = A(z,Masks,n1_LR,n2_LR, fmaskpro);
Kt = 1/m* norm(abs(yz(:)).^2 - y(:), 1); 


% truncation rules
normz = norm(z);
normz = normz/n1/n2;

Eh  =  abs(y - abs(yz).^2) <= Params.alpha_h * Kt /normz * abs(yz);

grad  = 1/m* At( 2* ( abs(yz).^2-y ) ./ (abs(yz).^2) .*yz ...
                  .* Eh, Masks, n1, n2, fmaskpro );    % truncated Poisson gradient
      
