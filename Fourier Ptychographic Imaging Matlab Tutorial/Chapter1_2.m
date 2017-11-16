%% simulate an incoherent imaging system
clear all, close all 
addpath('../');  % this allows finding tools path
opts.F = @(x) fftshift(fft2((x)));
opts.Ft = @(x) (ifft2(ifftshift(x)));
opts.pupilRadius = 20;
objectIntensity = double(imread('cameraman.tif'));
% objectAmplitude = sqrt(objectIntensity);

figure
subplot(321); imshow(objectIntensity,[]);
title('Input Intensity')

%%Setup parameters for the coherent imaging system
waveLength = 0.5e-6;
k0 = 2*pi/waveLength;
pixelSize = 0.5e-6;
NA = 0.1; cutoffFrequency = NA * k0;
%% Setup the low-pass filter
objectIntensityFT = opts.F(objectIntensity);%% simulate forward imaging process

[m,n] = size(objectIntensity); % image size of the high res object

kx = -pi/pixelSize: 2*pi/(pixelSize*(n-1)): pi/pixelSize;
ky = -pi/pixelSize: 2*pi/(pixelSize*(n-1)): pi/pixelSize;

[kxm, kym] = meshgrid(kx, ky);
CTF = ((kxm.^2+kym.^2) < cutoffFrequency^2);   % coherent transfer function
subplot(322); imshow(CTF,[]); title('CTF in the spatial freq domain')

W = tools.ZernikeCalc([2], [0], CTF, 'fringe',[]) + ...
    tools.ZernikeCalc([4], [2], CTF, 'fringe',[]);

% subplot(322);
% surf(kxm, kym,W ),camlight left; lighting phong, colormap('gray'), shading interp

pupil = exp(-1i.*W);
CTF2 = pupil.*CTF;   % coherent transfer function
subplot(323); imshow(CTF2,[]); 
surf(kxm, kym,real(CTF2) ),camlight left; lighting phong, colormap('gray'), shading interp
title('CTF with aberations')
% CTF2 = W.*CTF;   % coherent transfer function
% subplot(323); imshow(CTF2,[]); title('CTF with aberations')
% surf(kxm, kym,CTF2 ),camlight left; lighting phong, colormap('gray'), shading interp

%% set up the incoherent transfer function
cpsf = opts.Ft(CTF2) ;    % coherent PSF
ipsf = (abs(cpsf)).^2;   % incoherent PSF
OTF = abs(opts.F(ipsf)); % incoherent transfer function
OTF = OTF./max(max(OTF));
subplot(324); imshow(abs(CTF),[]); title('coherent transfer function')
subplot(325); imshow(abs(OTF),[]); title('Incoherent transfer function in the fourier domain')

% subplot(325);
% surf(kxm, kym,(abs(OTF)))
% camlight left; lighting phong
% colormap('gray')
% shading interp
% xlabel('kxm (rad/m)'); ylabel('kym (rad/m)');

%% perform low pass filtering in the fourier domain

outputFT = OTF.*objectIntensityFT;
% subplot(325); imshow(log(abs(objectIntensityFT)),[]);
% title('Filtered spectrum in the Fourier domain')

outputIntensity = opts.Ft(outputFT);
subplot(326); imshow(outputIntensity,[]);
title('Output Intensity')





