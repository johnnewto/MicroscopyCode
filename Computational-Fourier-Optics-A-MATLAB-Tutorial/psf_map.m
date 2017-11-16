% psf_map generate psf map

M=250;
L=1e-3;                %image plane side length
du=L/M;                %sample interval
u=-L/2:du:L/2-du; v=u; %coordinates

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

fu=-1/(2*du):1/L:1/(2*du)-(1/L); %image freq coords
fu=fftshift(fu); %shift cords, avoid shift H in loop
[Fu,Fv]=meshgrid(fu,fu);

I=zeros(M);
% loop through image plane positions
for u0=[-.7:.7/3:.7]
    for v0=[-.7:.7/3:.7]
        % wavefront
        W=seidel_5(u0,v0,-2*lambda*fnum*Fu...
            ,-2*lambda*fnum*Fv,...
            wd,w040,w131,w222,w220,w311);
        % coherent transfer function
        H=circ(sqrt(Fu.^2+Fv.^2)*2*lambda*fnum)...
            .*exp(-j*k*W);
        % PSF
        h2=abs(ifftshift(ifft2(H))).^2;
        % shift PSF to image plane position
        h2=circshift(h2,[round(v0*M/2)...
            ,round(u0*M/2)]);
        % add into combined frame
        I=I+h2;
    end
end

figure(1)
imagesc(u,v,nthroot(I,2));
xlabel('u (m)'); ylabel('v (m)');
colormap('gray'); axis square; axis xy
