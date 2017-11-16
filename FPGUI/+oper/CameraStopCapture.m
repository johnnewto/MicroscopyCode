function CameraStopCapture(this)
%     if this.simulation == true 
%         return
%     end
    if ~isprop(this, 'gui_h')
        disp('Error: Cant stop camera: Object must have property: .gui_h') 
        return
    end

    try
        if ~isempty(this.BaslerCam)
            this.BaslerCam.BaslerCamStop();
            this.BaslerCam.BaslerCamClose();

            delete(this.camListener);
            this.BaslerCam = [];
        end
    catch e
        disp('IN CameraStopCapture(this, src, event)');
        disp(e);
    end
%     set(this.gui_h.pbStopCapture, 'Enable', 'Off');
%     set(this.gui_h.pbStartCapture, 'Enable', 'On');
end
