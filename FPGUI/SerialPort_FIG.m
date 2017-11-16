function varargout = SerialPort_FIG(varargin)
%  	Author: John Newton
%   Copyright 2016 
%   Version: 1.0  |  Date: 2016.07.16

% SERIALPORT_FIG M-file for SerialPort_FIG.fig
%      SERIALPORT_FIG, by itself, creates a new SERIALPORT_FIG or raises the existing
%      singleton*.
%
%      H = SERIALPORT_FIG returns the handle to a new SERIALPORT_FIG or the handle to
%      the existing singleton*.
%


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SerialPort_FIG_OpeningFcn, ...
                   'gui_OutputFcn',  @SerialPort_FIG_OutputFcn, ...
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


% --- Executes just before SerialPort_FIG is made visible.
function SerialPort_FIG_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes SerialPort_FIG wait for user response (see UIRESUME)
    % uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SerialPort_FIG_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);



function editColor_Callback(hObject, eventdata, handles)
% hObject    handle to editColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editColor as text
%        str2double(get(hObject,'String')) returns contents of editColor as a double


% --- Executes during object creation, after setting all properties.
function editColor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
