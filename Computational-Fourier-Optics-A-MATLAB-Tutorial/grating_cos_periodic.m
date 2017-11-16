% grating_cos diffraction grating example (periodic)

lambda=0.5e-6;  %wavelength
f=0.5;          %propagation distance
P=1e-4;         %grating period
D1=1e-2;     %grating side length

L1=1e-2;        %array side length
M=500;          %# samples
dx1=L1/M;
x1=-L1/2:dx1:L1/2-dx1; %source coords
[X1,Y1]=meshgrid(x1,x1);

% Grating field and irradiance
u1=1/2*(1-cos(2*pi*X1/P)).*rect(X1/D1).*rect(Y1/D1);

I1=abs(u1).^2;
figure(1)
imagesc(x1,x1,I1);
colormap gray
axis square; axis xy;
xlabel('x (m)'); ylabel('y (m)');

% Fraunhofer pattern
[u2,L2]=propFF(u1,L1,lambda,f);
dx2=L2/M;
x2=-L2/2:dx2:L2/2-dx2; y2=x2;%obs coords
I2=abs(u2).^2;

figure(2)
imagesc(x2,y2,nthroot(I2,3));
colormap gray
axis square; axis xy;
xlabel('x (m)'); ylabel('y (m)');

figure(3);
plot(x2,I2(M/2+1,:));
xlabel('x (m)'); ylabel('Irradiance');

%analytic
[X2,Y2]=meshgrid(x2,y2);
lf=lambda*f;
u2a=(1/lf)*D1^2/2*sinc(D1/lf*Y2)...
    .*(sinc(D1/lf*X2)-1/2*sinc(D1/lf*(X2+lf/P))...
    -1/2*sinc(D1/lf*(X2-lf/P)));
I2a=abs(u2a).^2;

figure(4);
plot(x2,I2(M/2+1,:),x2,I2a(M/2+1,:),'.');
legend('digital','analytic');

% fractional power plot
Fpwr=I2*dx2*dx2/(L1^2);
figure(5);
plot(x2,Fpwr(M/2+1,:));
xlabel('x (m)'); ylabel('Fractional Power');