function setuEyeCam(camType)
    global cam img; 
    if ~strcmp(camType, 'mono') && ~strcmp(camType, 'color')
        return;
    end 
        
    %   Add NET assembly if it does not exist
    %   May need to change specific location of library
    asm = System.AppDomain.CurrentDomain.GetAssemblies;
    if ~any(arrayfun(@(n) strncmpi(char(asm.Get(n-1).FullName), ...
            'uEyeDotNet', length('uEyeDotNet')), 1:asm.Length))
        NET.addAssembly(...
            'C:\Program Files\IDS\uEye\Develop\DotNet\signed\uEyeDotNet.dll');
    end
    %   Create camera object handle
    if isempty(cam)
        cam = uEye.Camera;
    else
        cam.Exit();
    end
    %  Open 1st available camera
    %  Returns if unsuccessful
    if ~strcmp(char(cam.Init), 'SUCCESS') && ~strcmp(char(cam.Init), 'CaptureStatus')
        error('Could not initialize camera');
    end
    
    %  Set display mode to bitmap (DiB)
    if ~strcmp(char(cam.Display.Mode.Set(uEye.Defines.DisplayMode.DiB)), ...
            'SUCCESS')
        error('Could not set display mode');
    end
    
    %   Set the pixel clock to 10 MHz
    if ~strcmp(char(cam.Timing.PixelClock.Set(15)), 'SUCCESS')
        error('Could not set pixel clock');
    end

    %   Set colormode to 8-bit RAW
    if strcmp(camType, 'mono')
        cam.PixelFormat.Set(uEye.Defines.ColorMode.SensorRaw8);
        cam.Timing.Exposure.Set(0); % 0 means set to 1/frame rate.
        cam.Timing.Framerate.Set(16.77);
    else
        PixelFormat = uEye.Defines.ColorMode.RGB8Packed;
        cam.PixelFormat.Set(uEye.Defines.ColorMode.RGB8Packed);
        cam.Size.AOI.Set(960, 680, 1920, 1374); % 1/4 area
        cam.Timing.Exposure.Set(50); % 500ms
        cam.Timing.Framerate.Set(0);% 0 means set to max frame rate.   
        cam.AutoFeatures.Software.Gain.Enabled = 1;
    end
    
    %   Set trigger mode to software (single image acquisition)
    if ~strcmp(char(cam.Trigger.Set(uEye.Defines.TriggerMode.Software)), 'SUCCESS')
        error('Could not set trigger format');
    end
   
    
    [ErrChk, img.ID] = cam.Memory.Allocate(true);
    if ~strcmp(char(ErrChk), 'SUCCESS')
        error('Could not allocate memory');
    end
    if strcmp(camType, 'mono') || strcmp(camType, 'color')
        [ErrChk, val] = cam.Timing.Framerate.Get
        [~, val] = cam.Timing.Exposure.Get
        [~, val] = cam.Size.AOI.Get;
        [ErrChk, img.Width, img.Height, img.Bits, img.Pitch] ...
        = cam.Memory.Inquire(img.ID);
    end


    
%     if ~strcmp(char(cam.Acquisition.Freeze(true)), 'SUCCESS')
%         error('Could not acquire image');
%     end
%     
%     [ErrChk, tmp] = cam.Memory.CopyToArray(img.ID); 
%     if ~strcmp(char(ErrChk), 'SUCCESS')
%         error('Could not obtain image data');
%     end
%     
%     img.Data = reshape(uint8(tmp), [img.Width, img.Height, img.Bits/8]);
%     
%     img.himg = imshow(img.Data');axis image;

end