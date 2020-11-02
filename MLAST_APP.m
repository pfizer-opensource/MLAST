classdef MLAST_APP < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        MouseLungAutomatedSegmentationToolLabel  matlab.ui.control.Label
        InputSettingsPanel              matlab.ui.container.Panel
        SelectScanLogSheetLabel         matlab.ui.control.Label
        SelectScanLogSheetListBox       matlab.ui.control.ListBox
        SelectMouseHeaderLabel          matlab.ui.control.Label
        SelectMouseHeaderListBox        matlab.ui.control.ListBox
        StudyDirectoryLabel             matlab.ui.control.Label
        StudyDirectoryEditField         matlab.ui.control.EditField
        SelectStudyDir                  matlab.ui.control.Button
        ScanLogEditFieldLabel           matlab.ui.control.Label
        ScanLogEditField                matlab.ui.control.EditField
        SelectScanLog                   matlab.ui.control.Button
        OutputSettingsPanel             matlab.ui.container.Panel
        NameofOutputFileEditFieldLabel  matlab.ui.control.Label
        NameofOutputFileEditField       matlab.ui.control.EditField
        MetricstoReportButtonGroup      matlab.ui.container.ButtonGroup
        LungTumorScanButton             matlab.ui.control.RadioButton
        CustomizeButton                 matlab.ui.control.RadioButton
        OutputsListBoxLabel             matlab.ui.control.Label
        OutputsListBox                  matlab.ui.control.ListBox
        RunButton                       matlab.ui.control.Button
        AdvancedOptionsPanel            matlab.ui.container.Panel
        ExportResultsCheckBox           matlab.ui.control.CheckBox
        SaveAllLabelsCheckBox           matlab.ui.control.CheckBox
        SavematFileCheckBox             matlab.ui.control.CheckBox
        ThresholdingButtonGroup         matlab.ui.container.ButtonGroup
        KmeansButton                    matlab.ui.control.RadioButton
        OtsuButton                      matlab.ui.control.RadioButton
        UseAdvancedOptionsCheckBox      matlab.ui.control.CheckBox
        SaveQCLabelsCheckBox            matlab.ui.control.CheckBox
        ExitonFinishCheckBox            matlab.ui.control.CheckBox
        ClearAllButton                  matlab.ui.control.Button
    end

    
    properties (Access = public)
        studyDir = ''; % Parent Directory for Study
        scanLog = ''; % Scan Log for reference
        logDir = ''; % Location of scan log (might be different from studyDir)
        scanLogSheets = {}; % Names of sheets in scan log
        scanLogContents = {}; % All contents of selected sheet in scan log
        tagHeaders = []; % Locations of subject ID header cells in scan log
        tagNames = {}; % Subject IDs from scan log
        tagColors = {}; % Colors to use for output save file
        defaultMetrics = {'Tissue Volumes';'Tissue Percentages'}; % Default selections for metrics to be reported
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % Update user
            clc;
            disp('Welcome!'); 
            stFigPos = app.UIFigure.Position;
            app.UIFigure.Position = centerFigPos(stFigPos(3),stFigPos(4)); pause(1);
            disp('Please select study directory');
            
        end

        % Button pushed function: SelectStudyDir
        function SelectStudyDirPushed(app, event)
            % Set value
            app.studyDir = uigetdir('\*.*','Please Select Study Directory');
            app.UIFigure.Visible = 'off';
            app.UIFigure.Visible = 'on';
            % Double check valid study directory selected
            if app.studyDir == 0
                return;
            end
            
            % Display
            app.StudyDirectoryEditField.Value = app.studyDir;
            %Enable next button
            app.SelectScanLog.Enable = 'on';
            app.ScanLogEditField.Enable = 'on';
            app.ScanLogEditFieldLabel.Enable = 'on';
            app.ClearAllButton.Enable = 'on';
            % Update user
            clc;
            disp('Please select reference log');
            
            % Reset following field values to default    
            app.ScanLogEditField.Value = '';
            app.SelectScanLogSheetListBox.Items = {'Sheet 1'; 'Sheet 2'; 'Sheet 3'};
            app.SelectScanLogSheetListBox.Value = {};
            app.SelectMouseHeaderListBox.Items = {'Ear Tag';'Subject ID'};
            app.SelectMouseHeaderListBox.Value = {};
            app.NameofOutputFileEditField.Value = 'MLAST Results';
            app.LungTumorScanButton.Value = true;
            MetricstoReportButtonGroupSelectionChanged(app);
            app.UseAdvancedOptionsCheckBox.Value = 0;
            UseAdvancedOptionsCheckBoxValueChanged(app);
            app.ExitonFinishCheckBox.Value = 0;            
            
            % Disable previously enabled items
            app.SelectScanLogSheetListBox.Enable = 'off';
            app.SelectMouseHeaderListBox.Enable = 'off';
            app.NameofOutputFileEditField.Enable = 'off';
            app.LungTumorScanButton.Enable = 'off';
            app.CustomizeButton.Enable = 'off';
            app.OutputsListBox.Enable = 'off';
            app.UseAdvancedOptionsCheckBox.Enable = 'off';
            app.ExitonFinishCheckBox.Enable = 'off';
            app.RunButton.Enable = 'off';
        end

        % Button pushed function: SelectScanLog
        function SelectScanLogPushed(app, event)
            % Select file
            [app.scanLog, app.logDir] = uigetfile([app.studyDir '\*.*'],'Please Select Reference Log');
            app.UIFigure.Visible = 'off';
            app.UIFigure.Visible = 'on';
            % Double check valid study log selected
            if app.scanLog == 0
                return;
            end
            fileParts = strsplit(app.scanLog,'.');
            fileExt = fileParts{end};
            if ~contains(fileExt,{'xlsx','xls','csv'})
                msgbox('Please select an .xlsx, .xls, or .csv file');
                return;
            end
            % Display
            app.ScanLogEditField.Value = app.scanLog;
            % Get sheet names
            [~,sheets] = xlsfinfo(fullfile(app.logDir,app.scanLog));
            app.scanLogSheets = sheets;
            % Enable next button
            app.SelectScanLogSheetListBox.Items = sheets;
            app.SelectScanLogSheetListBox.Visible = 'on';
            app.SelectScanLogSheetListBox.Enable = 'on';
            % Update user
            clc;
            disp('Please select sheet to use');
            
            % Reset field values to default    
            app.SelectScanLogSheetListBox.Value = {};
            app.SelectMouseHeaderListBox.Value = {};
            app.NameofOutputFileEditField.Value = 'MLAST Results';
            app.LungTumorScanButton.Value = true;
            MetricstoReportButtonGroupSelectionChanged(app);
            app.UseAdvancedOptionsCheckBox.Value = 0;
            UseAdvancedOptionsCheckBoxValueChanged(app);
            app.ExitonFinishCheckBox.Value = 0;            
            
            % Disable previously enabled items
            app.SelectMouseHeaderListBox.Enable = 'off';
            app.NameofOutputFileEditField.Enable = 'off';
            app.LungTumorScanButton.Enable = 'off';
            app.CustomizeButton.Enable = 'off';
            app.OutputsListBox.Enable = 'off';
            app.UseAdvancedOptionsCheckBox.Enable = 'off';
            app.ExitonFinishCheckBox.Enable = 'off';
            app.RunButton.Enable = 'off';
        end

        % Value changed function: SelectScanLogSheetListBox
        function SelectScanLogSheetListBoxValueChanged(app, event)
            % Get value
            sheetInd = find(strcmp(app.scanLogSheets,app.SelectScanLogSheetListBox.Value));
            % Read scan log
            [~,~,cellContents] = xlsread(fullfile(app.logDir,app.scanLog), app.scanLogSheets{sheetInd});
            % Get possible ID tag headers
            [headerChoice, app.tagHeaders] = getTagHeaders(cellContents);
            % Enable next button
            app.SelectMouseHeaderListBox.Items = headerChoice;
            app.SelectMouseHeaderListBox.Enable = 'on';
            app.SelectMouseHeaderListBox.Visible = 'on';
            % Update user
            clc;
            disp('Please select header for column of subject IDs (from scan log)')
            
            % Reset field values to default    
            app.SelectMouseHeaderListBox.Value = {};
            app.NameofOutputFileEditField.Value = 'MLAST Results';
            app.LungTumorScanButton.Value = true;
            MetricstoReportButtonGroupSelectionChanged(app);
            app.UseAdvancedOptionsCheckBox.Value = 0;
            UseAdvancedOptionsCheckBoxValueChanged(app);
            app.ExitonFinishCheckBox.Value = 0;            
            
            % Disable previously enabled items
            app.NameofOutputFileEditField.Enable = 'off';
            app.LungTumorScanButton.Enable = 'off';
            app.CustomizeButton.Enable = 'off';
            app.OutputsListBox.Enable = 'off';
            app.UseAdvancedOptionsCheckBox.Enable = 'off';
            app.ExitonFinishCheckBox.Enable = 'off';
            app.RunButton.Enable = 'off';
        end

        % Value changed function: SelectMouseHeaderListBox
        function SelectMouseHeaderListBoxValueChanged(app, event)
            % Enable remaining buttons
            app.NameofOutputFileEditField.Enable = 'on';
            app.LungTumorScanButton.Enable = 'on';
            app.CustomizeButton.Enable = 'on';
            app.defaultMetrics = app.OutputsListBox.Value;
            app.ExportResultsCheckBox.Enable = 'on';
            app.SaveQCLabelsCheckBox.Enable = 'on';
            app.SaveAllLabelsCheckBox.Enable = 'on';
            app.SavematFileCheckBox.Enable = 'on';
            app.KmeansButton.Enable = 'on';
            app.OtsuButton.Enable = 'on';
            app.RunButton.Enable = 'on';
            app.UseAdvancedOptionsCheckBox.Enable = 'on';
            app.ExitonFinishCheckBox.Enable = 'on';
            app.ClearAllButton.Enable = 'on';
            
            % Update user
            clc;
            disp('Ready to analyze! Please select remaining desired settings and hit "Run".');
        end

        % Selection changed function: MetricstoReportButtonGroup
        function MetricstoReportButtonGroupSelectionChanged(app, event)
            selectedButton = app.MetricstoReportButtonGroup.SelectedObject;
            if strcmp(selectedButton.Text,'Customize')
                % Give user choice of many output variables
                app.OutputsListBox.Enable = 'on';
                app.OutputsListBox.Items = {'Tissue Volumes'; 'Tissue Percentages';'Densities';'Normalized Densities';'Total Thoracic Volume';...
                    'Diaphragm Volume';'Image Size';'Bone Threshold';'Bone Volume'};
            else
                % Return selection of output variables to default
                app.OutputsListBox.Items = {'Tissue Volumes'; 'Tissue Percentages'};
                app.OutputsListBox.Value = app.defaultMetrics;
                app.OutputsListBox.Enable = 'off';
            end
        end

        % Button pushed function: RunButton
        function RunButtonPushed(app, event)
            % Confirm overwrite of save file
            saveName = app.NameofOutputFileEditField.Value;
            if ~contains(saveName,'.xlsx') || ~contains(saveName,'.xls') || ~contains(saveName,'.csv')
                saveName = [saveName '.xlsx'];
            end
            if app.ExportResultsCheckBox.Value && exist(fullfile(app.studyDir,saveName),'file')~=0
                quest = ['There is already a file named ' saveName ' in that directory. Would you like to overwrite?'];
                questAns = questdlg(quest,'Warning');
                if isempty(questAns) || max(strcmp(questAns,{'No','Cancel'}))
                    return;
                end
            end
            
            % Get tag names and colors
            tagHeader = app.SelectMouseHeaderListBox.Value;
            sheetInd = find(strcmp(app.scanLogSheets,app.SelectScanLogSheetListBox.Value));
            [app.tagNames, app.tagColors] = getTagNames2(fullfile(app.logDir,app.scanLog),app.scanLogSheets{sheetInd},tagHeader);
            
            % Update user
            clc;
            disp('Beginning MLAST...'); 
            P1 = app.UIFigure.Position;
            unit1 = app.UIFigure.Units;
            waitWidth = 360; waitHeight = 75;
            Pcenter = [P1(1) + P1(3)/2 - waitWidth/2,P1(2) + P1(4)/2 - waitHeight/2, waitWidth, waitHeight];
            w = waitbar(.1,'Beginning MLAST...','Units',unit1,'Position',Pcenter);
            pause(.5);
            
            % Parse output metrics
            metricSelections = app.OutputsListBox.Value;
            metricOptions ={'Tissue Volumes','Tissue Percentages','Densities','Normalized Densities',...
                'Total Thoracic Volume','Diaphragm Volume','Image Size','Bone Threshold','Bone Volume'};
            whichMetrics = [];
            for m = 1:numel(metricSelections)
                whichMetrics = [whichMetrics, find(strcmp(metricOptions,metricSelections(m)))];
            end
            
            % Create input structure
            inputVars = struct;
            inputVars.loadPath = app.studyDir;
            inputVars.tagNames = app.tagNames;
            inputVars.tagColors = app.tagColors;
            inputVars.saveROIlabels = app.SaveAllLabelsCheckBox.Value;
            if inputVars.saveROIlabels
                inputVars.saveQClabels = 0;
            else
                inputVars.saveQClabels = app.SaveQCLabelsCheckBox.Value;
            end
            inputVars.exportDataTable = app.ExportResultsCheckBox.Value;
            inputVars.saveData = app.SavematFileCheckBox.Value;
            inputVars.segMethod = app.ThresholdingButtonGroup.SelectedObject.Text;
            inputVars.saveFileName = app.NameofOutputFileEditField.Value;
            inputVars.whichMetrics = whichMetrics;
            
            % Update user
            disp('Analyzing (this will take several minutes)...'); pause(.5);
            waitbar(.2,w,'Analyzing (this will take several minutes)...');
            
            % Run MLAST
            tic;
            [wasData, numScans] = MLAST_main_for_GUI(inputVars);
            analysisTime = toc;
            
            additionalVars = struct;
            additionalVars.wasData = wasData;
            additionalVars.numScans = numScans;
            additionalVars.analysisTime = analysisTime;
            
            % Write log file
            versionNum = 1;
            writeMLASTlog(inputVars,additionalVars,versionNum);
            
            % Update user
            if wasData
                userMsg = 'Analysis Complete!';
            else
                userMsg = 'No Data Found';
            end
            disp(userMsg); waitbar(1,w,userMsg);
            pause(1); close(w);
            
            if app.ExitonFinishCheckBox.Value
                app.UIFigureCloseRequest();
            else
                msgbox(userMsg);
            end
        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            % Update user
            disp('Goodbye!'); pause(.5);
            delete(app)
        end

        % Value changed function: UseAdvancedOptionsCheckBox
        function UseAdvancedOptionsCheckBoxValueChanged(app, event)
            value = app.UseAdvancedOptionsCheckBox.Value;
            if value == 1
                app.ExportResultsCheckBox.Visible = 'on';
                app.SaveQCLabelsCheckBox.Visible = 'on';
                app.SaveAllLabelsCheckBox.Visible = 'on';
                app.SavematFileCheckBox.Visible = 'on';
                app.ThresholdingButtonGroup.Visible = 'on';
            else
                app.ExportResultsCheckBox.Value = 1;
                app.ExportResultsCheckBox.Visible = 'off';
                app.SaveQCLabelsCheckBox.Value = 1;
                app.SaveQCLabelsCheckBox.Visible = 'off';
                app.SaveAllLabelsCheckBox.Value = 0;
                app.SaveAllLabelsCheckBox.Visible = 'off';
                app.SavematFileCheckBox.Value = 0;
                app.SavematFileCheckBox.Visible = 'off';
                app.KmeansButton.Value = true;
                app.ThresholdingButtonGroup.Visible = 'off';
            end
        end

        % Button pushed function: ClearAllButton
        function ClearAllButtonPushed(app, event)
            % Reset field values to default    
            app.StudyDirectoryEditField.Value = '';
            app.ScanLogEditField.Value = '';
            app.SelectScanLogSheetListBox.Items = {'Sheet 1'; 'Sheet 2'; 'Sheet 3'};
            app.SelectScanLogSheetListBox.Value = {};
            app.SelectMouseHeaderListBox.Items = {'Ear Tag';'Subject ID'};
            app.SelectMouseHeaderListBox.Value = {};
            app.NameofOutputFileEditField.Value = 'MLAST Results';
            app.LungTumorScanButton.Value = true;
            MetricstoReportButtonGroupSelectionChanged(app);
            app.UseAdvancedOptionsCheckBox.Value = 0;
            UseAdvancedOptionsCheckBoxValueChanged(app);
            app.ExitonFinishCheckBox.Value = 0;            
            
            % Disable previously enabled items
            app.ScanLogEditField.Enable = 'off';
            app.SelectScanLog.Enable = 'off';
            app.SelectScanLogSheetListBox.Enable = 'off';
            app.SelectMouseHeaderListBox.Enable = 'off';
            app.NameofOutputFileEditField.Enable = 'off';
            app.LungTumorScanButton.Enable = 'off';
            app.CustomizeButton.Enable = 'off';
            app.OutputsListBox.Enable = 'off';
            app.UseAdvancedOptionsCheckBox.Enable = 'off';
            app.ExitonFinishCheckBox.Enable = 'off';
            app.RunButton.Enable = 'off';
            app.ClearAllButton.Enable = 'off';
            
            % Update user
            clc;
            disp('Please select new study directory');
            
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [0.8 0.8 0.8];
            app.UIFigure.Position = [25 250 734 383];
            app.UIFigure.Name = 'UI Figure';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);

            % Create MouseLungAutomatedSegmentationToolLabel
            app.MouseLungAutomatedSegmentationToolLabel = uilabel(app.UIFigure);
            app.MouseLungAutomatedSegmentationToolLabel.HorizontalAlignment = 'center';
            app.MouseLungAutomatedSegmentationToolLabel.FontSize = 30;
            app.MouseLungAutomatedSegmentationToolLabel.FontWeight = 'bold';
            app.MouseLungAutomatedSegmentationToolLabel.FontColor = [0.0784 0.349 0.5294];
            app.MouseLungAutomatedSegmentationToolLabel.Position = [46.5 330 646 36];
            app.MouseLungAutomatedSegmentationToolLabel.Text = 'Mouse Lung Automated Segmentation Tool ';

            % Create InputSettingsPanel
            app.InputSettingsPanel = uipanel(app.UIFigure);
            app.InputSettingsPanel.Title = 'Input Settings';
            app.InputSettingsPanel.BackgroundColor = [0.902 0.902 0.902];
            app.InputSettingsPanel.FontWeight = 'bold';
            app.InputSettingsPanel.Position = [24 12 332 301];

            % Create SelectScanLogSheetLabel
            app.SelectScanLogSheetLabel = uilabel(app.InputSettingsPanel);
            app.SelectScanLogSheetLabel.Position = [10 109 131 22];
            app.SelectScanLogSheetLabel.Text = 'Select Scan Log Sheet:';

            % Create SelectScanLogSheetListBox
            app.SelectScanLogSheetListBox = uilistbox(app.InputSettingsPanel);
            app.SelectScanLogSheetListBox.Items = {'Sheet 1', 'Sheet 2', 'Sheet 3', '', ''};
            app.SelectScanLogSheetListBox.ValueChangedFcn = createCallbackFcn(app, @SelectScanLogSheetListBoxValueChanged, true);
            app.SelectScanLogSheetListBox.Enable = 'off';
            app.SelectScanLogSheetListBox.Position = [10 13 124 93];
            app.SelectScanLogSheetListBox.Value = {};

            % Create SelectMouseHeaderLabel
            app.SelectMouseHeaderLabel = uilabel(app.InputSettingsPanel);
            app.SelectMouseHeaderLabel.Position = [181 109 124 22];
            app.SelectMouseHeaderLabel.Text = 'Select Mouse Header:';

            % Create SelectMouseHeaderListBox
            app.SelectMouseHeaderListBox = uilistbox(app.InputSettingsPanel);
            app.SelectMouseHeaderListBox.Items = {'Ear Tag', 'Subject ID', '', ''};
            app.SelectMouseHeaderListBox.ValueChangedFcn = createCallbackFcn(app, @SelectMouseHeaderListBoxValueChanged, true);
            app.SelectMouseHeaderListBox.Enable = 'off';
            app.SelectMouseHeaderListBox.Position = [184 13 118 93];
            app.SelectMouseHeaderListBox.Value = {};

            % Create StudyDirectoryLabel
            app.StudyDirectoryLabel = uilabel(app.InputSettingsPanel);
            app.StudyDirectoryLabel.HorizontalAlignment = 'right';
            app.StudyDirectoryLabel.Position = [7 250 91 22];
            app.StudyDirectoryLabel.Text = 'Study Directory:';

            % Create StudyDirectoryEditField
            app.StudyDirectoryEditField = uieditfield(app.InputSettingsPanel, 'text');
            app.StudyDirectoryEditField.Editable = 'off';
            app.StudyDirectoryEditField.Position = [10 223 313 22];

            % Create SelectStudyDir
            app.SelectStudyDir = uibutton(app.InputSettingsPanel, 'push');
            app.SelectStudyDir.ButtonPushedFcn = createCallbackFcn(app, @SelectStudyDirPushed, true);
            app.SelectStudyDir.Position = [273 250 50 22];
            app.SelectStudyDir.Text = 'Select';

            % Create ScanLogEditFieldLabel
            app.ScanLogEditFieldLabel = uilabel(app.InputSettingsPanel);
            app.ScanLogEditFieldLabel.HorizontalAlignment = 'right';
            app.ScanLogEditFieldLabel.Position = [10 191 60 22];
            app.ScanLogEditFieldLabel.Text = 'Scan Log:';

            % Create ScanLogEditField
            app.ScanLogEditField = uieditfield(app.InputSettingsPanel, 'text');
            app.ScanLogEditField.Editable = 'off';
            app.ScanLogEditField.Enable = 'off';
            app.ScanLogEditField.Position = [10 166 313 22];

            % Create SelectScanLog
            app.SelectScanLog = uibutton(app.InputSettingsPanel, 'push');
            app.SelectScanLog.ButtonPushedFcn = createCallbackFcn(app, @SelectScanLogPushed, true);
            app.SelectScanLog.Enable = 'off';
            app.SelectScanLog.Position = [273 191 50 22];
            app.SelectScanLog.Text = 'Select';

            % Create OutputSettingsPanel
            app.OutputSettingsPanel = uipanel(app.UIFigure);
            app.OutputSettingsPanel.Title = 'Output Settings';
            app.OutputSettingsPanel.BackgroundColor = [0.902 0.902 0.902];
            app.OutputSettingsPanel.FontWeight = 'bold';
            app.OutputSettingsPanel.Position = [364 12 171 301];

            % Create NameofOutputFileEditFieldLabel
            app.NameofOutputFileEditFieldLabel = uilabel(app.OutputSettingsPanel);
            app.NameofOutputFileEditFieldLabel.HorizontalAlignment = 'right';
            app.NameofOutputFileEditFieldLabel.Position = [9 252 116 22];
            app.NameofOutputFileEditFieldLabel.Text = 'Name of Output File:';

            % Create NameofOutputFileEditField
            app.NameofOutputFileEditField = uieditfield(app.OutputSettingsPanel, 'text');
            app.NameofOutputFileEditField.Enable = 'off';
            app.NameofOutputFileEditField.Position = [9 231 154 22];
            app.NameofOutputFileEditField.Value = 'MLAST Results';

            % Create MetricstoReportButtonGroup
            app.MetricstoReportButtonGroup = uibuttongroup(app.OutputSettingsPanel);
            app.MetricstoReportButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @MetricstoReportButtonGroupSelectionChanged, true);
            app.MetricstoReportButtonGroup.Title = 'Metrics to Report:';
            app.MetricstoReportButtonGroup.Position = [9 151 154 73];

            % Create LungTumorScanButton
            app.LungTumorScanButton = uiradiobutton(app.MetricstoReportButtonGroup);
            app.LungTumorScanButton.Enable = 'off';
            app.LungTumorScanButton.Text = 'Lung Tumor Scan';
            app.LungTumorScanButton.Position = [11 27 117 22];
            app.LungTumorScanButton.Value = true;

            % Create CustomizeButton
            app.CustomizeButton = uiradiobutton(app.MetricstoReportButtonGroup);
            app.CustomizeButton.Enable = 'off';
            app.CustomizeButton.Text = 'Customize';
            app.CustomizeButton.Position = [11 5 79 22];

            % Create OutputsListBoxLabel
            app.OutputsListBoxLabel = uilabel(app.OutputSettingsPanel);
            app.OutputsListBoxLabel.Position = [12 117 51 22];
            app.OutputsListBoxLabel.Text = 'Outputs:';

            % Create OutputsListBox
            app.OutputsListBox = uilistbox(app.OutputSettingsPanel);
            app.OutputsListBox.Items = {'Tissue Volumes', 'Tissue Percentages'};
            app.OutputsListBox.Multiselect = 'on';
            app.OutputsListBox.Enable = 'off';
            app.OutputsListBox.Position = [13 13 150 101];
            app.OutputsListBox.Value = {'Tissue Volumes', 'Tissue Percentages'};

            % Create RunButton
            app.RunButton = uibutton(app.UIFigure, 'push');
            app.RunButton.ButtonPushedFcn = createCallbackFcn(app, @RunButtonPushed, true);
            app.RunButton.BackgroundColor = [0.6706 0.9294 0.6824];
            app.RunButton.Enable = 'off';
            app.RunButton.Position = [581 38 89 22];
            app.RunButton.Text = 'Run';

            % Create AdvancedOptionsPanel
            app.AdvancedOptionsPanel = uipanel(app.UIFigure);
            app.AdvancedOptionsPanel.Title = 'Advanced Options';
            app.AdvancedOptionsPanel.BackgroundColor = [0.902 0.902 0.902];
            app.AdvancedOptionsPanel.FontWeight = 'bold';
            app.AdvancedOptionsPanel.Position = [548 95 156 216];

            % Create ExportResultsCheckBox
            app.ExportResultsCheckBox = uicheckbox(app.AdvancedOptionsPanel);
            app.ExportResultsCheckBox.Enable = 'off';
            app.ExportResultsCheckBox.Visible = 'off';
            app.ExportResultsCheckBox.Text = 'Export Results';
            app.ExportResultsCheckBox.Position = [28 149 100 22];
            app.ExportResultsCheckBox.Value = true;

            % Create SaveAllLabelsCheckBox
            app.SaveAllLabelsCheckBox = uicheckbox(app.AdvancedOptionsPanel);
            app.SaveAllLabelsCheckBox.Enable = 'off';
            app.SaveAllLabelsCheckBox.Visible = 'off';
            app.SaveAllLabelsCheckBox.Text = 'Save All Labels';
            app.SaveAllLabelsCheckBox.Position = [28 107 105 22];

            % Create SavematFileCheckBox
            app.SavematFileCheckBox = uicheckbox(app.AdvancedOptionsPanel);
            app.SavematFileCheckBox.Enable = 'off';
            app.SavematFileCheckBox.Visible = 'off';
            app.SavematFileCheckBox.Text = 'Save .mat File';
            app.SavematFileCheckBox.Position = [28 85 99 22];

            % Create ThresholdingButtonGroup
            app.ThresholdingButtonGroup = uibuttongroup(app.AdvancedOptionsPanel);
            app.ThresholdingButtonGroup.Title = 'Thresholding:';
            app.ThresholdingButtonGroup.Visible = 'off';
            app.ThresholdingButtonGroup.Position = [16 13 123 69];

            % Create KmeansButton
            app.KmeansButton = uiradiobutton(app.ThresholdingButtonGroup);
            app.KmeansButton.Enable = 'off';
            app.KmeansButton.Text = 'Kmeans';
            app.KmeansButton.Position = [11 23 66 22];
            app.KmeansButton.Value = true;

            % Create OtsuButton
            app.OtsuButton = uiradiobutton(app.ThresholdingButtonGroup);
            app.OtsuButton.Enable = 'off';
            app.OtsuButton.Text = 'Otsu';
            app.OtsuButton.Position = [11 1 65 22];

            % Create UseAdvancedOptionsCheckBox
            app.UseAdvancedOptionsCheckBox = uicheckbox(app.AdvancedOptionsPanel);
            app.UseAdvancedOptionsCheckBox.ValueChangedFcn = createCallbackFcn(app, @UseAdvancedOptionsCheckBoxValueChanged, true);
            app.UseAdvancedOptionsCheckBox.Enable = 'off';
            app.UseAdvancedOptionsCheckBox.Text = 'Use Advanced Options';
            app.UseAdvancedOptionsCheckBox.Position = [10 170 145 22];

            % Create SaveQCLabelsCheckBox
            app.SaveQCLabelsCheckBox = uicheckbox(app.AdvancedOptionsPanel);
            app.SaveQCLabelsCheckBox.Enable = 'off';
            app.SaveQCLabelsCheckBox.Visible = 'off';
            app.SaveQCLabelsCheckBox.Text = 'Save QC Labels';
            app.SaveQCLabelsCheckBox.Position = [28 127 109 22];
            app.SaveQCLabelsCheckBox.Value = true;

            % Create ExitonFinishCheckBox
            app.ExitonFinishCheckBox = uicheckbox(app.UIFigure);
            app.ExitonFinishCheckBox.Enable = 'off';
            app.ExitonFinishCheckBox.Text = 'Exit on Finish';
            app.ExitonFinishCheckBox.Position = [558 65 94 22];

            % Create ClearAllButton
            app.ClearAllButton = uibutton(app.UIFigure, 'push');
            app.ClearAllButton.ButtonPushedFcn = createCallbackFcn(app, @ClearAllButtonPushed, true);
            app.ClearAllButton.BackgroundColor = [0.9216 0.5686 0.5686];
            app.ClearAllButton.Enable = 'off';
            app.ClearAllButton.Position = [581 12 89 22];
            app.ClearAllButton.Text = 'Clear All';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = MLAST_APP

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end