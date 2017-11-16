function [xx_mean_large] = A_Inverse_LinearOperator(xx_c,Masks,n1,n2,pupil)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% By Liheng Bian, Nov 8th, 2014. Contact me: lihengbian@gmail.com.
% This function operates the inverse linear transform on the signal xx_c.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Output: xx_mean_large: n1 * n2, original signal (HR spectrum).
% Input:  xx_c: n1_LR * n2_LR * L, sampling output (without abs)
%         Masks: L * 2 (each point indicates the index of the left-upper point of the LR image in the HR spectrum)
%         n1 and n2 are the pixel numbers of xx_mean_large (HR) in two dimensions
%         pupil: the pupil function.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Refference:
% Liheng Bian, Jinli Suo, Guoan Zheng, Kaikai Guo, Feng Chen and Qionghai Dai, 'Fourier ptychographic reconstruction using Wirtinger flow optimization,' Optics Express, 2015, vol. 23, no. 4, pp. 4856-4866.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[n1_LR, n2_LR, L] = size(xx_c);

xx_c = fft2(xx_c);
xx_c = fftshift(xx_c,1);
xx_c = fftshift(xx_c,2);

xx = zeros( max(Masks(:,1))-min(Masks(:,1))+n1_LR, max(Masks(:,2))-min(Masks(:,2))+n2_LR, L ); % save space

for k = 1:L
    index_x = Masks(k,1);
    index_y = Masks(k,2);
    xx( index_x-min(Masks(:,1))+1 : index_x-min(Masks(:,1))+n1_LR , index_y-min(Masks(:,2))+1 : index_y-min(Masks(:,2))+n2_LR , k ) = xx_c(:,:,k).*conj(pupil);
end

xx_mean = mean(xx,3);

xx_mean_large = zeros(n1,n2);
xx_mean_large( min(Masks(:,1)):min(Masks(:,1))+size(xx_mean,1)-1 , min(Masks(:,2)):min(Masks(:,2))+size(xx_mean,2)-1 ) = xx_mean;

end