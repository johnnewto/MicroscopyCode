function[u2]=prop2step(u1,L1,L2,lambda,z)
% propagation - 2 step Fresnel diffraction method
% assumes uniform sampling and square array
% u1 - complex field at source plane
% L1 - source plane side-length
% L2 - observation plane side-length
% lambda - wavelength 
% z - propagation distance
% u2 - output field at observation plane
%
[M,N]=size(u1);       %input array size
k=2*pi/lambda;        %wavenumber

% source plane
dx1=L1/M;
x1=-L1/2:dx1:L1/2-dx1;
[X,Y]=meshgrid(x1,x1);
u=u1.*exp(j*k/(2*z*L1)*(L1-L2)*(X.^2+Y.^2));
u=fft2(fftshift(u));

% dummy (frequency) plane
fx1=-1/(2*dx1):1/L1:1/(2*dx1)-1/L1;
fx1=fftshift(fx1);
[FX1,FY1]=meshgrid(fx1,fx1);
u=exp(-j*pi*lambda*z*L1/L2*(FX1.^2+FY1.^2)).*u;
u=ifftshift(ifft2(u));

% observation plane
dx2=L2/M;
x2=-L2/2:dx2:L2/2-dx2;
[X,Y]=meshgrid(x2,x2);
u2=(L2/L1)*u.*exp(-j*k/(2*z*L2)*(L1-L2)*(X.^2+Y.^2));
u2=u2*dx1^2/dx2^2;   %x1 to x2 scale adjustment
end
