function varargout = MCXeditor(varargin)
% MCXEDITOR MATLAB code for MCXeditor.fig
%      MCXEDITOR, by itself, creates a new MCXEDITOR or raises the existing
%      singleton*.
%
%      H = MCXEDITOR returns the handle to a new MCXEDITOR or the handle to
%      the existing singleton*.
%
%      MCXEDITOR('CALLBACK',heditObj,eventData,hedit,...) calls the local
%      function named CALLBACK in MCXEDITOR.M with the given input arguments.
%
%      MCXEDITOR('Property','Value',...) creates a new MCXEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MCXeditor_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MCXeditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIhedit

% Edit the above text to modify the response to help MCXeditor

% Last Modified by GUIDE v2.5 04-Oct-2018 13:44:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MCXeditor_OpeningFcn, ...
                   'gui_OutputFcn',  @MCXeditor_OutputFcn, ...
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


% --- Executes just before MCXeditor is made visible.
function MCXeditor_OpeningFcn(heditObj, eventdata, hedit, varargin)
% This function has no output args, see OutputFcn.
% heditObj    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% hedit    structure with hedit and user data (see GUIDATA)
% varargin   command line arguments to MCXeditor (see VARARGIN)

% Choose default command line output for MCXeditor
hedit.output = heditObj;

% Update hedit structure
guidata(heditObj, hedit);

% UIWAIT makes MCXeditor wait for user response (see UIRESUME)
% uiwait(hedit.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MCXeditor_OutputFcn(heditObj, eventdata, hedit) 
% varargout  cell array for returning output args (see VARARGOUT);
% heditObj    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% hedit    structure with hedit and user data (see GUIDATA)

% Get default command line output from hedit structure
varargout{1} = hedit.output;


function edit1_Callback(heditObj, eventdata, hedit)
% heditObj    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% hedit    structure with hedit and user data (see GUIDATA)
userInput = get(heditObj,'String');
disp(userInput)


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(heditObj, eventdata, hedit)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(heditObj,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(heditObj,'BackgroundColor','white');
end


% --- Executes on button press in RunScript.
function RunScript_Callback(heditObj, eventdata, hedit)
EditData = get(hedit.edit1, 'string'); hedit.EditData = string(EditData);

s = size(hedit.EditData);
%try
    for i = 1:s(1)
        eval(hedit.EditData{i,:});
    end
%catch
%   msgbox('The script is not correct!') 
%end
guidata(heditObj,hedit)

% --- Executes on button press in LoadScript.
function LoadScript_Callback(heditObj, eventdata, hedit)
p0=pwd;
[name, path] = uigetfile('*.m','Select Script');
cd(path)
set(hedit.edit1,'string','');
try
filetext = fileread(name);
filetext = string(filetext);
set(hedit.edit1, 'string',filetext);
catch
    
end
cd(p0)


% --- Executes on button press in SaveScript.
function SaveScript_Callback(heditObj, eventdata, hedit)
p0=pwd;
[filename, path] = uiputfile('*.m');
EditData = get(hedit.edit1, 'string'); hedit.EditData = string(EditData);
% for i=1:length(hedit.EditData)
% disp(hedit.EditData{i})
% end
cd(path)
f(1) = fopen(filename,'w');
    for i=1:length(hedit.EditData)
        fprintf(f(1),'%s \n',hedit.EditData{i});
    end
fclose(f(1));

cd(p0)


% --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
