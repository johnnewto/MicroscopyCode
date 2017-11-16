classdef Camera < handle
    properties
%         spsize = 2.2e-6; % sampling pixel size of the CCD
%         spsize = 1.67e-6; % effective sampling pixel size of the sensor at the image plane
        spsize = 2.9e-6; % effective sampling pixel size of the sensor at the image plane
        psize ; % final pixel size of the reconstruction
        NA = 0.05;
        % image size of the hi resolution object
        m = 256*4;    % Row
        n = 256*4;    % Col
        % image size of the low res camera output
        m1, n1; 
        pixelInc = 4;  % hi res / low res 
        CTF
        pupil
        CTF_withaberration
        waveLength
        cutoffFrequency
        
        L    % image plane side length (m)
        u;
        v;
        du;   % sampling or pixel size

    end
    
    methods
        % Constructor
        function this = Camera()
            this.waveLength = simu.constants().waveLength;
            k0 = 2*pi/this.waveLength;
            this.du = this.spsize;
            this.psize = this.spsize / this.pixelInc; % final pixel size of the reconstruction
            this.m1 = this.m/this.pixelInc;
            this.n1 = this.n/this.pixelInc; % image size of the camera output
            this.L  = this.psize * this.m;  % image side length  (m)
            this.u  = -this.L/2:this.du:this.L/2-this.du; 
            this.v = this.u; 
            
            %% Pupil
            this.cutoffFrequency = this.NA * k0;
            kmax = pi/this.spsize;
            [kxm, kym] = meshgrid(-kmax:kmax/((this.n1-1)/2):kmax, -kmax:kmax/((this.n1-1)/2):kmax);
            this.CTF = ((kxm.^2+kym.^2) < this.cutoffFrequency^2);   % coherent transfer function

            % defocus
            z = 0e-6;  kzm = sqrt(k0^2-kxm.^2-kym.^2);
            this.pupil = exp(1i.*z.*real(kzm)).*exp(-abs(z).*(imag(kzm)));
            this.CTF_withaberration = this.pupil.*this.CTF;

        end
    end
end
