function [z_ini, z, im_r, Relerrs] = fun_TPWFP_Real(y, Params, A, At, Masks, n1_LR, n2_LR, ini_flag, newfolder, save_sep, fmaskpro, z_groundtruth, displayflag)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% By Liheng Bian, Jan. 5th, 2016
% Adapted from the code samples from http://web.stanford.edu/~yxchen/TWF/code.html

% Inputs:
% y: captured low resolution images
% Params: algorithm parameters
% Masks: L * 2 (each row indicates the location of the left-upper pixel of the LR image in Fourier space)
% n1_LR, n2_LR: pixels in each dimension of the low resolution images
% ini_flag: initialization flag (-1: upsample version of the Low resolution image; 0: all zeros)
% newfolder: folder to save results
% save_sep % iterations to save results
% fmaskpro: pupil function
% z_groundtruth: groundtruth of the high resolution spatial spectrum
% displayflag: if display reconstruction results

% Outputs:
% z_ini: initialization of the spatial spectrum
% z: reconstructed spatial spectrum
% im_r: reconstructed sample
% Relerrs: relative error in each iteration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialization
newfolder = [newfolder '/TPWFP_ah_' num2str(Params.alpha_h) '_ini_' num2str(ini_flag)];
mkdir(newfolder);
save([newfolder '/Params.mat'],'Params');

n1 = Params.n1;
n2 = Params.n2;
L = Params.L;

if ini_flag == -1
    % find the image with largest intensity as the LR image captured under veitical light
    temp = sum(sum(y,1),2);
    lr_loc = temp == max(temp);
    z_im = sqrt( y(:,:,lr_loc) ); % take the LR image captured under veitical light as initialization
    z_im = imresize(z_im,[n1,n2]);
    z = fftshift(fft2(z_im));
elseif ini_flag == 0
    z = zeros(n1,n2);
end

z_ini = z;
im_r_ini = ifft2(ifftshift(z));

imwrite(uint8(255*(abs(im_r_ini))),[newfolder '/amp_000.jpg'],'jpg');
imwrite(uint8(255*(im_r_ini/max(max(im_r_ini)))),[newfolder '/amp_norm_000.jpg'],'jpg');

if exist('z_groundtruth','var')
    Relerrs = zeros([1+Params.T,1]);
    Relerrs(1) = norm(z_groundtruth - exp(-1i*angle(trace(z_groundtruth'*z))) * z, 'fro')/norm(z_groundtruth,'fro'); % Initial rel. error
else
    Relerrs = 0;
end

%% optimization
muf = @(t) min(1-exp(-t/Params.tau0), Params.muTWF); % Schedule for step size

if exist('z_groundtruth','var')
    if ~exist('displayflag','var') || (exist('displayflag','var') && displayflag==1)
        gcf = figure; hold on;
        title(['Relerrs TPWFP ah ' num2str(Params.alpha_h)]);
    end
end

for t = 1: Params.T,
    grad = fun_compute_grad_TPWFP_Real(z, y, Params, A, At, Masks, n1_LR, n2_LR, fmaskpro);
    z = z - muf(t) * grad;             % Gradient update

    % save results
    if mod(t,save_sep) == 0
        im_r = abs(ifft2(ifftshift(z)));
        filename = sprintf('/amp_%03d.jpg',t);
        imwrite(uint8(255*(abs(im_r))),[newfolder filename],'jpg');
        filename = sprintf('/amp_norm_%03d.jpg',t);
        imwrite(uint8(255*(abs(im_r)/max(max(abs(im_r))))),[newfolder filename],'jpg');
        im_r = ifft2(ifftshift(z));
        im_r_ang = angle(im_r)/pi;
        im_r_ang = im_r_ang - min(min(im_r_ang));
        filename = sprintf('/phase_%03d.jpg',t);
        imwrite(uint8(255*(abs(im_r_ang)/max(max(abs(im_r_ang))))),[newfolder filename],'jpg');
        fprintf(['TPWFP ' num2str(t) '\n']);
    end

    if exist('z_groundtruth','var')
        Relerrs(1+t) = norm(z_groundtruth - exp(-1i*angle(trace(z_groundtruth'*z))) * z, 'fro')/norm(z_groundtruth,'fro'); % Initial rel. error
        if ~exist('displayflag','var') || (exist('displayflag','var') && displayflag==1)
            set(groot,'CurrentFigure',gcf); plot(Relerrs(1:1+t));
            pause(0.01);
        end
    end

end

if exist('z_groundtruth','var')
    Relerrs_TPWFP = Relerrs;
    save([newfolder '/Relerrs_TPWFP.mat'],'Relerrs_TPWFP');
    if ~exist('displayflag','var') || (exist('displayflag','var') && displayflag==1)
        saveas(gcf, [newfolder '/Relerrs_TPWFP.fig']);
    end
end

im_r = ifft2(ifftshift(z));


