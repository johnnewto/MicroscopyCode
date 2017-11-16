function CameraStartCapture(this)
%     if this.simulation == true 
%         return
%     end
    % globals  for the BaslerCam frame grab event
%     global g_onFrameEvtData
    if ~isprop(this, 'gui_h')
        disp('Error: Cant start camera: Object must have property: .gui_h') 
        return
    end
        
    try
        if ~isempty(this.BaslerCam )
            ME = MException('BaslerCam:Start', 'Maybe alreasy open');
            throw(ME)
        end
        this.BaslerCam = oper.setBaslerCam(); 
        cam = this.BaslerCam;
    %     centerX = cam.Height/2;
    %     centerY = cam.Width/2;
        cam.BinningHorizontal = 1;
        cam.BinningVertical = 1;
        centerX = 2592/2;
        centerY = 1944/2;   % JN fix this later as can change with camera binning etc
    %     cam.BaslerCam = 2 * this.HiResImage.Camera.m;
    %     cam.BaslerCam = 2 * this.HiResImage.Camera.n;
        cam.Width = 256;
        cam.Height = 256;

        cam.OffsetX = centerX - cam.Width /2;
        cam.OffsetY = centerY - cam.Height /2;
        cam.ExposureAuto = 'Off';
        cam.GainAuto = 'Off';
%         cam.ExposureTime = 500*1000;   % 500 millisec
        cam.Gain = 0;
        
        % this is where the frame events are sent
        this.camListener = addlistener(this.BaslerCam,'ImageGrabbedEvt',@oper.onFrameEvent);

        % set an image handle with the right size dimensions
        data = double(zeros(cam.Height, cam.Width,3));
        axes(this.gui_h.axes1);
        if isfield(this.gui_h, 'imagePlot') && isvalid(this.gui_h.imagePlot)
           set(this.gui_h.imagePlot, 'CData', data); %   Draw image
        else
            this.gui_h.imagePlot = imshow(data);axis image;
        end

        this.BaslerCam.BaslerCamStart(); 
    catch e
        disp('Error Stating BaslerCam');
        disp(e)
    end

    
end