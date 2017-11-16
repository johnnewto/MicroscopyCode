%% simulate the forward imaging process of Fourier ptychography
% simulate the high resoluiton complex object 
im=double(imread('Lenna.png'));
im=imresize(im,[256 256]);
objectAmplitude_r = padarray(im(:,:,1),[128 128]);
objectAmplitude_g = padarray(im(:,:,2),[128 128]);
objectAmplitude_b = padarray(im(:,:,3),[128 128]);
phase = double(imread('westconcordorthophoto.png'));
phase = imresize(phase,[512 512])./max(max(phase));
object_r = objectAmplitude_r.*exp(1i.* phase);
object_g = objectAmplitude_g.*exp(1i.* phase);
object_b = objectAmplitude_b.*exp(1i.* phase);
%% setup the parameters for the coherent imaging system
waveLength_r = 0.63e-6;k0_r = 2*pi/waveLength_r;
waveLength_g = 0.53e-6;k0_g = 2*pi/waveLength_g;
waveLength_b = 0.47e-6;k0_b = 2*pi/waveLength_b;
spsize = 2.2e-6; % sampling pixel size of the CCD
psize = spsize / 4; % final pixel size of the reconstruction
NA = 0.08;
%% create the wave vectors for the LED illumiantion 
arraysize = 15;
xlocation = zeros(1,arraysize^2);
ylocation = zeros(1,arraysize^2);
LEDgap = 4; % 4mm between adjacent LEDs
LEDheight = 90; % distance bewteen the LED matrix and the sample
for i=1:arraysize % from top left to bottom right
    xlocation(1,1+arraysize*(i-1):15+arraysize*(i-1)) = (-(arraysize-1)/2:1:(arraysize-1)/2)*LEDgap;
    ylocation(1,1+arraysize*(i-1):15+arraysize*(i-1)) = ((arraysize-1)/2-(i-1))*LEDgap;
end;
kx_relative = -sin(atan(xlocation/LEDheight));  
ky_relative = -sin(atan(ylocation/LEDheight)); 
%% generate the low-pass filtered images
[m,n] = size(object_r); % image size of high resolution object
m1 = m/(spsize/psize);n1 = n/(spsize/psize); % image size of the final output 
dkx = 2*pi/(psize*n);dky = 2*pi/(psize*m);
kmax = pi/spsize;
[kxm kym] = meshgrid(-kmax:kmax/((n1-1)/2):kmax,-kmax:kmax/((n1-1)/2):kmax);
% red channel
kx_r = k0_r * kx_relative;
ky_r = k0_r * ky_relative;
imSeqLowRes_r = zeros(m1, n1, arraysize^2); % the final low resolution image sequence
cutoffFrequency_r = NA * k0_r;
CTF_r = double((kxm.^2+kym.^2)<cutoffFrequency_r^2); 
% green channel
kx_g = k0_g * kx_relative;
ky_g = k0_g * ky_relative;
imSeqLowRes_g = zeros(m1, n1, arraysize^2); % the final low resolution image sequence
cutoffFrequency_g = NA * k0_g;
CTF_g = double((kxm.^2+kym.^2)<cutoffFrequency_g^2); 
% blue channel
kx_b = k0_b * kx_relative;
ky_b = k0_b * ky_relative;
imSeqLowRes_b = zeros(m1, n1, arraysize^2); % the final low resolution image sequence
cutoffFrequency_b = NA * k0_b;
CTF_b = double((kxm.^2+kym.^2)<cutoffFrequency_b^2); 
% the incoherent summation of the R,G,B channels
imSeqLowRes = zeros(m1, n1, arraysize^2);
%% forward imaging model
objectFT_r = fftshift(fft2(object_r));
objectFT_g = fftshift(fft2(object_g));
objectFT_b = fftshift(fft2(object_b));
for tt =1:arraysize^2
    % red channel
    kxc_r = round((n+1)/2+kx_r(1,tt)/dkx);
    kyc_r = round((m+1)/2+ky_r(1,tt)/dky);
    kyl_r = round(kyc_r-(m1-1)/2);
    kyh_r = round(kyc_r+(m1-1)/2);
    kxl_r = round(kxc_r-(n1-1)/2);
    kxh_r = round(kxc_r+(n1-1)/2);
    imSeqLowFT_r = (m1/m)^2 * objectFT_r(kyl_r:kyh_r,kxl_r:kxh_r).*CTF_r;
    imSeqLowRes_r(:,:,tt) = abs(ifft2(ifftshift(imSeqLowFT_r)));
    % green channel
    kxc_g = round((n+1)/2+kx_g(1,tt)/dkx);
    kyc_g = round((m+1)/2+ky_g(1,tt)/dky);
    kyl_g = round(kyc_g-(m1-1)/2);
    kyh_g = round(kyc_g+(m1-1)/2);
    kxl_g = round(kxc_g-(n1-1)/2);
    kxh_g = round(kxc_g+(n1-1)/2);
    imSeqLowFT_g = (m1/m)^2 * objectFT_g(kyl_g:kyh_g,kxl_g:kxh_g).*CTF_g;
    imSeqLowRes_g(:,:,tt) = abs(ifft2(ifftshift(imSeqLowFT_g)));
    % blue channel
    kxc_b = round((n+1)/2+kx_b(1,tt)/dkx);
    kyc_b = round((m+1)/2+ky_b(1,tt)/dky);
    kyl_b = round(kyc_b-(m1-1)/2);
    kyh_b = round(kyc_b+(m1-1)/2);
    kxl_b = round(kxc_b-(n1-1)/2);
    kxh_b = round(kxc_b+(n1-1)/2);
    imSeqLowFT_b = (m1/m)^2 * objectFT_b(kyl_b:kyh_b,kxl_b:kxh_b).*CTF_b;
    imSeqLowRes_b(:,:,tt) = abs(ifft2(ifftshift(imSeqLowFT_b)));
    % summation of R,G,B channels
    imSeqLowRes(:,:,tt) = imSeqLowRes_r(:,:,tt) + imSeqLowRes_g(:,:,tt)+ imSeqLowRes_b(:,:,tt);
