function [z0, im_r, Relerrs] = WFP(Y, n1, n2, sigma2, Masks, pupil, T, mu_max, weight, newfolder, x)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% By Liheng Bian, Nov 24th, 2014. Contact me: lihengbian@gmail.com.
% This function runs the WFP algorithm.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Output: z0: n1 * n2, spectrum initialization (for result comparison);
%         im_r: n1 * n2, recovered HR pluraql image;
%         Relerrs: recovery errors in each iteration.
% Input:  Y: n1_LR * n2_LR * L, captured LR images;
%         n1 and n2 are the pixel numbers of im_r (HR) in two dimensions;
%         sigma2: variance of additive noise;
%         Masks: L * 2 (each point indicates the index of the left-upper point of the LR image in the HR spectrum);
%         pupil: the pupil function;
%         T: the number of iteration;
%         mu_max: the stepsize parameter;
%         weight: the weighting parameter;
%         newfolder: folder for saving results;
%         x: original benchmark HR spectrum for calculating recovery error.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Refference:
% Liheng Bian, Jinli Suo, Guoan Zheng, Kaikai Guo, Feng Chen and Qionghai Dai, 'Fourier ptychographic reconstruction using Wirtinger flow optimization,' Optics Express, 2015, vol. 23, no. 4, pp. 4856-4866.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% Initialization
[n1_LR,n2_LR,L] = size(Y);

z_im = sqrt( Y(:,:,fix(L/2)+1) )*n1_LR*n2_LR/n1/n2;
z_capture_example = z_im;
imwrite(uint8(255*z_capture_example),[newfolder '\z_capture_example.png'],'png');

z_im = imresize(z_im,[n1,n2]);
z0 = fftshift(fft2(z_im));
z = z0;
Relerrs = zeros(T+1,1) ;
Relerrs( 1 ) = sum(sum(abs(abs(z)-abs(x))))/sum(sum(abs(x))) ;
N = zeros(size(Y));
epsilon = N;

normest = sqrt(sum(Y(:))/L/n1_LR/n2_LR) ;
StepsizeN = 0.01;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Iterations
for t = 1 : T
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % update z
    Bz = A_LinearOperator(z,Masks,n1_LR,n2_LR,pupil);
    Cz  = (abs(Bz).^2 + N - Y )  .* Bz;
    w = A_Inverse_LinearOperator(Cz,Masks,n1,n2,pupil);
    
    alpha = - log(0.997);
    mu  = 1-exp(-alpha*t);
    mu  = min(mu,mu_max)/normest^2  ;
    z    = z-mu*w  ;
    
    % update N
    CN = (abs(Bz).^2 + N - Y ) + weight * (N.*N - 9*sigma2 + epsilon.*epsilon)*2.*N;
    stepN = mu * StepsizeN;
    N = N - stepN * CN;
    
    % update epsilon
    Etemp = 9*sigma2 - N.*N;
    Etemp(Etemp<0) = 0;
    epsilon = sqrt(Etemp);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % calculate recovery error
    Relerrs( t + 1 ) = sum(sum(abs(abs(z)-abs(x))))/sum(sum(abs(x))) ;
    % save iterative results
    if mod(t,20) == 0
        im_r = ifft2(ifftshift(z));
        imwrite(uint8(255*abs(im_r)),[newfolder '\im_r_' num2str(t) '.png'],'png');        
        im_r_ang = angle(im_r)/pi;
        im_r_ang = im_r_ang - min(min(im_r_ang));
        im_r_ang = im_r_ang/max(max(im_r_ang));
        imwrite(uint8(255*abs(im_r_ang)),[newfolder '\im_r_ang_' num2str(t) '.png'],'png');
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

end