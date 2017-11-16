function varargout = FP_FIG(varargin)
%  	Author: John Newton
%   Copyright 2016 
%   Version: 1.0  |  Date: 2016.07.16

% FP_FIG M-file for FP_FIG.fig
%      FP_FIG, by itself, creates a new FP_FIG or raises the existing
%      singleton*.
%
%      H = FP_FIG returns the handle to a new FP_FIG or the handle to
%      the existing singleton*.
%


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FP_FIG_OpeningFcn, ...
                   'gui_OutputFcn',  @FP_FIG_OutputFcn, ...
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


% --- Executes just before FP_FIG is made visible.
function FP_FIG_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes FP_FIG wait for user response (see UIRESUME)
    % uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FP_FIG_OutputFcn(hObject, eventdata, handles) 

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



function edtNoise_Callback(hObject, eventdata, handles)
% hObject    handle to edtNoise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtNoise as text
%        str2double(get(hObject,'String')) returns contents of edtNoise as a double


% --- Executes during object creation, after setting all properties.
function edtNoise_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtNoise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtGapError_Callback(hObject, eventdata, handles)
% hObject    handle to edtGapError (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtGapError as text
%        str2double(get(hObject,'String')) returns contents of edtGapError as a double


% --- Executes during object creation, after setting all properties.
function edtGapError_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtGapError (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in togbtnGenLowResImages.
function togbtnGenLowResImages_Callback(hObject, eventdata, handles)
% hObject    handle to togbtnGenLowResImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togbtnGenLowResImages


% --- Executes on button press in btnRunFPcam.
function btnRunFPcam_Callback(hObject, eventdata, handles)
% hObject    handle to btnRunFPcam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of btnRunFPcam


% --- Executes on button press in btnConnectLEDs.
function btnConnectLEDs_Callback(hObject, eventdata, handles)
% hObject    handle to btnConnectLEDs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbSaveImages.
function pbSaveImages_Callback(hObject, eventdata, handles)
% hObject    handle to pbSaveImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in history_box.
function history_box_Callback(hObject, eventdata, handles)
% hObject    handle to history_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns history_box contents as cell array
%        contents{get(hObject,'Value')} returns selected item from history_box


% --- Executes during object creation, after setting all properties.
function history_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to history_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
