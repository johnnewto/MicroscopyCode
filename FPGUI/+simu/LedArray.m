classdef LedArray < handle
    properties
        arraysize = 5;  % must be odd
        LEDgap = 3.25; % distance between adjacent LEDs (6mm)
        LEDheight = 130; % 130 mm between LED matrix and the sample
        waveLength 
%         waveLength = 0.53e-6;
        xlocation
        ylocation
        kx_relative
        ky_relative
        kx
        ky
        LedGapError;
    end
    
    methods
        % Constructor
        function this = LedArray()
            this.waveLength = simu.constants().waveLength;
            setLedPositions(this,0)
        end
        
        function this = setLedPositions(this,gapError)
            this.LedGapError = gapError;
            k0 = 2*pi/this.waveLength;
            this.xlocation = zeros(1,this.arraysize^2);
            this.ylocation = zeros(1,this.arraysize^2);

            for i=1:this.arraysize  % from top left to bottom right
                this.xlocation(1,1+this.arraysize*(i-1):this.arraysize+this.arraysize*(i-1))...   % Jn see changes here
                    =(-(this.arraysize-1)/2:1:(this.arraysize-1)/2)*this.LEDgap;
                this.ylocation(1,1+this.arraysize*(i-1):this.arraysize+this.arraysize*(i-1))...
                    =((this.arraysize-1)/2-(i-1))*this.LEDgap;
            end
            this.xlocation = this.xlocation + this.LEDgap*gapError*(rand(size(this.xlocation))-0.5);
            this.ylocation = this.ylocation + this.LEDgap*gapError*(rand(size(this.ylocation))-0.5);
            
            this.kx_relative = -sin(atan(this.xlocation/this.LEDheight));  % create kx, ky wavevectors
            this.ky_relative = -sin(atan(this.ylocation/this.LEDheight)); 
            
            this.kx = k0 * this.kx_relative;
            this.ky = k0 * this.ky_relative;
            
        end
        
    end
end
