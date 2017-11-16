function [ psi] = Proj_Fourier_v2( psi0, I, I0, c, F )
%PROJ_FOURIER projection based on intensity measurement in the fourier
%domain, replacing the amplitude of the Fourier transform by measured
%amplitude, sqrt(I)
% last modified by Lei Tian, lei_tian@alum.mit.edu, 3/1/2014


[n1,n2,r] = size(psi0);

if r == 1
    psi = F(sqrt(I/c).*psi0./(sqrt(I0)+eps));
else
    psi = zeros(n1,n2,r);
    for m = 1:r
        psi(:,:,m) = F(sqrt(I/c(m)).*psi0(:,:,m)./sqrt(I0+eps));
    end
end

if(0) 
    %%
    f1 = figure(99);
    subplot(221); imagesc(abs(psi0)); axis image; colormap gray;
    title('abs(psi0)');
    subplot(222); imagesc(abs(psi)); axis image; colormap gray;
    title('abs(psi)');
    subplot(223); imagesc(abs(I)); axis image; colormap gray;
    title('abs(I)');
    subplot(224); imagesc(abs(I0)); axis image;
    title('abs(I0)');
    drawnow;
end
end

