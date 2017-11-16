function runCam()
    global cam img; 
    setuEyeCam();
    cam.Timing.Framerate.Set(5);
    [ErrChk, val] = cam.Timing.Framerate.Get
    cam.Timing.Exposure.Set(200);
    [ErrChk, val] = cam.Timing.Exposure.Get
    %   Acquire & draw 100 times
    for n=1:10
        %   Acquire image
        if ~strcmp(char(cam.Acquisition.Freeze(true)), 'SUCCESS')
            error('Could not acquire image');
        end
          
        [ErrChk, tmp] = cam.Memory.CopyToArray(img.ID);  %   Extract image
        if ~strcmp(char(ErrChk), 'SUCCESS')
          error('Could not obtain image data');
        end

        img.Data = reshape(uint8(tmp), [img.Width, img.Height, img.Bits/8])';

        set(img.himg, 'CData', img.Data); %   Draw image
        drawnow;
    end
    
    if ~strcmp(char(cam.Exit), 'SUCCESS')  %   Close camera
        error('Could not close camera');
    end
end