function camera = setBaslerCam()     
   % parentpath = cd(cd('..\..\..\..'));
   % globals  for the camera frame grab event
    global g_onFrameEvtData; 
    try
        % is there an existing global camera open?
        g_onFrameEvtData.cam_h.BaslerCamStop();   % this should close existing camera
    catch
        disp('No camera to stop')
    end
 
   
    file = [cd, '\+oper\BaslerMatlab.dll'];
    asmInfo = NET.addAssembly(file);
    camera = BaslerMatlab.BaslerCam;
    g_onFrameEvtData.cam_h = camera;
end
 