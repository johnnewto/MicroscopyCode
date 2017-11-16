function [xx_c] = fun_A_Real(xx, Masks, n1_LR, n2_LR, fmaskpro)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% By Liheng Bian, Dec 20th, 2015.
% This function operates the linear transform 'A' on the signal (xx_c = A*xx, Y = |xx_c|^2)

% Inputs:
% xx: n1 * n2, original signal (HR spatial spectrum)
% Masks: L * 2 (each row indicates the location of the left-upper pixel of the LR image in Fourier space)
% n1_LR, n2_LR: pixels in each dimension of the low resolution images
% fmaskpro: pupil function

% Outputs:
% xx_c: n1_LR * n2_LR * L, sampling output (without abs)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
L = size(Masks,1);
[n1, n2] = size(xx);

xx_c = zeros(n1_LR,n2_LR,L);

for k = 1:L
    index_x = Masks(k,1);
    index_y = Masks(k,2);
    xx_c(:,:,k) = xx(index_x:index_x+n1_LR-1 ,index_y:index_y+n2_LR-1); % low frequency in center
    xx_c(:,:,k) = xx_c(:,:,k) .* fmaskpro;
    xx_c(:,:,k) = xx_c(:,:,k) * n1_LR*n2_LR/n1/n2; % solve scaling problem by Mfactor
end

xx_c = ifftshift(xx_c,1);
xx_c = ifftshift(xx_c,2); % high frequency in center
xx_c = ifft2( xx_c );

end