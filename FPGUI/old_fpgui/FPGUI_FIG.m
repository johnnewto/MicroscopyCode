function varargout = FPGUI_FIG(varargin)
%  	Author: John Newton
%   Copyright 2016 
%   Version: 1.0  |  Date: 2016.07.16

% FPGUI_FIG M-file for FPGUI_FIG.fig
%      FPGUI_FIG, by itself, creates a new FPGUI_FIG or raises the existing
%      singleton*.
%
%      H = FPGUI_FIG returns the handle to a new FPGUI_FIG or the handle to
%      the existing singleton*.
%


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FPGUI_FIG_OpeningFcn, ...
                   'gui_OutputFcn',  @FPGUI_FIG_OutputFcn, ...
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


% --- Executes just before FPGUI_FIG is made visible.
function FPGUI_FIG_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes FPGUI_FIG wait for user response (see UIRESUME)
    % uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FPGUI_FIG_OutputFcn(hObject, eventdata, handles) 

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
