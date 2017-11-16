classdef RecoverHiResImage < handle
    properties
        h_axes1;
        h_axes2;
        h_image1;
        h_image2;
        count = 0;
        run = false;
        simulation = true;
        LedArray;
        Camera;    
        pupilRadius = 20;
%         dkx;
%         dky;
        seq
        kxc;
        kyc;
        h_pupil;
        imSeqLowRes;
        objectRecoverFT;
        
        fu;  % fourier space freq coord for each pixel
        fv;

    end
    
    methods
        % Constructor
        function this = RecoverHiResImage(gaxis1, gaxis2)
            global h_RecoverHiResImage
            h_RecoverHiResImage = this;
            this.LedArray = simu.LedArray();  
            this.Camera = simu.Camera();
            m = this.Camera.m;
            n = this.Camera.n;
            % see Computation Fourier Optics p122
            L = this.Camera.L;
            du = this.Camera.psize; 
            % fourier space freq coord for each pixel
            fu = 2*pi*(-1/(2*du):1/L:1/(2*du)-(1/L));   
            fv= fu; 
            
            this.h_axes1 = gaxis1; 
            this.h_axes2 = gaxis2; 
            img1 = zeros([m,n]);
            img2 = zeros([m,n]);
            this.pupilRadius = this.Camera.cutoffFrequency; 
            axes(this.h_axes1); this.h_image1 = imshow(img1,[]); axis image; colormap gray;
%             axes(this.h_axes2); this.h_image2 = imshow(img2,[]); axis image; colormap gray;
            axes(this.h_axes2); this.h_image2 = imagesc(fu, fv, img2); axis image; colormap gray;
            
%             this.h_pupil = viscircles(round([m,n]/2), this.pupilRadius, 'LineWidth',1);
            % set function to call on mouse click
%             set(gcf, 'WindowButtonDownFcn', @RecoverHiResImage.getMousePositionOnImage);
% %             set(this.h_axes2,'ButtonDownFcn',@RecoverHiResImage.getMousePositionOnImage);

        end
        
        function Start(this)
            this.run = true;
            if this.simulation == false 
                return
            end
            InitialiseFP(this)
            
%              return  % for now
            loop = 1;
            for tt=1:loop
%                 for i3=1:3^2;
                for i3=1:this.LedArray.arraysize^2;
                    i2=this.seq(i3);
                    disp(['Image/led #: ', num2str(i2)]);

                    processFPImage(this, i2);
%                     opts.pupilRadius = round((Cam.m1-1)/2);
                    txt =  sprintf('Iter %d; Image %d',tt, i3);
                    plotReconstructedObject(this, [this.kyc(i2) this.kxc(i2)], txt);
                    pause (0.01)
                    if this.run == false
                        break;
                    end
                end
            end
        end
        
        function InitialiseFP(this)
            opts.display = 'iter';%'full';%'iter';
            opts.pupilRadius = this.pupilRadius;
            Leds = this.LedArray;
            Cam = this.Camera;
            
            % initial guess of the object
            objectRecover = ones(Cam.m,Cam.n);                     % spatial domain
            this.objectRecoverFT = fftshift(fft2(objectRecover));  % fourier domain
            this.seq = tools.gseq(Leds.arraysize);   % define the order of recovery, we start from the center (113'th image) to the edge of the spectrum (the 255'th image)
            pupil = 1;
            dkx = 2*pi/Cam.L;
            dky = 2*pi/Cam.L;

            loop = 1;
            this.kxc = round((Cam.n+1)/2+Leds.kx./dkx);
            this.kyc = round((Cam.m+1)/2+Leds.ky./dky);
            plotReconstructedObject(this, [this.kyc(this.seq(1)) this.kxc(this.seq(1))], '');
        end
       
        function processFPImage(this,i2)
            Cam = this.Camera;
            cx = this.kxc(i2);
            cy = this.kyc(i2);
            
            kyl = round(cy-(Cam.m1-1)/2); kyh = round(cy+(Cam.m1-1)/2);
            kxl = round(cx-(Cam.n1-1)/2); kxh = round(cx+(Cam.n1-1)/2);
            % low-res estimate (complex) from filtered hi-res estimate
            lowResFT = (Cam.m1/Cam.m)^2 * this.objectRecoverFT(kyl:kyh,kxl:kxh) .* Cam.CTF .*Cam.pupil;
            im_lowRes = ifft2(ifftshift(lowResFT));  
            % -> low res hybrid - replace low res estimate amplitude 
            %      part with actual measurment
            im_lowRes = (Cam.m/Cam.m1)^2 * ...
                             this.imSeqLowRes(:,:,i2).*exp(1i.*angle(im_lowRes));
            % low-res fourier from low-res hybrid             
            lowResFT=fftshift(fft2(im_lowRes)).*Cam.CTF.*(1./Cam.pupil);
            % replace CTF circle part in hi-res fourier plane 
            this.objectRecoverFT(kyl:kyh,kxl:kxh)=...
                (1-Cam.CTF).*this.objectRecoverFT(kyl:kyh,kxl:kxh) + lowResFT;
            % (1-Cam.CTF) = square washer shape, lowResFT = circle shape
        end
        
        function Stop(this)
            if this.simulation == false 
                return
            end
            this.run = false;
        end
        
        function plotReconstructedObject(this, cen, txt)
            Ft = @(x) fftshift(fft2((x)));
            IFt = @(x) (ifft2(ifftshift(x)));

