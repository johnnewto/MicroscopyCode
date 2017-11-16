classdef CaptureLowResImages < simu.GenerateLowResImages
    properties
        GrabbedImageCount = 0;
        GrabbedImageSum = 1;
        BaslerCam
        camListener
        gui_h



    end
%     events
%         evtImageGrabbed
%     end
    
    methods
        % Constructor
        function this = CaptureLowResImages(varargin)
            this = this@simu.GenerateLowResImages(varargin{1:4});
            this.gui_h = this.h_parent.gui_h;   % GUI in which  where camera displays images
            
            this.image = double(zeros(this.Camera.m1, this.Camera.n1));  % need fixing JN
            % path to low res files,
            % use Camera folder rather than Simulated folder
            this.pathname =  strrep(this.pathname,'Simulated','Camera');            
        end
        
        function Start(this)
            global g_onFrameEvtData
            global SerialPortObj

            g_onFrameEvtData.obj = this;
            
            Leds = this.LedArray;
            this.seq = tools.gseq(Leds.arraysize);   % define the order of recovery, we start from the center (113'th image) to the edge of the spectrum (the 255'th image)

            tt = 1;
            SerialPortObj.SetLED( tt);
            this.h_parent.WriteText( ['Led: ', num2str(tt, 3)]);
            
            oper.CameraStartCapture(this.h_parent);
            this.run = true;
            this.GrabbedImageCount = 0;

            while  tt  <= Leds.arraysize^2
                if this.GrabbedImageCount >= 2
%                 if this.GrabbedImageCount >= this.GrabbedImageSum
                    try
                        this.imSeqLowRes(:,:,tt) = this.image;
                        SerialPortObj.SetLED(tt+1);
                        
                        this.h_parent.WriteText( ['Grabbed Led: ', num2str(tt, 3)]);

                        set(this.h_parent.gui_h.imagePlot, 'CData', this.image); %   Draw image
                        this.image = double(zeros(this.Camera.m/4, this.Camera.n/4));  % need fixing JN
                        
                        tt = tt + 1;
                        this.GrabbedImageCount = 0;
                        
%                         figure(2)
%                         histogram(this.image)
                        
                    catch e
                        disp('Error in Capure Low res images')
                        disp(e)
                    end
                end

%                 set(this.h_imagePlot, 'CData', this.imSeqLowRes(:,:,tt)); %   Draw image
                drawnow
                pause (0.05)
                this.h_parent.WriteText( ['Led: ', num2str(tt, 3)]);                

                if this.run == false
                    break;
                end
                
            end
            oper.CameraStopCapture(this.h_parent); 
             
        end
        

        
        function OnImageGrab(this, img)
%             disp('got image')
            this.GrabbedImageCount = this.GrabbedImageCount + 1;
            this.image = img;
            
%             if this.GrabbedImageCount > 10
%                 set(this.h_parent.gui_h.imagePlot, 'CData', this.image); %   Draw image
%                 this.image = double(zeros(this.Camera.m*2, this.Camera.n*2));  % need fixing JN
%                 this.GrabbedImageCount = 0;
%             end


        end

        
        
    end
end
