function onFrameEvent(~,eventdata)
%     disp ('hello')    
    global g_onFrameEvtData ; 
    try
        tmp = eventdata.Buffer.uint8;
        width  = g_onFrameEvtData.cam_h.Width;
        height = g_onFrameEvtData.cam_h.Height;

        if length(tmp) == width * height
            % mono BaslerCam
            g_onFrameEvtData.currentImage = reshape(uint8(tmp), [g_onFrameEvtData.cam_h.Width, g_onFrameEvtData.cam_h.Height]); 
            g_onFrameEvtData.currentImage = permute(g_onFrameEvtData.currentImage,[2 1]);
        else
            % color BaslerCam
            g_onFrameEvtData.currentImage = reshape(uint8(tmp), [3, g_onFrameEvtData.cam_h.Width, g_onFrameEvtData.cam_h.Height]); 
            g_onFrameEvtData.currentImage = permute(g_onFrameEvtData.currentImage,[3 2 1]);
        end
        % Draw the BaslerCam image
        if ismethod (g_onFrameEvtData.obj,'OnImageGrab')
            g_onFrameEvtData.obj.OnImageGrab(g_onFrameEvtData.currentImage)
        end
%         if isprop(g_onFrameEvtData.gui_h.imagePlot)
%             set(g_onFrameEvtData.gui_h.imagePlot, 'CData', g_onFrameEvtData.currentImage); %   Draw image
%         end
    catch
        disp('onFrameEvent Error')
    end


end