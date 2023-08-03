function varargout = MCXgui(varargin)
    clc; 
    set(gcf,'Toolbar','none')

    %movegui(gcf,'north')
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @MCXgui_OpeningFcn, ...
                       'gui_OutputFcn',  @MCXgui_OutputFcn, ...
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
function MCXgui_OpeningFcn(hObject, ~, handles, varargin)
    global Energy;
    Energy = 12;
    handles.colx = 1; handles.coly=2;
%     handles.hRefData.Value=0;
    handles.output = hObject;
    handles.shdwclr = [0 .45 .74];
    handles.bgclr = get(gcf,'Color');  
    
    guidata(hObject, handles);


function varargout = MCXgui_OutputFcn(hObject, ~, handles) 
    varargout{1} = handles.output;



% --- LIST CREATION
function listbox1_CreateFcn(hObject, ~, handles)
    dirData = [dir('*.dat'); dir('*.xy'); dir('*.xye'); dir('*.gss'); dir('*.csv'); dir('*.ras')];  %# Get the data for the current directory
    dirIndex = [dirData.isdir];  %# Find the index for directories
    fileList = {dirData(~dirIndex).name}';  %'# Get a list of the files
    handles.listControl = uicontrol('style','listbox',...
    'units','Normalized',...
    'string',fileList,...
    'pos',[.45 .2 .5 .7],...
    'min',0,'max',10,...
    'callback',{@listbox1_Callback});
guidata(hObject, handles);

% --- PLOT DATA FIGURE
function listbox1_Callback(hObject, ~)
    handles = guidata(hObject);
    try
        handles.data = []; handles.filename=[];        
    catch        
    end    
    list = get(hObject,'string');
    FileToOpen=list(get(hObject,'value'));    
    try
     BarMsg = waitbar(0,'Loading data ...'); waitbar(0,BarMsg);
     for i=1:length(FileToOpen)
        handles.filename{i} = FileToOpen{i};
        try
            [handles.data{i},type] = MCX_LoadData(handles.filename{i},handles.hRefData.Value,handles.colx,handles.coly);
        catch
            [handles.data{i},type] = MCX_LoadData(handles.filename{i},0,handles.colx,handles.coly);
        end
        waitbar(i/length(FileToOpen),BarMsg);
        
     end
     waitbar(1,BarMsg);  
    catch e
     disp(e.message);
     delete(BarMsg);     return
    end
    
    delete(BarMsg);
    handles.pathname = pwd;
    %disp(handles.data{:}); return
    disp (handles.output);% return
    try 
        handles.figpos = get(handles.fig,'position');
    catch e
        e.message
    end
    set(gcf,'Units','Normalized');
    handles.fig = figure(1); %movegui(gcf,'northeast'); 
    set(handles.fig,'Units','Normalized','color','w');
        zoom(handles.fig,'on')

    handles.subplot.dat = subplot(1,1,1,'fontsize',16,'parent',handles.fig); 
    v=get(gca,'position'); set(gca,'position',[v(1) v(2) v(3) 0.8*v(4)]);
    set(gcf,'Toolbar','figure');
    uicontrol('Parent',handles.fig,'Style','text','String','E (keV)','Units','Normalized','position',[0.82 .85  0.08    0.035],'BackgroundColor','w');
    uicontrol('Parent',handles.fig,'Style','text','String','step:','Units','Normalized','position',[0.32    .92    0.08    0.04],'BackgroundColor','w');

    % FIGURE OPTIONS (radiobuttons)    
        FigOption_1 = uicontrol('Style','radiobutton','String','log(y)','Units','Normalized','Position',[0.17    0.96    0.12    0.045],'BackgroundColor','w');
            FigOption_1.Callback = @FigOptionLogY; 
        FigOption_2 = uicontrol('Style','radiobutton','String','log(X)','Units','Normalized','Position',[0.013    0.96    0.12    0.045],'BackgroundColor','w');
            FigOption_2.Callback = @FigOptionLogX;
         FigOption_3 = uicontrol('Style','radiobutton','String','Normalize','Units','Normalized','Position',[0.32    0.96    0.12    0.045],'BackgroundColor','w');
             FigOption_3.Callback = @FigOptionNorm;
        FigOption_4 = uicontrol('Style','radiobutton','String','2D plot','Units','Normalized','Position',[0.65    0.96    0.12    0.045],'BackgroundColor','w');
            FigOption_4.Callback = @FigOption2D;
        FigOption_5 = uicontrol('Style','pushbutton','String','Save data','Units','Normalized','Position',[0.85    0.95    0.12    0.045],'BackgroundColor','w');
            FigOption_5.Callback = @FigOptionSave;
        FigOption_6 = uicontrol('Style','radiobutton','String','Norm. to max','Units','Normalized','Position',[0.48    0.96    0.15   0.045],'BackgroundColor','w');
            FigOption_6.Callback = @FigOptionNorm2;
        FigOption_7 = uicontrol('Style','radiobutton','String','sqrt(y)','Units','Normalized','Position',[0.17    0.92    0.12    0.045],'BackgroundColor','w');
            FigOption_7.Callback = @FigOptionSqrtY;
        FigOption_8 = uicontrol('Style','pushbutton','String','Print Figure','Units','Normalized','Position',[0.85    0.9    0.12    0.045],'BackgroundColor','w');
            FigOption_8.Callback = @FigOptionSave2;    
        FigOption_9 = uicontrol('Style','Edit','String','12','Units','Normalized','Position',[0.9    .85    0.08    0.04],'BackgroundColor','w');
            FigOption_9.Callback = @EnergyEdit;   
        FigOption_10a = uicontrol('Style','edit','String','0','Units','Normalized',...
            'Position',[0.4    .92    0.04    0.04],...
            'BackgroundColor','w');
            FigOption_10a.Callback = @SplitEditA;
            
   for i = 1:length(FileToOpen)
    disp(type)
    %if type ~= 'Rietveld'   
        
    %end
    
    switch type
        case 'Rietveld'
            disp('Rietveld refinement')
            set(gca,'Yscale','lin')
            xlabel('2$\theta$','Interpreter','latex'); hold on;
            plot(handles.data{i}(:,1),handles.data{i}(:,2),...
                '.','parent',handles.subplot.dat,'Linewidth',1,...
                'MarkerSize',10,...
                'color',i*[0.2  .1 .25]/length(handles.data)); hold on;
            plot(handles.data{i}(:,1),handles.data{i}(:,4),...
             '-','parent',handles.subplot.dat,'Linewidth',2,...
             'color',i*[0.8 0.6 0.4]/length(handles.data)); 
            plot(handles.data{i}(:,1),handles.data{i}(:,5),...
             '-','parent',handles.subplot.dat,'Linewidth',1); 
            plot(handles.data{i}(:,1),handles.data{i}(:,2)-handles.data{i}(:,4),...
             '-','parent',handles.subplot.dat,'Linewidth',1); 
        case 'reflectivity'
            set( FigOption_1,'Value',1)
            set(gca,'Yscale','log')
            if handles.colx==1
                xlabel('Q (\AA$^{-1}$)','Interpreter','Latex'); 
            elseif handles.colx==3
                xlabel('2$\theta$','Interpreter','Latex'); 
            else
                xlabel('','Interpreter','Latex'); 
            end
        case 'diff'
            set(gca,'Yscale','lin')
            xlabel('2$\theta$','Interpreter','latex'); 
            plot(handles.data{i}(:,1),handles.data{i}(:,2),...
                '-','parent',handles.subplot.dat,'Linewidth',1,...
                'color',i*[0.8 0.6 0.4]/length(handles.data)); hold on;
     end
   end
    
    ylabel('counts','Interpreter','Latex');
    legend(handles.filename, 'Interpreter','none','box','off');
    handles.FigAxes = get(gcf,'CurrentAxes');
    handles.fig = gcf;
    set (gcf, 'WindowButtonMotionFcn', @mouseMove);
    set( gcf, 'pointer','crosshair', 'ToolBar', 'figure')
    handles.subplot.Toolbar.Visible = 'on';
