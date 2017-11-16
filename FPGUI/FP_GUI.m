%John Newton
%20-07-2016


%% class deffinition - The parent class the desired class to the handle class.
% This allows for better memory management by Matlab. 
classdef FP_GUI < handle  
    
    %class properties - access is private so nothing else can access these
    %variables. Useful in different sitionations
    properties (SetAccess = public)

        gui_h;
        busy = false;   % true if busy plotting ( a coup ;)
        CamImg;
        Mode = 'Simulation';
        LowResImages
        HiResImage
        h_parent
        run = false;
        imSeqLowRes
        LedArray;
        Camera;
        HistoryBox

    end
    
    methods        
        %function - class constructor - creates and init's the gui
        function this = FP_GUI(parent)
            global parentclass
            parentclass = this;
            if nargin == 0
                this.h_parent = [];
            else
                this.h_parent = parent;
            end
            
            
            %make the gui handle and store it locally
            this.gui_h = guihandles(FP_FIG); % load and run the guide generated M file
            disp(this.gui_h);   % display for debugging and development
            addpath('../');  % this allows finding tools path
 
            this.HistoryBox = misc.ListBox(this.gui_h.history_box);
            this.HistoryBox.textLength = 40;
            this.HistoryBox.Clear()
            this.HistoryBox.Write('Started')

            
            img=double(imread('USAF1951B250','png')); %read image file
            this.LedArray = simu.LedArray();
            this.LowResImages = simu.GenerateLowResImages(this, img, this.gui_h.axes1, this.gui_h.axes2);
            
            this.HiResImage   = simu.RecoverHiResImage( this.gui_h.axes3, this.gui_h.axes4);
            
            InitGuiControls(this); 
            SetGuiCallbacks(this); % connect callbacks

            set(gcf, 'WindowButtonDownFcn', @FP_GUI.getMousePositionOnImage);
            

            %             this.CamCntrl_GUI = CamCntr_GUI(this);
         
        end
        
        %% Display text in history window
%         function WriteText(this, text)
%             this.HistoryBox.Write(text);
%         end
       
        function WriteText(this, x)
              this.HistoryBox.Write(x);
%             DisptoString = @(x)  regexprep(evalc('disp(x)'), '<[^>]*>', '');
%             try
%                 this.HistoryBox.Write(DisptoString(x));
%             catch
%                 disp(x)
%             end
         end

        
    end
    
    
    %% Private Class Methods - these functions can only be access by the class itself.
    methods (Access = private)
        

        
        function SetGuiCallbacks(this)
            % set the figure uicontrols.

            set(this.gui_h.btnConnectLEDs, 'callback', @(src, event) ConnectLEDs(this, src, event));
            set(this.gui_h.btnRunFPcam,    'callback', @(src, event) btnRunFPcam(this, src, event));
            set(this.gui_h.btnRunFPsim,    'callback', @(src, event) btnRunFPsim(this, src, event));
            set(this.gui_h.pbSaveImages,   'callback', @(src, event) pbSaveImages(this, src, event));
            % set the figure close function.
            set(this.gui_h.figure1,  'closerequestfcn', @(src,event) Close_fcn(this, src, event));          
            set(this.gui_h.edtNoise,    'callback', @(src, event) SetPixelNoise  (this, src, event));
            set(this.gui_h.edtGapError,    'callback', @(src, event) SetLedGapError  (this, src, event));
            set(this.gui_h.togbtnGenLowResImages,    'callback', @(src, event) togbtnGenLowResImages  (this, src, event));
            set(gcf,'name',['FP Mode: ',this.Mode],'numbertitle','off')
        end

        function InitGuiControls(this)

%             figure(this.gui_h.figure1); % need to set ther guide figure handle property to visible
% 
%             axes(this.gui_h.axes1)
%             this.CamImg = imread('pout.tif');
%             imshow(this.CamImg);
             
        end

    
          % --- Executes on button press in pbHelp.
        function MicroEyeHelp(this, src, event)
            fprintf(this.serialConn,'%s\r\n', '?');

        end
        
        %% --- on press GenLowResImages
        function togbtnGenLowResImages(this, src, event)
            this.LowResImages.Start();
            this.imSeqLowRes = this.LowResImages.imSeqLowRes;
            
            
            this.gui_h.figure1.Name =['FP Mode: ',this.Mode];
%             ,'numbertitle','off')
%                 this.LowResImages.Stop();
            set(this.gui_h.pbSaveImages, 'Enable', 'On');
        end
       
        %% --- Executes on button press in btnRunFPcam.
        function btnRunFPcam(this, src, event)
            if strcmp (src.String, 'Run FP Cam')
                src.String = 'Stop FP'  
                this.HiResImage.imSeqLowRes = this.LowResImages.loadImages('Camera');
                this.HiResImage.Start(); 
                src.String = 'Run FP Cam'
            else
                this.HiResImage.Stop();
