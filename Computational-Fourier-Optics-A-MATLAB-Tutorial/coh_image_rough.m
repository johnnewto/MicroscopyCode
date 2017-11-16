%  coh_image Coherent Imaging Example (rough object)

A=imread('USAF1951B250','png'); %read image file
[M,N]=size(A);         %get image sample size
A=flipud(A);           %reverse row order
Ig=single(A);          %integer to floating
Ig=Ig/max(max(Ig));    %normalize ideal image

ug=sqrt(Ig).*exp(j*2*pi*rand(M)); %ideal image
L=0.3e-3;              %image plane side length (m)
du=L/M;                %sample interval (m)
u=-L/2:du:L/2-du; v=u;

figure(1)              %check ideal image
imagesc(u,v,Ig);
colormap('gray');  xlabel('u (m)'); ylabel('v (m)');
axis square
axis xy
lambda=0.5*10^-6;      %wavelength
wxp=6.25e-3;           %exit pupil radius
zxp=125e-3;            %exit pupil distance
f0=wxp/(lambda*zxp);   %cutoff frequency

fu=-1/(2*du):1/L:1/(2*du)-(1/L); %freq coords
fv=fu;
[Fu,Fv]=meshgrid(fu,fv);
H=circ(sqrt(Fu.^2+Fv.^2)/f0);

figure(2)              %check H
surf(fu,fv,H.*.99)
camlight left; lighting phong
colormap('gray')
shading interp
ylabel('fu (cyc/m)'); xlabel('fv (cyc/m)');
H=fftshift(H);
Gg=fft2(fftshift(ug));
Gi=Gg.*H;
ui=ifftshift(ifft2(Gi));
Ii=(abs(ui)).^2;

figure(3)              %image result
imagesc(u,v,nthroot(Ii,2));
colormap('gray'); xlabel('u (m)'); ylabel('v (m)');
axis square
axis xy

figure(4)              %horizontal image slice
vvalue=-0.8e-4;       %select row (y value)
vindex=round(vvalue/du+(M/2+1)); %convert row index
plot(u,Ii(vindex,:),u,Ig(vindex,:),':');
xlabel('u (m)'); ylabel('Irradiance');