uistack(MCXgui,'top')
set(MCXgui,'visible','on');
guidata(hObject, handles);


%%%%%%% PLOT options %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mouseMove (object, eventdata)
global Energy
gg=get(gcf,'CurrentAxes');

C = get (gg, 'CurrentPoint');
set(gcf,'Toolbar','figure');
Xstr =  num2str( round(C(1,1),3) ); Ystr = num2str( round(C(1,2),1) );

lambda = (12.39845)/Energy;
    d = ((lambda/2)/(sind(C(1,1)/2)));
    InfoStr = ['[X,Y] = (',Xstr, ', ',Ystr, ')  -  \textit{d} = ' num2str(round(d(1),3)) ' \AA' ];
title(gca, InfoStr,'Interpreter','Latex');
T = get(gca,'title');
T.Units = 'Normalized';
T.Position = [0.45,1.13,0];

function EnergyEdit (object, eventdata)
global Energy
Energy = str2double(get(object,'string'));


function SplitEditA (src, ~)
    n=str2double(get(src,'String'));
    da = get(gca,'Children'); 
    clear legstr;
    for i=1:length(da)
        legstr{i}=da(i).DisplayName;
        XData{i}=da(i).XData;
        YData{i}=da(i).YData;
    end
    legstr1=fliplr(legstr);
    hold off;
    for i = 1:length(XData)
        plot(XData{i},YData{i}+n*(i-1),'-','parent',gca,'Linewidth',1,'color',i*[0.8 0.6 0.4]/length(XData)); hold on;    
    end
try
    hleg = legend(legstr1, 'Interpreter','none','box','off');
%     set(hleg);
catch
end
xlabel('2$\theta$','Interpreter','Latex'); ylabel('counts','Interpreter','Latex')

function FigOptionLogX(src,~)
    val = get(src,'value'); set(src,'Units','Normalized');
    get(src,'position');

    if val == 0
        set(gca, 'XScale', 'lin')
    elseif val == 1
        set(gca, 'XScale', 'log')
    end

function FigOptionLogY(src,~)
val = get(src,'value'); 
%set(src,'Units','Normalized','color','w');
get(src,'position');
if val == 0
    set(gca, 'YScale', 'lin')
elseif val == 1
    set(gca, 'YScale', 'log')
end

function FigOptionSqrtY(src, ~)
val = get(src,'value');
da = get(gca,'Children'); 
clear legstr;
for i=1:length(da)
    legstr{i}=da(i).DisplayName;
    XData{i}=da(i).XData;
    YData{i}=da(i).YData;
end
hold off;

for i = 1:length(XData)
if val == 0
    plot(XData{i},YData{i}.^2,'-','parent',gca,'Linewidth',1,'color',i*[0.8 0.6 0.4]/length(XData)); hold on;
elseif val == 1
   plot(XData{i},sqrt(YData{i}),'-','parent',gca,'Linewidth',1,'color',i*[0.8 0.6 0.4]/length(XData)); hold on;   
