
classdef CamCntr_GUI < handle  
    properties (SetAccess = public)

        gui_h;
        h_parent;       % parent class
        busy = false;   % true if busy plotting ( a coup ;)
        CamImg;
        BaslerCam;
        LedArray;

        CaptureLowResImages;
        imSeqLowRes
        SetLEDGUI
        camListener
        HistoryBox

    end
    
     methods
        
        %% class constructor - creates and init's the gui
        function this = CamCntr_GUI(parent)
            global g_onFrameEvtData
            global SerialPortObj


            if nargin == 0
                this.h_parent = [];
            else
                this.h_parent = parent;
            end

            addpath('../');  % this allows finding tools path
            %make the gui handle and store it locally
            this.gui_h = guihandles(CamCntr_FIG); % load and run the guide generated M file
            disp(this.gui_h);   % display for debugging and development
            
            this.LedArray = simu.LedArray();

            InitGuiControls(this); 
            SetGuiCallbacks(this); % connect callbacks
%             this.SetLEDGUI = SerialPort_GUI(this);
%             this.SetLEDGUI.setGUIVisable('on');

            
%             this.LowResImages = oper.CaptureLowResImages(this.gui_h.axes1);
%             this.LedArray = simu.LedArray();
            img=double(imread('USAF1951B250','png')); %read image file
            this.CaptureLowResImages = oper.CaptureLowResImages(this, img, this.gui_h.axes1, this.gui_h.axes1);
            g_onFrameEvtData.obj = this.CaptureLowResImages;
            
            this.HistoryBox = misc.ListBox(this.gui_h.history_box);

            
%             data = double(zeros(this.BaslerCam.Height, this.BaslerCam.Width,3));
%             axes(this.gui_h.axes1);
%             if isfield(this.gui_h, 'imagePlot') && isvalid(this.gui_h.imagePlot)
%                set(this.gui_h.imagePlot, 'CData', data); %   Draw image
%             else
%                 this.gui_h.imagePlot = imshow(data);axis image;
%             end



        end
  
        function setGUIVisable(this, action)
            % action should be 'on' or 'off'
            this.gui_h.figure1.Visible = action;
        end
                
        function Close(this)
            this.h_parent = [];  % closing from parent
            Close_fcn(this)
        end

        function CameraStart(this)
            pbStart(this,[],[])
        end

        %% Display text in history window
        function WriteText(this, text)
            this.HistoryBox.Write(text);
        end
         

%         function OnImageGrab(this, image)
%             disp('got image')
%             GrabbedImageCount = GrabbedImageCount + 1;
%         end

        function OnImageGrab(this, img)
            disp('got image')
            set(this.gui_h.imagePlot, 'CData', img); %   Draw image
%             figure(2)
%             histogram(img)

        end

    end
    
        
    %% Private Class Methods - these functions can only be access by the class itself.
    methods (Access = private)
        %function - Close_fcn
        %% class deconstructor - handles the cleaning up of the class &
        % figure. Either the class or the figure can initiate the closing
        % condition, this function makes sure both are cleaned up
        function delete(this)

            oper.CameraStopCapture(this);

            try
                %delete the serial port gui
                this.SetLEDGUI.Close();
            catch e
                disp(e)
            end

            %remove the closerequestfcn from the figure, this prevents an
            %infinite loop with the following delete command
            set(this.gui_h.figure1,  'closerequestfcn', '');
            %delete the figure
            delete(this.gui_h.figure1);
            %clear out the pointer to the figure - prevents memory leaks
            this.gui_h = [];
        end
        
        function this = Close_fcn(this, ~, ~)
            if isempty(this.h_parent)
                delete(this);
            else
                this.gui_h.figure1.Visible = 'off';
            end
        end
        
        function SetGuiCallbacks(this)
            % set the figure uicontrols.
             set(this.gui_h.pbSetBin,        'callback', @(src, event) pbSetBin(this, src, event));            
             set(this.gui_h.pbSetResolution, 'callback', @(src, event) pbSetResolution(this, src, event));
             set(this.gui_h.pbStart,         'callback', @(src, event) pbStart(this, src, event));
             set(this.gui_h.edtExposure,     'callback', @(src, event) edtExposure(this, src, event));
             set(this.gui_h.pbCaptureImageSequence,     'callback', @(src, event) pbCaptureImageSequence(this, src, event));
             set(this.gui_h.btnSaveImages,    'callback', @(src, event) btnSaveImages(this, src, event));
             
             
             % set the figure close function.
             set(this.gui_h.figure1,  'closerequestfcn', @(src,event) Close_fcn(this, src, event));          
        end

        function InitGuiControls(this)
            figure(this.gui_h.figure1); % need to set ther guide figure handle property to visible
            set(this.gui_h.history_box, 'String', cell(1));
        end

 
        %% --- Executes on button press in pbStart.
        function pbStart(this, src, event)
            global g_onFrameEvtData

