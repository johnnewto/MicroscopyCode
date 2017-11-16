function runCam()
    global cam img; 
    camType = 'color';
    setuEyeCam(camType);
    data = uint8(zeros(img.Height, img.Width, img.Bits/8));
    h = imshow(data);axis image;

    %   Acquire & draw 100 times
    for n=1:40
        %   Acquire image
        if ~strcmp(char(cam.Acquisition.Freeze(true)), 'SUCCESS')
            error('Could not acquire image');
        end
          
        [ErrChk, tmp] = cam.Memory.CopyToArray(img.ID);  %   Extract image
        if ~strcmp(char(ErrChk), 'SUCCESS')
          error('Could not obtain image data');
        end
        data = reshape(uint8(tmp), [img.Bits/8, img.Width, img.Height]); 
        data = permute(data,[3 2 1]);

        if strcmp(camType, 'color')
            data = data(1:1374, 1:1920, :);    
        end

        set(h, 'CData', data); %   Draw image
        drawnow;
    end
    
    if ~strcmp(char(cam.Exit), 'SUCCESS')  %   Close camera
        error('Could not close camera');
    end
end