%                 src.String = 'Run FP'
            end
 
        end
        %% --- Executes on button press in btnRunFPsim
        function btnRunFPsim(this, src, event)
            if strcmp (src.String, 'Run FP Sim')
                src.String = 'Stop FP';  
                this.HiResImage.imSeqLowRes = this.LowResImages.loadImages('Simulated');
                this.HiResImage.Start(); 
                src.String = 'Run FP Sim';
            else
                this.HiResImage.Stop();
%                 src.String = 'Run FP'
            end
 
        end
 

        %% --- Executes on button press in pbSaveImages.
        function pbSaveImages(this, src, event)  
            
            this.LowResImages.SaveToFile('Simulated');     
            set(this.gui_h.pbSaveImages, 'Enable', 'Off');
        end
        
        
        
        function ConnectLEDs(this, src, event) 
            this.LowResImages.CheckParameters();
%             global SerialPortObj
% 
%             for x = -5: 5
%                 for y = -5: 5
%                     if abs(x) == 5 | abs(y) == 5
%                         SerialPortObj.SetLED( x, y)
%                     end
%                 end
%             end
             
        end
        
        %%

        function SetLedGapError(this, src, event)  
            
            if strcmp(src.Style,'edit')
                value = str2double(regexp(src.String, '(?:\d*\.)?\d+', 'match')); % http://regexr.com/
            else
                value = round(get(src,'Value')*100);
            end
            if (value<0), value=0; end 
            if (value>100), value=100; end; 
            
            this.HiResImage.LedArray.setLedPositions(value/100);
            this.HiResImage.InitialiseFP(this);
            this.gui_h.edtGapError.String = num2str(value,3);           
             
%             if strcmp(event.EventName, 'Action')
%                 plotAllAxes(this, 3);   % only plot on slider release
%             end
        end
          
        
        %%
        %class deconstructor - handles the cleaning up of the class &
        %figure. Either the class or the figure can initiate the closing
        %condition, this function makes sure both are cleaned up
        function delete(this)
            oper.CameraStopCapture(this);
            %remove the closerequestfcn from the figure, this prevents an
            %infinite loop with the following delete command
            
            
            try
                %delete the Camera gui
                this.CamCntrl_GUI.Close();
            catch e
                disp(e)
            end
            
            % delete main gui
            set(this.gui_h.figure1,  'closerequestfcn', '');
            delete(this.gui_h.figure1);
            
            %clear out the pointer to the figure - prevents memory leaks
            this.gui_h = [];
        end
        
        %function - Close_fcn
        
        function this = Close_fcn(this, src, event)
            delete(this);
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
    
    methods(Static)
       
        function getMousePositionOnImage(hObject, eventdata)
            global h_RecoverHiResImage h_GenerateLowResImages;
            global parentclass
            global SerialPortObj
            % not the best implementation no doubt
            this = h_RecoverHiResImage;
            cursorPoint = get(this.h_axes2, 'CurrentPoint');

            curX = cursorPoint(1,1);
            curY = cursorPoint(1,2);

            xLimits = get(this.h_axes2, 'xlim');
            yLimits = get(this.h_axes2, 'ylim');

            if (curX > min(xLimits) && curX < max(xLimits) && curY > min(yLimits) && curY < max(yLimits))
                % disp(['Cursor coordinates are (' num2str(curX) ', ' num2str(curY) ').']);
                if (curX > min(xLimits) && curX < max(xLimits) && curY > min(yLimits) && curY < max(yLimits))
                    % uncomment if you want to clear each time
                    %  InitialiseFP(h_RecoverHiResImage);

                    
                    ledn = closestLED(h_RecoverHiResImage,[curX,curY]);
                    %  disp(ledn);
                    try
                        SerialPortObj.SetLED(ledn);
                    catch e
%                         disp(dbstack)
%                         disp(e) 
                    end
                    processFPImage(h_RecoverHiResImage, ledn);
                    txt =  sprintf('Image %d', ledn);
%                     plotReconstructedObject(h_RecoverHiResImage, [curY curX], txt);
                    plotReconstructedObject(h_RecoverHiResImage, [this.kyc(ledn) this.kxc(ledn)], txt);
                
                    if strcmp(parentclass.Mode,'Simulation')
                        plotLowRes(h_GenerateLowResImages,ledn)
                    end
                end
            else
                disp('Cursor is outside bounds of image.');
            end
        end
    end

    
end

