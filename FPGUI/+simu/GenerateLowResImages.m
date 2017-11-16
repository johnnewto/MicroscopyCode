classdef GenerateLowResImages < handle
    properties
        h_parent;       % parent class
        h_axes1;
        h_axes2;
        h_image1;  % handle of the image data
        h_image2;  % handle of the image data
        image;
        run = false;
        simulation = true;       
        imSeqLowRes
        LedArray;
        Camera;   
        seq;
        pixelNoise = 0;
        
        fileNameformat = 'LowRes#%d.png'
        pathname; % path to low res files
    end
    
    methods
        %% Constructor
        function this = GenerateLowResImages(parent, img, gaxis1, gaxis2)
            global h_GenerateLowResImages
            h_GenerateLowResImages = this;
            this.h_parent = parent;
            this.LedArray = simu.LedArray();
            this.Camera = simu.Camera();

            this.h_axes1 = gaxis1; 
            this.h_axes2 = gaxis2; 
            
            Cam = this.Camera;
            axes(gaxis1);  % low res
%             this.h_image1 = imshow(zeros(Cam.m1, Cam.n1));axis image;
            this.h_image1 = imagesc(Cam.u, Cam.v, zeros(Cam.m1, Cam.n1));axis image;
%             axes(this.h_axes2); this.h_image2 = imagesc(fu, fv, img2); axis image; colormap gray;
            
            axes(gaxis2);   % hi Res
%             this.image = mat2gray(img);   % needs Image processing library
            this.image = img./ (max(max(img)));
            assert(max(max(this.image))<=1, 'needs to be 1 or less');
            this.h_image2 = imshow(this.image); axis image;
            
            % path to low res files
%             path = cd(cd('..'));    % parent path
             path = userpath;
            this.pathname =  fullfile(strrep(path,';',''),'FPImages');
            try
            [status, msg, msgID] = mkdir (this.pathname);
            catch
                disp('Error:')
            end
            disp(['Creating directory ', this.pathname])
            
            this.CheckParameters()
 

        end
        
        function CheckParameters(this)
            this.WriteText('checking Parameters');
            this.WriteText(sprintf('Wavelength: %d', this.LedArray.waveLength));
            this.WriteText(this.LedArray)
            this.WriteText(this.Camera)
            coherentResolution = this.LedArray.waveLength/this.Camera.NA
            magnification = 2*1/2;   % objective barrow lens
            maxpixelsize = magnification * coherentResolution/2
            
            
        end

        function WriteText(this, x)
            try
                this.h_parent.WriteText(x);
            catch
                disp(x)
            end
        end

  %%      
        function Start(this)
            this.run = true;
 
            if this.simulation == false 
                return
            end
            Leds = this.LedArray;
            Cam = this.Camera;

            Ft = @(x) fftshift(fft2((x)));
            IFt = @(x) (ifft2(ifftshift(x)));
%              objectAmpitude = double(imread('cameraman.tif'));
            objectAmpitude = this.image;
            objectAmpitude = imresize(objectAmpitude,[Cam.m,Cam.n]);
%             phase = double(imread('westconcordorthophoto.png'));
%             phase = pi*imresize(phase,[256,256])./max(max(phase));
            phase = zeros([Cam.m,Cam.n]);

            object = objectAmpitude.*exp(1i.*phase);

            %% generate the low-pass filtered images
%             img = zeros(Cam.m1, Cam.n1);
%             axes(this.h_axes1);
%             if isfield(this, 'h_imagePlot') && isvalid(this.h_imagePlot)
%                set(this.h_imagePlot, 'CData', img); %   Draw image
%             else
%                 this.h_imagePlot = imshow(img);axis image;
%             end
            k0 = 2*pi/Leds.waveLength;
            this.imSeqLowRes = zeros(Cam.m1, Cam.n1, Leds.arraysize^2); % output low-res image sequence
            kx = k0 * Leds.kx_relative;
            ky = k0 * Leds.ky_relative;
            dkx = 2*pi/(Cam.psize*Cam.n);
            dky = 2*pi/(Cam.psize*Cam.m);

            objectFT = fftshift(fft2(object));
            this.seq = tools.gseq(Leds.arraysize);   % define the order of recovery, we start from the center (113'th image) to the edge of the spectrum (the 255'th image)

            for tt = 1:Leds.arraysize^2
                kxc = round((Cam.n+1)/2+kx(1,tt)/dkx);
                kyc = round((Cam.m+1)/2+ky(1,tt)/dky);
                kyl = round(kyc-(Cam.m1-1)/2); kyh = round(kyc+(Cam.m1-1)/2);
                kxl = round(kxc-(Cam.n1-1)/2); kxh = round(kxc+(Cam.n1-1)/2);
                imSeqLowFT = (Cam.m1/Cam.m)^2 * objectFT(kyl:kyh,kxl:kxh).*Cam.CTF_withaberration;
                this.imSeqLowRes(:,:,tt) = abs(ifft2(ifftshift(imSeqLowFT)));               
                this.imSeqLowRes(:,:,tt) = addNoise(this, tt);
                plotLowRes(this,tt)
%                 set(this.h_imagePlot, 'CData', this.imSeqLowRes(:,:,tt)); %   Draw image
                drawnow
                pause (0.01)
                if this.run == false
                    break;
                end
                
            end
          
            plotLowRes(this,this.seq(1)); %   Draw image
             
        end
        
        function SaveToFile(this, filename)
             path =  fullfile(this.pathname, filename);             
 
            % Normalise it to 0 to 1
            % convert to 16 bit for png file
            this.imSeqLowRes = this.imSeqLowRes./ (max(max(this.imSeqLowRes)));
            this.imSeqLowRes = uint16(this.imSeqLowRes*(2^16-1));
%             this.image = mat2gray(img);   % needs Image processing library

            for tt=1:size(this.imSeqLowRes,3)
                filename = fullfile( path, sprintf(this.fileNameformat,tt));
                imwrite(this.imSeqLowRes(:,:,tt), filename );
            end
        end
        
        function ret = loadImages(this, filename)
            try
                path =  fullfile(this.pathname, filename);             
                for tt = 1:this.LedArray.arraysize^2
                    filename = fullfile( path, sprintf(this.fileNameformat,tt));
                    this.imSeqLowRes(:,:,tt) = imread(filename);
                end
%                  this.imSeqLowRes = mat2gray(this.imSeqLowRes);
                ret = this.imSeqLowRes;
            catch e
                disp(['Error reading Low Res Images from ' this.pathname])
                ret = [];
            end
        end


        function plotLowRes(this,ledn)
%             a = mat2gray(this.imSeqLowRes(:,:,ledn));
            a = (this.imSeqLowRes(:,:,ledn));
            try
            set(this.h_image1, 'CData', a); %   Draw image
            catch
                disp('ERROR: plotLowRes(this,ledn)')
            end
%             showHistogram(this, a)
        end
        
        function ret = addNoise(this,tt)
%             SNR = 10log10[var(image)/var(noise)]
%             var(noise) = var(image) / 10^(SNR/10)
            I = this.imSeqLowRes(:,:,tt);
            ret = I + this.pixelNoise*rand(size(I));
%             v = var(I(:)) / (10^(0/10));  % 0db SNR 
%             v = 0;
%             ret = imnoise(I, 'gaussian', 0, v);
%             ret = imnoise(this.imSeqLowRes(:,:,tt),'salt & pepper',0.02);
        end
        
        function showHistogram(this, img)
         	figure(2)
         	histogram(img, 'BinLimits', [0 1])
        end
        
        function Stop(this)
            if this.simulation == false 
                return
            end
            this.run = false;
        end
    end
end