end
ylabel('counts','Interpreter','Latex');
try
hleg = legend(legstr, 'Interpreter','none','box','off');
% set(hleg, 'Interpreter','none','box','off');
catch
end
end

function FigOptionNorm(src, ~)
val = get(src,'value');
da = get(gca,'Children'); 
clear legstr;
for i=1:length(da)
    legstr{i}=da(i).DisplayName;
    XData{i}=da(i).XData;
    YData{i}=da(i).YData;
end
hold off;

for i = 1:length(XData)
if val == 0
    plot(XData{i},YData{i},'-','parent',gca,'Linewidth',1); hold on;
elseif val == 1
   plot(XData{i},YData{i}/trapz(YData{i}),'-','parent',gca,'Linewidth',1,'color',i*[0.8 0.6 0.4]/length(YData)); hold on;   
end
ylabel('counts','Interpreter','Latex');
try
hleg = legend(legstr, 'Interpreter','none','box','off');
% set(hleg);
catch
end
end

function FigOptionNorm2(src, ~)
val = get(src,'value');
da = get(gca,'Children'); 
clear legstr;
for i=1:length(da)
    legstr{i}=da(i).DisplayName;
    XData{i}=da(i).XData;
    YData{i}=da(i).YData;
end
hold off;

for i = 1:length(XData)
if val == 0
    plot(XData{i},YData{i},'-','parent',gca,'Linewidth',1); hold on;
elseif val == 1
   plot(XData{i},YData{i}/max(YData{i}),'-','parent',gca,'Linewidth',1); hold on;   
end
ylabel('counts','Interpreter','Latex');
try
hleg = legend(legstr, 'Interpreter','none','box','off');
% set(hleg, 'Interpreter','none','box','off');
catch
end
end

function FigOption2D(src,~)
val = get(src,'value'); set(src,'Units','Normalized');
if val == 0
   close(gcf)
elseif val == 1
   da=get(gca,'Children');
   for i=1:length(da)
      xdata{i} = da(i).XData; 
      ydata{i} = da(i).YData;
   end
   if length(xdata)<2
       msgbox('Please, select more data')
       return
   end
      hold off
   for i=1:length(ydata)
      L(i)=length(ydata{i});
   end
   lmin = min(L);
   runs = (0:1:length(ydata)-1);
   
   BarMsg = waitbar(0,'Loading...'); waitbar(0,BarMsg);
    for i=1:length(ydata)
        YY(i,:) = ydata{length(ydata)-i+1}(1:lmin);
        waitbar(i/length(ydata),BarMsg);
    end
    %YY = flip(YY);
    waitbar(1,BarMsg); delete(BarMsg);
%    surfc(xdata{1}(1:lmin),runs,YY,'edgecolor','none','FaceAlpha',0.98,'EdgeColor','none'); view([0 90]); grid off
   
    N=35; 
    for h=1:N
        fcn(h,:)=[1*h/N .15 1-0.9*h/N];
    end
   surfc(xdata{1}(1:lmin),runs,YY,'edgecolor','none','FaceAlpha',0.85,'EdgeColor','none'); view([0 90]); grid off
   colormap(fcn);
   brighten(-0.525)
    shading(gca,'interp')
    
   xlabel('2$\theta$','Interpreter','Latex'); ylabel('run number','Interpreter','Latex'); xlim([min(xdata{1}) max(xdata{1})]);ylim([0 length(ydata)-1])
   colorbar; %colormap(jet)
   %colormap(brewermap([],'*YlGnBu'))
end

