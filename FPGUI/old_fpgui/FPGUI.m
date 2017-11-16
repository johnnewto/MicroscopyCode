%John Newton
%20-07-2016


%% class deffinition - The parent class the desired class to the handle class.
% This allows for better memory management by Matlab. 
classdef FPGUI < handle  
    
    properties (SetObservable = true)
        f       % frequency components in Hz
        a       % amplitude
    end

    %class properties - access is private so nothing else can access these
    %variables. Useful in different sitionations
    properties (SetAccess = public)

        gui_h;
        busy = false;   % true if busy plotting ( a coup ;)
        terminator = '';
        serialConn;
        LedValue = 0;  % Led illumination value
        CamImg;
        lastLedXY = [0 0];
        simulation = true;
        tb
        im
        h_CamGUI
    end
    
    %Open class methods - in this case, it is restricted to the class
    %constructor. These functions can be accessed by calling the class
    %name. 
    %Ex M = gui_class_example(); calls the class contructor
    %
    %M.sub_function() would call the function sub_fnction, in this example,
    %there is no such function defined.
    methods
        
        %function - class constructor - creates and init's the gui
        function this = FPGUI()
            global gui_h
            
            %make the gui handle and store it locally
            this.gui_h = guihandles(FPGUI_FIG); % load and run the guide generated M file
            disp(this.gui_h);   % display for debugging and development
            addpath('../');  % this allows finding tools path
            InitGuiControls(this); 
            SetGuiCallbacks(this); % connect callbacks
            this.tb = ToggleButton;
            this.im = CameraGui(this.gui_h.axes1, double(imread('cameraman.tif')));
%             
%             plotAllAxes(this);     % first plot of data
            set(this.gui_h.pbcameraUp,   'Enable', 'On');

         
        end
        
    end
    
    
    %% Private Class Methods - these functions can only be access by the class itself.
    methods (Access = private)
        %% --- Executes on button press in pbcameraUp.
        function CameraUp(this, src, event)
              this.h_CamGUI = CamGUI(this);

%             if isnumeric(str2num(get(this.gui_h.edCamDistText, 'String')))
%                 sendCommand(this, ['g-',get(this.gui_h.edCamDistText, 'String')], 'Finished GO');   
%                 enableButtons(this, 'Off')  % disable Tx text field and Rx buttons
%             end
        end

        function SetGuiCallbacks(this)
            % set the figure uicontrols.
             set(this.gui_h.connectButton,    'callback', @(src, event) connectButton(this, src, event));            
             set(this.gui_h.Tx_send,          'callback', @(src, event) Tx_send(this, src, event));
