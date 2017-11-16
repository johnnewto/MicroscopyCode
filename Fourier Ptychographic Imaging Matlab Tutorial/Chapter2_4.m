%% simulate forward imaging process
clear all, close all % High res complex object
addpath('../');  % this allows finding tools path
opts.display = 'iter';%'full';%'iter';
% opts.F = @(x) fftshift(fft2(ifftshift(x)));
% opts.Ft = @(x) fftshift(ifft2(ifftshift(x)));
opts.F = @(x) fftshift(fft2((x)));
opts.Ft = @(x) (ifft2(ifftshift(x)));
objectAmpitude = double(imread('cameraman.tif'));
phase = double(imread('westconcordorthophoto.png'));
figure
subplot(221); imshow(imread('cameraman.tif'));
title('Input Amplitude')
subplot(222); imshow(imread('westconcordorthophoto.png'));
title('Input Phase')

phase = pi*imresize(phase,[256,256])./max(max(phase));
object = objectAmpitude.*exp(1i.*phase);
subplot(223); imshow(abs(object),[]); title('Input Complex Object');

subplot(224); imshow(angle(object),[]); title('Input Complex phase');

%% create the wave vectors for the led
arraysize = 15; % length of one size
xlocation = zeros(1,arraysize^2);
ylocation = zeros(1,arraysize^2);
LEDgap = 4; % distance between adjacent LEDs
LEDheight = 90; % 90 mm between LED matrix and the sample

for i=1:arraysize  % from top left to bottom right
    xlocation(1,1+arraysize*(i-1):arraysize+arraysize*(i-1))...   % Jn see changes here
        =(-(arraysize-1)/2:1:(arraysize-1)/2)*LEDgap;
    ylocation(1,1+arraysize*(i-1):arraysize+arraysize*(i-1))...
        =((arraysize-1)/2-(i-1))*LEDgap;
end
kx_relative = -sin(atan(xlocation/LEDheight));  % create kx, ky wavevectors
ky_relative = -sin(atan(ylocation/LEDheight)); 
%% setup the parameters of the coherent imaging system
waveLength = 0.63e-6;
k0 = 2*pi/waveLength;
spsize = 2.75e-6; % sampling pixel size of the CCD
psize = spsize / 4; % final pixel size of the reconstruction
NA = 0.08;
[m,n] = size(object); % image size of the high res object
m1 = m/(spsize/psize);
n1 = n/(spsize/psize); % image size of the final output

%% Pupil
cutoffFrequency = NA * k0;
kmax = pi/spsize;
[kxm, kym] = meshgrid(-kmax:kmax/((n1-1)/2):kmax, -kmax:kmax/((n1-1)/2):kmax);
CTF = ((kxm.^2+kym.^2) < cutoffFrequency^2);   % coherent transfer function


z = 50e-6;  kzm = sqrt(k0^2-kxm.^2-kym.^2);
pupil = exp(1i.*z.*real(kzm)).*exp(-abs(z).*(imag(kzm)));
CTF_withaberration = pupil.*CTF;
figure; 
surf(kxm, kym,angle(CTF_withaberration) )

%% generate the low-pass filtered images
imSeqLowRes = zeros(m1, n1, arraysize^2); % output low-res image sequence
kx = k0 * kx_relative;
ky = k0 * ky_relative;
dkx = 2*pi/(psize*n);
dky = 2*pi/(psize*m);

objectFT = fftshift(fft2(object));
for tt = 1:arraysize^2
    kxc = round((n+1)/2+kx(1,tt)/dkx);
    kyc = round((m+1)/2+ky(1,tt)/dky);
    kyl = round(kyc-(m1-1)/2); kyh = round(kyc+(m1-1)/2);
    kxl = round(kxc-(n1-1)/2); kxh = round(kxc+(n1-1)/2);
    imSeqLowFT = (m1/m)^2 * objectFT(kyl:kyh,kxl:kxh).*CTF_withaberration;
    imSeqLowRes(:,:,tt) = abs(ifft2(ifftshift(imSeqLowFT)));
end
figure; 
scale = 6;
img = imresize(imSeqLowRes(:,:,1),scale);
subplot(131); imshow(img,[]);
title('The 1''st low-res');

img = imresize(imSeqLowRes(:,:,round((arraysize^2)/2)),scale);
subplot(132); imshow(img,[]);
title(sprintf('The %d''rd low-res',round((arraysize^2)/2)));

img = imresize(imSeqLowRes(:,:,arraysize^2),scale);
subplot(133); imshow(img,[]);
title(sprintf('The %d''rd low-res',arraysize^2));



%% recover the high resolution image
seq = tools.gseq(arraysize);   % define the order of recovery, we start from the center (113'th image) to the edge of the spectrum (the 255'th image)
objectRecover = ones(m,n); % initial guess of the object
objectRecoverFT = opts.F(objectRecover);
pupil = 1;
loop = 5;

for tt=1:loop
    for i3=1:arraysize^2;
        i2=seq(i3);
        kxc = round((n+1)/2+kx(1,i2)/dkx);
        kyc = round((m+1)/2+ky(1,i2)/dky);
        kyl = round(kyc-(m1-1)/2); kyh = round(kyc+(m1-1)/2);
        kxl = round(kxc-(n1-1)/2); kxh = round(kxc+(n1-1)/2);
        lowResFT_1 = objectRecoverFT(kyl:kyh,kxl:kxh) .* CTF .*pupil;
        im_lowRes = opts.Ft(lowResFT_1);
        im_lowRes = (m/m1)^2 * ...
                         imSeqLowRes(:,:,i2).*exp(1i.*angle(im_lowRes));
        lowResFT_2 = opts.F(im_lowRes);
                     
        objectRecoverFT(kyl:kyh,kxl:kxh)=objectRecoverFT(kyl:kyh,kxl:kxh) + ...
            conj(CTF.*pupil)./(max(max(abs(CTF.*pupil).^2))).*(lowResFT_2 - lowResFT_1);
                    
        pupil = pupil + conj(objectRecoverFT(kyl:kyh,kxl:kxh))./ ...
            (max(max(abs(objectRecoverFT(kyl:kyh,kxl:kxh)).^2))).*(lowResFT_2 - lowResFT_1);
                   
        tools.plotReconstructedObject(objectRecoverFT, tt, i3, [kyc kxc], opts);
            
    end
    figure(5); 
    surf(kxm, kym,angle(pupil) )
end
% ,camlight left; lighting phong, colormap('gray'), shading interp

%        converIndex(loop) = converIndex(loop)+mean(abs(im_lowRes))./ ...
%             sum(sum(abs(im_lowRes- im_SeqlowRes(:,:,i2))));
%         
%  
%%
figure
subplot(221);imshow(abs(opts.Ft(objectRecoverFT)),[]); 
title('         Recovered Complex Amplitude');
subplot(222);imshow(angle(opts.Ft(objectRecoverFT)),[]);
subplot(223);imshow(log(objectRecoverFT),[]);
title('Recovered Spectrum');

subplot(224);imshow(log(objectRecoverFT),[]);
title('Recovered Spectrum');

figure; 
surf(kxm, kym,angle(pupil) )
figure; 
surf(kxm, kym,angle(pupil.*CTF) )

    
%% Helper Functions


    
    
    
    
    
    








