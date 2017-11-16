% pc_temp partial temporal coherence example

lambda0=650e-9;     %center wavelength (m)
c=3e8;              %speed of light
k0=2*pi/lambda0;    %center wavenumber
nu0=c/lambda0;      %center frequency

% Gaussian lineshape parameters
N=51;               %number of components (odd)
delnu=2e9;          %spectral denstiy FWHM (Hz)
b=delnu/(2*sqrt(log(2))); %FWHM scaling
dnu=4*delnu/N;      %freq interval

% source plane parameters
L1=50e-3;           %source plane side length
M=250;              %# samples (even)
dx1=L1/M;           %sample interval
x1=-L1/2:dx1:L1/2-dx1; %source coords
x1=fftshift(x1);     %shift x coord
[X1,Y1]=meshgrid(x1,x1);

% beam parameters
w=1e-3;             %radius
dels=5e-3;          %transverse separation
deld=5e-2;          %delay distance
f=0.25;             %focal dist for Fraunhofer
lf=lambda0*f;

% loop through lines
I2=zeros(M);
for n=1:N
   % spectral density function
   nu=(n-(N+1)/2)*dnu+nu0;
   S=1/(sqrt(pi)*b)*exp(-(nu-nu0)^2/b^2);
   k=2*pi*nu/c;
   % source
   u=circ(sqrt((X1-dels/2).^2+Y1.^2)/w)...
       +circ(sqrt((X1+dels/2).^2+Y1.^2)/w)...
       *exp(j*k*deld);
   % Fraunhofer pattern
   u2=1/lf*(fft2(u))*dx1^2;
   % weighted irradiance and sum
   I2=I2+S*(abs(u2).^2)*dnu;
end

I2=ifftshift(I2); %normalize/center irradiance
x2=(-1/(2*dx1):1/L1:1/(2*dx1)-1/L1)*lf; %obs coords
y2=x2;

figure(1)              %irradiance image
imagesc(x2,y2,I2);
xlabel('x (m)'); ylabel('y (m)'); 
axis square; axis xy; colormap('gray');

figure(2)              %irradiance profile
plot(x2,I2(M/2+1,:));
xlabel('x (m)'); ylabel('Irradiance'); 

%analytic result
gam=exp(-(pi*delnu*deld/(c*2*sqrt(log(2))))^2);
I2ax=2/lf^2*((w^2*jinc(w/lf*x2)).^2).*(1+gam*cos(2*pi*dels*x2/lf+k0*deld));
figure(3)
plot(x2,I2(M/2+1,:),x2,I2ax,'.');
xlabel('x (m)'); ylabel('Irradiance');