function FigOptionSave(src,~)
set(gca,'yscale','lin')
da = get(gca,'Children'); 
BarMsg = waitbar(0,'Please wait, saving data to file-mod.xy ...'); 
waitbar(0,BarMsg);
for i=1:length(da)
    A = [da(i).XData', da(i).YData' 1e-3*(da(i).YData')/length(da(i).YData)];
waitbar(i/length(da),BarMsg)    
f{i} = fopen([da(i).DisplayName '-mod.xy'], 'wt');
    fprintf(f{i}, '%3.6f %10.15f %10.15f\n',A.');
fclose(f{i});
end
waitbar(1,BarMsg)    
delete(BarMsg)
set(gca,'yscale','log')

function FigOptionSave2(src,~)
AxesH = gca;
Figure2 = figure;
copyobj(AxesH, Figure2);
title('');
answer=inputdlg('Save figure as','save figure as',1,{'Figure.png'});
saveas(gcf,answer{1})


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in hPath.
function hPath_Callback(hObject, ~, handles)
try
    close(handles.fig);
catch
end
p0 = pwd;
handles.pathname=uigetdir(p0);
cd(handles.pathname);
guidata(hObject, handles);
close(MCXgui)
MCXgui

% --- RESET/RESTART/DEBUG.
function BP_reset_Callback(hObject, ~, handles)
close(MCXgui)
MCXgui



% --- Executes on button press in hInterpolate.
function hInterpolate_Callback(hObject, ~, handles)
prompt={'Grid (>/= 1)'};
Guess={'1'};
Grid=inputdlg(prompt,'Input for Interpolation',[1 35],Guess);
BarMsg = waitbar(0,'Please wait Until Interpolation is completed...'); 
try
   for i=1:length(handles.filename)
      try 
       [a,~] = MCX_LoadData(handles.filename{i},handles.hRefData.Value,handles.colx,handles.coly);

        figure('color','w'); hold on; box on; xlabel('2$\theta$','Interpreter','Latex'); ylabel('Intensity','Interpreter','Latex')

        plot(a(:,1),a(:,2),'o','linewidth',1);
        waitbar(i/length(handles.filename)-0.1,BarMsg)
            [X,Y,eY]=InterpolTheGaps(a(:,1),a(:,2),a(:,3),str2double(Grid));
        plot(X,Y,'-+','linewidth',1); legend('data','Interpolation', 'Interpreter','none','box','off');
        savename = [handles.filename{i}(1:(end-4)),'_ntrp','.xye'];
    
        f1{i} = fopen(savename, 'wt');
        A = [ X' , Y' , eY'];
        fprintf(f1{i}, '%3.5f %10.5f %10.6f\n',A.');
        fclose(f1{i});
      
      catch e1
          disp(e1.message);
      end
    end
   
catch e
delete(BarMsg);
disp(e.message);
close(MCXgui)
end

MCXgui;
delete(BarMsg);
msgbox(['All data have been interpolated and saved in *_interpolated.xye']);
% update list
 dirData = [dir('*.dat'); dir('*.xy'); dir('*.xye'); dir('*.ras')];  %# Get the data for the current directory
    dirIndex = [dirData.isdir];  %# Find the index for directories
    fileList = {dirData(~dirIndex).name}';  %'# Get a list of the files
    handles.listControl.String = fileList;
guidata(hObject,handles);

% --- Executes on button press in hDATconvXY. SAVE data TO XY
% (export/convert DAT to XY)
function hDATconvXY_Callback(hObject, eventdata, handles) 
handles = guidata(hObject);
filename = handles.filename;
GSASscale = 99999;

for i = 1:length(filename)
   filename{i}(end-2:end)
    if filename{i}(end-2:end) == "xye" || filename{i}(end-2:end) == ".xy"
           msgbox('Please, select *.dat files only!') 
           return
    end
end

BarMsg = waitbar(0,'Please wait until data have been converted...'); 
waitbar(0.1,BarMsg)
if ~iscell(filename)
    filename = {filename};
end
try
  for i = 1:length(filename)
    [a{i},~] = MCX_LoadData(handles.filename{i},handles.hRefData.Value,handles.colx,handles.coly);
    savename{i} = [filename{i}(1:(end-4)),'.xy'];
    f{i} = fopen(savename{i}, 'wt');

    if handles.hRefData.Value == 0 % powder diffraction data
        if max(a{i}(:,2))>GSASscale
            I = (a{i}(:,2)./a{i}(:,3))*GSASscale;            
        else
            I = (a{i}(:,2)./a{i}(:,3))*GSASscale;            
        end    
        
        A = [ a{i}(:,1) , I];
        fprintf(f{i}, '%3.5f %10.5f \n',A.');    
        
    elseif handles.hRefData.Value == 1  % reflectivity data (no need to convert)
        A = [ a{i}(:,2) , a{i}(:,4) ]; % 
        fprintf(f{i}, '%f %f \n',A.'); 
    else
        waitbar(0,msgbox('Invalid input (reflectivity data checkbox ON).'));
        return
    end
    fclose(f{i});
    disp([filename{i} ' has been saved as ' savename{i}])
    waitbar(i/length(filename),BarMsg)
  end
    waitbar(1,BarMsg)
catch
  delete(BarMsg);
end
delete(BarMsg);
uiwait(msgbox(savename, 'Saved data','modal'));

% update list
 dirData = [dir('*.dat'); dir('*.xy'); dir('*.xye');  dir('*.ras') ];  %# Get the data for the current directory
    dirIndex = [dirData.isdir];  %# Find the index for directories
    fileList = {dirData(~dirIndex).name}';  %'# Get a list of the files
    handles.listControl.String = fileList;
guidata(hObject,handles);

% --- Executes on button press in hDATconv. SAVE/Export/Convert data TO XYE
function hDATconv_Callback(hObject, ~, handles)
handles = guidata(hObject);
filename = handles.filename;
GSASscale = 99999;
for i = 1:length(filename)
    if filename{i}(end-2:end) == "xye" || filename{i}(end-2:end) == ".xy"
           msgbox('Please, select *.dat files only!') 
           return
    end
end
    

BarMsg = waitbar(0,'Please wait until data have been converted...'); 
waitbar(0.1,BarMsg)
if ~iscell(filename)
    filename = {filename};
end
try

for i = 1:length(filename)
    [a{i},~] = MCX_LoadData(handles.filename{i},handles.hRefData.Value,handles.colx,handles.coly);    
    savename{i} = [filename{i}(1:(end-4)),'.xye'];
    f{i} = fopen(savename{i}, 'wt');
    
    if handles.hRefData.Value == 0 % powder diffraction data      
      if ~all(a{i}(:,3)) % empty I0 column
        if max(a{i}(:,2))>GSASscale
            I = (GSASscale/max(a{i}(:,2)))*(a{i}(:,2)./a{i}(:,3));
            eI = (GSASscale/max(a{i}(:,2)))*sqrt(a{i}(:,2))./(a{i}(:,3));
        else
            I = max(a{i}(:,2))*(a{i}(:,2)./a{i}(:,3));
            eI = max(a{i}(:,2))*sqrt(a{i}(:,2))./(a{i}(:,3));
        end    
      else % normal data containing both I and I0 
            I = (a{i}(:,2)./a{i}(:,3))*GSASscale;
            eI = (sqrt(a{i}(:,2))./a{i}(:,3))*GSASscale;       
      end
        A = [ a{i}(:,1) , I , eI];
        fprintf(f{i}, '%3.5f %10.5f %10.5f\n',A.');    
    else % reflectivity data (no need to convert)
      A = [ a{i}(:,2) , a{i}(:,4) , 1e-3*sqrt(a{i}(:,4))]; % modify error
      fprintf(f{i}, '%3.5f %10.5f %10.5f\n',A.'); 
      return
    end
    fclose(f{i});
    disp([filename{i} ' has been saved as ' savename{i}])
    waitbar(i/length(filename),BarMsg)
end
waitbar(1,BarMsg)
catch
delete(BarMsg);
end
delete(BarMsg);
uiwait(msgbox(savename, 'Saved data','modal'));
% update list
 dirData = [dir('*.dat'); dir('*.xy'); dir('*.xye'); dir('*.ras')];  %# Get the data for the current directory
    dirIndex = [dirData.isdir];  %# Find the index for directories
    fileList = {dirData(~dirIndex).name}';  %'# Get a list of the files
    handles.listControl.String = fileList;
guidata(hObject,handles);

% --- Executes on key press with focus on listbox1 and none of its controls.
function listbox1_KeyPressFcn(hObject, ~, handles)


% --- Executes during object creation, after setting all properties.
function hDATconv_CreateFcn(hObject, ~, handles)


% --- EXPORT to GSAS (hGSASconv)
function hGSASconv_Callback(hObject, ~, handles)
%[filename] = uigetfile('*.dat;*.xye;*.xy','Choose .dat file(s) to convert','multiselect','on');
handles = guidata(hObject);
filename = handles.filename;


BarMsg = waitbar(0,'Please wait until data have been converted...'); 
waitbar(0.1,BarMsg)
try
if ~iscell(filename)
    filename = {filename}; % filename must be a cell array anyway!
end
if handles.hRefData.Value == 1
    waitbar(0,msgbox('Sorry, cannot convert reflectivity data into GSAS!'));
    return
end
for i = 1:length(filename)
[a{i}] = MCX_LoadData(handles.filename{i},handles.hRefData.Value,handles.colx,handles.coly);
    switch filename{i}(end-2:end)
    case('dat')
        savename{i} = [filename{i}(1:(end-4)),'.gsas'];
    case('xye')
        savename{i} = [filename{i}(1:(end-4)),'.gsas'];
    case('.xy')
        savename{i} = [filename{i}(1:(end-3)),'.gsas'];
    end
title = 'MCX generated gsas-file';
npoints = length(a{i});
Nlines = round((npoints-1)/10+1);
FirstElement = a{i}(1,1);
LastElement = a{i}(end,1);
GSASautoscale = 99999;

    ScaledData = a{i}(:,2);

step = sqrt( ((LastElement-FirstElement)/npoints)^2 );

f{i} = fopen(savename{i}, 'wt');
    fprintf(f{i},'%-70s%10.2f \n' , title, LastElement*100.0)
    fprintf(f{i},'BANK 1 %8d %8d CONST %10.2f %10.5f 0 0 %4s %30s\n',npoints,Nlines,100.0*FirstElement,100.0*step,' STD','')
for k = 1:Nlines
    try
    fprintf(f{i},' %6.0f ',ScaledData(k*10-9:k*10));
    fprintf(f{i},'\n');
    catch
    fprintf(f{i},' %6.0f ',ScaledData(k*10-9:end));    
    fprintf(f{i},'%6.0f ',ScaledData(npoints));    
    end
end
fclose(f{i});
disp([filename{i} ' has been saved as ' savename{i}]);
waitbar(i/length(filename),BarMsg);
end
waitbar(1,BarMsg);
catch
delete(BarMsg);
end
delete(BarMsg);
% update list
 dirData = [dir('*.dat'); dir('*.xy'); dir('*.xye'); dir('*.ras')];  %# Get the data for the current directory
    dirIndex = [dirData.isdir];  %# Find the index for directories
    fileList = {dirData(~dirIndex).name}';  %'# Get a list of the files
    handles.listControl.String = fileList;
guidata(hObject,handles);



% --- Executes on button press in pushbutton_SiCalib. (MINUIT) - LeBail
% refinement
function pushbutton_SiCalib_Callback(hObject, ~, handles)
    handles.calibration.Guess = inputdlg({'Select Energy (keV)','zero guess'},'Input for Calibration',[1 35],{'10','0'});
    
    standardQuestion = questdlg('Please, choose standard material:', ...
                             'Standard', ...
                             'Silicon', 'CeO2', 'LaB6', 'Silicon');
    % Handle response
    switch standardQuestion
        case 'Silicon'
            handles.calibration.standard = 'Si';
        case 'CeO2'
            handles.calibration.standard = 'CeO2';
        case('LaB6')
            handles.calibration.standard = 'LaB6';
    end
    dhkl=dHKL(handles.calibration.standard);

    pw0 = pwd;
    handles.calibration.Energy = str2double(handles.calibration.Guess(1));  
    handles.calibration.Zero = str2double(handles.calibration.Guess(2));  
    cd(pw0)

    % start fitting (fminuit)
    Method = 'Caglioti'; % this one works better
    disp(handles.filename{1})
    if length(handles.filename) > 1
       warndlg('Multiple files selected: calibration applied only on the first file!','Warnign!','modal'); 
    end
    handles.calibration.FileSiName = handles.filename{1};
    handles.calibration.data = handles.data{1};
    
    [FitParam, ErrParam, a] = MCX_Standard(handles.calibration.Energy,...
        handles.calibration.Zero,...
        handles.calibration.FileSiName,...
        Method,handles.calibration.standard,...
        handles.colx,...
        handles.coly);   
    
    xth = [min(a(:,1))-1:.001:max(a(:,1))+1];
    switch Method
      case ('Caglioti')
        parfit{1} = FitParam(1); eparfit{1} = ErrParam(1); % refined lambda
        parfit{2} = FitParam(2); eparfit{2} = ErrParam(2); % refined eta
        parfit{3} = FitParam(3); eparfit{3} = ErrParam(3); % refined zero
            n = length(FitParam(1,4:end-3)); % number of peaks
        parfit{4} = FitParam(4:3+n); eparfit{4} = ErrParam(4:3+n); % refined Intensities
        parfit{5} = FitParam(end-2:end); eparfit{5} = ErrParam(end-2:end); % refined Profile

        y = MCX_multiPV_Caglioti(xth,parfit);

        ydiff = MCX_multiPV_Caglioti(a(:,1),parfit)-a(:,2)'-0.1*max(a(:,2));
        parstr = ['[U, V, W] = '];
        disp(['lambda = ' num2str(parfit{1}) ])
        disp(['zero = ' num2str(parfit{3}) ])
        disp(['Lor-Gauss mixing = ' num2str(parfit{2}) ])
        disp(['Intensities = ' num2str(parfit{4}) ])
        disp([parstr, num2str(parfit{5}) ])
        tth_c = real(2*asind( parfit{1}./(2*dhkl(1:length(parfit{4})))  )) + parfit{3};

      case('GSAS')
        parfit{1} = FitParam(1); eparfit{1} = ErrParam(1); % refined lambda
        parfit{2} = FitParam(2); eparfit{2} = ErrParam(2); % refined zero
            n = length(FitParam(1,3:end-5)); % number of peaks
        parfit{3} = FitParam(3:2+n); eparfit{3} = ErrParam(3:2+n); % refined Intensities
        parfit{4} = FitParam(end-4:end); eparfit{4} = ErrParam(end-4:end); % refined Profile

        y = MCX_multiPV_GSAS(xth,parfit); 
        ydiff = MCX_multiPV_GSAS(a(:,1),parfit)-a(:,2)'-0.1*max(a(:,2));
        disp([int2str(n) ' peaks have been fitted: '])
        disp(parfit{3})

        disp(['lambda = ' num2str(parfit{1}) ])
        disp(['zero = ' num2str(parfit{2}) ])
        disp(['Intensities = ' num2str(parfit{3}) ])
        disp(['[U, V, W, X, Y] = ', num2str(parfit{4}) ])
        tth_c = real(2*asind( parfit{1}./(2*dhkl(1:length(parfit{3})))  )) + parfit{2};
    end

    cla(gca)
    plot(a(:,1),a(:,2),'ko'); hold on; 
    plot(xth,y,'-','linewidth',1); box on; xlabel('2$\theta$ (deg)','Interpreter','Latex'); ylabel('Intensity (a.u.)','Interpreter','Latex')
    plot(a(:,1),ydiff,'-');
    set(gcf,'color','w')


     for i=1:length(tth_c)
         plot([tth_c(i) tth_c(i)],[-max(a(:,2))*(0.1) -max(a(:,2))*0.12],'k-','linewidth',1); 
     end
    title(handles.calibration.FileSiName,'Interpreter','none');
    l1 = legend({'data','fit','diff','refs'},'box','off','color','none','Interpreter','none');

%     set(l1,'box','off','color','none','Interpreter','none');

    if length(parfit) == 5
        Res = {['$\lambda$ = ' num2str(round(1e4*parfit{1})/1e4) '(' '$\pm$' num2str(roundsd(eparfit{1},2)) ') \AA']; ...
        ['zero = ' num2str(round(1e4*parfit{3})/1e4) '(' '$\pm$' num2str(roundsd(eparfit{3},2)) ')']};

    elseif length(parfit) == 4
        Res = {['$\lambda$ = ' num2str(round(1e4*parfit{1})/1e4) '(' '$\pm$' num2str(roundsd(eparfit{1},2)) ') \AA']; ...
        ['zero = ' num2str(round(1e4*parfit{2})/1e4) '(' '$\pm$' num2str(roundsd(eparfit{2},2)) ')']};    

    end

    text(.2, .85, Res{1},'Units','Normalized','Parent',gca,'Interpreter','Latex');
    text(.2, .80, Res{2}, 'Units','Normalized','Parent',gca,'Interpreter','Latex');
    text(.2, .75, ['E='  num2str(round(12.3984202/parfit{1},3)) ' keV'], 'Units','Normalized','Parent',gca,'Interpreter','latex');
    zoom(gcf,'on')
    guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function pushbutton_SiCalib_CreateFcn(hObject, ~, handles)

% --- Executes on button press in hSelectRegion. SLICE DATA
function hSelectRegion_Callback(hObject, ~, handles)
    axes(handles.subplot.dat); %set the current axes to axes2
        [rect] = ginput(2); % get x-limits to cut
    for i = 1:length(handles.data)    
        x{i} = handles.data{i}(:,1); 
        y{i} = handles.data{i}(:,2);
        ey{i} = handles.data{i}(:,3);

        switch handles.filename{i}(end-2:end)
        case '.xy'
            n(i) = 3;
        case 'xye'
            n(i) = 4;
        case 'dat'
            n(i) = 4;
        end
        DATAs = data_slice(rect(1,1),rect(2,1),[x{i},y{i},ey{i}]); 
        X{i}=DATAs(:,1);     Y{i}=DATAs(:,2);     eY{i}=DATAs(:,3); 
        handles.data{i} = [X{i} Y{i} eY{i}];

        plot(X{i},Y{i},'-','parent',handles.subplot.dat,'Linewidth',1); hold on;
        handles.range = [rect(1,1) rect(2,1)];
        handles.figpos = get(handles.fig,'position');

    end
    answer = questdlg('Would you like to save data with new range?', ...
        'Save menu', ...
        'YES','NO','NO');

    switch answer % Handle response
        case 'YES'
        BarMsg = waitbar(0,'Removing excluded data and saving to _sliced.xye file ...'); 
        BarMsg.Children.Title.Interpreter = 'none';
        waitbar(0.05,BarMsg);
        for i = 1:length(handles.filename)
            savename = [handles.filename{i}(1:end-n(i)) '_sliced.xye'];
            sliced_file = fopen(savename, 'wt');
                S = [handles.data{i}];
                fprintf(sliced_file,'%4.5f %10.3f %10.3f\n',S.');
            fclose(sliced_file);
            waitbar(i/length(handles.filename),BarMsg);
        end
        waitbar(1,BarMsg); delete(BarMsg);
        msgbox('Sliced data have been saved!');
        case 'NO'
            return
    end
    zoom(gcf,'on')
    guidata(hObject, handles);

% --- REMOVE BACKGROUND sav button (_SUB)
function ApplyBgdButton_Callback(hObject, ~, handles)
    cla(handles.subplot.dat,'reset');
    BarMsg = waitbar(0,'Removing background from data and saving to *_SUB.xye file. Please wait'); 
    BarMsg.Children.Title.Interpreter = 'none';
     waitbar(0.5,BarMsg);

    for k = 1:length(handles.yb)
        yn = handles.data{k}(:,2)-handles.yb{k};
        savename={[(handles.filename{k}(1:end-4)) '_SUB.xye']};
       try
        sub_file = fopen(savename{1}, 'wt');
            A = [handles.data{k}(:,1) yn sqrt(handles.data{k}(:,3))/length(handles.data{k}(:,3))];
            fprintf(sub_file,'%3.6f %10.6f %10.6f\n',A.');
        fclose(sub_file);
        handles.filename{k} = savename{1};
        delete(BarMsg);
        catch e
            e.message
            delete(BarMsg)
            msgbox(['Something wrong here...' savename]);
        end
    plot(handles.data{k}(:,1),yn,'-','parent',handles.subplot.dat); hold on;
    legend(handles.filename{k},'fit','box','off','color','none','Interpreter','none')
    handles.data{k} = [handles.data{k}(:,1) yn handles.data{k}(:,3)];
    end
    zoom(gcf,'on')
    
    % update list
    dirData = [dir('*.dat'); dir('*.xy'); dir('*.xye'); dir('*.ras') ];  %# Get the data for the current directory
    dirIndex = [dirData.isdir];  %# Find the index for directories
    fileList = {dirData(~dirIndex).name}';  %'# Get a list of the files
    handles.listControl.String = fileList;
    guidata(hObject,handles);

% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, ~, handles)


% --- Executes on slider movement.
function sliderBgd_Callback(hObject, ~, handles)
    order=round(get(hObject,'Value'));
    try
    cla(handles.subplot.dat,'reset');
    hold off;
    for i = 1:length(handles.data)
        [Ybgd,~,~] = backcor_Mattia(handles.data{i}(:,1),handles.data{i}(:,2),order,0.1,'atq');
        disp(order)
        handles.yb{i} = Ybgd;
%          plot(handles.data{i}(:,1),handles.data{i}(:,2),'k-', 'parent',handles.subplot.dat); hold on;
       if i==1 
        plot(handles.data{i}(:,1),handles.data{i}(:,2),'b-',...
            handles.data{i}(:,1),handles.data{i}(:,2)-handles.yb{i},'r',...
            handles.data{i}(:,1),handles.yb{i},'g',...
            'parent',handles.subplot.dat); hold on; 
       else
        plot(handles.data{i}(:,1),handles.data{i}(:,2),'b-',...
            handles.data{i}(:,1),handles.data{i}(:,2)-handles.yb{i},'r',...
            handles.data{i}(:,1),handles.yb{i},'g',...
            'parent',handles.subplot.dat); hold on; 
       end
        
    end
    box on;
    catch e
        e.message
        msgbox('Please, open some data first')
    end
    guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function sliderBgd_CreateFcn(hObject, ~, handles)
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
    numSteps = 18;
    set(hObject,'min',0,'max',numSteps,...
    'SliderStep',[1/(numSteps-1) , 1/(numSteps-1) ]);

% --- Executes during object creation, after setting all properties.
function hGSASconv_CreateFcn(hObject, ~, handles)

% --- Executes during object creation, after setting all properties.
function hSelectRegion_CreateFcn(hObject, ~, handles)

% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
    ImagePlateConvFun_2()

% --- Executes during object deletion, before destroying properties.
function listbox1_DeleteFcn(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function uipanel5_CreateFcn(hObject, eventdata, handles)


% --- Executes on button press in hRefData. %Reflectivity option checkbox
function hRefData_Callback(hObject, ~, handles)
    handles.hRefData = hObject;
    val = get(hObject,'Value'); %returns toggle state of checkbox1
    handles.hRefData.Value = val;%disp(handles.hInvertCols.Value)
    guidata(hObject, handles);


% --------------------------------------------------------------------
function hMenuPeak_Callback(~, ~, handles) % direct beam fit
clc;
S = get(handles.FigAxes,'Children');
x = S.XData;
y = S.YData;

[~, indexAtMaxY] = max(y);
x0 = x(indexAtMaxY(1));
chi2in.model = 'pseudoVoigt'; %y = pseudovoigt(x,[Amp,x0,eta,FWHM])
chi2in.data=[x; y];
fh=str2func(chi2in.model);
guess=[max(y) x0 .1 .03 1e-2];
global stepbounds 
stepbounds = [1 -1 0 1e12*max(y);...
              2  1 min(x) max(x)
              3  1 1e-6    0.999999999;...
              4  1 1e-6 1e6;...
              5  1 -1e-6    max(y)];
[par, ~, ~] = fminuit('chi2',guess,chi2in,'-b');

figure('Color','w'); hold on; box on;

plot(x,y,'ko'); plot(x,fh(x,par),'LineWidth',2,'Color',[.8 .6 .4]);
text(.7,.8,['2$\theta_0$=',num2str(round(par(2),4))],'Units','normalized','Interpreter','latex');
text(.7,.7,['fwhm=',num2str(round(par(4),3))],'Units','normalized','Interpreter','latex');
text(.7,.6,['$\eta$=',num2str(round(par(3),2))],'Units','normalized','Interpreter','latex');
zoom(gcf,'on')


% --------------------------------------------------------------------
function help_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function menu_editor_Callback(hObject, eventdata, handles)
    MCXeditor

% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)


% --- Executes on slider movement.
function sliderSmoothing_Callback(hObject, eventdata, handles)
    order=round(get(hObject,'Value'));        
        cla(handles.subplot.dat,'reset');
        for i = 1:length(handles.data)
            [handles.xs{i},handles.ys{i}] = sweet(handles.data{i}(:,1),handles.data{i}(:,2),order);

            hold on; box on;
        end
    plot(handles.data{1}(:,1),handles.data{1}(:,2),'b',handles.xs{1},handles.ys{1},'r','parent',handles.subplot.dat);  % first

    guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function sliderSmoothing_CreateFcn(hObject, eventdata, handles)
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
    numSteps = 30;
    set(hObject,'min',0,'max',numSteps,...
    'SliderStep',[1/(numSteps-1) , 1/(numSteps-1) ]);

% --- Executes on button press in ApplySmoothingButton.
function ApplySmoothingButton_Callback(hObject, eventdata, handles)
    cla(handles.subplot.dat,'reset');

    BarMsg = waitbar(0,'Smothing data and saving to *_SMTD.xye file. Please wait'); 
    BarMsg.Children.Title.Interpreter = 'none';
        waitbar(0.05,BarMsg);
        switch handles.filename{1}(end-2:end)
            case('.xy')
                n=2;
            case('dat')
                n=4;
            case('xye')
                n=4;
        end
        
        try
        fclose('all');
         for i=1:length(handles.xs)  
            savenameS=[(handles.filename{i}(1:end-n)) '_smth.xye'];
            smtd_file = fopen(savenameS, 'w');
                A = [handles.xs{i} handles.ys{i} 1e-3*sqrt(handles.ys{i})/length(handles.ys{i})];
                fprintf(smtd_file,'%3.6f %10.6f %10.6f\n',A.');
            fclose(smtd_file);
            handles.filename{i} = savenameS;
            delete(BarMsg);
         end
        catch
            delete(BarMsg)
            msgbox(['Something wrong here...' savename]);
        end
    plot(handles.xs{1},handles.ys{1},'-','parent',handles.subplot.dat);        % first
    plot(handles.xs{end},handles.ys{end},'-','parent',handles.subplot.dat);    % last
    handles.data{1} = [handles.xs{1} handles.ys{1} 1e-3*sqrt(handles.ys{1})/length(handles.ys{1})];
    % update list
    dirData = [dir('*.dat'); dir('*.xy'); dir('*.xye'); dir('*.ras')];  %# Get the data for the current directory
    dirIndex = [dirData.isdir];  %# Find the index for directories
    fileList = {dirData(~dirIndex).name}';  %'# Get a list of the files
    handles.listControl.String = fileList;
    guidata(hObject,handles);





function hcolx_Callback(hObject, eventdata, handles)
    handles.colx = round(str2num(get(hObject,'String')));
    guidata(hObject, handles);
% --- Executes during object creation, after setting all properties.
function hcolx_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function hcoly_Callback(hObject, eventdata, handles)
    handles.coly = round(str2num(get(hObject,'String')));
    guidata(hObject, handles);
% --- Executes during object creation, after setting all properties.
function hcoly_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --------------------------------------------------------------------
function SumFrames_Callback(hObject, eventdata, handles)
    Sum2Dframes();

% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function uipanel2_CreateFcn(hObject, eventdata, handles)


% --- Executes on button press in updateList. (refresh)
function updateList_Callback(hObject, eventdata, handles)
    dirData = [dir('*.dat'); dir('*.xy'); dir('*.xye');  dir('*.ras')];  %# Get the data for the current directory
    dirIndex = [dirData.isdir];  %# Find the index for directories
    fileList = {dirData(~dirIndex).name}';  %'# Get a list of the files
    
    handles.listControl.String = fileList;
    
    %     uicontrol('style','listbox',...
    %     'units','Normalized',...
    %     'string',fileList,...
    %     'pos',[.45 .2 .5 .7],...
    %     'min',0,'max',10,...
    %     'callback',{@listbox1_Callback});
guidata(hObject, handles);