%             this.LedValue = min([this.LedValue + 1,255]); 
%             sendCommand(this, ['l',int2str(this.LedValue)], 'IllLed');   
%             enableButtons(this, 'Off')  % disable Tx text field and Rx buttons
            if isempty (this.BaslerCam)
                set(this.gui_h.pbCaptureImageSequence,  'Enable', 'off');

                WriteText(this, 'BaslerCam Started');
                g_onFrameEvtData.obj = this;

                oper.CameraStartCapture(this);
                this.gui_h.pbStart.String = 'Stop';
                % set exposure to whats in the editExposure box
                src = this.gui_h.edtExposure;
                this.edtExposure(src, [])
                set(this.gui_h.pbCaptureImageSequence,  'Enable', 'on');

            else
                WriteText(this, 'BaslerCam Stoped');
                oper.CameraStopCapture(this);
                this.gui_h.pbStart.String = 'Start';
            end
                
 
        end
        

        %% --- Executes on button press in pbSetBin.
        function pbSetBin(this, src, event)
            if ~isempty (this.BaslerCam)
                this.BaslerCam.BaslerCamStop();
                bin = mod(this.BaslerCam.BinningVertical, 4) + 1; 
                this.BaslerCam.BinningVertical = bin;
                this.BaslerCam.BinningHorizontal = bin;
                this.BaslerCam.BaslerCamStart();
                WriteText(this, ['Set BaslerCam Bin: ', num2str(bin, 2)]);
            end
        end
        
        %% --- Executes on button press in edtExposure.        
        function edtExposure(this, src, event)  
           % exposureis in usec 
            if ~isempty (this.BaslerCam)
                multiplier = 1000;  % millisec
                if strcmp(src.Style,'edit')
                    value = str2double(regexp(src.String, '(?:\d*\.)?\d+', 'match')); % http://regexr.com/
                else
                    value = round(get(src,'Value'));
                end

                if (value<0), value=0; end 
                if (value>1000), value=1000; end; % 1000 msec max

                this.BaslerCam.ExposureTime = value * multiplier;
                this.gui_h.edtExposure.String = [num2str(this.BaslerCam.ExposureTime / multiplier,4)];           
                WriteText(this, ['Set BaslerCam Exposure: ', num2str(this.BaslerCam.ExposureTime / multiplier), ' msec']);
            end      
        end
        
        
        %% --- Executes on button press in pbGetImageSequence.
        function pbCaptureImageSequence(this, src, event)
            if strncmp (src.String, 'Capture',7)
                set(this.gui_h.pbStart,  'Enable', 'off');

                src.String = 'Stop Capture' ;
                this.CaptureLowResImages.Start();
                this.imSeqLowRes = this.CaptureLowResImages.imSeqLowRes;
                this.CaptureLowResImages.Stop();
                src.String = 'Capture Image Sequence' ;               
                set(this.gui_h.btnSaveImages, 'Enable', 'On');
                set(this.gui_h.pbStart,  'Enable', 'on');
                
            else
                this.CaptureLowResImages.Stop();
                src.String = 'Capture Image Sequence' ;
            end
            
%             do more here john!!!

        end
        
        %% --- Executes on button press in pbSaveImages.
        function btnSaveImages(this, src, event)  
            
            this.CaptureLowResImages.SaveToFile('Camera');     
            set(this.gui_h.btnSaveImages, 'Enable', 'Off');
        end


        %% --- Executes on button press in pbSetResolution.
        function pbSetResolution(this, src, event)
%             this.LedValue = max([this.LedValue - 1,0]); 
%             sendCommand(this, ['l',int2str(this.LedValue)], 'IllLed');   
%             enableButtons(this, 'Off')  % disable Tx text field and Rx buttons
%                 this.CaptureLowResImages.SaveToFile();

        end
        
        

            
        %% enable or disable controls
        function enableButtons(this, action)    
            set(this.gui_h.pbSetResolution,  'Enable', action);
            set(this.gui_h.pbSetBin, 'Enable', action);
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

