function [sample, f_sample, im_capture, fprob_real, fprob_save, dkx, dky, kx, ky, Masks] = fun_FPM_Capture(samplename, noise, n, M_factor, fprob_flag, inputImagefolder)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% By Liheng Bian, Jan. 5th, 2016
% Thanks to Xiaoze Ou for offering code samples.

% Inputs:
% samplename.amplitude: amplitude image name
% samplename.phase: phase image name or 0
% noise.type: corrupted noise type
% noise.variance: variance of the noise
% n: pixels of high resolution image
% M_factor: magnification factor of the microscope imaging system
% fprob_flag: if use aberrant pupil function to generate LR images (0: no; 1: yes)

% Outputs:
% sample: high resolution sample
% f_sample: spatial spectrum of the sample
% im_capture: simulated FPM captured low resolution images
% fprob_real: utilized pupil function to capture images
% fprob_save: ideal pupil function (all ones inside the NA circle and all zeros outside the circle)
% dkx, dky: 2*pi/(psize*n)
% kx, ky: wave vectors 2pi/lambda*sin(theta)
% Masks: locations of the first pixel of each camptured images in Fourier space
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% load images
modulus = imresize(im2double(imread(samplename.amplitude)), [n n]);
if samplename.phase == 0
    phase = zeros([n, n]);
else
    phase = imresize(im2double(imread(samplename.phase)), [n n]);
    phase = phase - min(min(phase));
    phase = phase/max(max(phase));
    phase = (phase)*pi/2; % 0~pi/2
end
sample = modulus .* exp(1j*phase);
f_sample=fftshift(fft2(sample)); % low frequency in center

%% system parameters
LEDp = 4; % LED pitch distance, mm
H = 84.8; % height from LED to sample, mm
wlength = 0.625e-6; % wavelength of red light, m
NA = 0.08; % numerical aperture of the objective
psize = 0.2e-6; % pixel size in the reconstructed image, m
FOV = psize*n;
disp(['FOV = ',num2str(FOV/1e-6), ' um']);

snum = 7; % half LED numbers
snum = 2; % half LED numbers

%% calculate kx, ky for each LED (center (0,0))
centerx=0;centery=0;
xlocation=zeros(1,(2*snum+1)^2);
ylocation=zeros(1,(2*snum+1)^2);
% lightupseq=gseq(2*snum+1)-0.01;  % special light up sequence
lightupseq=(1:(2*snum+1)^2)-0.01;  % simple linear light up sequence

for tt=1:(2*snum+1)^2
    xi=centerx-snum+round(mod(lightupseq(1,tt),2*snum+1))-1;
    yi=centery-snum+floor(lightupseq(1,tt)/(2*snum+1));
    xlocation(1,tt)=xi-centerx;
    ylocation(1,tt)=yi-centery;
end;
clear tt xi yi lightupseq
dkx=2*pi/(psize*n);
dky=2*pi/(psize*n);
kx=2*pi./wlength*(xlocation*LEDp./sqrt(xlocation.^2.*LEDp.^2 + ylocation.^2.*LEDp.^2 + H.^2)); % kx = 2pi/lambda*sin(theta)   pixel shift = psize*n/lambda*sin(theta)
ky=2*pi./wlength*(ylocation*LEDp./sqrt(xlocation.^2.*LEDp.^2 + ylocation.^2.*LEDp.^2 + H.^2));

tempkx = kx;
tempky = ky;
tempkx(abs(kx)>3.152e6 | abs(ky)>3.152e6) = [];
tempky(abs(kx)>3.152e6 | abs(ky)>3.152e6) = [];
kx = tempkx;
ky = tempky;

L = length(kx);

%% capture low resolution images
NAfil=round(NA*(1/wlength)*n*psize); % pixel number of the radius in NA
mask=zeros(n,n);
[km, kn]=meshgrid(1:n,1:n);
mask((((km-n/2)/NAfil).^2+((kn-n/2)/NAfil).^2)<1)=1;
fprob_save=mask;

if fprob_flag == 1
    % use 5 orders of Zernike polynomials to simulate aberrant pupil function
    def=0.1;ax=-0.21;ay=0.13;cx=0.0;cy=0.0;
    zn=def*gzn(n,NAfil*2,0,2)+ax*gzn(n,NAfil*2,2,2)...
        +ay*gzn(n,NAfil*2,-2,2)+cx*gzn(n,NAfil*2,1,3)...
        +cy*gzn(n,NAfil*2,-1,3);
    fprob_real=mask.*exp(pi*1j.*zn);
else
    fprob_real = mask;
end

hwidth = n/M_factor/2;

Masks = zeros([L,2]);
for i = 1:size(kx,2)
    Masks(i,1) = n/2+round(kx(1,i)/dkx)-hwidth+1;
    Masks(i,2) = n/2+round(ky(1,i)/dky)-hwidth+1;
end
fmaskpro = fprob_real(n/2-hwidth+1:n/2+hwidth,n/2-hwidth+1:n/2+hwidth);
im_capture = fun_A_Real(f_sample, Masks, n/M_factor, n/M_factor, fmaskpro);
im_capture = abs(im_capture).^2;

%% add noise
if strcmp(noise.type, 'gaussian')
    im_capture=max(max(max(im_capture))) .* imnoise(im_capture/max(max(max(im_capture))),'gaussian', 0, noise.variance);
elseif strcmp(noise.type, 'speckle')
    im_capture=max(max(max(im_capture))) .* imnoise(im_capture/max(max(max(im_capture))),'speckle', noise.variance);
elseif strcmp(noise.type, 'pupillocation')
    limit = 0;
    Masks_noise = Masks;
    Masks_noise(limit:L,:) = round(Masks(limit:L,:) + randn(size(Masks(limit:L,:)))*sqrt(noise.variance));
    im_capture = A_Function_Real(f_sample, Masks_noise, n/M_factor, n/M_factor, fmaskpro);
    im_capture = abs(im_capture).^2;
end


for i = 1: size(im_capture,3)
	filename = sprintf('/capture_%03d.tif',i);
	imwrite(uint16((2^16-1)*(im_capture(:,:,i))),[inputImagefolder filename],'tif');
end