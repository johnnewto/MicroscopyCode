% pc_spatial partial spatial coherence example

lambda=650e-9;      %center wavelength (m)

L1=50e-3;           %source plane side length
M=250;              %# samples (even)
dx1=L1/M;           %sample interval
x1=-L1/2:dx1:L1/2-dx1; %source coords
x1=fftshift(x1);    %shift x coord
[X1,Y1]=meshgrid(x1,x1);

% beam parameters
w=1e-3;             %radius
dels=5e-3;          %transverse separation
f=0.25;             %Fraunhofer focal distance
lf=lambda*f;

% partial spatial coherence screen parameters
N=100;              %number of screens (even)
Lcr=8e-3;           %spatial correlation length
sigma_f=2.5*Lcr;    %Gaussian filter parameter    
sigma_r=sqrt(4*pi*sigma_f^4/Lcr^2); %random std

dfx1=1/L1;
fx1=-1/(2*dx1):dfx1:1/(2*dx1)-dfx1;
fx1=fftshift(fx1);
[FX1,FY1]=meshgrid(fx1,fx1);

% source field
u1=circ(sqrt((X1-dels/2).^2+Y1.^2)/w)...
    +circ(sqrt((X1+dels/2).^2+Y1.^2)/w);
% filter spectrum
F=exp(-pi^2*sigma_f^2*(FX1.^2+FY1.^2));

% loop through screens
I2=zeros(M);
for n=1:N/2
   % make 2 random screens
   fie=(ifft2(F.*(randn(M)+j*randn(M)))...
       *sigma_r/dfx1)*M^2*dfx1^2;
   % Fraunhofer pattern applying screen 1
   u2=1/lf*(fft2(u1.*exp(j*real(fie))))*dx1^2; 
   I2=I2+abs(u2).^2;
   % Fraunhofer pattern applying screen 2
   u2=1/lf*(fft2(u1.*exp(j*imag(fie))))*dx1^2; 
   I2=I2+abs(u2).^2;
end

I2=ifftshift(I2)/N;    %normalize & center irradiance
x2=(-1/(2*dx1):1/L1:1/(2*dx1)-1/L1)*lf; %obs coords
y2=x2;

figure(1)              %irradiance image
imagesc(x2,y2,I2);
xlabel('x (m)'); ylabel('y (m)'); 
axis square; axis xy;
colormap('gray');

figure(2)              %irradiance slice
plot(x2,I2(M/2+1,:));
xlabel('x (m)'); ylabel('Irradiance');

%power check
p1=sum(sum(abs(u1).^2))*dx1^2
p2=sum(sum(I2))*(1/L1*lf)^2

%analytic result
mu=exp(-dels^2/Lcr^2)
I2ax=2/lf^2*(w^2*jinc(w*x2/lf)).^2.*(1+mu*cos(2*pi*dels*x2/lf));
figure(3)
plot(x2,I2(M/2+1,:),x2,I2ax,'.');
xlabel('x (m)'); ylabel('Irradiance');
