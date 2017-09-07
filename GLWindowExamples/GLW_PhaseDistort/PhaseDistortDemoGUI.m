function varargout = PhaseDistortDemoGUI(varargin)

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @PhaseDistortDemoGUI_OpeningFcn, ...
                       'gui_OutputFcn',  @PhaseDistortDemoGUI_OutputFcn, ...
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
end

% --- Executes just before PhaseDistortDemoGUI is made visible.
function PhaseDistortDemoGUI_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to PhaseDistortDemoGUI (see VARARGIN)

    % Choose default command line output for PhaseDistortDemoGUI
    handles.output = hObject;

    experimentParams = struct;
    experimentParams.generatePhaseFieldFromPinkNoise = false;
    experimentParams.useSoftCircularAperture = false;
    experimentParams.imageResizingFactor     = 1.5;
    experimentParams.questTrials             = 60;
    
    handles.experimentParams = experimentParams;
    
    set(handles.WindowImagesCheckbox, 'Value', handles.experimentParams.useSoftCircularAperture);
    if (experimentParams.generatePhaseFieldFromPinkNoise)
        set(handles.Noise1fMethodButton, 'Value', 1);
        set(handles.DavidMethodButton,   'Value', 0);
    else
        set(handles.Noise1fMethodButton, 'Value', 0);
        set(handles.DavidMethodButton,   'Value', 1);
    end
    
    set(handles.ResizingFactor, 'String', sprintf('%2.2f', handles.experimentParams.imageResizingFactor));
    set(handles.QuestTrials, 'String', sprintf('%2.0f', handles.experimentParams.questTrials));
    
    % Update handles structure
    guidata(hObject, handles);
    
    % UIWAIT makes PhaseDistortDemoGUI wait for user response (see UIRESUME)
    % uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = PhaseDistortDemoGUI_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;
end

% --- Executes on button press in StartExperiment.
function StartExperiment_Callback(hObject, eventdata, handles)
    
    handles.experimentParams.imageResizingFactor     = str2double(get(handles.ResizingFactor, 'String'));
    handles.experimentParams.questTrials             = str2double(get(handles.QuestTrials, 'String'));
    handles.experimentParams.useSoftCircularAperture = get(handles.WindowImagesCheckbox, 'Value');
    handles.experimentParams
    
    PhaseDistortDemo(handles.experimentParams.generatePhaseFieldFromPinkNoise, ...
                     handles.experimentParams.useSoftCircularAperture, ...
                     handles.experimentParams.imageResizingFactor, ...
                     handles.experimentParams.questTrials, ...
                     handles.ResultsAxes);            
end

function WindowImagesCheckbox_Callback(hObject, eventdata, handles)
     handles.experimentParams.useSoftCircularAperture = get(hObject,'Value');
end


function ResizingFactor_Callback(hObject, eventdata, handles)
    handles.experimentParams.imageResizingFactor = str2double(get(hObject,'String'));
end

function QuestTrials_Callback(hObject, eventdata, handles)
    handles.experimentParams.questTrials = str2double(get(hObject,'String'));
end

function ResizingFactor_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function edit2_Callback(hObject, eventdata, handles)

end

function edit2_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function RandomPhaseGenerationSelector_SelectionChangeFcn(hObject, eventdata, handles)

    switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
        case 'DavidMethodButton'
            handles.experimentParams.generatePhaseFieldFromPinkNoise = false;
        case 'Noise1fMethodButton'
            handles.experimentParams.generatePhaseFieldFromPinkNoise = true;
        otherwise
            % Code for when there is no match.
    end
 
end

function figure1_CreateFcn(hObject, eventdata, handles)
end

function QuestTrials_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function edit4_Callback(hObject, eventdata, handles)
end

function edit4_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
