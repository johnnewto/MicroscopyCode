
classdef SerialPort_GUI < handle  
    properties (SetAccess = private)

        gui_h;
        h_parent;       % parent class
        busy = false;   % true if busy plotting ( a coup ;)
        terminator = '';
        serialConn;
        LedValue = 0;  % Led illumination value
        CamImg;
        LedColor = 777;
        lastLedXY = [0 0];
%         centerX = 16;
%         centerY = 16;
        centerX = 8;
        centerY = 8;
        LedArray;
        HistoryBox

    end
    
     methods
        
        %% class constructor - creates and init's the gui
        function this = SerialPort_GUI(parent)
            global SerialPortObj
            if nargin == 0
                this.h_parent = [];
            else
                this.h_parent = parent;
            end
            
            addpath('../');  % this allows finding tools path
            
            SerialPortObj = this;
            this.LedArray = simu.LedArray();

            
            %make the gui handle and store it locally
            this.gui_h = guihandles(SerialPort_FIG); % load and run the guide generated M file
            disp(this.gui_h);   % display for debugging and development

            InitGuiControls(this); 
            SetGuiCallbacks(this); % connect callbacks
            delete(instrfindall)
            this.HistoryBox = misc.ListBox(this.gui_h.history_box);

        end
  
        function setGUIVisable(this, action)
            % action should be 'on' or 'off'
            this.gui_h.figure1.Visible = action;
        end
        
        function SetLED(this, ledn)
           arraysize = this.LedArray.arraysize;
            y  = ceil(ledn/arraysize) ;
            x  = ledn -(y-1)*arraysize ;
            x = x - (arraysize + 1)/2;
            y = y - (arraysize + 1)/2;
            disp(['led ', num2str(ledn), ' x:', num2str(x), ' y:', num2str(y)]);
            % adjust order sign to suit H/W
            try
%                     this.SetLEDxy( -y, -x)  % ? good
%                      this.SetLEDxy( y, x)    % ? good
%                 this.SetLEDxy( -y, x)     % very good
%                   this.SetLEDxy( y, -x)     % no good
%                  this.SetLEDxy( x, -y)  
%                  this.SetLEDxy( -x, y)  
                  this.SetLEDxy( x, y)  
                ShowLed(this);
            catch
                disp('SetLED error')
            end
        end

        function SetLEDxy(this, x, y, col)
            if nargin < 4
                col = this.LedColor;
            end
            this.lastLedXY = [x y];

            huns = floor(col / 100); col = col - huns*100;
            tens = floor(col / 10);  col = col - tens*10;
            ones = col;
            colorOn = 28*[huns tens ones]; % this will give a MAX of 252
            x = this.centerX+x;
            y = this.centerY+y;
            fprintf(this.serialConn,'P%d %d %d %d %d\n', [x, y, colorOn], 'sync');
            disp(sprintf('P: %d  y: %d   R: %d   G: %d   B: %d ' ,[x, y, colorOn]));
        end    
 
        function ShowLed(this)
            fprintf(this.serialConn,'S\n', 'sync');
        end
        
%         function old2SetLEDxy(this, x, y, col)
%             if nargin < 4
%                 col = this.LedColor;
%             end
%             this.lastLedXY = [x y];
% 
%             huns = floor(col / 100); col = col - huns*100;
%             tens = floor(col / 10);  col = col - tens*10;
%             ones = col;
%             colorOn = [huns tens ones]; % this will give a MAX of 9
%             % 8 x 8 array sequentially numbered 0 to 63
%             % 1,1 = 0
%             x = this.centerX+x;
%             y = this.centerY+y;
%             ledN = x + y * 8;
%             
%             % led numbers are winding  snale like so use look up table.
%             disp(sprintf('led: %d,  x: %d,  y: %d ',ledN, x, y))
%             fprintf(this.serialConn,'s%d %d %d %d\n', [ledN, colorOn], 'sync');
%      end    

        
%         function old_SetLEDxy(this, x, y, col)
%             if nargin < 4
%                 col = this.LedColor;
%             end
%             this.lastLedXY = [x y];
% 
%             huns = floor(col / 100); col = col - huns*100;
%             tens = floor(col / 10);  col = col - tens*10;
%             ones = col;
%             colorOn = [huns tens ones]; % this will give a MAX of 9
%             fprintf(this.serialConn,'%d %d %d %d %d\n', [this.centerX+x, this.centerY+y, colorOn], 'sync');
%         end    

        
         function SetOneLED(this, x, y, col)
            if nargin < 4
                col = this.LedColor;
            end
            try