%              set(this.gui_h.pbHelp,           'callback', @(src, event) MicroEyeHelp(this, src, event));
             set(this.gui_h.pbHelp,           'callback', @(src, event) LEDWhiteSquare(this, src, event));
             
             set(this.gui_h.pbClear,          'callback', @(src, event) ClearSerialText(this, src, event));

             
             set(this.gui_h.pbcameraDown,     'callback', @(src, event) CameraDown(this, src, event));
             set(this.gui_h.pbcameraUp,       'callback', @(src, event) CameraUp(this, src, event));

             set(this.gui_h.pbLedOff,          'callback', @(src, event) LedOff(this, src, event));
             set(this.gui_h.pbLedOn,           'callback', @(src, event) LedOn(this, src, event));

             set(this.gui_h.pbStartCapture,    'callback', @(src, event) CameraStartCapture(this, src, event));
             set(this.gui_h.pbStopCapture,     'callback',  @(src, event) CameraStopCapture(this, src, event));

             set(this.gui_h.tbMeasure,          'callback', @(src, event) ImageMeasure(this, src, event));           
             set(this.gui_h.tbCutLine,          'callback', @(src, event) ImageCutLine(this, src, event));
             
                         
            % set the figure close function.
             set(this.gui_h.figure1,  'closerequestfcn', @(src,event) Close_fcn(this, src, event));          
        end

        function InitGuiControls(this)

            figure(this.gui_h.figure1); % need to set ther guide figure handle property to visible
            serialPorts = instrhwinfo('serial');
            nPorts = length(serialPorts.SerialPorts);
            set(this.gui_h.portList, 'String', ...
                [{'Select a port'} ; serialPorts.SerialPorts ]);
            set(this.gui_h.portList, 'Value', 1);   
            set(this.gui_h.history_box, 'String', cell(1));
            axes(this.gui_h.axes1)
            this.CamImg = imread('pout.tif');
            imshow(this.CamImg);
             
        end

        %% Connect to the selected serial port
        function connectButton(this, src, event)
            if strcmp(get(src,'String'),'Connect') % currently disconnected
                serPortn = get(this.gui_h.portList, 'Value');
                if serPortn == 1
                    errordlg('Select valid COM port');
                else
                    serList = get(this.gui_h.portList,'String');
                    serPort = serList{serPortn};
                    this.serialConn = serial(serPort, 'TimeOut', 1, ...
                        'BaudRate', str2num(get(this.gui_h.baudRateText, 'String')));

                %         this.serialConn.BytesAvailableFcnMode = 'byte';
                %         this.serialConn.BytesAvailableFcnCount = 200;
                    this.serialConn.BytesAvailableFcn = {@(src,event) Serial_OnDataReceived(this,src,event)} ; %// note how the parameters are passed to the callback 

                    try
                        fopen(this.serialConn);

                        % enable Tx text field and Rx buttons
                        enableButtons(this, 'On')  

                        set(src, 'String','Disconnect')
                    catch e
                        errordlg(e.message);
                    end

                end
            else
                % disable Tx text field and Rx buttons
                enableButtons(this, 'Off')  
                set(src, 'String','Connect')
                fclose(this.serialConn);
            end
        end
    
        %%  Send Serial Data
        function Tx_send(this, src, event)
            TxText = get(this.gui_h.Tx_send, 'String');
            fprintf(this.serialConn,'%s\r\n', TxText);
            set(src, 'String', '');
        end
        
         % --- Executes on button press in pbHelp.
        function MicroEyeHelp(this, src, event)
            fprintf(this.serialConn,'%s\r\n', '?');

        end

         % --- Executes on button press in pbHelp.
        function ClearSerialText(this, src, event)
            set(this.gui_h.history_box, 'Value', 1 );
            set(this.gui_h.history_box, 'String', {''});
        end
       
        
        %% called on serial data
        function Serial_OnDataReceived(this, src, event)
            try
                currList = get(this.gui_h.history_box, 'String');

                while src.BytesAvailable > 0,
                    RxText = (fgetl(src));
                    currList = [currList ; [RxText] ];
                    len = length(currList);
                    if len > 20
                        currList(1:len-20) = [];
                    end
                    len = min([length(RxText), length(this.terminator)]);
                    if strcmp(RxText(1:len), this.terminator)
                        disp('Finish');
                        enableButtons(this, 'On')  % enable Tx text field and Rx buttons
                    end
                end
                set(this.gui_h.history_box, 'String', currList);
                set(this.gui_h.history_box, 'Value', length(currList));

            catch e
                disp(e)
            end    
        end
        
        %% Send a micro Eye command
        function sendCommand(this, command, term )  
            this.terminator = term;
            fprintf(this.serialConn,'%s\r\n', command);
        end
        
        %% --- Executes on button press in pbcameraDown.
        function CameraDown(this, src, event)
            if isnumeric(str2num(get(this.gui_h.edCamDistText, 'String')))
                sendCommand(this, ['g',get(this.gui_h.edCamDistText, 'String')], 'Finished GO');   
                enableButtons(this, 'Off')  % disable Tx text field and Rx buttons
            end
        end
        
