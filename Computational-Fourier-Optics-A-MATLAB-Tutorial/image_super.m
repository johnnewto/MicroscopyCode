% image_super superposition image (version 2)

A=imread('USAF1951B250','png');
[M,N]=size(A); A=flipud(A);
Ig=single(A); Ig=Ig/max(max(Ig));

L=1e-3;                %image plane side length
du=L/M;                %sample interval
u=-L/2:du:L/2-du; v=u; %coordinates
fN=1/(2*du)            %Nyquist frequency

lambda=0.5*10^-6;      %wavelength
k=2*pi/lambda;         %wavenumber
wxp=2.5e-3;            %exit pupil radius
zxp=100e-3;            %exit pupil distance
fnum=zxp/(2*wxp)       %exit pupil f-number

twof0=1/(lambda*fnum)  %inc cutoff freq
fN=1/(2*du)            %Nyquist frequency

% aberration coefficients
wd=0*lambda;
w040=0.5*lambda;
w131=1*lambda;
w222=1.5*lambda;
w220=0*lambda;
w311=0*lambda;

% frequency coordinates
fu=-1/(2*du):1/L:1/(2*du)-(1/L);
fu=fftshift(fu); %shift cords, avoid shift H in loop
[Fu,Fv]=meshgrid(fu,fu);

I=zeros(M);
% loop through image plane positions
for n=1:M
    v0=(n-(M/2+1))/(M/2) %norm v image coord
    for m=1:M
        u0=(m-(M/2+1))/(M/2); %norm u image coord
        % wavefront
        W=seidel_5(u0,v0,-2*lambda*fnum*Fu,...
            -2*lambda*fnum*Fv,...
            wd,w040,w131,w222,w220,w311);
        % coherent transfer function
        H=circ(sqrt(Fu.^2+Fv.^2)*2*lambda*fnum)...
            .*exp(-j*k*W);
        % PSF - normalize PSF area to 1
        h2=abs(ifftshift(ifft2(H))).^2;
        h2=h2/(sum(sum(h2)));
        % shift h2 to image plane position
        h2=circshift(h2,[n-(M/2+1),m-(M/2+1)]);
        % superposition
        I=Ig(n,m)*h2+I;
    end
end

figure(1)
imagesc(u,v,nthroot(I,3));
colormap('gray'); axis square; axis xy
xlabel('x (m)'); ylabel('y (m)');
