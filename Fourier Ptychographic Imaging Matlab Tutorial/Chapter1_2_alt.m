%% simulate an incoherent imaging system
clear all, close all 
addpath('../');  % this allows finding tools path
opts.F = @(x) fftshift(fft2((x)));
opts.Ft = @(x) (ifft2(ifftshift(x)));
opts.pupilRadius = 20;
objectIntensity = double(imread('cameraman.tif'));
% objectAmplitude = sqrt(objectIntensity);
[M,N]=size(objectIntensity);         %get image sample size

figure
subplot(321); imshow(objectIntensity,[]);
title('Input Intensity')

%%Setup parameters for the coherent imaging system


pixelSize = 0.5e-6;

% L=0.3e-3;              %image plane side length (m)
L=M*pixelSize             %image plane side length (m)
du=L/M;                %sample interval (m)  or pixel size
u=-L/2:du:L/2-du; v=u;

lambda=0.5*10^-6;      %wavelength
wxp=6.25e-3;           %exit pupil radius
zxp=62.5e-3;            %exit pupil distance
f0=wxp/(lambda*zxp);   %coherent cutoff  (cycles / m)
fN = zxp/(2*wxp);      %f number
NA = wxp/zxp;          %numerical aperture

%% Setup the low-pass filter
objectIntensityFT = opts.F(objectIntensity);%% simulate forward imaging process

fu=-1/(2*du):1/L:1/(2*du)-(1/L); %freq coords
fv=fu;
[Fu,Fv]=meshgrid(fu,fv);
CTF=tools.circ((Fu.^2+Fv.^2)/f0^2);

subplot(322); imshow(CTF,[]); title('CTF in the spatial freq domain')

W = tools.ZernikeCalc([2], [4], CTF, 'fringe',[]) + ...
    tools.ZernikeCalc([4], [4], CTF, 'fringe',[]);


CTF=tools.circ(exp(1i.*W).*(Fu.^2+Fv.^2)/f0^2);   % coherent transfer function
subplot(323); imshow(CTF,[]); title('CTF with aberations')
xlabel('fu (cyc/m)'); ylabel('fv (cyc/m)');
%% set up the incoherent transfer function
cpsf = opts.Ft(CTF) ;    % coherent PSF
ipsf = (abs(cpsf)).^2;   % incoherent PSF
OTF = abs(opts.F(ipsf)); % incoherent transfer function
OTF = OTF./max(max(OTF));
subplot(324); imshow(abs(CTF),[]); title('coherent transfer function')
subplot(325); imshow(abs(OTF),[]); title('Incoherent transfer function in the fourier domain')

subplot(325); surf(fu,fv,abs(OTF))
camlight left; lighting phong
colormap('gray')
shading interp
xlabel('fu (cyc/m)'); ylabel('fv (cyc/m)');

%% perform low pass filtering in the fourier domain

outputFT = OTF.*objectIntensityFT;
% subplot(325); imshow(log(abs(objectIntensityFT)),[]);
% title('Filtered spectrum in the Fourier domain')

outputIntensity = opts.Ft(outputFT);
subplot(326); imshow(outputIntensity,[]);
title('Output Intensity')





