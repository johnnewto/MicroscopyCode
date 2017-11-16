

function capture25Images()
    global cam img ser; 
    camType = 'color';

    setuEyeCam(camType); 
%     if strcmp(camType, 'mono')
%         cam.Timing.Exposure.Set(0); % 0 means set to 1/frame rate.
%         cam.Timing.Framerate.Set(16.77);
%     elseif strcmp(camType, 'color')
%         cam.Size.AOI.Set(960, 680, 1920, 1374); % 1/4 area
%         cam.Timing.Exposure.Set(100); % 500ms
%         cam.Timing.Framerate.Set(0);% 0 means set to max frame rate.
%     end
     if strcmp(camType, 'mono') || strcmp(camType, 'color')
         [ErrChk, val] = cam.Timing.Framerate.Get
         [~, val] = cam.Timing.Exposure.Get
         [~, val] = cam.Size.AOI.Get;
     end

    if isempty(ser)
        ser = serial('COM4');
%     else
%         fclose(ser);
%         ser = ser(1)
    end
    
    if strcmp(camType, 'mono') || strcmp(camType, 'color')
        %   Acquire image
        if ~strcmp(char(cam.Acquisition.Freeze(uEye.Defines.DeviceParameter.Wait)), 'SUCCESS')
            error('Could not acquire image');
        end
        data = uint8(zeros(img.Height, img.Width));
        h = imshow(data);axis image;
    end
    %   Acquire images 5 x 5 
    file = 1;
    for col=-2:1:2
    for row=-2:1:2
        lastLedOff();
        ledOnXY(row, col, [7 0 0]);
        if strcmp(camType, 'mono') || strcmp(camType, 'color')
            acc = single(zeros(img.Height, img.Width));
            len = 10;
            for i = 1:len
                %   Acquire image
                cam.Acquisition.Freeze(uEye.Defines.DeviceParameter.Wait);
                [~, tmp] = cam.Memory.CopyToArray(img.ID, uEye.Defines.ColorMode.RGB8Packed);  %   Extract image
                % size = img.Width * img.Height * img.Bits/8
                data = reshape(uint8(tmp), [img.Bits/8, img.Width, img.Height]); 
                data = permute(data,[3 2 1]);
                acc = acc + single(data(:,:,1));  % get red only
            end
            acc = uint8(acc/len);
            filename = sprintf('capture_%02d.tif', file);
            % filename = ['capture_', num2str(file),'.png'];
            filepath =['C:\Users\John\Desktop\FPM\',filename];
            imwrite(acc, filepath);
            file = file + 1;
            set(h, 'CData', acc); %   Draw image
            figure(2)
            imshow(acc);axis image;
            drawnow;
        else
            pause(0.5)
        end
%         pause(0.1);
    end
    end
    
    if strcmp(camType, 'mono') || strcmp(camType, 'color')
  
        if ~strcmp(char(cam.Exit), 'SUCCESS')  %   Close camera
            error('Could not close camera');
        end
    end
    % Disconnect from the serial port.
%     fclose(ser);
    % Clean up all objects.
%     ser = [];
    
end