%         %% --- Executes on button press in pbcameraUp.
%         function CameraUp(this, src, event)
%               this.h_CamGUI = CamGUI();
% 
% %             if isnumeric(str2num(get(this.gui_h.edCamDistText, 'String')))
% %                 sendCommand(this, ['g-',get(this.gui_h.edCamDistText, 'String')], 'Finished GO');   
% %                 enableButtons(this, 'Off')  % disable Tx text field and Rx buttons
% %             end
%         end

        %% --- Executes on button press in pbLedOn.
        function LedOn(this, src, event)
            this.LedValue = min([this.LedValue + 1,255]); 
            sendCommand(this, ['l',int2str(this.LedValue)], 'IllLed');   
            enableButtons(this, 'Off')  % disable Tx text field and Rx buttons
        end
        
        %% --- Executes on button press in pbLedOff.
        function LedOff(this, src, ~)
            this.LedValue = max([this.LedValue - 1,0]); 
            sendCommand(this, ['l',int2str(this.LedValue)], 'IllLed');   
            enableButtons(this, 'Off')  % disable Tx text field and Rx buttons
        end
        
        %% --- Executes on button press in pbStartCapture.
        function CameraStartCapture(this, src, event)
%             simu.GenerateLowResImages(this, src, event);
%             oper.CameraStartCapture(this, src, event);
            set(this.gui_h.pbStopCapture, 'Enable', 'On');
            set(this.gui_h.pbStartCapture, 'Enable', 'Off');
            this.im.startPlot()

        end

        %% --- Executes on button press in pbStopCapture.
        function CameraStopCapture(this, src, event)
            this.im.stopPlot()
% 
%             simu.StopLowResImages(this, src, event);
%             oper.CameraStopCapture(this, src, event);
            set(this.gui_h.pbStopCapture, 'Enable', 'Off');
            set(this.gui_h.pbStartCapture, 'Enable', 'On');
        end
        
        %% --- on Image Frame Event.
%         function onFrameEvent(~,eventdata)
%             global cam currentImage ; 
% 
%             tmp = eventdata.Buffer.uint8;
%             currentImage = reshape(uint8(tmp), [3, cam.Width, cam.Height]); 
%             currentImage = permute(currentImage,[3 2 1]);
%             % Draw the camera image
%             set(this.gui_h.imagePlot, 'CData', currentImage); %   Draw image
% %             updateSectionLines(handles) 
%         end   
        

            
        %% --- Executes on button press in tbMeasure.
        function ImageMeasure(this, src, event)
            function PositionCallback(pos)
