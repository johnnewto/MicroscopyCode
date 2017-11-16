function [xx_sum_large] = fun_At_Real(xx_c, Masks, n1, n2, fmaskpro)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% By Liheng Bian, Dec 20th, 2015.
% This function operates the inverse linear transform 'A' on the input signal (LR captured images)

% Inputs:
% xx_c: n1_LR * n2_LR * L, low resolution images (without abs)
% Masks: L * 2 (each row indicates the location of the left-upper pixel of the LR image in Fourier space)
% n1, n2: pixels in each dimension of the high resolution image
% fmaskpro: pupil function

% Outputs:
% xx_mean_large: n1 * n2, original signal (high resolution spatial spectrum)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[n1_LR, n2_LR, L] = size(xx_c);

xx_c = fft2(xx_c);
xx_c = fftshift(xx_c,1);
xx_c = fftshift(xx_c,2); % low frequency in center
xx_c = xx_c .* repmat(conj(fmaskpro),[1,1,L]);
xx_c = xx_c/n1_LR/n2_LR*(n1*n2); % solve scaling problem by Mfactor

xx_c = xx_c*n1*n2; % according to original TWF


xx = zeros( max(Masks(:,1))-min(Masks(:,1))+n1_LR, max(Masks(:,2))-min(Masks(:,2))+n2_LR, L ); % save space

for k = 1:L
    index_x = Masks(k,1);
    index_y = Masks(k,2);
    xx( index_x-min(Masks(:,1))+1 : index_x-min(Masks(:,1))+n1_LR , index_y-min(Masks(:,2))+1 : index_y-min(Masks(:,2))+n2_LR , k ) = xx_c(:,:,k);
end

xx_sum = sum(xx,3); % transpose of repmat is sum

xx_sum_large = zeros(n1,n2);
xx_sum_large( min(Masks(:,1)):min(Masks(:,1))+size(xx_sum,1)-1 , min(Masks(:,2)):min(Masks(:,2))+size(xx_sum,2)-1 ) = xx_sum;

end