end;
figure;imshow(imSeqLowRes(:,:,113),[]);
%% Recover the high resolution images at R,G,and B channels
seq = gseq(arraysize);
objectRecover_r = ones(m,n);objectRecoverFT_r = fftshift(fft2(objectRecover_r));
objectRecover_g = ones(m,n);objectRecoverFT_g = fftshift(fft2(objectRecover_g));
objectRecover_b = ones(m,n);objectRecoverFT_b = fftshift(fft2(objectRecover_b));
loop = 25;
for tt=1:loop
    for i3=1:arraysize^2
        i2=seq(i3);
        kxc_r=round((n+1)/2-kx_r(1,i2)/dkx);kyc_r=round((m+1)/2-ky_r(1,i2)/dky);
        kxc_g=round((n+1)/2-kx_g(1,i2)/dkx);kyc_g=round((m+1)/2-ky_g(1,i2)/dky);
        kxc_b=round((n+1)/2-kx_b(1,i2)/dkx);kyc_b=round((m+1)/2-ky_b(1,i2)/dky);
        kyl_r=round(kyc_r-(m1-1)/2);kyh_r=round(kyc_r+(m1-1)/2);
        kyl_g=round(kyc_g-(m1-1)/2);kyh_g=round(kyc_g+(m1-1)/2);
        kyl_b=round(kyc_b-(m1-1)/2);kyh_b=round(kyc_b+(m1-1)/2);
        kxl_r=round(kxc_r-(n1-1)/2);kxh_r=round(kxc_r+(n1-1)/2);
        kxl_g=round(kxc_g-(n1-1)/2);kxh_g=round(kxc_g+(n1-1)/2);
        kxl_b=round(kxc_b-(n1-1)/2);kxh_b=round(kxc_b+(n1-1)/2);             
        lowResFT_1r = (m1/m)^2 * objectRecoverFT_r(kyl_r:kyh_r,kxl_r:kxh_r).*CTF_r;
        lowResFT_1g = (m1/m)^2 * objectRecoverFT_g(kyl_g:kyh_g,kxl_g:kxh_g).*CTF_g;
        lowResFT_1b = (m1/m)^2 * objectRecoverFT_b(kyl_b:kyh_b,kxl_b:kxh_b).*CTF_b;        
        im_lowRes_r = ifft2(ifftshift(lowResFT_1r));
        im_lowRes_g = ifft2(ifftshift(lowResFT_1g));
        im_lowRes_b = ifft2(ifftshift(lowResFT_1b));
        rbg_sum = sqrt((abs(im_lowRes_r)).^2+(abs(im_lowRes_g)).^2+(abs(im_lowRes_b)).^2);               
        im_lowRes_r = (m/m1)^2 * imSeqLowRes(:,:,i2).*abs(im_lowRes_r)./rbg_sum.*exp(1i.*angle(im_lowRes_r)); 
        lowResFT_2r = fftshift(fft2(im_lowRes_r)).*CTF_r;
        im_lowRes_g = (m/m1)^2 * imSeqLowRes(:,:,i2).*abs(im_lowRes_g)./rbg_sum.*exp(1i.*angle(im_lowRes_g)); 
        lowResFT_2g = fftshift(fft2(im_lowRes_g)).*CTF_g;
        im_lowRes_b = (m/m1)^2 * imSeqLowRes(:,:,i2).*abs(im_lowRes_b)./rbg_sum.*exp(1i.*angle(im_lowRes_b)); 
        lowResFT_2b = fftshift(fft2(im_lowRes_b)).*CTF_b;
        objectRecoverFT_r(kyl_r:kyh_r,kxl_r:kxh_r) = objectRecoverFT_r(kyl_r:kyh_r,kxl_r:kxh_r)+ conj(CTF_r)./(max(max(abs(CTF_r).^2))).*(lowResFT_2r - lowResFT_1r);
        objectRecoverFT_g(kyl_g:kyh_g,kxl_g:kxh_g) = objectRecoverFT_g(kyl_g:kyh_g,kxl_g:kxh_g)+ conj(CTF_g)./(max(max(abs(CTF_g).^2))).*(lowResFT_2g - lowResFT_1g);
        objectRecoverFT_b(kyl_b:kyh_b,kxl_b:kxh_b) = objectRecoverFT_b(kyl_b:kyh_b,kxl_b:kxh_b)+ conj(CTF_b)./(max(max(abs(CTF_b).^2))).*(lowResFT_2b - lowResFT_1b);
    end;
end;
objectRecover_r=ifft2(ifftshift(objectRecoverFT_r));
objectRecover_g=ifft2(ifftshift(objectRecoverFT_g));
objectRecover_b=ifft2(ifftshift(objectRecoverFT_b));
figure;imshow(abs(objectRecover_r),[]);
figure;imshow(abs(objectRecover_g),[]);
figure;imshow(abs(objectRecover_b),[]);

