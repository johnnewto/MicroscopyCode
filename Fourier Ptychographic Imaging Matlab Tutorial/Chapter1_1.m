%% simulate forward imaging process
clear all, close all % High res complex object
addpath('../');  % this allows finding tools path
opts.display = 'iter';%'full';%'iter';
opts.F = @(x) fftshift(fft2((x)));
opts.Ft = @(x) (ifft2(ifftshift(x)));
opts.pupilRadius = 20;
objectIntensity = double(imread('cameraman.tif'));
objectAmplitude = sqrt(objectIntensity);


figure
subplot(221); imshow(objectAmplitude,[]);
title('Input Amplitude')

%%Setup parameters for the coherent imaging system
waveLength = 0.5e-6;
k0 = 2*pi/waveLength;
pixelSize = 0.5e-6;
NA = 0.1; 
cutoffFrequency = NA * k0;    % (radians / m)
%% Setup the low-pass filter
objectAmplitudeFT = opts.F(objectAmplitude);
[m,n] = size(objectAmplitude); % image size of the high res object

kx = -pi/pixelSize: 2*pi/(pixelSize*(n-1)): pi/pixelSize;
ky = -pi/pixelSize: 2*pi/(pixelSize*(n-1)): pi/pixelSize;

[kxm, kym] = meshgrid(kx, ky);
CTF = ((kxm.^2+kym.^2) < cutoffFrequency^2);   % coherent transfer function
subplot(222); imshow(CTF,[]); title('CTF in the spatial freq domain')

%% The filtering process

outputFT = CTF.*objectAmplitudeFT;
subplot(223); imshow(log(abs(outputFT)),[]);
title('Filtered spectrum in the spatial freq domain')

%% Output amplitude and intensity
outputAmplitude = opts.Ft(outputFT);
outputIntensity = abs(outputAmplitude).^2;
subplot(224); imshow(outputAmplitude,[]);
title('Output Amplitude')