%                 cameraPixelsize = 1.67;
%                 pos = pos * cameraPixelsize;
%                 len = sqrt((pos(1)-pos(2))^2 + (pos(3)-pos(4))^2);
%             %     title(mat2str(pos*pixelsize,3))
%                 title(this.gui_h.axes1, [mat2str(len,5), ' um'])
            end
            % clear  function to call on mouse click
        %     set(gcf, 'WindowButtonDownFcn', @getMousePositionOnImage);  
            set(this.gui_h.figure1, 'WindowButtonDownFcn', '');

            set(this.gui_h.figure1,'toolbar','figure')
            axes(this.gui_h.axes1)
            if get(src,'Value')
                cameraPixelsize = 1.67;
                posA = [10 100];
                posB = [100 100]; 
                pos = [posA posB];
                pos = pos * cameraPixelsize;
                len = sqrt((pos(1)-pos(3))^2 + (pos(2)-pos(4))^2);
                title([mat2str(len,5), ' um'])
                this.gui_h.imline = imline(this.gui_h.axes1, posA, posB);
                setColor(this.gui_h.imline,[0 1 0]);
                this.gui_h.PositionCallback = addNewPositionCallback(...
                    this.gui_h.imline,@(pos) PositionCallback(pos) );
            else
                % After observing the callback behavior, remove the callback.
                % using the removeNewPositionCallback API function.     
                removeNewPositionCallback(this.gui_h.imline, this.gui_h.PositionCallback);
                title('');
                delete(this.gui_h.imline);
            end
        end

        
        %% --- Executes on button press in tbCutLine.
        function ImageCutLine(this, src, event)
            function getMousePositionOnImage(src, event)
                cursorPoint = get(this.gui_h.axes1, 'CurrentPoint');

                curX = cursorPoint(1,1);
                curY = cursorPoint(1,2);

                xLimits = get(this.gui_h.axes1, 'xlim');
                yLimits = get(this.gui_h.axes1, 'ylim');

                if (curX > min(xLimits) && curX < max(xLimits) && curY > min(yLimits) && curY < max(yLimits))
                    disp(['Cursor coordinates are (' num2str(curX) ', ' num2str(curY) ').']);
                    if (curX > min(xLimits) && curX < max(xLimits) && curY > min(yLimits) && curY < max(yLimits))
                        displaySectionLines(this, curX, curY);
                    end
                else
                    disp('Cursor is outside bounds of image.');
                end
            end
            
            if isempty(this.CamImg)
                set(src,'Enable','off'); % tbCutLine
                return
            end 

            % set function to call on mouse click
            set(gcf, 'WindowButtonDownFcn', @getMousePositionOnImage);  

            try
                % button txt toggle
                txt = get(src,'String')
                switch txt
                    case 'Vertical'
                        set(src,'String', 'Horizontal');
                    case 'Horizontal'
                        set(src,'String', 'Vertical');
                    case 'Section Off'
                        set(src,'String', 'Vertical');
                    otherwise
                        set(src,'String', 'Section Off');
                end

                % Now Set plot lines
                if isfield(this.gui_h, 'lineHorz') && isvalid(this.gui_h.lineHorz)
                    curY = get(this.gui_h.lineHorz, 'YData');
                    curY = curY(1);
                else
                    curY = this.CamImg.Height/2;
                end

                if isfield(this.gui_h, 'lineVert') && isvalid(this.gui_h.lineVert)
                    curX = get(this.gui_h.lineVert, 'XData');
                    curX = curX(1);
                else
                    curX = this.CamImg.Width/2;
                end

                displaySectionLines(this, curX, curY)

            catch e
                disp(e)
            end
        end

        
        %% display the section cut lines on the image and plot
        function displaySectionLines(this, curX, curY)
            global  currentImage
            if isfield(this.gui_h, 'plotHorz') 
                delete (this.gui_h.plotHorz);
            end
        %     if isfield(this.gui_h, 'lineHorz') 
        %         delete (this.gui_h.lineHorz);
        %     end
        %     if isfield(this.gui_h, 'lineVert') 
        %         delete (this.gui_h.lineVert);
        %     end

            if isfield(this.gui_h, 'plotVert') 
                delete (this.gui_h.plotVert);
            end

            xLimits = get(this.gui_h.axes1, 'xlim');
            yLimits = get(this.gui_h.axes1, 'ylim');

            if isfield(this.gui_h, 'lineHorz') && isvalid(this.gui_h.lineHorz)
                set(this.gui_h.lineHorz, 'YData', [curY curY]);
            else
                axes(this.gui_h.axes1); 
                this.gui_h.lineHorz = line( xLimits, [curY curY]);
            end
            if isfield(this.gui_h, 'lineVert') && isvalid(this.gui_h.lineVert)
                set(this.gui_h.lineVert, 'XData', [curX curX]);
            else
                axes(this.gui_h.axes1); 
                this.gui_h.lineVert = line( [curX curX], yLimits);
            end

            if ~isempty(currentImage)
                txt = get(this.gui_h.tbCutLine,'String');
                switch txt
                    case 'Horizontal'
                        this.gui_h.plotHorz = plot(this.gui_h.axes2, currentImage(round(curY),:,1));
            %             if isfield(this.gui_h, 'lineHorz') && isvalid(this.gui_h.lineHorz)
            %                 set(this.gui_h.lineHorz, 'YData', [curY curY]);
            %             else
            %                 axes(this.gui_h.axes1); this.gui_h.lineHorz = line( xLimits, [curY curY]);
            %             end
                    case 'Vertical'
                        this.gui_h.plotVert = plot(this.gui_h.axes2, currentImage(:,round(curX),1));
            %             if isfield(this.gui_h, 'lineVert') && isvalid(this.gui_h.lineVert)
            %                 set(this.gui_h.lineVert, 'XData', [curX curX]);
            %             else
            %                 axes(this.gui_h.axes1); this.gui_h.lineVert = line( [curX curX], yLimits);
            %             end
                end
            end
        end

        function updateSectionLines(this)
            global  currentImage
            curX = 1; curY = 1;   % just in case not set below
            if isfield(this.gui_h, 'lineHorz') && isvalid(this.gui_h.lineHorz)
                curY = get(this.gui_h.lineHorz, 'YData');
                curY = curY(1);
            end

            if isfield(this.gui_h, 'lineVert') && isvalid(this.gui_h.lineVert)
                curX = get(this.gui_h.lineVert, 'XData');
                curX = curX(1);
            end

            if isfield(this.gui_h, 'plotVert') && isvalid(this.gui_h.plotVert)
                set(this.gui_h.plotVert, 'YData', currentImage(:,round(curX),1)); %   Draw plot
            end

            if isfield(this.gui_h, 'plotHorz') && isvalid(this.gui_h.plotHorz)
                set(this.gui_h.plotHorz, 'YData', currentImage(round(curY),:,1)); %   Draw line on the image
            end
        end
      
        
        
            
        %% enable or disable controls
        function enableButtons(this, action)    
            set(this.gui_h.Tx_send,  'Enable', action);
            set(this.gui_h.rxButton, 'Enable', action);
            set(this.gui_h.pbHelp,   'Enable', action);
            set(this.gui_h.pbcameraDown, 'Enable', action);
            set(this.gui_h.pbcameraUp,   'Enable', action);
            set(this.gui_h.pbLedOn,  'Enable', action);
            set(this.gui_h.pbLedOff, 'Enable', action);
        end
        
        
        %%
        %class deconstructor - handles the cleaning up of the class &
        %figure. Either the class or the figure can initiate the closing
        %condition, this function makes sure both are cleaned up
        function delete(this)
            %remove the closerequestfcn from the figure, this prevents an
            %infinite loop with the following delete command
            set(this.gui_h.figure1,  'closerequestfcn', '');
            %delete the figure
            delete(this.gui_h.figure1);
            %clear out the pointer to the figure - prevents memory leaks
            this.gui_h = [];
        end
        
        %function - Close_fcn
        
        function this = Close_fcn(this, src, event)
            delete(this);
        end
        
        %% --- Executes on button press in WhiteSquare.
        function LEDWhiteSquare(this, src, event)
            function ledOnXY(this, x, y, rgb)
                this.lastLedXY = [x y];

                centerX = 16;
                centerY = 16;
                fprintf(this.serialConn,'%d %d %d %d %d\n', [centerX+x, centerY+y, rgb], 'sync');
            end        

            offsetx = 0;
            offsety = -8;
            colorOn = [3 3 3];

            for x = -5: 5
                for y = -5: 5
                    if get(src,'Value') == 1
                        ledOnXY(this, x+offsetx, y+offsety, colorOn);
                    else
                        ledOnXY(this, x+offsetx, y+offsety, [0 0 0]);
                    end
                end
            end
        end
        
       %%            
       function GuiBusy(this, doSet)
            persistent oldpointer
            handlesArray = findobj(this.gui_h.figure1, 'type', 'uicontrol');
            if doSet
                set(handlesArray, 'Enable', 'off');
                oldpointer = get(this.gui_h.figure1, 'pointer'); 
                set(this.gui_h.figure1, 'pointer', 'watch') ;
                drawnow;
            else
                set(handlesArray, 'Enable', 'on');
                set(this.gui_h.figure1, 'pointer', oldpointer);
           end
                
        end
         
    end
    
end

