%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% By Liheng Bian, Nov 24th, 2014. Contact me: lihengbian@gmail.com.
% This demo does the simulation of Fourier ptychology, and use WFP to reconstruct the HR plural image.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; close all; clc;
addpath(genpath(pwd));
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% code parameters
T = 500  ; % number of iteration
mu_max = 0.4;
weight = 1;

% simulation parameters
ratio_LR = 0.1; % ratio between LR and HR
ratio_step = ratio_LR * 0.4; % step of LR captured spectra
sigmaN = 0.004; % standard derivation of additive noise
%%
% simulate captured LR images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read benchmark images
im_real = im2double(imread('data_source\Lena_512.png'));

phase_temp = im2double(imread('data_source\Map_512.tiff'));
phase_temp = phase_temp - min(min(phase_temp));
phase_temp = phase_temp/max(max(phase_temp));
phase_real = (phase_temp)*pi/2; % 0~pi/2

im = im_real .* (cos(phase_real) + 1j*sin(phase_real));

imf = fftshift(fft2(im));
x = imf;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[n1,n2] = size(x);
n1_LR = round(n1*ratio_LR);
n2_LR = round(n2*ratio_LR);
step = round(n1*ratio_step);

pupil = Creat_Pupil(round(n1_LR*0.4),n1_LR,n2_LR);
figure;
imshow(pupil); title('Simulated pupil');

% get mask index
k = 0;
for k1 = round(n1/4):step:round(n1/4*3)
    for k2 = round(n2/4):step:round(n2/4*3)
        k = k + 1;
        Masks(k,1) = k1;
        Masks(k,2) = k2;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% simulate captured images
L = size(Masks,1);
[xx_c] = A_LinearOperator(x,Masks,n1_LR,n2_LR,pupil);
Y = abs(xx_c).^2  ;

Y_original = Y;
Y_original_max = max(max(max(Y)));
N_real = sigmaN * max(max(max(Y))) * randn(size(Y));
Y = Y + N_real;
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% creat a folder to save results

newfolder = ['C:\Users\John\Desktop\WFP\results\Iter_' num2str(T)  '_Mumax_' num2str(mu_max)];
newfolder = [newfolder '_SigmaN_' num2str(sigmaN) '_RatioLR_' num2str(ratio_LR) '_Step_' num2str(ratio_step)];
mkdir(newfolder);

im_ang = angle(im)/pi;
imwrite(uint8(255*abs(im_ang)),[newfolder '\im_ang.png'],'png');
imwrite(uint8(255*abs(im)),[newfolder '\im.png'],'png');
%%
% Begin WFP reconstruction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic
sigma2 = (Y_original_max * sigmaN)^2;
[z0, im_r, Relerrs] = WFP(Y, n1, n2, sigma2, Masks, pupil, T, mu_max, weight, newfolder, x);
runtime = toc;
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save results
gcf = figure;
plot(Relerrs); xlabel('Iteration'); ylabel('Recovery Error');
saveas(gcf,[newfolder '\Error.fig']);

save([newfolder '\im.mat'],'im');
save([newfolder '\Y.mat'],'Y');
save([newfolder '\z0.mat'],'z0');
save([newfolder '\im_r.mat'],'im_r');
save([newfolder '\Relerrs.mat'],'Relerrs');

paratext1 = ['shots = ' num2str(L) ' ; runtime = ' num2str(runtime) '  ;  '];
paratext2 = ['umax = ' num2str(mu_max)  ' ; weight = ' num2str(weight) ' ;  '];
fid = fopen([newfolder '\Paratext.txt'],'w');
fprintf(fid,'%s\n',paratext1);
fprintf(fid,'%s\n',paratext2);
fclose(fid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%