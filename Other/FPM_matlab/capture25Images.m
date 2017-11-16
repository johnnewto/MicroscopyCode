

function capture25Images()
    global cam img ser; 
    useCam = 1;
    if useCam  
        setuEyeCam(); 
        cam.Timing.Exposure.Set(0); % 0 means set to 1/frame rate.
        cam.Timing.Framerate.Set(16.77);
        [ErrChk, val] = cam.Timing.Framerate.Get
        [~, val] = cam.Timing.Exposure.Get
    end

    if isempty(ser)
        ser = serial('COM4');
%     else
%         fclose(ser);
%         ser = ser(1)
    end
    
    if useCam  
        %   Acquire image
        if ~strcmp(char(cam.Acquisition.Freeze(uEye.Defines.DeviceParameter.Wait)), 'SUCCESS')
            error('Could not acquire image');
        end
        data = zeros(img.Height, img.Width );
        h = imshow(data);axis image;
    end
    %   Acquire images 5 x 5 
    file = 1;
    for col=-2:1:2
    for row=-2:1:2
        ledOnXY(row, col)
        if useCam  
            %   Acquire image
            cam.Acquisition.Freeze(uEye.Defines.DeviceParameter.Wait);
            [~, tmp] = cam.Memory.CopyToArray(img.ID);  %   Extract image

            data = reshape(uint8(tmp), [img.Width, img.Height, img.Bits/8])';   
            % data = single(data) / 255;
            data = mat2gray(data);
            filename = ['capture_', num2str(file),'.png'];
            filepath =['C:\Users\John\Desktop\FPM\',filename];
            imwrite(data, filepath);
            file = file + 1;
            set(h, 'CData', data); %   Draw image
            % imagesc(data);axis image;
            drawnow;
        else
            pause(0.5)
        end
%         pause(0.1);
    end
    end
    
    if useCam  
        if ~strcmp(char(cam.Exit), 'SUCCESS')  %   Close camera
            error('Could not close camera');
        end
    end
    % Disconnect from the serial port.
%     fclose(ser);
    % Clean up all objects.
%     ser = [];
    
end
%%
% function old_capture25Images()
%     global cam  dev; 
% %     setuEyeCam();
%     openLEDmatrix();
% 
%     for i = 1:10
%          writeRead(dev,[2 2]); % Turn on row & col
%          pause(0.2)
%          writeRead(dev,[2 0]); % Turn on row & col
% 
%          writeRead(dev,[2 2^4]); % Turn on row & col
%          pause(0.2)
%          writeRead(dev,[2 0]); % Turn on row & col
%          
%          writeRead(dev,[3 2^3]); % Turn on row & col
%          pause(0.2)
%          writeRead(dev,[3 0]); % Turn on row & col
%        
%          writeRead(dev,[4 2]); % Turn on row & col
%          pause(0.2)
%          writeRead(dev,[4 0]); % Turn on row & col
%          
%          writeRead(dev,[4 2^4]); % Turn on row & col
%          pause(0.2)
%          writeRead(dev,[4 0]); % Turn on row & col
%     end
% return
%     
%     %   Acquire images 5 x 5 
%     for row=1:5
%     for col=1:5
%         writeRead(dev,[row 2^col]); % Turn on row & col
%         
% %         %   Acquire image
% %         if ~strcmp(char(cam.Acquisition.Freeze(true)), 'SUCCESS')
% %             error('Could not acquire image');
% %         end
%           
% %         [ErrChk, tmp] = cam.Memory.CopyToArray(img.ID);  %   Extract image
% %         if ~strcmp(char(ErrChk), 'SUCCESS')
% %           error('Could not obtain image data');
% %         end
%         pause(0.5)
%         writeRead(dev,[row 0]); % Turn off row
% 
% %         img.Data = reshape(uint8(tmp), [img.Width, img.Height, img.Bits/8])';        
% %         filename = ['capture ', num2str(row),'_', num2str(col),'.png'];
% %         filepath =['C:\Users\John\Desktop\FPM\',filename];
% %         imwrite(img.Data, filepath);
%         
% %         set(img.himg, 'CData', img.Data); %   Draw image
%         drawnow;
% 
%         pause(0.1);
%     end
%     end
%     
%     if ~strcmp(char(cam.Exit), 'SUCCESS')  %   Close camera
%         error('Could not close camera');
%     end
% end