%             if strcmp(opts.display,'iter') && rem(m,1) == 0 
                axes(this.h_axes1);
                % Display reconstructed image amplitude from IFFT of recovered FT
                img = abs(IFt(this.objectRecoverFT));
                img = img./(max(max(img)));
                set(this.h_image1, 'CData', img); 
%                 set(this.h_image1, 'CData', mat2gray(abs(IFt(this.objectRecoverFT)))); 
                title(['HiRes Amplitude ', txt]);
                axes(this.h_axes2);
                %   Display phase angle of recovered FT  
                set(this.h_image2, 'CData', angle(this.objectRecoverFT));           
                title(['Fourier Phase Angle ', txt]);
                delete(this.h_pupil);
                % convert cen to frequency units
                cen = cen - this.Camera.m/2;
                % 2 pi radians / cycle,  this.Camera.pixelInc = 4 is resolution increase over low res
%                 cen = this.Camera.pixelInc * 2 * pi * cen / this.Camera.L; 
                cen =  2 * pi * cen / this.Camera.L; 
                this.h_pupil = viscircles([cen(2) cen(1)], this.pupilRadius, 'LineWidth',1);
                drawnow;
%             end
        end
        
        
%         function this.loadImages(this, loadFunction)
%             loadFunction();
%         end

        function ret = closestLED(this,A)
            B = [this.kxc; this.kyc]';
            % 2 pi radians / cycle
            A =  this.Camera.m/2 + this.Camera.L * A / (2 * pi); 

            %compute Euclidean distances:
            distances = sqrt(sum(bsxfun(@minus, B, A).^2,2));            
            ret = find(distances==min(distances));
        end
        
%         function getMousePositionOnImage(src, event)
%             global h_RecoverHiResImage   % not the best implementation no doubt
%             this = h_RecoverHiResImage;
%             cursorPoint = get(this.h_axes2, 'CurrentPoint');
% 
%             curX = cursorPoint(1,1);
%             curY = cursorPoint(1,2);
% 
%             xLimits = get(this.h_axes2, 'xlim');
%             yLimits = get(this.h_axes2, 'ylim');
% 
%             if (curX > min(xLimits) && curX < max(xLimits) && curY > min(yLimits) && curY < max(yLimits))
%                 disp(['Cursor coordinates are (' num2str(curX) ', ' num2str(curY) ').']);
%                 if (curX > min(xLimits) && curX < max(xLimits) && curY > min(yLimits) && curY < max(yLimits))
%                     ledn = closestLED(this,[curX,curY]);
%                     disp(ledn);
% 
%                     processFPImage(this, ledn);
%                     txt =  sprintf('Image %d', ledn);
%                     plotReconstructedObject(this, [this.kyc(ledn) this.kxc(ledn)], txt);
%                 
%                 
%                 end
%             else
%                 disp('Cursor is outside bounds of image.');
%             end
%         end

    end
end


%             for tt=1:loop
%                 for i3=1:Leds.arraysize^2;
%                     i2=seq(i3);
%                     processFPImage(i2);
%                     kxc = round((Cam.n+1)/2+kx(1,i2)/dkx);
%                     kyc = round((Cam.m+1)/2+ky(1,i2)/dky);
%                     kyl = round(kyc-(Cam.m1-1)/2); kyh = round(kyc+(Cam.m1-1)/2);
%                     kxl = round(kxc-(Cam.n1-1)/2); kxh = round(kxc+(Cam.n1-1)/2);
%                     lowResFT = (Cam.m1/Cam.m)^2 * objectRecoverFT(kyl:kyh,kxl:kxh) .* Cam.CTF .*Cam.pupil;
%                     im_lowRes = IFt(lowResFT);
%                     im_lowRes = (Cam.m/Cam.m1)^2 * ...
%                                      imSeqLowRes(:,:,i2).*exp(1i.*angle(im_lowRes));
%                     lowResFT=Ft(im_lowRes).*Cam.CTF.*(1./Cam.pupil);
%                     objectRecoverFT(kyl:kyh,kxl:kxh)=...
%                                     (1-Cam.CTF).*objectRecoverFT(kyl:kyh,kxl:kxh) + lowResFT;
%                     opts.pupilRadius = round((Cam.m1-1)/2);
%                     plotReconstructedObject(this, objectRecoverFT, tt, i3, [kyc kxc], opts);
%                     pause (0.01)
%                     if this.run == false
%                         break;
%                     end
%                 end
%             end