%                 xy = this.lastLedXY;
%                 fprintf(this.serialConn,'P%d %d %d %d %d\n', [this.centerX+xy(1), this.centerY+xy(2),  0, 0, 0], 'sync');
%                 this.lastLedXY = [x y];

                huns = floor(col / 100); col = col - huns*100;
                tens = floor(col / 10);  col = col - tens*10;
                ones = col;
                colorOn = 28*[huns tens ones]; % this will give a MAX of 252
                fprintf(this.serialConn,'P%d %d %d %d %d\n', [this.centerX+x, this.centerY+y, colorOn], 'sync');
                ShowLed(this);
            catch e
                disp('Serial Port Error')
            end
        end
        
        function Close(this)
            this.h_parent = [];  % closing from parent
            Close_fcn(this)
        end



    end
    
        
    %% Private Class Methods - these functions can only be access by the class itself.
    methods (Access = private)
        %function - Close_fcn
        %% class deconstructor - handles the cleaning up of the class &
        % figure. Either the class or the figure can initiate the closing
        % condition, this function makes sure both are cleaned up
        function delete(this)
            %remove the closerequestfcn from the figure, this prevents an
            %infinite loop with the following delete command
            set(this.gui_h.figure1,  'closerequestfcn', '');
            %delete the figure
            delete(this.gui_h.figure1);
            %clear out the pointer to the figure - prevents memory leaks
            this.gui_h = [];
            %close the serial port
            if ~isempty(this.serialConn)
                fclose(this.serialConn);
            end
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
             set(this.gui_h.connectButton,    'callback', @(src, event) connectButton(this, src, event));            
             set(this.gui_h.Tx_send,          'callback', @(src, event) Tx_send(this, src, event));
%              set(this.gui_h.pbHelp,         'callback', @(src, event) MicroEyeHelp(this, src, event));
             set(this.gui_h.btnSetSquare,      'callback', @(src, event) LEDWhiteSquare(this, src, event));
             
             set(this.gui_h.pbClear,          'callback', @(src, event) ClearSerialText(this, src, event));
             set(this.gui_h.editColor,        'callback', @(src, event) EditColorText(this, src, event));
             set(this.gui_h.pbLedOn,          'callback', @(src, event) pbLedOn(this, src, event));
             
             

             % set the figure close function.
             set(this.gui_h.figure1,  'closerequestfcn', @(src,event) Close_fcn(this, src, event));          
        end

        function InitGuiControls(this)

            figure(this.gui_h.figure1); % need to set ther guide figure handle property to visible
%             serialPorts = instrhwinfo('serial');
%             nPorts = length(serialPorts.SerialPorts);
            serialPorts = tools.getAvailableComPort();
            nPorts = length(serialPorts);
            set(this.gui_h.portList, 'String', ...
                [{'Select a port'} ; serialPorts ]);
            set(this.gui_h.portList, 'Value', 1);   
              
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
            fprintf(this.serialConn,'%s\n', TxText);
            set(src, 'String', '');
        end
        
         % --- Executes on button press in pbHelp.
        function MicroEyeHelp(this, src, event)
            fprintf(this.serialConn,'%s\r\n', '?');

        end

         % --- Executes on button press in pbHelp.
        function ClearSerialText(this, src, event)
            this.HistoryBox.Clear()
        end

         % --- Executes on button press in editColor.
        function EditColorText(this, src, event)
            disp(src.String)
            
            value = str2double(regexp(src.String, '(?:\d*\.)?\d+', 'match')); % http://regexr.com/
            if isempty(value), value=0; end 
            if value<0, value=0; end 
            if value>999, value=999; end; 
            this.LedColor = value;
            this.gui_h.editColor.String = [num2str(this.LedColor,'%03d')];           

        end

        
        %% called on serial data
        function old_Serial_OnDataReceived(this, src, event)
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
        
        %% called on serial data
        function Serial_OnDataReceived(this, src, event)
            try
                while src.BytesAvailable > 0,
                    RxText = (fgetl(src));
                    this.HistoryBox.Write(RxText)
                    len = min([length(RxText), length(this.terminator)]);
                    if strcmp(RxText(1:len), this.terminator)
                        disp('Finish');
                        enableButtons(this, 'On')  % enable Tx text field and Rx buttons
                    end
                end

            catch e
                disp(e)
            end    
        end
         
        %% Send a micro Eye command
        function sendCommand(this, command, term )  
            this.terminator = term;
            fprintf(this.serialConn,'%s\r\n', command);
        end
        

        %% --- Executes on button press in pbLedOn.
        % set the center led
        function pbLedOn(this, src, event)
            if strcmp(src.String, 'LED on')
                src.String = 'LED off';
                this.SetLEDxy(0, 0, 020)  % RGB = 020
            else
                src.String = 'LED on';
                this.SetLEDxy(0, 0, 000)
            end
        end
        
            
        %% enable or disable controls
        function enableButtons(this, action)    
            set(this.gui_h.Tx_send,  'Enable', action);
            set(this.gui_h.btnSetSquare, 'Enable', action);
            set(this.gui_h.pbHelp,   'Enable', action);
            set(this.gui_h.pbLedOn,   'Enable', action);
        end
        
        
        %% --- Executes on button press in WhiteSquare.
        function LEDWhiteSquare(this, src, event)

            for y = -1: 1
                for x = -1: 1
                    if get(src,'Value') == 1
                        SetLEDxy(this, x, y);
                    else
                        SetLEDxy(this, x, y);
                    end
                end
            end
            this.ShowLed();
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

