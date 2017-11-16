function plotReconstructedObject(O, iter, m, cen, opts)
    Ft = @(x) fftshift(fft2((x)));
    IFt = @(x) (ifft2(ifftshift(x)));

    if strcmp(opts.display,'iter') && rem(m,1) == 0 
        figure(77)

        txt =  sprintf('Iter %d; Image %d',iter, m);
%         fftshift(fft2(ifftshift(x)));
        subplot(121); imshow(abs(IFt(O)),[]); axis image; colormap gray;
        title(['ampl ', txt]);

        subplot(122); imshow(angle(O),[]); axis image; colormap gray; 
        title(['fourier phase ', txt]);
        radius = opts.pupilRadius;
        viscircles([cen(2) cen(1)], radius, 'LineWidth',1);
        drawnow;
    end
end