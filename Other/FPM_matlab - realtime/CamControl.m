function varargout = CamControl(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CamControl_OpeningFcn, ...
                   'gui_OutputFcn',  @CamControl_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before CamControl is made visible.
function CamControl_OpeningFcn(hObject, eventdata, handles, varargin)
    global lastLedXY
    lastLedXY = [0 0];
    % Choose default command line output for CamControl
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    % This sets up the initial plot - only do when we are invisible
    % so window can get raised using CamControl.
    if strcmp(get(hObject,'Visible'),'off')
        plot(rand(5));
    end

    % UIWAIT makes CamControl wait for user response (see UIRESUME)
    % uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CamControl_OutputFcn(hObject, eventdata, handles)
    varargout{1} = handles.output;

% --- Executes on button press in pbRunCamera.
function pbRunCamera_Callback(hObject, eventdata, handles)
%     hObject.
    axes(handles.axes1);
    cla;
    
    hObject.String = 'Running';
    hObject.Enable = 'off';
    runCam();
    hObject.Enable = 'on';
    hObject.String = 'Run Camera';



% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
    file = uigetfile('*.fig');
    if ~isequal(file, 0)
        open(file);
    end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
    printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
    global ser
    selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                         ['Close ' get(handles.figure1,'Name') '...'],...
                         'Yes','No','Yes');
    if strcmp(selection,'No')
        return;
    end
    fclose( serial(ser.Port) );
    delete(handles.figure1)


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
         set(hObject,'BackgroundColor','white');
    end
    set(hObject, 'String', {'plot(rand(5))', 'plot(sin(1:0.01:25))', 'bar(1:.5:10)', 'plot(membrane)', 'surf(peaks)'});


    
    % --- Executes on button press in pbArduino.
function pbArduino_Callback(hObject, eventdata, handles)
%     global  dev;
    
%     openArduino();
%     writeRead(dev,[15 1]); % LEDS all on
%     pause(1);
%     writeRead(dev,[15 0]); % LEDS all off
% 
%     for led = 8:-1:1
%         writeRead(dev,[led 2^4]) % Turn on row
%         pause(0.3);
%         writeRead(dev,[led 0]) % Turn off row
%     end

     

% --- Executes on button press in pbCapture25.
function pbCapture25_Callback(hObject, eventdata, handles)
    capture25Images();



function openSerial()
global ser
% Create the serial port object if it does not exist
% otherwise use the object that was found.
if isempty(ser)
    ser = serial('COM4');
else
    fclose(ser);
    ser = ser(1);
end

% Connect to instrument object, obj1.
fopen(ser);
pause(2)

function closeSerial()
global ser
% Disconnect from the serial port.
fclose(ser);

% Clean up all objects.
ser = [];
        
% function ledOnXY(x, y)
%     global ser
%     if isempty(ser)
%         ser = serial('COM4');
%         fopen(ser);
%     end
% 
%     centerX = 17;
%     centerY = 18;
%     fprintf(ser,'%d %d\n', [centerX+x, centerY+y], 'sync'); 


% --- Executes on button press in pbStarLed.
function pbStarLed_Callback(hObject, eventdata, handles)
    persistent position
    if isempty(position)
        position = 1;
    end

    rgb = [7 0 0];
    off = [0 0 0];
    switch position
        case 1
            position = 2;
            lastLedOff();
            ledOnXY(0, 0, rgb)
            
        case 2
            position = 3;
            lastLedOff();
            ledOnXY(0, 1, rgb)
        case 3
            position = 4;
            lastLedOff();
            ledOnXY(1, 1, rgb)
        case 4
            position = 1;
            lastLedOff();
            ledOnXY(1, 0, rgb)
        case 5
            position = 1;
            lastLedOff();
            ledOnXY(0, 0, rgb)
    end

% --- Executes on button press in cbCenterLEDOn.
function cbCenterLEDOn_Callback(hObject, eventdata, handles)


    if get(hObject,'Value') == 1
        ledOnXY(0, 0, [0 7 0]);
    else
        ledOnXY(0, 0, [0 0 0]);
    end
    
% --- Executes on button press in cbWhiteSquare.
function cbWhiteSquare_Callback(hObject, eventdata, handles)
    offsetx = 0;
    offsety = -8;
    colorOn = [3 3 3]
    
    for x = -5: 5
        for y = -5: 5
            if get(hObject,'Value') == 1
                ledOnXY(x+offsetx, y+offsety, colorOn);
            else
                ledOnXY(x+offsetx, y+offsety, [0 0 0]);
            end
        end
    end
