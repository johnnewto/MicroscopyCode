function [xx_c] = A_LinearOperator(xx,Masks,n1_LR,n2_LR,pupil)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% By Liheng Bian, Nov 8th, 2014. Contact me: lihengbian@gmail.com.
% This function operates the linear transform on the signal xx (namely "A").
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Output: xx_c: n1_LR * n2_LR * L, sampling output (without abs).
% Input:  xx: n1 * n2, original signal (HR spectrum);
%         Masks: L * 2 (each point indicates the index of the left-upper point of the LR image in the HR spectrum);
%         n1_LR and n2_LR are the pixel numbers of xx_c (LR) in two dimensions;
%         pupil: the pupil function.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Refference:
% Liheng Bian, Jinli Suo, Guoan Zheng, Kaikai Guo, Feng Chen and Qionghai Dai, 'Fourier ptychographic reconstruction using Wirtinger flow optimization,' Optics Express, 2015, vol. 23, no. 4, pp. 4856-4866.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

L = size(Masks,1);

xx_c = zeros(n1_LR,n2_LR,L);

for k = 1:L
    index_x = Masks(k,1);
    index_y = Masks(k,2);
    xx_c(:,:,k) = xx(index_x:index_x+n1_LR-1 ,index_y:index_y+n2_LR-1).*pupil;
end

xx_c = ifftshift(xx_c,1);
xx_c = ifftshift(xx_c,2);
xx_c = ifft2( xx_c );

end