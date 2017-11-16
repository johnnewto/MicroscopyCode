% grating_sqr diffraction grating example 1D

lambda=0.5e-6;  %wavelength
f=0.5;          %propagation distance
P=1e-4;         %grating period
D1=1e-3;        %grating side length

L1=1e-2;        %array side length
M=2200;         %# samples
dx1=L1/M;
x1=-L1/2:dx1:L1/2-dx1; %source coords
%[X1,Y1]=meshgrid(x1,x1);

% construct grating field
fc=fft(fftshift(ucomb(x1/P)));
fr=fft(fftshift(rect(x1/(P/2))));
ux=ifftshift(ifft(fc.*fr)); %1D conv rect & comb
%u1=repmat(ux,M,1);          %replicate to 2D
u1=ux.*rect(x1/D1); %set size

% 1D Fraunhofer pattern
lf=lambda*f;
u2=sqrt(1/lf)*ifftshift(fft(fftshift(u1)))*dx1;
L2=lf/dx1;

dx2=L2/M;
I2=abs(u2).^2;
x2=-L2/2:dx2:L2/2-dx2;

figure(1);
plot(x2,I2);
xlabel('x (m)'); ylabel('Irradiance');
