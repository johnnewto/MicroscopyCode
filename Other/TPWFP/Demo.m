%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% By Liheng Bian, Feb. 9th, 2016. Contact me: lihengbian@gmail.com.
% This demo does the simulation of Fourier ptychology, and use TPWFP to reconstruct the HR plural image.
% Ref: Liheng Bian et al., "Fourier ptychographic reconstruction using
% Poisson maximum likelihood and truncated Wirtinger gradient".
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; close all; clc;
addpath(genpath(pwd));

%% FPM simulation parameters
samplename.amplitude = 'Lena_512.png';
samplename.amplitude = 'usaf512.png';
samplename.phase = 'Map_512.tiff';

noise.type = 'gaussian';
noise.variance = 0.002^2;

n = 512; % pixels of high resolution image
M_factor=8; % magnification factor
fprob_flag = 0; % if use aberrant pupil function to generate LR images

newfolder = ['C:/Users/John/Desktop/TPWFP/data_reconstruction/Noise_' num2str(noise.type) '_' num2str(noise.variance) '_Probe_' num2str(fprob_flag) '_Amp_' samplename.amplitude '_Phase_' num2str(samplename.phase)];
mkdir(newfolder);

inputImagefolder = ['C:/Users/John/Desktop/TPWFP/inputImages'];
mkdir(inputImagefolder);


%% generate captured images
[sample, f_sample , im_capture, fprob_real, fprob_save, dkx, dky, kx, ky, Masks] = fun_FPM_Capture(samplename, noise, n, M_factor, fprob_flag, inputImagefolder);

figure;
subplot(1,2,1),imshow(abs(sample),[]); title('groundtruth amplitude');
subplot(1,2,2),imshow(angle(sample),[]); title('groundtruth phase');


% Read images from disk
%%
imglist = dir([inputImagefolder,'/*.tif']);
fprintf(['loading the images...\n']);
count = 0;
Iall = zeros(size(im_capture));
WhichImages = 1:length(imglist);
for m = 1:length(imglist)
    if(find(WhichImages == m))
        count = count + 1;
        fprintf(['loading ',imglist(m).name, '\n']);
        fn = [inputImagefolder,'/',imglist(m).name];
        % all image data
        img = imread(fn);
        Iall(:,:,count) = img;       
    end
end
im_capture = double(Iall)/(2^16-1);
fprintf(['\nfinish loading images\n']);



%%
save([newfolder '/sample.mat'],'sample');
save([newfolder '/im_capture.mat'],'im_capture');
save([newfolder '/fprob_real.mat'],'fprob_real');
save([newfolder '/fprob_save.mat'],'fprob_save');
save([newfolder '/dkx.mat'],'dkx');
save([newfolder '/dky.mat'],'dky');
save([newfolder '/kx.mat'],'kx');
save([newfolder '/ky.mat'],'ky');

imwrite(uint8(255*(abs(sample)/max(max(abs(sample))))),[newfolder '/sample_amp.jpg'],'jpg');
im_r_ang = angle(sample)/pi;
im_r_ang = im_r_ang - min(min(im_r_ang));
imwrite(uint8(255*(abs(im_r_ang)/max(max(abs(im_r_ang))))),[newfolder '/sample_phase.jpg'],'jpg');

hwidth = n/M_factor/2;

if fprob_flag == 1
    temp = fprob_real(n/2-hwidth+1:n/2+hwidth,n/2-hwidth+1:n/2+hwidth);
    imwrite(uint8(255*(abs(temp)/max(max(abs(temp))))),[newfolder '/probe_real_amp.jpg'],'jpg');
    im_r_ang = angle(temp)/pi;
    im_r_ang = im_r_ang - min(min(im_r_ang));
    imwrite(uint8(255*(abs(im_r_ang)/max(max(abs(im_r_ang))))),[newfolder '/probe_real_phase.jpg'],'jpg');
end

%% TPWFP reconstruction

ini_flag = -1; % initialization flag (-1: upsample version of the Low resolution image; 0: all zeros)
save_sep_Poisson = 10; % iterations to save results

Y = im_capture;
[n1_LR, n2_LR, L] = size(Y);
n1 = n1_LR * M_factor;
n2 = n2_LR * M_factor;
hwidth = n/M_factor/2;
fmaskpro = fprob_save(n/2-hwidth+1:n/2+hwidth,n/2-hwidth+1:n/2+hwidth);
A = @fun_A_Real;
At = @fun_At_Real;

% Set Parameters
if exist('Params')                == 0,  Params.n1          = n1;  end
if isfield(Params, 'n2')          == 0,  Params.n2          = n2;  end             % signal dimension
if isfield(Params, 'L')           == 0,  Params.L           = L;   end             % number of measurements
if isfield(Params, 'alpha_h')     == 0,  Params.alpha_h     = 25/8;    end
if isfield(Params, 'tau0')        == 0,  Params.tau0        = 330/8;  end     % Time constant for step size
if isfield(Params, 'muTWF')       == 0,  Params.muTWF       = 0.1/8;  end     % step size of TWF
if isfield(Params, 'T')           == 0,  Params.T           = 100;  end    	% number of iterations
if isfield(Params, 'npower_iter') == 0,  Params.npower_iter = 50;   end		% number of power iterations
Params.m = n1_LR * n2_LR * L;

[z_ini, z, im_r, Relerrs_TWFP] = fun_TPWFP_Real(Y, Params, A, At, Masks, n1_LR, n2_LR, ini_flag, newfolder, save_sep_Poisson, fmaskpro, f_sample);

%%
figure;
subplot(1,2,1),imshow(abs(im_r),[]); title('TPWFP amplitude');
subplot(1,2,2),imshow(angle(im_r),[]); title('TPWFP phase'); colorbar;
