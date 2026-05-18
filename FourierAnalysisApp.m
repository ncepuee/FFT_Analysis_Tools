classdef FourierAnalysisApp < matlab.apps.AppBase
%FOURIERANALYSISAPP MATLAB UI for Simulink-style FFT analysis.
%
% Run from MATLAB with:
%   FourierAnalysisApp

    properties (Access = private)
        Figure
        ControlGrid
        ControlPanel
        PlotPanel
        LoadButton
        WorkspaceButton
        LanguageLabel
        LanguageDropDown
        PlotDetailLabel
        PlotDetailDropDown
        GridEnableCheckBox
        GridStyleLabel
        GridStyleDropDown
        BoxEnableCheckBox
        FileLabel
        SignalLabel
        SignalDropDown
        ChannelLabel
        ChannelDropDown
        FundamentalLabel
        FundamentalEdit
        CyclesLabel
        CyclesEdit
        StartTimeLabel
        StartTimeEdit
        MaxFreqLabel
        MaxFreqEdit
        ThdMethodLabel
        ThdMethodDropDown
        ThdMaxFreqLabel
        ThdMaxFreqDropDown
        AnalyzeButton
        ExportButton
        ExportFigureButton
        ExportMatButton
        ZoomEnableCheckBox
        ZoomPanel
        Zoom1StartEdit
        Zoom1EndEdit
        Zoom1YMinEdit
        Zoom1YMaxEdit
        Zoom2StartEdit
        Zoom2EndEdit
        Zoom2YMinEdit
        Zoom2YMaxEdit
        Zoom3StartEdit
        Zoom3EndEdit
        Zoom3YMinEdit
        Zoom3YMaxEdit
        DrawZoomButton
        SpectrumInsetEnableCheckBox
        SpectrumInsetPanel
        SpectrumRangesEdit
        SpectrumYMinEdit
        SpectrumYMaxEdit
        InsertSpectrumInsetButton
        DeleteSpectrumInsetButton
        StatusLabel
        FooterHtml
        AboutButton
        TimeAxes
        SpectrumAxes
        ResultTable

        Language char = 'zh'
        CurrentFileName char = ''
        CurrentFilePath char = ''
        MatData struct = struct()
        CsvData struct = struct()
        WorkspaceData struct = struct()
        SignalCandidates struct = struct('label', {}, 'path', {}, 'source', {}, 'column', {})
        CurrentTime double = []
        CurrentWaveform double = []
        Result struct = struct()
        HasResult logical = false
        LastStatusKey char = 'select_file'
        LastStatusArgs cell = {}
        PlotDetailMode char = 'fast'
        GridEnabled logical = false
        GridLineStyle char = '-'
        BoxEnabled logical = true
        ZoomEnabled logical = false
        SpectrumInsetEnabled logical = false
        ThdMethod char = 'matlab'
        ThdMaxFrequencyMode char = 'nyquist'
        SpectrumInsetOverlays = []
        SpectrumInsetRanges double = zeros(0, 2)
        SpectrumInsetYLimits cell = {}
        MaxTimePlotPoints double = 20000
        FineTimePlotPoints double = 200000
        MaxSpectrumBarCount double = 5000
        MaxSpectrumLinePoints double = 20000
    end

    methods (Access = public)
        function app = FourierAnalysisApp()
            app.createComponents();
            registerApp(app, app.Figure);
            runStartupFcn(app, @(app) startupFcn(app));

            if nargout == 0
                clear app
            end
        end

        function delete(app)
            if ~isempty(app.Figure) && isvalid(app.Figure)
                app.Figure.UserData = [];
                app.Figure.CloseRequestFcn = [];
                delete(app.Figure);
            end
        end

        function loadDataFileFromPath(app, filePath)
            app.loadDataFilePath(filePath);
        end

        function loadSignalsFromWorkspace(app)
            app.loadWorkspaceSignals();
        end

        function setAppLanguage(app, languageValue)
            languageValue = char(languageValue);
            if any(strcmpi(languageValue, {'en', 'english'}))
                app.LanguageDropDown.Value = 'English';
            else
                app.LanguageDropDown.Value = '中文';
            end
            app.onLanguageChanged();
        end

        function runCurrentAnalysis(app)
            app.analyzeSignal();
        end

        function fig = exportCurrentAnalysisFigure(app)
            fig = app.exportAnalysisFigure();
        end

        function outputPath = exportLoadedCsvToMatFile(app, outputPath, channelIndex)
            if nargin < 3
                channelIndex = 1;
            end
            outputPath = app.writeLoadedCsvToMat(outputPath, channelIndex);
        end

        function fig = drawSpectrumInsetFigure(app)
            fig = app.insertSpectrumInsetView();
        end

        function deleteSpectrumInsetFigure(app)
            app.deleteSpectrumInsetView();
        end

        function setSpectrumInsetFrequencyRange(app, freqStart, freqEnd)
            app.setSpectrumInsetFrequencyRanges([freqStart, freqEnd]);
        end

        function setSpectrumInsetFrequencyRanges(app, ranges)
            app.setSpectrumInsetRangeText(ranges);
            app.updateSpectrumInsetYLimits(ranges, true);
        end
    end

    methods (Access = private)
        function startupFcn(app)
            app.updateLanguageTexts();
            app.Figure.UserData = app;
            app.Figure.Visible = 'on';
        end

        function createComponents(app)
            app.Figure = uifigure('Name', app.text('app_title'), ...
                'Visible', 'off', ...
                'CloseRequestFcn', @(~, ~) delete(app), ...
                'Position', [100 80 1240 760]);

            rootGrid = uigridlayout(app.Figure, [2 1]);
            rootGrid.RowHeight = {'1x', 42};
            rootGrid.ColumnWidth = {'1x'};
            rootGrid.Padding = [12 12 12 10];
            rootGrid.RowSpacing = 8;

            mainGrid = uigridlayout(rootGrid, [1 2]);
            mainGrid.Layout.Row = 1;
            mainGrid.Layout.Column = 1;
            mainGrid.ColumnWidth = {340, '1x'};
            mainGrid.RowHeight = {'1x'};
            mainGrid.Padding = [0 0 0 0];
            mainGrid.ColumnSpacing = 12;

            footerGrid = uigridlayout(rootGrid, [1 2]);
            footerGrid.Layout.Row = 2;
            footerGrid.Layout.Column = 1;
            footerGrid.ColumnWidth = {'1x', 88};
            footerGrid.RowHeight = {'1x'};
            footerGrid.Padding = [0 0 0 0];
            footerGrid.ColumnSpacing = 8;

            app.FooterHtml = uihtml(footerGrid, ...
                'HTMLSource', app.resourceFile('authorLinks.html'), ...
                'HTMLEventReceivedFcn', @(~, event) app.onAuthorLinkEvent(event));
            app.FooterHtml.Layout.Row = 1;
            app.FooterHtml.Layout.Column = 1;

            app.AboutButton = uibutton(footerGrid, ...
                'Text', app.text('about_button'), ...
                'ButtonPushedFcn', @(~, ~) app.showAboutDialog());
            app.AboutButton.Layout.Row = 1;
            app.AboutButton.Layout.Column = 2;

            app.ControlPanel = uipanel(mainGrid, 'Title', app.text('fft_params'), ...
                'Scrollable', 'on');
            app.ControlPanel.Layout.Row = 1;
            app.ControlPanel.Layout.Column = 1;

            app.ControlGrid = uigridlayout(app.ControlPanel, [27 2]);
            app.ControlGrid.ColumnWidth = {95, '1x'};
            app.ControlGrid.RowHeight = {34, 28, 34, 34, 34, 34, 34, 34, 34, 34, 34, 34, 30, 34, 30, 34, 34, 34, 34, 30, 0, 0, 34, 0, 0, 120, 52};
            app.ControlGrid.Padding = [12 12 12 12];
            app.ControlGrid.RowSpacing = 8;
            try
                app.ControlGrid.Scrollable = 'on';
            catch
                app.ControlPanel.Scrollable = 'on';
            end

            app.LoadButton = uibutton(app.ControlGrid, 'Text', app.text('load_button'), ...
                'ButtonPushedFcn', @(~, ~) app.loadDataFile());
            app.LoadButton.Layout.Row = 1;
            app.LoadButton.Layout.Column = 1;

            app.WorkspaceButton = uibutton(app.ControlGrid, 'Text', app.text('load_workspace_button'), ...
                'ButtonPushedFcn', @(~, ~) app.loadWorkspaceSignals());
            app.WorkspaceButton.Layout.Row = 1;
            app.WorkspaceButton.Layout.Column = 2;

            app.FileLabel = uilabel(app.ControlGrid, 'Text', app.text('loaded_none'), ...
                'WordWrap', 'on');
            app.FileLabel.Layout.Row = 2;
            app.FileLabel.Layout.Column = [1 2];

            app.LanguageLabel = uilabel(app.ControlGrid, 'Text', app.text('language'));
            app.LanguageLabel.Layout.Row = 3;
            app.LanguageLabel.Layout.Column = 1;

            app.LanguageDropDown = uidropdown(app.ControlGrid, ...
                'Items', {'中文', 'English'}, ...
                'Value', '中文', ...
                'ValueChangedFcn', @(~, ~) app.onLanguageChanged());
            app.LanguageDropDown.Layout.Row = 3;
            app.LanguageDropDown.Layout.Column = 2;

            app.SignalLabel = uilabel(app.ControlGrid, 'Text', app.text('signal_var'));
            app.SignalLabel.Layout.Row = 4;
            app.SignalLabel.Layout.Column = 1;

            app.SignalDropDown = uidropdown(app.ControlGrid, ...
                'Items', {app.text('load_file_first')}, ...
                'ValueChangedFcn', @(~, ~) app.onSignalChanged());
            app.SignalDropDown.Layout.Row = 4;
            app.SignalDropDown.Layout.Column = 2;

            app.ChannelLabel = uilabel(app.ControlGrid, 'Text', app.text('channel'));
            app.ChannelLabel.Layout.Row = 5;
            app.ChannelLabel.Layout.Column = 1;

            app.ChannelDropDown = uidropdown(app.ControlGrid, 'Items', {'1'}, ...
                'ValueChangedFcn', @(~, ~) app.onChannelChanged());
            app.ChannelDropDown.Layout.Row = 5;
            app.ChannelDropDown.Layout.Column = 2;

            app.FundamentalLabel = uilabel(app.ControlGrid, 'Text', app.text('fundamental_hz'));
            app.FundamentalLabel.Layout.Row = 6;
            app.FundamentalLabel.Layout.Column = 1;

            app.FundamentalEdit = uieditfield(app.ControlGrid, 'numeric', ...
                'Value', 50, 'Limits', [eps Inf]);
            app.FundamentalEdit.Layout.Row = 6;
            app.FundamentalEdit.Layout.Column = 2;

            app.CyclesLabel = uilabel(app.ControlGrid, 'Text', app.text('cycles'));
            app.CyclesLabel.Layout.Row = 7;
            app.CyclesLabel.Layout.Column = 1;

            app.CyclesEdit = uieditfield(app.ControlGrid, 'numeric', ...
                'Value', 10, 'Limits', [eps Inf]);
            app.CyclesEdit.Layout.Row = 7;
            app.CyclesEdit.Layout.Column = 2;

            app.StartTimeLabel = uilabel(app.ControlGrid, 'Text', app.text('start_time_s'));
            app.StartTimeLabel.Layout.Row = 8;
            app.StartTimeLabel.Layout.Column = 1;

            app.StartTimeEdit = uieditfield(app.ControlGrid, 'numeric', 'Value', 0);
            app.StartTimeEdit.Layout.Row = 8;
            app.StartTimeEdit.Layout.Column = 2;

            app.MaxFreqLabel = uilabel(app.ControlGrid, 'Text', app.text('max_freq_hz'));
            app.MaxFreqLabel.Layout.Row = 9;
            app.MaxFreqLabel.Layout.Column = 1;

            app.MaxFreqEdit = uieditfield(app.ControlGrid, 'numeric', ...
                'Value', 3000, 'Limits', [eps Inf]);
            app.MaxFreqEdit.Layout.Row = 9;
            app.MaxFreqEdit.Layout.Column = 2;

            app.ThdMethodLabel = uilabel(app.ControlGrid, 'Text', app.text('thd_method'));
            app.ThdMethodLabel.Layout.Row = 10;
            app.ThdMethodLabel.Layout.Column = 1;

            app.ThdMethodDropDown = uidropdown(app.ControlGrid, ...
                'Items', app.thdMethodItems(), ...
                'Value', app.thdMethodValue(), ...
                'ValueChangedFcn', @(~, ~) app.onThdMethodChanged());
            app.ThdMethodDropDown.Layout.Row = 10;
            app.ThdMethodDropDown.Layout.Column = 2;

            app.ThdMaxFreqLabel = uilabel(app.ControlGrid, 'Text', app.text('thd_max_frequency'));
            app.ThdMaxFreqLabel.Layout.Row = 11;
            app.ThdMaxFreqLabel.Layout.Column = 1;

            app.ThdMaxFreqDropDown = uidropdown(app.ControlGrid, ...
                'Items', app.thdMaxFrequencyItems(), ...
                'Value', app.thdMaxFrequencyValue(), ...
                'ValueChangedFcn', @(~, ~) app.onThdMaxFrequencyChanged());
            app.ThdMaxFreqDropDown.Layout.Row = 11;
            app.ThdMaxFreqDropDown.Layout.Column = 2;

            app.PlotDetailLabel = uilabel(app.ControlGrid, 'Text', app.text('plot_detail'));
            app.PlotDetailLabel.Layout.Row = 12;
            app.PlotDetailLabel.Layout.Column = 1;

            app.PlotDetailDropDown = uidropdown(app.ControlGrid, ...
                'Items', app.plotDetailItems(), ...
                'ValueChangedFcn', @(~, ~) app.onPlotDetailChanged());
            app.PlotDetailDropDown.Layout.Row = 12;
            app.PlotDetailDropDown.Layout.Column = 2;

            app.GridEnableCheckBox = uicheckbox(app.ControlGrid, ...
                'Text', app.text('enable_grid_checkbox'), ...
                'Value', false, ...
                'ValueChangedFcn', @(~, ~) app.onAxesFormatChanged());
            app.GridEnableCheckBox.Layout.Row = 13;
            app.GridEnableCheckBox.Layout.Column = [1 2];

            app.GridStyleLabel = uilabel(app.ControlGrid, 'Text', app.text('grid_style'));
            app.GridStyleLabel.Layout.Row = 14;
            app.GridStyleLabel.Layout.Column = 1;

            app.GridStyleDropDown = uidropdown(app.ControlGrid, ...
                'Items', app.gridStyleItems(), ...
                'ValueChangedFcn', @(~, ~) app.onAxesFormatChanged());
            app.GridStyleDropDown.Layout.Row = 14;
            app.GridStyleDropDown.Layout.Column = 2;

            app.BoxEnableCheckBox = uicheckbox(app.ControlGrid, ...
                'Text', app.text('enable_box_checkbox'), ...
                'Value', true, ...
                'ValueChangedFcn', @(~, ~) app.onAxesFormatChanged());
            app.BoxEnableCheckBox.Layout.Row = 15;
            app.BoxEnableCheckBox.Layout.Column = [1 2];

            app.AnalyzeButton = uibutton(app.ControlGrid, 'Text', app.text('analyze_button'), ...
                'Enable', 'off', ...
                'ButtonPushedFcn', @(~, ~) app.analyzeSignal());
            app.AnalyzeButton.Layout.Row = 16;
            app.AnalyzeButton.Layout.Column = [1 2];

            app.ExportButton = uibutton(app.ControlGrid, 'Text', app.text('export_button'), ...
                'Enable', 'off', ...
                'ButtonPushedFcn', @(~, ~) app.exportResult());
            app.ExportButton.Layout.Row = 17;
            app.ExportButton.Layout.Column = [1 2];

            app.ExportFigureButton = uibutton(app.ControlGrid, 'Text', app.text('export_figure_button'), ...
                'Enable', 'off', ...
                'ButtonPushedFcn', @(~, ~) app.exportAnalysisFigure());
            app.ExportFigureButton.Layout.Row = 18;
            app.ExportFigureButton.Layout.Column = [1 2];

            app.ExportMatButton = uibutton(app.ControlGrid, 'Text', app.text('export_mat_button'), ...
                'Enable', 'off', ...
                'ButtonPushedFcn', @(~, ~) app.exportLoadedCsvToMat());
            app.ExportMatButton.Layout.Row = 19;
            app.ExportMatButton.Layout.Column = [1 2];

            app.SpectrumInsetEnableCheckBox = uicheckbox(app.ControlGrid, ...
                'Text', app.text('enable_spectrum_inset_checkbox'), ...
                'Value', false, ...
                'ValueChangedFcn', @(~, ~) app.onSpectrumInsetEnableChanged());
            app.SpectrumInsetEnableCheckBox.Layout.Row = 20;
            app.SpectrumInsetEnableCheckBox.Layout.Column = [1 2];

            app.SpectrumInsetPanel = uipanel(app.ControlGrid, 'Title', app.text('spectrum_inset_panel_title'));
            app.SpectrumInsetPanel.Layout.Row = 21;
            app.SpectrumInsetPanel.Layout.Column = [1 2];
            app.createSpectrumInsetControls(app.SpectrumInsetPanel);

            app.InsertSpectrumInsetButton = uibutton(app.ControlGrid, 'Text', app.text('insert_spectrum_inset_button'), ...
                'Enable', 'off', ...
                'ButtonPushedFcn', @(~, ~) app.insertSpectrumInsetView());
            app.InsertSpectrumInsetButton.Layout.Row = 22;
            app.InsertSpectrumInsetButton.Layout.Column = 1;

            app.DeleteSpectrumInsetButton = uibutton(app.ControlGrid, 'Text', app.text('delete_spectrum_inset_button'), ...
                'Enable', 'off', ...
                'ButtonPushedFcn', @(~, ~) app.deleteSpectrumInsetView());
            app.DeleteSpectrumInsetButton.Layout.Row = 22;
            app.DeleteSpectrumInsetButton.Layout.Column = 2;

            app.ZoomEnableCheckBox = uicheckbox(app.ControlGrid, ...
                'Text', app.text('enable_zoom_checkbox'), ...
                'Value', false, ...
                'ValueChangedFcn', @(~, ~) app.onZoomEnableChanged());
            app.ZoomEnableCheckBox.Layout.Row = 23;
            app.ZoomEnableCheckBox.Layout.Column = [1 2];

            app.ZoomPanel = uipanel(app.ControlGrid, 'Title', app.text('zoom_panel_title'));
            app.ZoomPanel.Layout.Row = 24;
            app.ZoomPanel.Layout.Column = [1 2];
            app.createZoomControls(app.ZoomPanel);

            app.DrawZoomButton = uibutton(app.ControlGrid, 'Text', app.text('draw_zoom_button'), ...
                'Enable', 'off', ...
                'ButtonPushedFcn', @(~, ~) app.plotZoomView());
            app.DrawZoomButton.Layout.Row = 25;
            app.DrawZoomButton.Layout.Column = [1 2];

            app.ResultTable = uitable(app.ControlGrid, ...
                'ColumnName', {app.text('table_item'), app.text('table_value')}, ...
                'Data', cell(0, 2));
            app.ResultTable.Layout.Row = 26;
            app.ResultTable.Layout.Column = [1 2];

            app.StatusLabel = uilabel(app.ControlGrid, 'Text', app.text('select_file'), ...
                'WordWrap', 'on');
            app.StatusLabel.Layout.Row = 27;
            app.StatusLabel.Layout.Column = [1 2];
            app.updateSpectrumInsetVisibility();
            app.updateZoomVisibility();

            app.PlotPanel = uipanel(mainGrid, 'Title', app.text('analysis_results'));
            app.PlotPanel.Layout.Row = 1;
            app.PlotPanel.Layout.Column = 2;

            plotGrid = uigridlayout(app.PlotPanel, [2 1]);
            plotGrid.RowHeight = {'1x', '1x'};
            plotGrid.Padding = [12 12 12 12];
            plotGrid.RowSpacing = 12;

            app.TimeAxes = uiaxes(plotGrid);
            app.TimeAxes.Layout.Row = 1;
            app.applyAxesFormat(app.TimeAxes);

            app.SpectrumAxes = uiaxes(plotGrid);
            app.SpectrumAxes.Layout.Row = 2;
            app.applyAxesFormat(app.SpectrumAxes);
        end

        function createSpectrumInsetControls(app, parent)
            insetGrid = uigridlayout(parent, [3 4]);
            insetGrid.ColumnWidth = {58, '1x', 58, '1x'};
            insetGrid.RowHeight = {28, 24, 36};
            insetGrid.Padding = [8 8 8 8];
            insetGrid.RowSpacing = 5;
            insetGrid.ColumnSpacing = 6;

            uilabel(insetGrid, 'Text', app.text('spectrum_ranges'));
            app.SpectrumRangesEdit = uieditfield(insetGrid, 'text');
            app.SpectrumRangesEdit.Layout.Row = 1;
            app.SpectrumRangesEdit.Layout.Column = [2 4];

            uilabel(insetGrid, 'Text', app.text('zoom_ymin'));
            app.SpectrumYMinEdit = uieditfield(insetGrid, 'text');
            uilabel(insetGrid, 'Text', app.text('zoom_ymax'));
            app.SpectrumYMaxEdit = uieditfield(insetGrid, 'text');

            hint = uilabel(insetGrid, 'Text', app.text('spectrum_inset_hint'), 'WordWrap', 'on');
            hint.Layout.Row = 3;
            hint.Layout.Column = [1 4];
        end

        function refreshSpectrumInsetControls(app)
            values = app.spectrumInsetFieldValues();
            if ~isempty(app.InsertSpectrumInsetButton) && isvalid(app.InsertSpectrumInsetButton)
                insertEnable = app.InsertSpectrumInsetButton.Enable;
            else
                insertEnable = 'off';
            end
            if ~isempty(app.DeleteSpectrumInsetButton) && isvalid(app.DeleteSpectrumInsetButton)
                deleteEnable = app.DeleteSpectrumInsetButton.Enable;
            else
                deleteEnable = 'off';
            end
            delete(app.SpectrumInsetPanel.Children);
            app.createSpectrumInsetControls(app.SpectrumInsetPanel);
            app.setSpectrumInsetFieldValues(values);
            app.InsertSpectrumInsetButton.Enable = insertEnable;
            app.DeleteSpectrumInsetButton.Enable = deleteEnable;
            app.updateSpectrumInsetVisibility();
        end

        function createZoomControls(app, parent)
            zoomGrid = uigridlayout(parent, [11 4]);
            zoomGrid.ColumnWidth = {58, '1x', 58, '1x'};
            zoomGrid.RowHeight = {20, 24, 24, 20, 24, 24, 20, 24, 24, 34, 34};
            zoomGrid.Padding = [8 8 8 8];
            zoomGrid.RowSpacing = 5;
            zoomGrid.ColumnSpacing = 6;

            label = uilabel(zoomGrid, 'Text', app.text('zoom1_label'), 'FontWeight', 'bold');
            label.Layout.Row = 1;
            label.Layout.Column = [1 4];

            uilabel(zoomGrid, 'Text', app.text('zoom_start'));
            app.Zoom1StartEdit = uieditfield(zoomGrid, 'text');
            uilabel(zoomGrid, 'Text', app.text('zoom_end'));
            app.Zoom1EndEdit = uieditfield(zoomGrid, 'text');

            uilabel(zoomGrid, 'Text', app.text('zoom_ymin'));
            app.Zoom1YMinEdit = uieditfield(zoomGrid, 'text');
            uilabel(zoomGrid, 'Text', app.text('zoom_ymax'));
            app.Zoom1YMaxEdit = uieditfield(zoomGrid, 'text');

            label = uilabel(zoomGrid, 'Text', app.text('zoom2_label'), 'FontWeight', 'bold');
            label.Layout.Row = 4;
            label.Layout.Column = [1 4];

            uilabel(zoomGrid, 'Text', app.text('zoom_start'));
            app.Zoom2StartEdit = uieditfield(zoomGrid, 'text');
            uilabel(zoomGrid, 'Text', app.text('zoom_end'));
            app.Zoom2EndEdit = uieditfield(zoomGrid, 'text');

            uilabel(zoomGrid, 'Text', app.text('zoom_ymin'));
            app.Zoom2YMinEdit = uieditfield(zoomGrid, 'text');
            uilabel(zoomGrid, 'Text', app.text('zoom_ymax'));
            app.Zoom2YMaxEdit = uieditfield(zoomGrid, 'text');

            label = uilabel(zoomGrid, 'Text', app.text('zoom3_label'), 'FontWeight', 'bold');
            label.Layout.Row = 7;
            label.Layout.Column = [1 4];

            uilabel(zoomGrid, 'Text', app.text('zoom_start'));
            app.Zoom3StartEdit = uieditfield(zoomGrid, 'text');
            uilabel(zoomGrid, 'Text', app.text('zoom_end'));
            app.Zoom3EndEdit = uieditfield(zoomGrid, 'text');

            uilabel(zoomGrid, 'Text', app.text('zoom_ymin'));
            app.Zoom3YMinEdit = uieditfield(zoomGrid, 'text');
            uilabel(zoomGrid, 'Text', app.text('zoom_ymax'));
            app.Zoom3YMaxEdit = uieditfield(zoomGrid, 'text');

            hint = uilabel(zoomGrid, 'Text', app.text('zoom_empty_hint'), 'WordWrap', 'on');
            hint.Layout.Row = [10 11];
            hint.Layout.Column = [1 4];
        end

        function refreshZoomControls(app)
            values = app.zoomFieldValues();
            buttonEnable = 'off';
            if ~isempty(app.DrawZoomButton) && isvalid(app.DrawZoomButton)
                buttonEnable = app.DrawZoomButton.Enable;
            end

            delete(app.ZoomPanel.Children);
            app.createZoomControls(app.ZoomPanel);
            app.setZoomFieldValues(values);
            app.DrawZoomButton.Enable = buttonEnable;
        end

        function updateSpectrumInsetVisibility(app)
            if isempty(app.ControlGrid) || ~isvalid(app.ControlGrid)
                return;
            end

            rowHeights = app.ControlGrid.RowHeight;
            if app.SpectrumInsetEnabled
                rowHeights{21} = 108;
                rowHeights{22} = 34;
                app.SpectrumInsetPanel.Visible = 'on';
                app.InsertSpectrumInsetButton.Visible = 'on';
                app.DeleteSpectrumInsetButton.Visible = 'on';
            else
                rowHeights{21} = 0;
                rowHeights{22} = 0;
                app.SpectrumInsetPanel.Visible = 'off';
                app.InsertSpectrumInsetButton.Visible = 'off';
                app.DeleteSpectrumInsetButton.Visible = 'off';
            end
            app.ControlGrid.RowHeight = rowHeights;
            app.restoreActionButtons();
        end

        function updateZoomVisibility(app)
            if isempty(app.ControlGrid) || ~isvalid(app.ControlGrid)
                return;
            end

            rowHeights = app.ControlGrid.RowHeight;
            if app.ZoomEnabled
                rowHeights{24} = 380;
                rowHeights{25} = 34;
                app.ZoomPanel.Visible = 'on';
                app.DrawZoomButton.Visible = 'on';
            else
                rowHeights{24} = 0;
                rowHeights{25} = 0;
                app.ZoomPanel.Visible = 'off';
                app.DrawZoomButton.Visible = 'off';
            end
            app.ControlGrid.RowHeight = rowHeights;
            app.restoreActionButtons();
        end

        function loadDataFile(app)
            [file, path] = uigetfile( ...
                {'*.mat;*.csv', app.text('data_files_filter'); ...
                 '*.mat', app.text('mat_files_filter'); ...
                 '*.csv', app.text('csv_files_filter')}, ...
                app.text('select_data_file'));
            if isequal(file, 0)
                return;
            end

            fullPath = fullfile(path, file);
            app.loadDataFilePath(fullPath);
        end

        function loadDataFilePath(app, fullPath)
            fullPath = char(fullPath);
            if ~isfile(fullPath)
                error('FourierAnalysisApp:FileNotFound', 'File not found: %s', fullPath);
            end
            [~, file, extension] = fileparts(fullPath);
            file = [file extension];
            app.LoadButton.Enable = 'off';
            app.WorkspaceButton.Enable = 'off';
            app.AnalyzeButton.Enable = 'off';
            app.ExportButton.Enable = 'off';
            app.ExportFigureButton.Enable = 'off';
            app.ExportMatButton.Enable = 'off';
            app.InsertSpectrumInsetButton.Enable = 'off';
            app.DeleteSpectrumInsetButton.Enable = 'off';
            app.clearSpectrumInsetDisplay();
            app.setStatus('loading_file');
            drawnow('limitrate');
            cleanup = onCleanup(@() app.restoreActionButtons());
            try
                app.MatData = struct();
                app.CsvData = struct();
                app.WorkspaceData = struct();
                if strcmpi(extension, '.csv')
                    app.CsvData = readScopeCsv(fullPath);
                    app.SignalCandidates = FourierAnalysisApp.csvSignalCandidates(app.CsvData);
                else
                    app.MatData = load(fullPath);
                    app.SignalCandidates = app.findSignalCandidates(app.MatData, "", "mat");
                end
            catch ME
                app.showError('file_load_failed', ME.message);
                return;
            end

            app.CurrentFileName = file;
            app.CurrentFilePath = fullPath;
            app.FileLabel.Text = file;
            app.HasResult = false;
            app.Result = struct();
            app.ResultTable.Data = cell(0, 2);
            app.ExportButton.Enable = 'off';
            app.ExportFigureButton.Enable = 'off';
            app.ExportMatButton.Enable = 'off';
            app.InsertSpectrumInsetButton.Enable = 'off';
            app.DeleteSpectrumInsetButton.Enable = 'off';
            app.clearSpectrumInsetDisplay();

            if isempty(app.SignalCandidates)
                app.SignalDropDown.Items = {app.text('no_supported_signal')};
                app.SignalDropDown.Value = app.text('no_supported_signal');
                app.AnalyzeButton.Enable = 'off';
                app.CurrentTime = [];
                app.CurrentWaveform = [];
                app.setStatus('no_supported_format');
                app.resetPlots();
                return;
            end

            labels = {app.SignalCandidates.label};
            app.SignalDropDown.Items = labels;
            app.SignalDropDown.Value = labels{1};
            app.AnalyzeButton.Enable = 'on';
            if strcmpi(extension, '.csv')
                app.ExportMatButton.Enable = 'on';
            end
            if strcmpi(extension, '.csv')
                app.setStatus('csv_loaded', numel(labels), app.CsvData.sampleInterval, app.CsvData.timeOffset);
            else
                app.setStatus('signals_found', numel(labels));
            end
            app.onSignalChanged();
            clear cleanup;
            app.restoreActionButtons();
        end

        function loadWorkspaceSignals(app)
            app.LoadButton.Enable = 'off';
            app.WorkspaceButton.Enable = 'off';
            app.AnalyzeButton.Enable = 'off';
            app.ExportButton.Enable = 'off';
            app.ExportFigureButton.Enable = 'off';
            app.ExportMatButton.Enable = 'off';
            app.InsertSpectrumInsetButton.Enable = 'off';
            app.DeleteSpectrumInsetButton.Enable = 'off';
            app.clearSpectrumInsetDisplay();
            app.setStatus('workspace_loading');
            drawnow('limitrate');
            cleanup = onCleanup(@() app.restoreActionButtons());

            try
                [app.WorkspaceData, app.SignalCandidates] = FourierAnalysisApp.workspaceSignalCandidates();
                app.MatData = struct();
                app.CsvData = struct();
            catch ME
                app.showError('workspace_load_failed', ME.message);
                return;
            end

            app.CurrentFileName = app.text('workspace_source');
            app.CurrentFilePath = '';
            app.FileLabel.Text = app.CurrentFileName;
            app.HasResult = false;
            app.Result = struct();
            app.ResultTable.Data = cell(0, 2);
            app.ExportButton.Enable = 'off';
            app.ExportFigureButton.Enable = 'off';
            app.ExportMatButton.Enable = 'off';
            app.InsertSpectrumInsetButton.Enable = 'off';
            app.DeleteSpectrumInsetButton.Enable = 'off';
            app.clearSpectrumInsetDisplay();

            if isempty(app.SignalCandidates)
                app.SignalDropDown.Items = {app.text('no_supported_signal')};
                app.SignalDropDown.Value = app.text('no_supported_signal');
                app.AnalyzeButton.Enable = 'off';
                app.CurrentTime = [];
                app.CurrentWaveform = [];
                app.setStatus('workspace_no_supported_signal');
                app.resetPlots();
                return;
            end

            labels = {app.SignalCandidates.label};
            app.SignalDropDown.Items = labels;
            app.SignalDropDown.Value = labels{1};
            app.AnalyzeButton.Enable = 'on';
            app.setStatus('workspace_loaded', numel(labels));
            app.onSignalChanged();
            clear cleanup;
            app.restoreActionButtons();
        end

        function onSignalChanged(app)
            if isempty(app.SignalCandidates)
                return;
            end

            index = find(strcmp(char(app.SignalDropDown.Value), {app.SignalCandidates.label}), 1);
            if isempty(index)
                return;
            end

            try
                candidate = app.SignalCandidates(index);
                if strcmp(candidate.source, 'csv')
                    [time, waveform] = FourierAnalysisApp.readCsvSignal(app.CsvData, candidate.column);
                elseif strcmp(candidate.source, 'workspace')
                    [time, waveform] = app.readSignal(app.WorkspaceData, candidate.path);
                else
                    [time, waveform] = app.readSignal(app.MatData, candidate.path);
                end
            catch ME
                app.showError('signal_read_failed', ME.message);
                return;
            end

            app.CurrentTime = time(:);
            app.CurrentWaveform = waveform;
            app.HasResult = false;
            app.Result = struct();
            app.ResultTable.Data = cell(0, 2);
            app.ExportButton.Enable = 'off';
            app.ExportFigureButton.Enable = 'off';
            app.InsertSpectrumInsetButton.Enable = 'off';
            app.DeleteSpectrumInsetButton.Enable = 'off';
            app.clearSpectrumInsetDisplay();

            channelCount = size(waveform, 2);
            channelItems = arrayfun(@(k) sprintf('%d', k), 1:channelCount, 'UniformOutput', false);
            app.ChannelDropDown.Items = channelItems;
            app.ChannelDropDown.Value = channelItems{1};
            app.setDefaultZoomFields();

            app.plotPreview();
            cla(app.SpectrumAxes);
            app.formatSpectrumAxes('empty');
        end

        function onChannelChanged(app)
            if isempty(app.CurrentTime) || isempty(app.CurrentWaveform)
                return;
            end

            app.HasResult = false;
            app.Result = struct();
            app.ResultTable.Data = cell(0, 2);
            app.ExportButton.Enable = 'off';
            app.ExportFigureButton.Enable = 'off';
            app.InsertSpectrumInsetButton.Enable = 'off';
            app.DeleteSpectrumInsetButton.Enable = 'off';
            app.clearSpectrumInsetDisplay();
            app.plotPreview();
            cla(app.SpectrumAxes);
            app.formatSpectrumAxes('empty');
        end

        function analyzeSignal(app)
            if isempty(app.CurrentTime) || isempty(app.CurrentWaveform)
                app.setStatus('load_select_signal');
                return;
            end

            app.AnalyzeButton.Enable = 'off';
            app.ExportButton.Enable = 'off';
            app.ExportFigureButton.Enable = 'off';
            app.InsertSpectrumInsetButton.Enable = 'off';
            app.DeleteSpectrumInsetButton.Enable = 'off';
            app.clearSpectrumInsetDisplay();
            app.setStatus('analysis_running');
            drawnow('limitrate');
            cleanup = onCleanup(@() app.restoreActionButtons());

            channelIndex = str2double(app.ChannelDropDown.Value);
            waveform = app.CurrentWaveform(:, channelIndex);

            try
                app.Result = fftAnalyzeSignal(app.CurrentTime, waveform, ...
                    app.FundamentalEdit.Value, app.CyclesEdit.Value, ...
                    app.StartTimeEdit.Value, app.MaxFreqEdit.Value, ...
                    app.ThdMethod, app.thdMaxFrequencyLimit());
            catch ME
                app.showError('fft_failed', ME.message);
                return;
            end

            app.HasResult = true;
            app.plotResult(waveform);
            app.updateResultTable();
            app.setDefaultSpectrumInsetFields();
            app.ExportButton.Enable = 'on';
            app.ExportFigureButton.Enable = 'on';
            if app.SpectrumInsetEnabled
                app.InsertSpectrumInsetButton.Enable = 'on';
            end
            app.setStatus('analysis_done');
            clear cleanup;
            app.restoreActionButtons();
        end

        function exportResult(app)
            if ~app.HasResult
                return;
            end
            assignin('base', 'FFT_UI_Result', app.Result);
            app.setStatus('export_done');
        end

        function exportLoadedCsvToMat(app)
            if ~app.hasLoadedCsv()
                app.showError('csv_export_mat_failed', app.text('csv_export_mat_no_data'));
                return;
            end

            channelIndex = app.selectCsvMatExportChannel();
            if isempty(channelIndex)
                return;
            end

            [~, defaultName] = fileparts(app.CurrentFileName);
            if isempty(defaultName)
                defaultName = 'scopeData';
            end
            channelName = FourierAnalysisApp.csvChannelExportName(app.CsvData, channelIndex);
            defaultFile = fullfile(fileparts(app.CurrentFilePath), ...
                sprintf('%s_%s.mat', defaultName, channelName));
            [file, path] = uiputfile({'*.mat', app.text('mat_files_filter')}, ...
                app.text('select_mat_export_file'), defaultFile);
            if isequal(file, 0)
                return;
            end

            outputPath = fullfile(path, file);
            try
                app.writeLoadedCsvToMat(outputPath, channelIndex);
            catch ME
                app.showError('csv_export_mat_failed', ME.message);
                return;
            end
            app.setStatus('csv_export_mat_done', outputPath);
        end

        function outputPath = writeLoadedCsvToMat(app, outputPath, channelIndex)
            if ~app.hasLoadedCsv()
                error('FourierAnalysisApp:NoCsvData', app.text('csv_export_mat_no_data'));
            end
            if nargin < 3
                channelIndex = 1;
            end

            outputPath = char(outputPath);
            [~, variableName] = fileparts(outputPath);
            variableName = matlab.lang.makeValidName(variableName);
            if strlength(string(variableName)) == 0
                variableName = 'scopeData';
            end
            matVariables = FourierAnalysisApp.csvDataToFftAnalyzerMatVariable( ...
                app.CsvData, app.CurrentFilePath, channelIndex, variableName);
            save(outputPath, '-struct', 'matVariables', '-v7.3');
        end

        function tf = hasLoadedCsv(app)
            tf = isstruct(app.CsvData) && isfield(app.CsvData, 'time') && ...
                isfield(app.CsvData, 'waveforms') && ~isempty(app.CsvData.time) && ...
                ~isempty(app.CsvData.waveforms);
        end

        function channelIndex = selectCsvMatExportChannel(app)
            channelCount = size(app.CsvData.waveforms, 2);
            if channelCount == 1
                channelIndex = 1;
                return;
            end

            [channelIndex, ok] = listdlg( ...
                'PromptString', app.text('select_csv_channel_prompt'), ...
                'SelectionMode', 'single', ...
                'ListString', app.CsvData.signalLabels, ...
                'ListSize', [360 180], ...
                'Name', app.text('select_csv_channel_title'));
            if ~ok
                channelIndex = [];
            end
        end

        function fig = exportAnalysisFigure(app)
            if ~app.HasResult || isempty(app.CurrentTime) || isempty(app.CurrentWaveform)
                app.setStatus('load_select_signal');
                fig = [];
                return;
            end

            channelIndex = app.currentChannelIndex();
            waveform = app.CurrentWaveform(:, channelIndex);
            signalName = app.currentSignalName(channelIndex);
            result = app.Result;

            fig = figure('Name', app.text('export_figure_title'), ...
                'Color', 'white', ...
                'Position', [520 160 980 720]);

            timeAxes = axes('Parent', fig, 'Units', 'normalized', ...
                'Position', [0.08 0.58 0.88 0.33]);
            app.drawTimeResult(timeAxes, waveform);
            app.setStandaloneAxesFormat(timeAxes);
            app.setStandaloneTitle(timeAxes, sprintf('%s - %s', app.text('time_title'), signalName));
            app.setStandaloneXLabel(timeAxes, app.text('time_xlabel'));
            app.setStandaloneYLabel(timeAxes, app.text('mag_ylabel'));
            app.setStandaloneLegend(timeAxes, {app.text('legend_signal'), app.text('legend_window')});

            spectrumAxes = axes('Parent', fig, 'Units', 'normalized', ...
                'Position', [0.08 0.11 0.88 0.33]);
            app.drawSpectrumResult(spectrumAxes);
            app.setStandaloneAxesFormat(spectrumAxes);
            app.setStandaloneTitle(spectrumAxes, app.text('spectrum_result_title', ...
                result.fundamentalFrequency, result.fundamentalMagnitude, result.thd * 100));
            app.setStandaloneXLabel(spectrumAxes, app.text('freq_xlabel'));
            app.setStandaloneYLabel(spectrumAxes, app.text('percent_ylabel'));
            if app.hasSpectrumInsetDisplay()
                app.expandSpectrumInsetYLimit(spectrumAxes, app.SpectrumInsetYLimits);
                app.drawSpectrumInsetOverlays(app.SpectrumInsetRanges, app.SpectrumInsetYLimits, spectrumAxes, false);
                frames = app.spectrumInsetRelativeFrames(app.SpectrumInsetRanges, spectrumAxes);
                app.drawSpectrumInsetAxes(app.SpectrumInsetRanges, app.SpectrumInsetYLimits, spectrumAxes, false);
                app.drawSpectrumInsetConnectorAnnotations(spectrumAxes, frames, ...
                    app.SpectrumInsetRanges, app.SpectrumInsetYLimits);
            end

            if isdeployed
                app.setStatus('figure_export_done_deployed');
            else
                assignin('base', 'FFT_UI_Figure', fig);
                app.setStatus('figure_export_done');
            end
        end

        function onLanguageChanged(app)
            if strcmp(app.LanguageDropDown.Value, 'English')
                app.Language = 'en';
            else
                app.Language = 'zh';
            end
            app.updateLanguageTexts();
        end

        function onPlotDetailChanged(app)
            value = app.PlotDetailDropDown.Value;
            items = app.plotDetailItems();
            fastItem = items{1};
            fineItem = items{2};

            if strcmp(value, fastItem)
                app.PlotDetailMode = 'fast';
            elseif strcmp(value, fineItem)
                app.PlotDetailMode = 'fine';
            else
                app.PlotDetailMode = 'full';
            end

            if app.HasResult
                channelIndex = str2double(app.ChannelDropDown.Value);
                app.plotResult(app.CurrentWaveform(:, channelIndex));
            elseif ~isempty(app.CurrentTime)
                app.plotPreview();
            end
        end

        function onThdMethodChanged(app)
            value = app.ThdMethodDropDown.Value;
            items = app.thdMethodItems();
            if strcmp(value, items{2})
                app.ThdMethod = 'spectrum';
            else
                app.ThdMethod = 'matlab';
            end

            if app.HasResult
                app.analyzeSignal();
            end
        end

        function onThdMaxFrequencyChanged(app)
            value = app.ThdMaxFreqDropDown.Value;
            items = app.thdMaxFrequencyItems();
            if strcmp(value, items{2})
                app.ThdMaxFrequencyMode = 'max';
            else
                app.ThdMaxFrequencyMode = 'nyquist';
            end

            if app.HasResult
                app.analyzeSignal();
            end
        end

        function onAxesFormatChanged(app)
            app.GridEnabled = logical(app.GridEnableCheckBox.Value);
            app.BoxEnabled = logical(app.BoxEnableCheckBox.Value);

            items = app.gridStyleItems();
            if strcmp(app.GridStyleDropDown.Value, items{2})
                app.GridLineStyle = '--';
            else
                app.GridLineStyle = '-';
            end

            if app.GridEnabled
                app.GridStyleDropDown.Enable = 'on';
                app.GridStyleLabel.Enable = 'on';
            else
                app.GridStyleDropDown.Enable = 'off';
                app.GridStyleLabel.Enable = 'off';
            end

            if app.HasResult
                channelIndex = app.currentChannelIndex();
                app.plotResult(app.CurrentWaveform(:, channelIndex));
            elseif ~isempty(app.CurrentTime)
                app.plotPreview();
                cla(app.SpectrumAxes);
                app.formatSpectrumAxes('empty');
            else
                app.resetPlots();
            end
        end

        function onZoomEnableChanged(app)
            app.ZoomEnabled = logical(app.ZoomEnableCheckBox.Value);
            app.updateZoomVisibility();
        end

        function onSpectrumInsetEnableChanged(app)
            app.SpectrumInsetEnabled = logical(app.SpectrumInsetEnableCheckBox.Value);
            if ~app.SpectrumInsetEnabled && app.HasResult
                app.deleteSpectrumInsetView();
            end
            app.updateSpectrumInsetVisibility();
        end

        function updateLanguageTexts(app)
            app.Figure.Name = app.text('app_title');
            app.ControlPanel.Title = app.text('fft_params');
            app.PlotPanel.Title = app.text('analysis_results');
            app.SpectrumInsetPanel.Title = app.text('spectrum_inset_panel_title');
            app.ZoomPanel.Title = app.text('zoom_panel_title');
            app.ZoomEnableCheckBox.Text = app.text('enable_zoom_checkbox');
            app.LoadButton.Text = app.text('load_button');
            app.WorkspaceButton.Text = app.text('load_workspace_button');
            app.LanguageLabel.Text = app.text('language');
            app.PlotDetailLabel.Text = app.text('plot_detail');
            app.PlotDetailDropDown.Items = app.plotDetailItems();
            app.PlotDetailDropDown.Value = app.plotDetailValue();
            app.GridEnableCheckBox.Text = app.text('enable_grid_checkbox');
            app.GridStyleLabel.Text = app.text('grid_style');
            app.GridStyleDropDown.Items = app.gridStyleItems();
            app.GridStyleDropDown.Value = app.gridStyleValue();
            app.BoxEnableCheckBox.Text = app.text('enable_box_checkbox');
            if app.GridEnabled
                app.GridStyleLabel.Enable = 'on';
                app.GridStyleDropDown.Enable = 'on';
            else
                app.GridStyleLabel.Enable = 'off';
                app.GridStyleDropDown.Enable = 'off';
            end
            app.SignalLabel.Text = app.text('signal_var');
            app.ChannelLabel.Text = app.text('channel');
            app.FundamentalLabel.Text = app.text('fundamental_hz');
            app.CyclesLabel.Text = app.text('cycles');
            app.StartTimeLabel.Text = app.text('start_time_s');
            app.MaxFreqLabel.Text = app.text('max_freq_hz');
            app.ThdMethodLabel.Text = app.text('thd_method');
            app.ThdMethodDropDown.Items = app.thdMethodItems();
            app.ThdMethodDropDown.Value = app.thdMethodValue();
            app.ThdMaxFreqLabel.Text = app.text('thd_max_frequency');
            app.ThdMaxFreqDropDown.Items = app.thdMaxFrequencyItems();
            app.ThdMaxFreqDropDown.Value = app.thdMaxFrequencyValue();
            app.AnalyzeButton.Text = app.text('analyze_button');
            app.ExportButton.Text = app.text('export_button');
            app.ExportFigureButton.Text = app.text('export_figure_button');
            app.ExportMatButton.Text = app.text('export_mat_button');
            app.SpectrumInsetEnableCheckBox.Text = app.text('enable_spectrum_inset_checkbox');
            app.InsertSpectrumInsetButton.Text = app.text('insert_spectrum_inset_button');
            app.DeleteSpectrumInsetButton.Text = app.text('delete_spectrum_inset_button');
            app.DrawZoomButton.Text = app.text('draw_zoom_button');
            app.AboutButton.Text = app.text('about_button');
            app.ResultTable.ColumnName = {app.text('table_item'), app.text('table_value')};
            app.refreshSpectrumInsetControls();
            app.refreshZoomControls();
            app.updateSpectrumInsetVisibility();
            app.updateZoomVisibility();

            if isempty(app.CurrentFileName)
                app.FileLabel.Text = app.text('loaded_none');
                app.SignalDropDown.Items = {app.text('load_file_first')};
                app.SignalDropDown.Value = app.text('load_file_first');
            elseif isempty(app.SignalCandidates)
                app.SignalDropDown.Items = {app.text('no_supported_signal')};
                app.SignalDropDown.Value = app.text('no_supported_signal');
            end

            app.StatusLabel.Text = app.text(app.LastStatusKey, app.LastStatusArgs{:});

            if app.HasResult
                channelIndex = str2double(app.ChannelDropDown.Value);
                app.plotResult(app.CurrentWaveform(:, channelIndex));
                app.updateResultTable();
            elseif ~isempty(app.CurrentTime)
                app.plotPreview();
                app.formatSpectrumAxes('empty');
            else
                app.resetPlots();
            end
        end

        function plotPreview(app)
            cla(app.TimeAxes);
            channelIndex = app.currentChannelIndex();
            [plotTime, plotWaveform] = FourierAnalysisApp.downsampleForPlot( ...
                app.CurrentTime, app.CurrentWaveform(:, channelIndex), app.timePlotPointLimit());
            plot(app.TimeAxes, plotTime, plotWaveform, ...
                'Color', [0.1 0.35 0.8]);
            title(app.TimeAxes, app.text('time_preview'));
            xlabel(app.TimeAxes, app.text('time_xlabel'));
            ylabel(app.TimeAxes, app.text('mag_ylabel'));
            app.applyAxesFormat(app.TimeAxes);
        end

        function plotResult(app, waveform)
            cla(app.TimeAxes);
            app.drawTimeResult(app.TimeAxes, waveform);

            app.clearSpectrumInsetDisplay();
            cla(app.SpectrumAxes);
            app.drawSpectrumResult(app.SpectrumAxes);
        end

        function drawTimeResult(app, axesHandle, waveform)
            result = app.Result;
            [plotTime, plotWaveform] = FourierAnalysisApp.downsampleForPlot( ...
                app.CurrentTime, waveform, app.timePlotPointLimit());
            [windowTime, windowWaveform] = FourierAnalysisApp.downsampleForPlot( ...
                result.windowTime, result.windowWaveform, app.timePlotPointLimit());
            plot(axesHandle, plotTime, plotWaveform, 'Color', [0.1 0.35 0.8]);
            hold(axesHandle, 'on');
            plot(axesHandle, windowTime, windowWaveform, ...
                'Color', [0.85 0.15 0.1], 'LineWidth', 1.2);
            hold(axesHandle, 'off');
            title(axesHandle, app.text('time_title'));
            xlabel(axesHandle, app.text('time_xlabel'));
            ylabel(axesHandle, app.text('mag_ylabel'));
            legend(axesHandle, {app.text('legend_signal'), app.text('legend_window')}, ...
                'Location', 'best');
            app.applyAxesFormat(axesHandle);
        end

        function drawSpectrumResult(app, axesHandle)
            result = app.Result;
            app.drawSpectrumSeries(axesHandle, result.displayFreqs, result.displayPercent);
            title(axesHandle, app.text('spectrum_result_title', ...
                result.fundamentalFrequency, result.fundamentalMagnitude, result.thd * 100));
            xlabel(axesHandle, app.text('freq_xlabel'));
            ylabel(axesHandle, app.text('percent_ylabel'));
            xlim(axesHandle, [0 max(result.displayFreqs)]);
            app.applyAxesFormat(axesHandle);
        end

        function seriesHandle = drawSpectrumSeries(app, axesHandle, freqs, percentValues)
            if numel(freqs) <= app.MaxSpectrumBarCount
                seriesHandle = bar(axesHandle, freqs, percentValues, ...
                    'FaceColor', [0.2 0.45 0.75], 'EdgeColor', 'none');
                tipFreqs = freqs;
                tipPercent = percentValues;
            else
                [plotFreqs, plotPercent] = FourierAnalysisApp.compressSpectrumForPlot( ...
                    freqs, percentValues, app.MaxSpectrumLinePoints);
                seriesHandle = plot(axesHandle, plotFreqs, plotPercent, ...
                    'Color', [0.2 0.45 0.75], 'LineWidth', 1);
                tipFreqs = plotFreqs;
                tipPercent = plotPercent;
            end
            app.configureSpectrumDataTips(seriesHandle, tipFreqs, tipPercent, app.text('spectrum_datatip_series'));
        end

        function formatSpectrumAxes(app, mode)
            if strcmp(mode, 'empty')
                title(app.SpectrumAxes, app.text('spectrum_title'));
            end
            xlabel(app.SpectrumAxes, app.text('freq_xlabel'));
            ylabel(app.SpectrumAxes, app.text('percent_ylabel'));
            app.applyAxesFormat(app.SpectrumAxes);
        end

        function plotZoomView(app)
            if isempty(app.CurrentTime) || isempty(app.CurrentWaveform)
                app.setStatus('load_select_signal');
                return;
            end

            try
                [zoomRanges, yLimits] = app.readZoomConfig();
            catch ME
                app.showError('zoom_failed', ME.message);
                return;
            end

            channelIndex = app.currentChannelIndex();
            time = app.CurrentTime;
            waveform = app.CurrentWaveform(:, channelIndex);
            signalName = app.currentSignalName(channelIndex);
            zoomCount = size(zoomRanges, 1);
            for k = 1:zoomCount
                if ~any(time >= zoomRanges(k, 1) & time <= zoomRanges(k, 2))
                    app.showError('zoom_failed', app.text('zoom_no_data', zoomRanges(k, 1), zoomRanges(k, 2)));
                    return;
                end
            end

            figure('Name', app.text('zoom_figure_title'), ...
                'Color', 'white', ...
                'Position', [520 120 980 680]);

            overviewPos = [0.08 0.59 0.86 0.32];
            zoomPositions = app.zoomAxesPositions(zoomCount);

            overviewAxes = subplot('Position', overviewPos);
            [plotTime, plotWaveform] = FourierAnalysisApp.downsampleForPlot( ...
                time, waveform, app.timePlotPointLimit());
            plot(overviewAxes, plotTime, plotWaveform, 'Color', [0.1 0.35 0.8]);
            hold(overviewAxes, 'on');
            for k = 1:zoomCount
                app.drawZoomBoundary(overviewAxes, zoomRanges(k, 1));
                app.drawZoomBoundary(overviewAxes, zoomRanges(k, 2));
            end
            hold(overviewAxes, 'off');
            xlim(overviewAxes, [time(1), time(end)]);
            app.setStandaloneAxesFormat(overviewAxes);
            app.setStandaloneTitle(overviewAxes, sprintf('%s - %s', app.text('zoom_overview_title'), signalName));
            app.setStandaloneXLabel(overviewAxes, app.text('time_xlabel'));
            app.setStandaloneYLabel(overviewAxes, app.text('mag_ylabel'));

            for k = 1:zoomCount
                zoomAxes = subplot('Position', zoomPositions(k, :));
                idx = time >= zoomRanges(k, 1) & time <= zoomRanges(k, 2);
                [zoomTime, zoomWaveform] = FourierAnalysisApp.downsampleForPlot( ...
                    time(idx), waveform(idx), app.timePlotPointLimit());
                plot(zoomAxes, zoomTime, zoomWaveform, 'Color', [0.1 0.35 0.8]);
                xlim(zoomAxes, zoomRanges(k, :));
                if ~isempty(yLimits{k})
                    ylim(zoomAxes, yLimits{k});
                end
                app.setStandaloneAxesFormat(zoomAxes);
                app.setStandaloneTitle(zoomAxes, app.text('zoom_subplot_title', k, zoomRanges(k, 1), zoomRanges(k, 2)));
                app.setStandaloneXLabel(zoomAxes, app.text('time_xlabel'));
                app.setStandaloneYLabel(zoomAxes, app.text('mag_ylabel'));
            end
        end

        function fig = insertSpectrumInsetView(app)
            fig = app.Figure;
            if ~app.HasResult
                app.setStatus('spectrum_inset_need_analysis');
                return;
            end

            try
                [freqRanges, commonYLimit] = app.readSpectrumInsetConfig();
            catch ME
                app.showError('spectrum_inset_failed', ME.message);
                return;
            end

            [validRanges, yLimits] = app.validSpectrumInsetConfig(freqRanges, commonYLimit);
            validCount = size(validRanges, 1);

            if validCount == 0
                app.showError('spectrum_inset_failed', app.text('spectrum_inset_no_valid_ranges'));
                return;
            end

            try
                [validRanges, yLimits] = app.mergeSpectrumInsetConfig(validRanges, yLimits);
            catch ME
                app.showError('spectrum_inset_failed', ME.message);
                return;
            end

            app.SpectrumInsetRanges = validRanges;
            app.SpectrumInsetYLimits = yLimits;
            app.redrawSpectrumInsetDisplay();
            app.setStatus('spectrum_inset_done', size(validRanges, 1));
            app.restoreActionButtons();
        end

        function deleteSpectrumInsetView(app)
            if ~app.HasResult
                app.clearSpectrumInsetDisplay();
                app.restoreActionButtons();
                return;
            end

            app.clearSpectrumInsetDisplay();
            cla(app.SpectrumAxes);
            app.drawSpectrumResult(app.SpectrumAxes);
            app.setStatus('spectrum_inset_deleted');
            app.restoreActionButtons();
        end

        function setSpectrumInsetRangeText(app, ranges)
            if isempty(ranges)
                app.SpectrumRangesEdit.Value = '';
                return;
            end
            rangeText = strings(size(ranges, 1), 1);
            for k = 1:size(ranges, 1)
                rangeText(k) = sprintf('%.9g-%.9g', ranges(k, 1), ranges(k, 2));
            end
            app.SpectrumRangesEdit.Value = strjoin(rangeText, ', ');
        end

        function [validRanges, yLimits] = validSpectrumInsetConfig(app, freqRanges, commonYLimit)
            result = app.Result;
            validRanges = zeros(size(freqRanges));
            yLimits = cell(size(freqRanges, 1), 1);
            validCount = 0;
            for k = 1:size(freqRanges, 1)
                insetIndex = result.displayFreqs >= freqRanges(k, 1) & result.displayFreqs <= freqRanges(k, 2);
                if ~any(insetIndex)
                    continue;
                end
                validCount = validCount + 1;
                validRanges(validCount, :) = freqRanges(k, :);
                if isempty(commonYLimit)
                    yLimits{validCount} = app.defaultSpectrumInsetYLimit(freqRanges(k, :));
                else
                    yLimits{validCount} = commonYLimit;
                end
            end
            validRanges = validRanges(1:validCount, :);
            yLimits = yLimits(1:validCount);
        end

        function [mergedRanges, mergedYLimits] = mergeSpectrumInsetConfig(app, newRanges, newYLimits)
            if size(newRanges, 1) == 2
                mergedRanges = newRanges;
                mergedYLimits = newYLimits;
                return;
            end

            mergedRanges = app.SpectrumInsetRanges;
            mergedYLimits = app.SpectrumInsetYLimits;

            for k = 1:size(newRanges, 1)
                existingIndex = app.findMatchingSpectrumInsetRange(mergedRanges, newRanges(k, :));
                if isempty(existingIndex)
                    if size(mergedRanges, 1) >= 2
                        error(app.text('spectrum_range_count_error'));
                    end
                    mergedRanges(end + 1, :) = newRanges(k, :); %#ok<AGROW>
                    mergedYLimits{end + 1, 1} = newYLimits{k}; %#ok<AGROW>
                else
                    mergedRanges(existingIndex, :) = newRanges(k, :);
                    mergedYLimits{existingIndex} = newYLimits{k};
                end
            end
        end

        function index = findMatchingSpectrumInsetRange(~, ranges, targetRange)
            index = [];
            if isempty(ranges)
                return;
            end
            tolerance = max(1e-9, 1e-9 * max(abs(targetRange)));
            matches = all(abs(ranges - targetRange) <= tolerance, 2);
            index = find(matches, 1);
        end

        function updateSpectrumInsetYLimits(app, ranges, force)
            if nargin < 3
                force = false;
            end
            if isempty(ranges) || ~app.HasResult
                return;
            end
            if ~force && (~isempty(strtrim(app.SpectrumYMinEdit.Value)) || ~isempty(strtrim(app.SpectrumYMaxEdit.Value)))
                return;
            end
            maxY = 0;
            for k = 1:size(ranges, 1)
                yLimit = app.defaultSpectrumInsetYLimit(ranges(k, :));
                maxY = max(maxY, yLimit(2));
            end
            app.SpectrumYMinEdit.Value = '0';
            app.SpectrumYMaxEdit.Value = app.formatNumberForEdit(maxY);
        end

        function resetPlots(app)
            cla(app.TimeAxes);
            title(app.TimeAxes, app.text('time_title'));
            xlabel(app.TimeAxes, app.text('time_xlabel'));
            ylabel(app.TimeAxes, app.text('mag_ylabel'));
            app.applyAxesFormat(app.TimeAxes);

            cla(app.SpectrumAxes);
            app.formatSpectrumAxes('empty');
            app.clearSpectrumInsetDisplay();
        end

        function updateResultTable(app)
            result = app.Result;
            app.ResultTable.Data = {
                app.text('result_fs'), result.fs
                app.text('result_dt'), result.dt
                app.text('result_df'), result.df
                app.text('result_n'), result.N
                app.text('result_fund_freq'), result.fundamentalFrequency
                app.text('result_fund_mag'), result.fundamentalMagnitude
                app.text('result_thd_method'), app.thdMethodDisplayName(result.thdMethod)
                app.text('result_thd'), result.thd * 100
                app.text('result_thd_matlab'), result.thdMatlabOriginal * 100
                app.text('result_thd_full_spectrum'), result.thdFullSpectrum * 100
                };
        end

        function setDefaultZoomFields(app)
            if isempty(app.CurrentTime)
                return;
            end

            timeStart = app.CurrentTime(1);
            timeEnd = app.CurrentTime(end);
            span = timeEnd - timeStart;
            if span <= 0
                return;
            end

            zoomStart = timeStart + 0.10 * span;
            zoomEnd = timeStart + 0.15 * span;
            app.Zoom1StartEdit.Value = app.formatNumberForEdit(zoomStart);
            app.Zoom1EndEdit.Value = app.formatNumberForEdit(zoomEnd);
            app.Zoom1YMinEdit.Value = '';
            app.Zoom1YMaxEdit.Value = '';
            app.Zoom2StartEdit.Value = '';
            app.Zoom2EndEdit.Value = '';
            app.Zoom2YMinEdit.Value = '';
            app.Zoom2YMaxEdit.Value = '';
            app.Zoom3StartEdit.Value = '';
            app.Zoom3EndEdit.Value = '';
            app.Zoom3YMinEdit.Value = '';
            app.Zoom3YMaxEdit.Value = '';
        end

        function setDefaultSpectrumInsetFields(app)
            if ~app.HasResult || isempty(app.Result.displayFreqs)
                return;
            end

            result = app.Result;
            maxFreq = max(result.displayFreqs);
            if maxFreq <= 0
                return;
            end

            f0 = result.fundamentalFrequency;
            if maxFreq > 2 * f0
                freqStart = 2 * f0;
                freqEnd = min(maxFreq, max(freqStart + f0, 10 * f0));
            else
                freqStart = 0.10 * maxFreq;
                freqEnd = 0.35 * maxFreq;
            end

            if freqEnd <= freqStart
                freqStart = 0;
                freqEnd = maxFreq;
            end

            freqRanges = [freqStart, freqEnd];
            app.setSpectrumInsetRangeText(freqRanges);
            app.SpectrumYMinEdit.Value = '';
            app.SpectrumYMaxEdit.Value = '';
        end

        function [ranges, yLimits] = readZoomConfig(app)
            z1Start = app.parseRequiredEdit(app.Zoom1StartEdit.Value, app.text('zoom1_start_name'));
            z1End = app.parseRequiredEdit(app.Zoom1EndEdit.Value, app.text('zoom1_end_name'));
            app.validateZoomRange(z1Start, z1End, app.text('zoom1_label'));
            ranges = zeros(3, 2);
            yLimits = cell(3, 1);
            zoomCount = 1;
            ranges(zoomCount, :) = [z1Start, z1End];
            yLimits{zoomCount} = app.readOptionalYLimit( ...
                app.Zoom1YMinEdit.Value, app.Zoom1YMaxEdit.Value, app.text('zoom1_label'));

            optionalSpecs = {
                app.Zoom2StartEdit, app.Zoom2EndEdit, app.Zoom2YMinEdit, app.Zoom2YMaxEdit, app.text('zoom2_label'), app.text('zoom2_start_name'), app.text('zoom2_end_name')
                app.Zoom3StartEdit, app.Zoom3EndEdit, app.Zoom3YMinEdit, app.Zoom3YMaxEdit, app.text('zoom3_label'), app.text('zoom3_start_name'), app.text('zoom3_end_name')
                };
            for k = 1:size(optionalSpecs, 1)
                startText = strtrim(optionalSpecs{k, 1}.Value);
                endText = strtrim(optionalSpecs{k, 2}.Value);
                if isempty(startText) && isempty(endText)
                    continue;
                end
                if isempty(startText) || isempty(endText)
                    error(app.text('zoom_optional_pair_error', optionalSpecs{k, 5}));
                end

                startTime = app.parseRequiredEdit(startText, optionalSpecs{k, 6});
                endTime = app.parseRequiredEdit(endText, optionalSpecs{k, 7});
                app.validateZoomRange(startTime, endTime, optionalSpecs{k, 5});
                zoomCount = zoomCount + 1;
                ranges(zoomCount, :) = [startTime, endTime];
                yLimits{zoomCount} = app.readOptionalYLimit( ...
                    optionalSpecs{k, 3}.Value, optionalSpecs{k, 4}.Value, optionalSpecs{k, 5});
            end
            ranges = ranges(1:zoomCount, :);
            yLimits = yLimits(1:zoomCount);
        end

        function [freqRanges, yLimit] = readSpectrumInsetConfig(app)
            freqRanges = app.parseSpectrumRanges(app.SpectrumRangesEdit.Value);
            minFreq = min(app.Result.displayFreqs);
            maxFreq = max(app.Result.displayFreqs);
            for k = 1:size(freqRanges, 1)
                if freqRanges(k, 2) < minFreq || freqRanges(k, 1) > maxFreq
                    error(app.text('spectrum_freq_outside_error', minFreq, maxFreq));
                end
                freqRanges(k, :) = [max(minFreq, freqRanges(k, 1)), min(maxFreq, freqRanges(k, 2))];
            end

            yLimit = app.readOptionalYLimit( ...
                app.SpectrumYMinEdit.Value, app.SpectrumYMaxEdit.Value, app.text('spectrum_inset_label'));
        end

        function freqRanges = parseSpectrumRanges(app, textValue)
            textValue = strtrim(char(textValue));
            if isempty(textValue)
                error(app.text('zoom_required_error', app.text('spectrum_ranges_name')));
            end

            parts = regexp(textValue, '[,;，；\n\r]+', 'split');
            freqRanges = zeros(numel(parts), 2);
            rangeCount = 0;
            numberPattern = '([0-9]+(\.[0-9]*)?|\.[0-9]+)([eE][+-]?[0-9]+)?';
            for k = 1:numel(parts)
                part = strtrim(parts{k});
                if isempty(part)
                    continue;
                end
                numbers = regexp(part, numberPattern, 'match');
                if numel(numbers) ~= 2
                    error(app.text('spectrum_range_format_error'));
                end
                freqStart = str2double(numbers{1});
                freqEnd = str2double(numbers{2});
                if ~isfinite(freqStart) || ~isfinite(freqEnd)
                    error(app.text('spectrum_range_format_error'));
                end
                if freqEnd <= freqStart
                    error(app.text('spectrum_freq_order_error'));
                end
                rangeCount = rangeCount + 1;
                freqRanges(rangeCount, :) = [freqStart, freqEnd];
            end

            if rangeCount == 0
                error(app.text('zoom_required_error', app.text('spectrum_ranges_name')));
            end
            if rangeCount > 2
                error(app.text('spectrum_range_count_error'));
            end
            freqRanges = freqRanges(1:rangeCount, :);
        end

        function yLimit = defaultSpectrumInsetYLimit(app, freqRange)
            result = app.Result;
            idx = result.displayFreqs >= freqRange(1) & result.displayFreqs <= freqRange(2);
            if ~any(idx)
                yLimit = [0, 1];
                return;
            end

            localMax = max(result.displayPercent(idx));
            if ~isfinite(localMax) || localMax <= 0
                localMax = max(result.displayPercent) * 0.10;
            end
            if ~isfinite(localMax) || localMax <= 0
                localMax = 1;
            end
            yLimit = [0, max(1, localMax * 1.18)];
        end

        function yLimits = readZoomYLimits(app)
            yLimits = cell(3, 1);
            yLimits{1} = app.readOptionalYLimit( ...
                app.Zoom1YMinEdit.Value, app.Zoom1YMaxEdit.Value, app.text('zoom1_label'));
            yLimits{2} = app.readOptionalYLimit( ...
                app.Zoom2YMinEdit.Value, app.Zoom2YMaxEdit.Value, app.text('zoom2_label'));
            yLimits{3} = app.readOptionalYLimit( ...
                app.Zoom3YMinEdit.Value, app.Zoom3YMaxEdit.Value, app.text('zoom3_label'));
        end

        function yLimit = readOptionalYLimit(app, yMinText, yMaxText, label)
            yMinText = strtrim(yMinText);
            yMaxText = strtrim(yMaxText);
            if isempty(yMinText) && isempty(yMaxText)
                yLimit = [];
                return;
            end
            if isempty(yMinText) || isempty(yMaxText)
                error(app.text('zoom_y_pair_error', label));
            end

            yMin = app.parseRequiredEdit(yMinText, app.text('zoom_ymin'));
            yMax = app.parseRequiredEdit(yMaxText, app.text('zoom_ymax'));
            if yMax <= yMin
                error(app.text('zoom_y_order_error', label));
            end
            yLimit = [yMin, yMax];
        end

        function value = parseRequiredEdit(app, textValue, label)
            textValue = strtrim(textValue);
            if isempty(textValue)
                error(app.text('zoom_required_error', label));
            end
            value = str2double(textValue);
            if ~isfinite(value)
                error(app.text('zoom_numeric_error', label));
            end
        end

        function validateZoomRange(app, startTime, endTime, label)
            if endTime <= startTime
                error(app.text('zoom_time_order_error', label));
            end
            if endTime < app.CurrentTime(1) || startTime > app.CurrentTime(end)
                error(app.text('zoom_time_outside_error', label, app.CurrentTime(1), app.CurrentTime(end)));
            end
        end

        function index = currentChannelIndex(app)
            index = str2double(app.ChannelDropDown.Value);
            if ~isfinite(index) || index < 1 || index > size(app.CurrentWaveform, 2)
                index = 1;
            end
        end

        function name = currentSignalName(app, channelIndex)
            signalName = char(app.SignalDropDown.Value);
            if size(app.CurrentWaveform, 2) > 1
                name = sprintf('%s - %s %d', signalName, app.text('channel'), channelIndex);
            else
                name = signalName;
            end
        end

        function drawSpectrumInsetOverlays(app, freqRanges, yLimits, axesHandle, rememberHandles)
            if nargin < 4 || isempty(axesHandle)
                axesHandle = app.SpectrumAxes;
            end
            if nargin < 5
                rememberHandles = true;
            end
            if isempty(axesHandle) || ~isvalid(axesHandle)
                return;
            end

            overlays = gobjects(size(freqRanges, 1), 1);
            hold(axesHandle, 'on');
            for k = 1:size(freqRanges, 1)
                yLimit = yLimits{k};
                overlays(k) = rectangle(axesHandle, ...
                    'Position', [freqRanges(k, 1), yLimit(1), diff(freqRanges(k, :)), diff(yLimit)], ...
                    'EdgeColor', [0.85 0.15 0.1], ...
                    'LineStyle', '--', ...
                    'LineWidth', 1.1, ...
                    'HitTest', 'off');
            end
            hold(axesHandle, 'off');
            if rememberHandles
                app.SpectrumInsetOverlays = [app.SpectrumInsetOverlays(:); overlays(:)];
            end
        end

        function expandSpectrumInsetYLimit(~, axesHandle, yLimits)
            currentYLimit = ylim(axesHandle);
            maxInsetY = currentYLimit(2);
            for k = 1:numel(yLimits)
                maxInsetY = max(maxInsetY, yLimits{k}(2));
            end
            ylim(axesHandle, [currentYLimit(1), maxInsetY * 1.04]);
        end

        function drawSpectrumInsetAxes(app, freqRanges, yLimits, axesHandle, rememberHandles)
            if isempty(freqRanges)
                return;
            end
            if nargin < 4 || isempty(axesHandle)
                axesHandle = app.SpectrumAxes;
            end
            if nargin < 5
                rememberHandles = true;
            end

            result = app.Result;
            insetHandles = gobjects(0);
            if isa(axesHandle, 'matlab.ui.control.UIAxes')
                frames = app.spectrumInsetDataFrames(freqRanges, axesHandle);
                hold(axesHandle, 'on');
                for k = 1:size(freqRanges, 1)
                    insetIndex = result.displayFreqs >= freqRanges(k, 1) & result.displayFreqs <= freqRanges(k, 2);
                    newHandles = app.drawSingleSpectrumInsetFrame( ...
                        axesHandle, ...
                        frames(k, :), ...
                        freqRanges(k, :), ...
                        yLimits{k}, ...
                        result.displayFreqs(insetIndex), ...
                        result.displayPercent(insetIndex));
                    insetHandles = [insetHandles; newHandles(:)]; %#ok<AGROW>
                end
                hold(axesHandle, 'off');
            else
                frames = app.spectrumInsetRelativeFrames(freqRanges, axesHandle);
                for k = 1:size(freqRanges, 1)
                    insetIndex = result.displayFreqs >= freqRanges(k, 1) & result.displayFreqs <= freqRanges(k, 2);
                    insetAxes = app.createSpectrumInsetAxes(axesHandle, frames(k, :));
                    app.drawSingleSpectrumInsetAxes( ...
                        insetAxes, ...
                        frames(k, :), ...
                        freqRanges(k, :), ...
                        yLimits{k}, ...
                        result.displayFreqs(insetIndex), ...
                        result.displayPercent(insetIndex));
                    insetHandles = [insetHandles; insetAxes]; %#ok<AGROW>
                end
            end
            if rememberHandles
                app.SpectrumInsetOverlays = [app.SpectrumInsetOverlays(:); insetHandles(:)];
            end
        end

        function redrawSpectrumInsetDisplay(app)
            app.clearSpectrumInsetGraphics();
            cla(app.SpectrumAxes);
            app.drawSpectrumResult(app.SpectrumAxes);
            if app.hasSpectrumInsetDisplay()
                app.expandSpectrumInsetYLimit(app.SpectrumAxes, app.SpectrumInsetYLimits);
                app.drawSpectrumInsetAxes(app.SpectrumInsetRanges, app.SpectrumInsetYLimits);
                frames = app.spectrumInsetDataFrames(app.SpectrumInsetRanges, app.SpectrumAxes);
                app.drawSpectrumInsetOverlays(app.SpectrumInsetRanges, app.SpectrumInsetYLimits);
                app.drawSpectrumInsetConnectorLines(app.SpectrumAxes, frames, app.SpectrumInsetRanges, app.SpectrumInsetYLimits);
            end
        end

        function insetAxes = createSpectrumInsetAxes(app, mainAxes, relativeFrame)
            if isa(mainAxes, 'matlab.ui.control.UIAxes')
                mainPosition = getpixelposition(mainAxes, true);
                insetPosition = [
                    mainPosition(1) + relativeFrame(1) * mainPosition(3), ...
                    mainPosition(2) + relativeFrame(2) * mainPosition(4), ...
                    relativeFrame(3) * mainPosition(3), ...
                    relativeFrame(4) * mainPosition(4)
                    ];
                insetAxes = uiaxes(app.Figure, 'Position', insetPosition);
                try
                    insetAxes.Toolbar.Visible = 'off';
                catch
                end
            else
                fig = ancestor(mainAxes, 'figure');
                oldUnits = mainAxes.Units;
                mainAxes.Units = 'normalized';
                mainPosition = mainAxes.Position;
                mainAxes.Units = oldUnits;
                insetPosition = [
                    mainPosition(1) + relativeFrame(1) * mainPosition(3), ...
                    mainPosition(2) + relativeFrame(2) * mainPosition(4), ...
                    relativeFrame(3) * mainPosition(3), ...
                    relativeFrame(4) * mainPosition(4)
                    ];
                insetAxes = axes('Parent', fig, 'Units', 'normalized', 'Position', insetPosition);
            end
            insetAxes.Tag = 'SpectrumInsetAxes';
        end

        function drawSingleSpectrumInsetAxes(app, insetAxes, ~, freqRange, yLimit, freqs, percentValues)
            app.drawSpectrumSeries(insetAxes, freqs, percentValues);
            xlim(insetAxes, freqRange);
            ylim(insetAxes, yLimit);
            app.applyAxesFormat(insetAxes);
            title(insetAxes, app.text('spectrum_inset_subplot_title', freqRange(1), freqRange(2)), ...
                'FontSize', 9, 'Interpreter', 'none');
            xlabel(insetAxes, app.text('freq_xlabel'), 'FontSize', 8);
            ylabel(insetAxes, app.text('percent_ylabel'), 'FontSize', 8);
            insetAxes.FontSize = 8;
        end

        function handles = drawSpectrumInsetGrid(app, axesHandle, plotX, plotY)
            handles = gobjects(0);
            if ~app.GridEnabled
                return;
            end

            gridColor = [0.82 0.82 0.82];
            xGrid = linspace(plotX(1), plotX(2), 4);
            yGrid = linspace(plotY(1), plotY(2), 4);
            for k = 2:numel(xGrid)-1
                handles(end + 1, 1) = line(axesHandle, [xGrid(k) xGrid(k)], plotY, ...
                    'Color', gridColor, ...
                    'LineStyle', app.GridLineStyle, ...
                    'LineWidth', 0.45, ...
                    'HitTest', 'off'); %#ok<AGROW>
            end
            for k = 2:numel(yGrid)-1
                handles(end + 1, 1) = line(axesHandle, plotX, [yGrid(k) yGrid(k)], ...
                    'Color', gridColor, ...
                    'LineStyle', app.GridLineStyle, ...
                    'LineWidth', 0.45, ...
                'HitTest', 'off'); %#ok<AGROW>
            end
        end

        function drawSpectrumInsetConnectorLines(app, axesHandle, frames, freqRanges, yLimits)
            if isempty(frames)
                return;
            end

            connectorHandles = gobjects(0);
            hold(axesHandle, 'on');
            for k = 1:size(frames, 1)
                frame = frames(k, :);
                frameX = [frame(1), frame(1) + frame(3)];
                frameY = [frame(2), frame(2) + frame(4)];
                plotX = [frameX(1) + 0.055 * frame(3), frameX(2) - 0.055 * frame(3)];
                plotY = [frameY(1) + 0.18 * frame(4), frameY(2) - 0.18 * frame(4)];
                yLimit = yLimits{k};

                connectorHandles(end + 1, 1) = line(axesHandle, ...
                    [freqRanges(k, 1), plotX(1)], [yLimit(2), plotY(1)], ...
                    'Color', [0.9 0.35 0.25], ...
                    'LineStyle', '--', ...
                    'LineWidth', 1.05, ...
                    'Clipping', 'off', ...
                    'HitTest', 'off'); %#ok<AGROW>
                connectorHandles(end + 1, 1) = line(axesHandle, ...
                    [freqRanges(k, 2), plotX(2)], [yLimit(2), plotY(1)], ...
                    'Color', [0.9 0.35 0.25], ...
                    'LineStyle', '--', ...
                    'LineWidth', 1.05, ...
                    'Clipping', 'off', ...
                    'HitTest', 'off'); %#ok<AGROW>
            end
            hold(axesHandle, 'off');
            app.SpectrumInsetOverlays = [app.SpectrumInsetOverlays(:); connectorHandles(:)];
        end

        function annotationHandles = drawSpectrumInsetConnectorAnnotations(app, axesHandle, relativeFrames, freqRanges, insetYLimits)
            annotationHandles = gobjects(0);
            if isempty(relativeFrames)
                return;
            end

            fig = ancestor(axesHandle, 'figure');
            if isempty(fig) || ~isvalid(fig)
                return;
            end

            oldUnits = axesHandle.Units;
            restoreUnits = onCleanup(@() set(axesHandle, 'Units', oldUnits));
            axesHandle.Units = 'normalized';
            mainPosition = axesHandle.Position;
            xLimits = xlim(axesHandle);
            mainYLimits = ylim(axesHandle);

            for k = 1:size(relativeFrames, 1)
                frame = relativeFrames(k, :);
                plotX = [frame(1) + 0.055 * frame(3), frame(1) + frame(3) - 0.055 * frame(3)];
                plotY = frame(2) + 0.18 * frame(4);
                sourceY = insetYLimits{k}(2);

                sourceLeft = app.axesDataToFigurePoint(mainPosition, xLimits, mainYLimits, ...
                    freqRanges(k, 1), sourceY);
                sourceRight = app.axesDataToFigurePoint(mainPosition, xLimits, mainYLimits, ...
                    freqRanges(k, 2), sourceY);
                targetLeft = [
                    mainPosition(1) + plotX(1) * mainPosition(3), ...
                    mainPosition(2) + plotY * mainPosition(4)
                    ];
                targetRight = [
                    mainPosition(1) + plotX(2) * mainPosition(3), ...
                    mainPosition(2) + plotY * mainPosition(4)
                    ];

                annotationHandles(end + 1, 1) = app.drawSpectrumInsetAnnotationLine( ...
                    fig, sourceLeft, targetLeft); %#ok<AGROW>
                annotationHandles(end + 1, 1) = app.drawSpectrumInsetAnnotationLine( ...
                    fig, sourceRight, targetRight); %#ok<AGROW>
            end
        end

        function lineHandle = drawSpectrumInsetAnnotationLine(~, fig, sourcePoint, targetPoint)
            sourcePoint = min(max(sourcePoint, 0), 1);
            targetPoint = min(max(targetPoint, 0), 1);
            lineHandle = annotation(fig, 'line', ...
                [sourcePoint(1), targetPoint(1)], ...
                [sourcePoint(2), targetPoint(2)], ...
                'Color', [0.9 0.35 0.25], ...
                'LineStyle', '--', ...
                'LineWidth', 1.05);
        end

        function point = axesDataToFigurePoint(~, axesPosition, xLimits, yLimits, xValue, yValue)
            point = [
                axesPosition(1) + (xValue - xLimits(1)) / diff(xLimits) * axesPosition(3), ...
                axesPosition(2) + (yValue - yLimits(1)) / diff(yLimits) * axesPosition(4)
                ];
        end

        function configureSpectrumDataTips(app, chartHandle, freqs, percentValues, seriesName)
            try
                if isempty(chartHandle) || ~isvalid(chartHandle) || ~isprop(chartHandle, 'DataTipTemplate')
                    return;
                end
                freqs = freqs(:);
                percentValues = percentValues(:);
                if numel(freqs) ~= numel(percentValues)
                    return;
                end
                chartHandle.DisplayName = seriesName;
                chartHandle.DataTipTemplate.Interpreter = 'none';
                chartHandle.DataTipTemplate.DataTipRows = [
                    dataTipTextRow(app.text('datatip_frequency'), freqs), ...
                    dataTipTextRow(app.text('datatip_percent'), percentValues)
                    ];
            catch
            end
        end

        function handles = drawSingleSpectrumInsetFrame(app, axesHandle, frame, freqRange, yLimit, freqs, percentValues)
            frameX = [frame(1), frame(1) + frame(3)];
            frameY = [frame(2), frame(2) + frame(4)];
            plotX = [frameX(1) + 0.055 * frame(3), frameX(2) - 0.055 * frame(3)];
            plotY = [frameY(1) + 0.18 * frame(4), frameY(2) - 0.18 * frame(4)];
            handles = gobjects(0);

            handles(end + 1, 1) = rectangle(axesHandle, ...
                'Position', frame, ...
                'FaceColor', 'white', ...
                'EdgeColor', 'none', ...
                'HitTest', 'off');
            gridHandles = app.drawSpectrumInsetGrid(axesHandle, plotX, plotY);
            handles = [handles; gridHandles(:)]; %#ok<AGROW>

            if numel(freqs) > 450
                stride = ceil(numel(freqs) / 450);
                freqs = freqs(1:stride:end);
                percentValues = percentValues(1:stride:end);
            end

            xValues = plotX(1) + (freqs - freqRange(1)) ./ diff(freqRange) * diff(plotX);
            yBase = plotY(1);
            yValues = plotY(1) + (percentValues - yLimit(1)) ./ diff(yLimit) * diff(plotY);
            yValues = min(max(yValues, plotY(1)), plotY(2));

            if numel(app.Result.displayFreqs) <= app.MaxSpectrumBarCount
                xSegments = [xValues(:)'; xValues(:)'; nan(1, numel(xValues))];
                ySegments = [repmat(yBase, 1, numel(yValues)); yValues(:)'; nan(1, numel(yValues))];
                insetSeries = line(axesHandle, xSegments(:), ySegments(:), ...
                    'Color', [0.2 0.45 0.75], ...
                    'LineWidth', 0.7, ...
                    'HitTest', 'on', ...
                    'PickableParts', 'visible');
                tipFreqSegments = [freqs(:)'; freqs(:)'; nan(1, numel(freqs))];
                tipPercentSegments = [percentValues(:)'; percentValues(:)'; nan(1, numel(percentValues))];
                app.configureSpectrumDataTips(insetSeries, tipFreqSegments(:), tipPercentSegments(:), ...
                    app.text('spectrum_inset_datatip_series'));
            else
                insetSeries = line(axesHandle, xValues(:), yValues(:), ...
                    'Color', [0.2 0.45 0.75], ...
                    'LineWidth', 1, ...
                    'HitTest', 'on', ...
                    'PickableParts', 'visible');
                app.configureSpectrumDataTips(insetSeries, freqs(:), percentValues(:), ...
                    app.text('spectrum_inset_datatip_series'));
            end
            handles(end + 1, 1) = insetSeries;
            handles(end + 1, 1) = line(axesHandle, plotX, [yBase yBase], ...
                'Color', [0.25 0.25 0.25], ...
                'LineWidth', 0.5, ...
                'HitTest', 'off');
            handles(end + 1, 1) = line(axesHandle, [plotX(1) plotX(1)], plotY, ...
                'Color', [0.25 0.25 0.25], ...
                'LineWidth', 0.5, ...
                'HitTest', 'off');
            if app.BoxEnabled
                handles(end + 1, 1) = line(axesHandle, plotX, [plotY(2) plotY(2)], ...
                    'Color', [0.25 0.25 0.25], ...
                    'LineWidth', 0.5, ...
                    'HitTest', 'off');
                handles(end + 1, 1) = line(axesHandle, [plotX(2) plotX(2)], plotY, ...
                    'Color', [0.25 0.25 0.25], ...
                    'LineWidth', 0.5, ...
                    'HitTest', 'off');
            end

            titleText = app.text('spectrum_inset_subplot_title', freqRange(1), freqRange(2));
            handles(end + 1, 1) = text(axesHandle, mean(frameX), frameY(2) - 0.045 * frame(4), ...
                titleText, ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'top', ...
                'FontName', app.standaloneFontName(titleText), ...
                'FontSize', 9, ...
                'Color', [0.05 0.05 0.05], ...
                'HitTest', 'off');
            handles(end + 1, 1) = text(axesHandle, plotX(1), frameY(1) + 0.04 * frame(4), ...
                app.formatNumberForEdit(freqRange(1)), ...
                'HorizontalAlignment', 'left', ...
                'VerticalAlignment', 'bottom', ...
                'FontName', 'Times New Roman', ...
                'FontSize', 8, ...
                'Color', [0.05 0.05 0.05], ...
                'HitTest', 'off');
            handles(end + 1, 1) = text(axesHandle, plotX(2), frameY(1) + 0.04 * frame(4), ...
                app.formatNumberForEdit(freqRange(2)), ...
                'HorizontalAlignment', 'right', ...
                'VerticalAlignment', 'bottom', ...
                'FontName', 'Times New Roman', ...
                'FontSize', 8, ...
                'Color', [0.05 0.05 0.05], ...
                'HitTest', 'off');
        end

        function frames = spectrumInsetRelativeFrames(app, freqRanges, axesHandle)
            if nargin < 3 || isempty(axesHandle)
                axesHandle = app.SpectrumAxes;
            end
            insetCount = size(freqRanges, 1);
            [relativeWidth, relativeHeight] = app.spectrumInsetRelativeSize(insetCount);
            candidates = app.spectrumInsetCandidates(relativeWidth, relativeHeight);
            scores = app.scoreSpectrumInsetCandidates(candidates, relativeWidth, relativeHeight, freqRanges, axesHandle);
            [~, order] = sort(scores, 'descend');
            selected = order(1:min(insetCount, numel(order)));

            frames = zeros(insetCount, 4);
            for k = 1:insetCount
                if k <= numel(selected)
                    candidate = candidates(selected(k), :);
                else
                    candidate = [0.08 + 0.30 * mod(k - 1, 3), 0.58 - 0.32 * floor((k - 1) / 3)];
                end
                frames(k, :) = [candidate(1), candidate(2), relativeWidth, relativeHeight];
            end
        end

        function frames = spectrumInsetDataFrames(app, freqRanges, axesHandle)
            relativeFrames = app.spectrumInsetRelativeFrames(freqRanges, axesHandle);
            xLimits = xlim(axesHandle);
            yLimits = ylim(axesHandle);
            frames = zeros(size(relativeFrames));
            for k = 1:size(relativeFrames, 1)
                frames(k, :) = [
                    xLimits(1) + diff(xLimits) * relativeFrames(k, 1), ...
                    yLimits(1) + diff(yLimits) * relativeFrames(k, 2), ...
                    diff(xLimits) * relativeFrames(k, 3), ...
                    diff(yLimits) * relativeFrames(k, 4)
                    ];
            end
        end

        function [relativeWidth, relativeHeight] = spectrumInsetRelativeSize(~, insetCount)
            if insetCount <= 1
                relativeWidth = 0.36;
                relativeHeight = 0.32;
            elseif insetCount == 2
                relativeWidth = 0.30;
                relativeHeight = 0.28;
            else
                relativeWidth = 0.26;
                relativeHeight = 0.24;
            end
        end

        function candidates = spectrumInsetCandidates(~, relativeWidth, relativeHeight)
            xPositions = [0.08, 0.37, 0.66];
            yPositions = [0.64, 0.36];
            candidates = zeros(numel(xPositions) * numel(yPositions), 2);
            row = 0;
            for y = yPositions
                for x = xPositions
                    row = row + 1;
                    candidates(row, :) = [min(x, 0.96 - relativeWidth), min(y, 0.93 - relativeHeight)];
                end
            end
        end

        function scores = scoreSpectrumInsetCandidates(app, candidates, relativeWidth, ~, freqRanges, axesHandle)
            xLimits = xlim(axesHandle);
            yPreference = candidates(:, 2);
            scores = yPreference * 2;
            maxPercent = max(app.Result.displayPercent);
            if ~isfinite(maxPercent) || maxPercent <= 0
                maxPercent = 1;
            end

            for k = 1:size(candidates, 1)
                candidateFreq = [
                    xLimits(1) + candidates(k, 1) * diff(xLimits)
                    xLimits(1) + (candidates(k, 1) + relativeWidth) * diff(xLimits)
                    ];
                localIndex = app.Result.displayFreqs >= candidateFreq(1) & app.Result.displayFreqs <= candidateFreq(2);
                if any(localIndex)
                    localPeak = max(app.Result.displayPercent(localIndex)) / maxPercent;
                    scores(k) = scores(k) - localPeak;
                end
                for r = 1:size(freqRanges, 1)
                    overlap = max(0, min(candidateFreq(2), freqRanges(r, 2)) - max(candidateFreq(1), freqRanges(r, 1)));
                    scores(k) = scores(k) - 3 * overlap / max(diff(freqRanges(r, :)), eps);
                end
            end
        end

        function clearSpectrumInsetDisplay(app)
            app.clearSpectrumInsetGraphics();
            app.SpectrumInsetRanges = zeros(0, 2);
            app.SpectrumInsetYLimits = {};
        end

        function clearSpectrumInsetGraphics(app)
            if ~isempty(app.SpectrumInsetOverlays)
                validOverlays = isgraphics(app.SpectrumInsetOverlays);
                delete(app.SpectrumInsetOverlays(validOverlays));
                app.SpectrumInsetOverlays = [];
            end
        end

        function tf = hasSpectrumInsetDisplay(app)
            tf = ~isempty(app.SpectrumInsetRanges) && ...
                size(app.SpectrumInsetRanges, 2) == 2 && ...
                numel(app.SpectrumInsetYLimits) == size(app.SpectrumInsetRanges, 1);
        end

        function drawZoomBoundary(~, axesHandle, xValue)
            yLimits = ylim(axesHandle);
            line(axesHandle, [xValue xValue], yLimits, ...
                'Color', 'k', 'LineStyle', '--', 'LineWidth', 0.9);
        end

        function drawInsetConnectorLines(app, fig, mainAxes, insetAxes, freqRange, yLimit)
            mainPointLeft = app.dataToFigureNormalized(mainAxes, freqRange(1), yLimit(2));
            mainPointRight = app.dataToFigureNormalized(mainAxes, freqRange(2), yLimit(2));
            insetPosition = insetAxes.Position;
            insetTopLeft = [insetPosition(1), insetPosition(2) + insetPosition(4)];
            insetTopRight = [insetPosition(1) + insetPosition(3), insetPosition(2) + insetPosition(4)];

            annotation(fig, 'line', ...
                [mainPointLeft(1), insetTopLeft(1)], ...
                [mainPointLeft(2), insetTopLeft(2)], ...
                'Color', [0.9 0.35 0.25], 'LineStyle', ':', 'LineWidth', 0.85);
            annotation(fig, 'line', ...
                [mainPointRight(1), insetTopRight(1)], ...
                [mainPointRight(2), insetTopRight(2)], ...
                'Color', [0.9 0.35 0.25], 'LineStyle', ':', 'LineWidth', 0.85);
        end

        function point = dataToFigureNormalized(~, axesHandle, xValue, yValue)
            oldUnits = axesHandle.Units;
            axesHandle.Units = 'normalized';
            axesPosition = axesHandle.Position;
            axesHandle.Units = oldUnits;

            xLimits = xlim(axesHandle);
            yLimits = ylim(axesHandle);
            xRatio = (xValue - xLimits(1)) / diff(xLimits);
            yRatio = (yValue - yLimits(1)) / diff(yLimits);
            point = [
                axesPosition(1) + axesPosition(3) * xRatio
                axesPosition(2) + axesPosition(4) * yRatio
                ];
            point = min(max(point, 0), 1);
        end

        function setStandaloneTitle(app, axesHandle, textValue)
            [displayText, interpreter] = app.standaloneText(textValue);
            textObject = title(axesHandle, displayText, 'Interpreter', interpreter);
            textObject.FontName = app.standaloneFontName(textValue);
        end

        function setStandaloneXLabel(app, axesHandle, textValue)
            [displayText, interpreter] = app.standaloneText(textValue);
            textObject = xlabel(axesHandle, displayText, 'Interpreter', interpreter);
            textObject.FontName = app.standaloneFontName(textValue);
        end

        function setStandaloneYLabel(app, axesHandle, textValue)
            [displayText, interpreter] = app.standaloneText(textValue);
            textObject = ylabel(axesHandle, displayText, 'Interpreter', interpreter);
            textObject.FontName = app.standaloneFontName(textValue);
        end

        function setStandaloneLegend(app, axesHandle, textValues)
            [displayTexts, interpreter] = app.standaloneTextList(textValues);
            legendObject = legend(axesHandle, displayTexts, 'Location', 'best', 'Interpreter', interpreter);
            legendObject.FontName = app.standaloneFontName(strjoin(string(textValues), ' '));
        end

        function setStandaloneAxesFormat(app, axesHandle)
            app.applyAxesFormat(axesHandle);
            set(axesHandle, 'LineWidth', 0.75, ...
                'FontName', 'Times New Roman', ...
                'FontSize', 12.5, ...
                'GridAlpha', 0.4, ...
                'GridColor', [0.1, 0.1, 0.1]);
            set(ancestor(axesHandle, 'figure'), 'Color', 'white');
        end

        function applyAxesFormat(app, axesHandle)
            if app.GridEnabled
                grid(axesHandle, 'on');
                axesHandle.GridLineStyle = app.GridLineStyle;
                axesHandle.GridAlpha = 0.4;
                axesHandle.GridColor = [0.1, 0.1, 0.1];
            else
                grid(axesHandle, 'off');
            end

            if app.BoxEnabled
                box(axesHandle, 'on');
            else
                box(axesHandle, 'off');
            end
            axesHandle.LineWidth = 0.75;
        end

        function [displayText, interpreter] = standaloneText(~, textValue)
            textValue = char(textValue);
            displayText = textValue;
            interpreter = 'none';
        end

        function [displayTexts, interpreter] = standaloneTextList(~, textValues)
            displayTexts = cell(size(textValues));
            for k = 1:numel(textValues)
                displayTexts{k} = char(textValues{k});
            end
            interpreter = 'none';
        end

        function fontName = standaloneFontName(~, textValue)
            if FourierAnalysisApp.hasNonAsciiText(textValue)
                fontName = FourierAnalysisApp.preferredChineseFont();
            else
                fontName = 'Times New Roman';
            end
        end

        function positions = zoomAxesPositions(~, zoomCount)
            switch zoomCount
                case 1
                    positions = [0.09 0.12 0.86 0.32];
                case 2
                    positions = [
                        0.09 0.12 0.40 0.32
                        0.55 0.12 0.40 0.32
                        ];
                otherwise
                    positions = [
                        0.08 0.12 0.26 0.30
                        0.38 0.12 0.26 0.30
                        0.68 0.12 0.26 0.30
                        ];
            end
        end

        function values = zoomFieldValues(app)
            fields = {
                'Zoom1StartEdit'
                'Zoom1EndEdit'
                'Zoom1YMinEdit'
                'Zoom1YMaxEdit'
                'Zoom2StartEdit'
                'Zoom2EndEdit'
                'Zoom2YMinEdit'
                'Zoom2YMaxEdit'
                'Zoom3StartEdit'
                'Zoom3EndEdit'
                'Zoom3YMinEdit'
                'Zoom3YMaxEdit'
                };
            values = cell(size(fields));
            for k = 1:numel(fields)
                control = app.(fields{k});
                if isempty(control) || ~isvalid(control)
                    values{k} = '';
                else
                    values{k} = control.Value;
                end
            end
        end

        function values = spectrumInsetFieldValues(app)
            fields = {
                'SpectrumRangesEdit'
                'SpectrumYMinEdit'
                'SpectrumYMaxEdit'
                };
            values = cell(size(fields));
            for k = 1:numel(fields)
                control = app.(fields{k});
                if isempty(control) || ~isvalid(control)
                    values{k} = '';
                else
                    values{k} = control.Value;
                end
            end
        end

        function setZoomFieldValues(app, values)
            fields = {
                'Zoom1StartEdit'
                'Zoom1EndEdit'
                'Zoom1YMinEdit'
                'Zoom1YMaxEdit'
                'Zoom2StartEdit'
                'Zoom2EndEdit'
                'Zoom2YMinEdit'
                'Zoom2YMaxEdit'
                'Zoom3StartEdit'
                'Zoom3EndEdit'
                'Zoom3YMinEdit'
                'Zoom3YMaxEdit'
                };
            for k = 1:min(numel(fields), numel(values))
                app.(fields{k}).Value = values{k};
            end
        end

        function setSpectrumInsetFieldValues(app, values)
            fields = {
                'SpectrumRangesEdit'
                'SpectrumYMinEdit'
                'SpectrumYMaxEdit'
                };
            for k = 1:min(numel(fields), numel(values))
                app.(fields{k}).Value = values{k};
            end
        end

        function textValue = formatNumberForEdit(~, value)
            textValue = sprintf('%.9g', value);
        end

        function maxPoints = timePlotPointLimit(app)
            switch app.PlotDetailMode
                case 'fine'
                    maxPoints = app.FineTimePlotPoints;
                case 'full'
                    maxPoints = Inf;
                otherwise
                    maxPoints = app.MaxTimePlotPoints;
            end
        end

        function items = thdMethodItems(app)
            items = {
                app.text('thd_method_matlab')
                app.text('thd_method_spectrum')
                };
        end

        function value = thdMethodValue(app)
            items = app.thdMethodItems();
            if strcmp(app.ThdMethod, 'spectrum')
                value = items{2};
            else
                value = items{1};
            end
        end

        function value = thdMethodDisplayName(app, method)
            method = char(method);
            items = app.thdMethodItems();
            if strcmp(method, 'spectrum')
                value = items{2};
            else
                value = items{1};
            end
        end

        function items = thdMaxFrequencyItems(app)
            items = {
                app.text('thd_max_nyquist')
                app.text('thd_max_same_as_max')
                };
        end

        function value = thdMaxFrequencyValue(app)
            items = app.thdMaxFrequencyItems();
            if strcmp(app.ThdMaxFrequencyMode, 'max')
                value = items{2};
            else
                value = items{1};
            end
        end

        function value = thdMaxFrequencyLimit(app)
            if strcmp(app.ThdMaxFrequencyMode, 'max')
                value = app.MaxFreqEdit.Value;
            else
                value = Inf;
            end
        end

        function items = plotDetailItems(app)
            items = {
                app.text('plot_detail_fast')
                app.text('plot_detail_fine')
                app.text('plot_detail_full')
                };
        end

        function value = plotDetailValue(app)
            items = app.plotDetailItems();
            switch app.PlotDetailMode
                case 'fine'
                    value = items{2};
                case 'full'
                    value = items{3};
                otherwise
                    value = items{1};
            end
        end

        function items = gridStyleItems(app)
            items = {
                app.text('grid_style_solid')
                app.text('grid_style_dashed')
                };
        end

        function value = gridStyleValue(app)
            items = app.gridStyleItems();
            if strcmp(app.GridLineStyle, '--')
                value = items{2};
            else
                value = items{1};
            end
        end

        function setStatus(app, key, varargin)
            app.LastStatusKey = key;
            app.LastStatusArgs = varargin;
            app.StatusLabel.Text = app.text(key, varargin{:});
        end

        function restoreActionButtons(app)
            app.LoadButton.Enable = 'on';
            app.WorkspaceButton.Enable = 'on';
            if app.hasLoadedCsv()
                app.ExportMatButton.Enable = 'on';
            else
                app.ExportMatButton.Enable = 'off';
            end
            if isempty(app.CurrentTime) || isempty(app.CurrentWaveform)
                app.AnalyzeButton.Enable = 'off';
                app.DrawZoomButton.Enable = 'off';
                app.InsertSpectrumInsetButton.Enable = 'off';
                app.DeleteSpectrumInsetButton.Enable = 'off';
            else
                app.AnalyzeButton.Enable = 'on';
                if app.ZoomEnabled
                    app.DrawZoomButton.Enable = 'on';
                else
                    app.DrawZoomButton.Enable = 'off';
                end
            end

            if app.HasResult
                app.ExportButton.Enable = 'on';
                app.ExportFigureButton.Enable = 'on';
                if app.SpectrumInsetEnabled
                    app.InsertSpectrumInsetButton.Enable = 'on';
                else
                    app.InsertSpectrumInsetButton.Enable = 'off';
                end
                if app.SpectrumInsetEnabled && app.hasSpectrumInsetDisplay()
                    app.DeleteSpectrumInsetButton.Enable = 'on';
                else
                    app.DeleteSpectrumInsetButton.Enable = 'off';
                end
            else
                app.ExportButton.Enable = 'off';
                app.ExportFigureButton.Enable = 'off';
                app.InsertSpectrumInsetButton.Enable = 'off';
                app.DeleteSpectrumInsetButton.Enable = 'off';
            end
        end

        function showError(app, titleKey, messageText)
            app.StatusLabel.Text = messageText;
            uialert(app.Figure, messageText, app.text(titleKey));
        end

        function showAboutDialog(app)
            dialog = uifigure('Name', app.text('about_title'), ...
                'Position', [420 260 560 300], ...
                'WindowStyle', 'modal');
            html = uihtml(dialog, ...
                'Position', [0 0 560 300], ...
                'HTMLSource', app.resourceFile('aboutAuthor.html'), ...
                'HTMLEventReceivedFcn', @(~, event) app.onAuthorLinkEvent(event));
            html.Data = struct('unused', true);
        end

        function value = aboutText(~)
            value = sprintf(['FFT Analysis Tools\n\n' ...
                'Copyright (c) 2026 Zhenbin Huang\n\n' ...
                'Author: Zhenbin Huang\n' ...
                'ORCID: https://orcid.org/0000-0002-0628-0387\n' ...
                'LinkedIn: https://www.linkedin.com/in/zhenbin-huang/']);
        end

        function onAuthorLinkEvent(app, event)
            if ~strcmp(event.HTMLEventName, 'OpenLink')
                return;
            end

            url = char(event.HTMLEventData);
            allowedUrls = {
                'https://orcid.org/0000-0002-0628-0387'
                'https://www.linkedin.com/in/zhenbin-huang/'
                };
            if ~any(strcmp(url, allowedUrls))
                return;
            end

            try
                web(url, '-browser');
            catch ME
                app.showError('link_open_failed', ME.message);
            end
        end

        function filePath = resourceFile(~, fileName)
            appFolder = fileparts(mfilename('fullpath'));
            candidates = {
                fullfile(appFolder, 'resources', fileName)
                fullfile(appFolder, fileName)
                };
            if isdeployed
                candidates{end+1} = fullfile(ctfroot, 'resources', fileName);
                candidates{end+1} = fullfile(ctfroot, fileName);
            end

            for k = 1:numel(candidates)
                if isfile(candidates{k})
                    filePath = candidates{k};
                    return;
                end
            end
            error('Resource file not found: %s', fileName);
        end

        function value = text(app, key, varargin)
            if strcmp(app.Language, 'en')
                template = app.englishText(key);
            else
                template = app.chineseText(key);
            end

            if isempty(varargin)
                value = template;
            else
                value = sprintf(template, varargin{:});
            end
        end
    end

    methods (Static, Access = private)
        function template = chineseText(key)
            switch key
                case 'app_title'
                    template = '傅里叶分析';
                case 'fft_params'
                    template = 'FFT 参数';
                case 'analysis_results'
                    template = '分析结果';
                case 'load_button'
                    template = '加载文件';
                case 'load_workspace_button'
                    template = '识别工作区';
                case 'loaded_none'
                    template = '未加载文件';
                case 'workspace_source'
                    template = 'MATLAB 工作区';
                case 'language'
                    template = '语言';
                case 'plot_detail'
                    template = '显示精度';
                case 'about_button'
                    template = 'About';
                case 'about_title'
                    template = 'FFT Analysis Tools';
                case 'plot_detail_fast'
                    template = '快速 2万点';
                case 'plot_detail_fine'
                    template = '精细 20万点';
                case 'plot_detail_full'
                    template = '完整 全部点';
                case 'enable_grid_checkbox'
                    template = '显示网格';
                case 'grid_style'
                    template = '网格线';
                case 'grid_style_solid'
                    template = '实线';
                case 'grid_style_dashed'
                    template = '虚线';
                case 'enable_box_checkbox'
                    template = '显示图外框';
                case 'enable_spectrum_inset_checkbox'
                    template = '启用频谱局部放大';
                case 'spectrum_inset_panel_title'
                    template = '频谱局部放大';
                case 'spectrum_ranges'
                    template = '频段 Hz';
                case 'spectrum_freq_start'
                    template = 'F 起点';
                case 'spectrum_freq_end'
                    template = 'F 终点';
                case 'spectrum_inset_hint'
                    template = '最多两组，格式如 40-100, 2400-2800；Y 留空则每个放大图自动缩放。';
                case 'insert_spectrum_inset_button'
                    template = '插入';
                case 'delete_spectrum_inset_button'
                    template = '删除';
                case 'spectrum_inset_need_analysis'
                    template = '请先完成 FFT 分析。';
                case 'spectrum_inset_failed'
                    template = '频谱局部放大失败';
                case 'spectrum_inset_no_data'
                    template = '频率区间 %.6g - %.6g Hz 内没有频谱点。';
                case 'spectrum_inset_no_valid_ranges'
                    template = '输入的频段在当前频谱中没有可显示的频谱点。';
                case 'spectrum_inset_done'
                    template = '已在频谱图中显示 %d 个局部放大区域。';
                case 'spectrum_inset_deleted'
                    template = '已删除频谱局部放大区域。';
                case 'spectrum_ranges_name'
                    template = '频谱频段';
                case 'spectrum_range_format_error'
                    template = '频段格式应类似 40-100, 2400-2800。';
                case 'spectrum_range_count_error'
                    template = '一次最多显示 2 个频谱局部放大区域。';
                case 'spectrum_freq_start_name'
                    template = '频谱起始频率';
                case 'spectrum_freq_end_name'
                    template = '频谱结束频率';
                case 'spectrum_freq_order_error'
                    template = '频谱结束频率必须大于起始频率。';
                case 'spectrum_freq_outside_error'
                    template = '频率区间超出当前频谱范围 %.6g - %.6g Hz。';
                case 'spectrum_inset_label'
                    template = '频谱局部放大';
                case 'spectrum_inset_figure_title'
                    template = '频谱局部放大';
                case 'spectrum_inset_main_title'
                    template = 'FFT 频谱局部放大';
                case 'spectrum_inset_subplot_title'
                    template = '%.6g - %.6g Hz';
                case 'spectrum_datatip_series'
                    template = '频谱';
                case 'spectrum_inset_datatip_series'
                    template = '频谱局部放大';
                case 'datatip_frequency'
                    template = '频率 (Hz)';
                case 'datatip_percent'
                    template = '幅值 (%)';
                case 'enable_zoom_checkbox'
                    template = '启用波形局部放大';
                case 'zoom_panel_title'
                    template = '波形局部放大';
                case 'zoom1_label'
                    template = '放大区 1';
                case 'zoom2_label'
                    template = '放大区 2（可选）';
                case 'zoom3_label'
                    template = '放大区 3（可选）';
                case 'zoom_start'
                    template = '起点 s';
                case 'zoom_end'
                    template = '终点 s';
                case 'zoom_ymin'
                    template = 'Y 下限';
                case 'zoom_ymax'
                    template = 'Y 上限';
                case 'zoom_empty_hint'
                    template = 'Y 轴留空为自动；放大区 2/3 起止时间留空则跳过。';
                case 'draw_zoom_button'
                    template = '绘制放大图';
                case 'zoom_figure_title'
                    template = '波形局部放大';
                case 'zoom_overview_title'
                    template = '整体波形';
                case 'zoom_subplot_title'
                    template = '放大区 %d: %.6g - %.6g s';
                case 'zoom_failed'
                    template = '局部放大绘图失败';
                case 'zoom_no_data'
                    template = '区间 %.6g - %.6g s 内没有数据点。';
                case 'zoom1_start_name'
                    template = '放大区 1 起点';
                case 'zoom1_end_name'
                    template = '放大区 1 终点';
                case 'zoom2_start_name'
                    template = '放大区 2 起点';
                case 'zoom2_end_name'
                    template = '放大区 2 终点';
                case 'zoom3_start_name'
                    template = '放大区 3 起点';
                case 'zoom3_end_name'
                    template = '放大区 3 终点';
                case 'zoom_required_error'
                    template = '%s 不能为空。';
                case 'zoom_numeric_error'
                    template = '%s 必须是有效数字。';
                case 'zoom_time_order_error'
                    template = '%s 的终点时间必须大于起点时间。';
                case 'zoom_time_outside_error'
                    template = '%s 超出当前数据时间范围 %.6g - %.6g s。';
                case 'zoom_optional_pair_error'
                    template = '%s 的起点和终点必须同时填写，或同时留空。';
                case 'zoom_y_pair_error'
                    template = '%s 的 Y 下限和 Y 上限必须同时填写，或同时留空。';
                case 'zoom_y_order_error'
                    template = '%s 的 Y 上限必须大于 Y 下限。';
                case 'signal_var'
                    template = '信号变量';
                case 'load_file_first'
                    template = '请先加载文件';
                case 'no_supported_signal'
                    template = '未找到可分析信号';
                case 'channel'
                    template = '通道';
                case 'fundamental_hz'
                    template = '基频 Hz';
                case 'cycles'
                    template = '周期数';
                case 'start_time_s'
                    template = '起始时间 s';
                case 'max_freq_hz'
                    template = '最大频率 Hz';
                case 'thd_method'
                    template = 'THD 算法';
                case 'thd_method_matlab'
                    template = 'MATLAB 原版';
                case 'thd_method_spectrum'
                    template = '全频谱';
                case 'thd_max_frequency'
                    template = 'THD 最高频率';
                case 'thd_max_nyquist'
                    template = '奈奎斯特频率';
                case 'thd_max_same_as_max'
                    template = '同最大频率';
                case 'analyze_button'
                    template = '开始分析';
                case 'export_button'
                    template = '导出结果到工作区';
                case 'export_figure_button'
                    template = '导出 MATLAB Figure';
                case 'export_mat_button'
                    template = '导出 CSV 单路为 FFT MAT';
                case 'table_item'
                    template = '项目';
                case 'table_value'
                    template = '数值';
                case 'select_file'
                    template = '请选择 MAT/CSV 文件，或直接识别 MATLAB 工作区变量。';
                case 'loading_file'
                    template = '正在加载文件，请稍候...';
                case 'workspace_loading'
                    template = '正在扫描 MATLAB 工作区，请稍候...';
                case 'data_files_filter'
                    template = '数据文件 (*.mat, *.csv)';
                case 'mat_files_filter'
                    template = 'MAT 文件 (*.mat)';
                case 'csv_files_filter'
                    template = 'CSV 文件 (*.csv)';
                case 'select_data_file'
                    template = '选择 MAT 或 CSV 文件';
                case 'select_mat_file'
                    template = '选择 MAT 文件';
                case 'select_mat_export_file'
                    template = '保存 CSV 转换后的 MAT 文件';
                case 'select_csv_channel_title'
                    template = '选择 CSV 通道';
                case 'select_csv_channel_prompt'
                    template = '请选择要转换为 Simulink FFT Analyzer MAT 文件的一路信号：';
                case 'no_supported_format'
                    template = '未找到支持的数据格式。MAT 或工作区中的 struct/Simulink.SimulationOutput 需包含 time 和 signals.values；CSV 需包含 TIME 和至少一个波形列。';
                case 'signals_found'
                    template = '已找到 %d 个可分析信号。';
                case 'workspace_loaded'
                    template = '已从 MATLAB 工作区识别 %d 个可分析信号。';
                case 'workspace_no_supported_signal'
                    template = 'MATLAB 工作区中未找到可分析的带时间信号。';
                case 'csv_loaded'
                    template = '已识别 %d 个 CSV 波形；采样间隔 %.6g s；时间已平移 %.6g s 到从 0 开始。';
                case 'load_select_signal'
                    template = '请先加载并选择信号。';
                case 'analysis_running'
                    template = '正在分析，请稍候...';
                case 'analysis_done'
                    template = '分析完成。';
                case 'export_done'
                    template = '结果已导出到工作区变量 FFT_UI_Result。';
                case 'csv_export_mat_done'
                    template = 'CSV 已导出为 MAT 文件：%s';
                case 'csv_export_mat_no_data'
                    template = '当前没有已加载的 CSV 数据。';
                case 'csv_export_mat_failed'
                    template = 'CSV 导出 MAT 失败';
                case 'figure_export_done'
                    template = '图已导出到 MATLAB figure，并保存为工作区变量 FFT_UI_Figure。';
                case 'figure_export_done_deployed'
                    template = '图已导出为 MATLAB figure 窗口，可在该窗口中继续保存或编辑。';
                case 'export_figure_title'
                    template = 'FFT 分析结果';
                case 'file_load_failed'
                    template = '文件加载失败';
                case 'workspace_load_failed'
                    template = '工作区读取失败';
                case 'link_open_failed'
                    template = '打开链接失败';
                case 'signal_read_failed'
                    template = '信号读取失败';
                case 'fft_failed'
                    template = 'FFT 分析失败';
                case 'time_title'
                    template = '含 FFT 窗口的信号';
                case 'time_preview'
                    template = '信号预览';
                case 'time_xlabel'
                    template = '时间 (s)';
                case 'mag_ylabel'
                    template = '幅值';
                case 'spectrum_title'
                    template = 'FFT 频谱';
                case 'freq_xlabel'
                    template = '频率 (Hz)';
                case 'percent_ylabel'
                    template = '幅值（占基波百分比）';
                case 'legend_signal'
                    template = '信号';
                case 'legend_window'
                    template = 'FFT 窗口';
                case 'spectrum_result_title'
                    template = '基波 %.3g Hz = %.4g，THD = %.3f%%';
                case 'result_fs'
                    template = '采样频率 fs (Hz)';
                case 'result_dt'
                    template = '采样间隔 dt (s)';
                case 'result_df'
                    template = '频率分辨率 df (Hz)';
                case 'result_n'
                    template = 'FFT 点数 N';
                case 'result_fund_freq'
                    template = '基波频率 (Hz)';
                case 'result_fund_mag'
                    template = '基波幅值';
                case 'result_thd_method'
                    template = 'THD 算法';
                case 'result_thd_matlab'
                    template = 'THD MATLAB 原版 (%)';
                case 'result_thd_full_spectrum'
                    template = 'THD 全频谱 (%)';
                case 'result_thd'
                    template = 'THD (%)';
                otherwise
                    template = key;
            end
        end

        function template = englishText(key)
            switch key
                case 'app_title'
                    template = 'FFT Analysis Tools';
                case 'fft_params'
                    template = 'FFT Parameters';
                case 'analysis_results'
                    template = 'Analysis Results';
                case 'load_button'
                    template = 'Load File';
                case 'load_workspace_button'
                    template = 'Workspace';
                case 'loaded_none'
                    template = 'No file loaded';
                case 'workspace_source'
                    template = 'MATLAB Workspace';
                case 'language'
                    template = 'Language';
                case 'plot_detail'
                    template = 'Plot Detail';
                case 'about_button'
                    template = 'About';
                case 'about_title'
                    template = 'FFT Analysis Tools';
                case 'plot_detail_fast'
                    template = 'Fast 20k pts';
                case 'plot_detail_fine'
                    template = 'Fine 200k pts';
                case 'plot_detail_full'
                    template = 'Full all pts';
                case 'enable_grid_checkbox'
                    template = 'Show Grid';
                case 'grid_style'
                    template = 'Grid Line';
                case 'grid_style_solid'
                    template = 'Solid';
                case 'grid_style_dashed'
                    template = 'Dashed';
                case 'enable_box_checkbox'
                    template = 'Show Plot Box';
                case 'enable_spectrum_inset_checkbox'
                    template = 'Enable Spectrum Inset';
                case 'spectrum_inset_panel_title'
                    template = 'Spectrum Inset';
                case 'spectrum_ranges'
                    template = 'Bands Hz';
                case 'spectrum_freq_start'
                    template = 'F Start';
                case 'spectrum_freq_end'
                    template = 'F End';
                case 'spectrum_inset_hint'
                    template = 'Up to two bands, e.g. 40-100, 2400-2800. Leave Y empty for per-inset auto scale.';
                case 'insert_spectrum_inset_button'
                    template = 'Insert';
                case 'delete_spectrum_inset_button'
                    template = 'Delete';
                case 'spectrum_inset_need_analysis'
                    template = 'Run FFT analysis first.';
                case 'spectrum_inset_failed'
                    template = 'Spectrum Inset Failed';
                case 'spectrum_inset_no_data'
                    template = 'No spectrum points exist in %.6g - %.6g Hz.';
                case 'spectrum_inset_no_valid_ranges'
                    template = 'The input bands do not contain visible spectrum points.';
                case 'spectrum_inset_done'
                    template = 'Displayed %d spectrum inset region(s) in the spectrum plot.';
                case 'spectrum_inset_deleted'
                    template = 'Deleted spectrum inset region(s).';
                case 'spectrum_ranges_name'
                    template = 'Spectrum bands';
                case 'spectrum_range_format_error'
                    template = 'Band format should look like 40-100, 2400-2800.';
                case 'spectrum_range_count_error'
                    template = 'Show at most 2 spectrum inset regions at once.';
                case 'spectrum_freq_start_name'
                    template = 'Spectrum start frequency';
                case 'spectrum_freq_end_name'
                    template = 'Spectrum end frequency';
                case 'spectrum_freq_order_error'
                    template = 'Spectrum end frequency must be greater than start frequency.';
                case 'spectrum_freq_outside_error'
                    template = 'Frequency range is outside the current spectrum range %.6g - %.6g Hz.';
                case 'spectrum_inset_label'
                    template = 'Spectrum inset';
                case 'spectrum_inset_figure_title'
                    template = 'Spectrum Inset';
                case 'spectrum_inset_main_title'
                    template = 'FFT Spectrum Inset';
                case 'spectrum_inset_subplot_title'
                    template = '%.6g - %.6g Hz';
                case 'spectrum_datatip_series'
                    template = 'Spectrum';
                case 'spectrum_inset_datatip_series'
                    template = 'Spectrum inset';
                case 'datatip_frequency'
                    template = 'Frequency (Hz)';
                case 'datatip_percent'
                    template = 'Magnitude (%)';
                case 'enable_zoom_checkbox'
                    template = 'Enable Waveform Zoom';
                case 'zoom_panel_title'
                    template = 'Waveform Zoom';
                case 'zoom1_label'
                    template = 'Zoom Region 1';
                case 'zoom2_label'
                    template = 'Zoom Region 2 (Optional)';
                case 'zoom3_label'
                    template = 'Zoom Region 3 (Optional)';
                case 'zoom_start'
                    template = 'Start s';
                case 'zoom_end'
                    template = 'End s';
                case 'zoom_ymin'
                    template = 'Y Min';
                case 'zoom_ymax'
                    template = 'Y Max';
                case 'zoom_empty_hint'
                    template = 'Leave Y limits empty for auto scale. Leave region 2/3 start/end empty to skip them.';
                case 'draw_zoom_button'
                    template = 'Draw Zoom Figure';
                case 'zoom_figure_title'
                    template = 'Waveform Zoom';
                case 'zoom_overview_title'
                    template = 'Overview';
                case 'zoom_subplot_title'
                    template = 'Zoom %d: %.6g - %.6g s';
                case 'zoom_failed'
                    template = 'Zoom Plot Failed';
                case 'zoom_no_data'
                    template = 'No data points exist in %.6g - %.6g s.';
                case 'zoom1_start_name'
                    template = 'Zoom region 1 start';
                case 'zoom1_end_name'
                    template = 'Zoom region 1 end';
                case 'zoom2_start_name'
                    template = 'Zoom region 2 start';
                case 'zoom2_end_name'
                    template = 'Zoom region 2 end';
                case 'zoom3_start_name'
                    template = 'Zoom region 3 start';
                case 'zoom3_end_name'
                    template = 'Zoom region 3 end';
                case 'zoom_required_error'
                    template = '%s cannot be empty.';
                case 'zoom_numeric_error'
                    template = '%s must be a valid number.';
                case 'zoom_time_order_error'
                    template = '%s end time must be greater than start time.';
                case 'zoom_time_outside_error'
                    template = '%s is outside the current data time range %.6g - %.6g s.';
                case 'zoom_optional_pair_error'
                    template = '%s start and end must both be filled, or both be empty.';
                case 'zoom_y_pair_error'
                    template = '%s Y min and Y max must both be filled, or both be empty.';
                case 'zoom_y_order_error'
                    template = '%s Y max must be greater than Y min.';
                case 'signal_var'
                    template = 'Signal';
                case 'load_file_first'
                    template = 'Load a file first';
                case 'no_supported_signal'
                    template = 'No analyzable signal found';
                case 'channel'
                    template = 'Channel';
                case 'fundamental_hz'
                    template = 'Fundamental Hz';
                case 'cycles'
                    template = 'Cycles';
                case 'start_time_s'
                    template = 'Start Time s';
                case 'max_freq_hz'
                    template = 'Max Freq Hz';
                case 'thd_method'
                    template = 'THD Method';
                case 'thd_method_matlab'
                    template = 'MATLAB original';
                case 'thd_method_spectrum'
                    template = 'Full spectrum';
                case 'thd_max_frequency'
                    template = 'Max THD Freq';
                case 'thd_max_nyquist'
                    template = 'Nyquist frequency';
                case 'thd_max_same_as_max'
                    template = 'Same as Max frequency';
                case 'analyze_button'
                    template = 'Analyze';
                case 'export_button'
                    template = 'Export Result to Workspace';
                case 'export_figure_button'
                    template = 'Export MATLAB Figure';
                case 'export_mat_button'
                    template = 'Export One CSV Channel to FFT MAT';
                case 'table_item'
                    template = 'Item';
                case 'table_value'
                    template = 'Value';
                case 'select_file'
                    template = 'Select a MAT/CSV file or scan MATLAB workspace variables.';
                case 'loading_file'
                    template = 'Loading file, please wait...';
                case 'workspace_loading'
                    template = 'Scanning MATLAB workspace, please wait...';
                case 'data_files_filter'
                    template = 'Data Files (*.mat, *.csv)';
                case 'mat_files_filter'
                    template = 'MAT Files (*.mat)';
                case 'csv_files_filter'
                    template = 'CSV Files (*.csv)';
                case 'select_data_file'
                    template = 'Select MAT or CSV File';
                case 'select_mat_file'
                    template = 'Select MAT File';
                case 'select_mat_export_file'
                    template = 'Save Converted MAT File';
                case 'select_csv_channel_title'
                    template = 'Select CSV Channel';
                case 'select_csv_channel_prompt'
                    template = 'Select one signal channel to convert to a Simulink FFT Analyzer MAT file:';
                case 'no_supported_format'
                    template = 'No supported data format was found. MAT/workspace structs or Simulink.SimulationOutput entries must contain time and signals.values; CSV files must contain TIME and at least one waveform column.';
                case 'signals_found'
                    template = 'Found %d analyzable signal(s).';
                case 'workspace_loaded'
                    template = 'Recognized %d analyzable signal(s) from MATLAB workspace.';
                case 'workspace_no_supported_signal'
                    template = 'No analyzable time-based signal was found in MATLAB workspace.';
                case 'csv_loaded'
                    template = 'Recognized %d CSV waveform(s); sample interval %.6g s; shifted time by %.6g s so it starts at 0.';
                case 'load_select_signal'
                    template = 'Load and select a signal first.';
                case 'analysis_running'
                    template = 'Analyzing, please wait...';
                case 'analysis_done'
                    template = 'Analysis complete.';
                case 'export_done'
                    template = 'Result exported to workspace variable FFT_UI_Result.';
                case 'csv_export_mat_done'
                    template = 'CSV exported to MAT file: %s';
                case 'csv_export_mat_no_data'
                    template = 'No loaded CSV data is available.';
                case 'csv_export_mat_failed'
                    template = 'CSV MAT Export Failed';
                case 'figure_export_done'
                    template = 'Figure exported to MATLAB figure and workspace variable FFT_UI_Figure.';
                case 'figure_export_done_deployed'
                    template = 'Figure exported to a MATLAB figure window for saving or further editing.';
                case 'export_figure_title'
                    template = 'FFT Analysis Result';
                case 'file_load_failed'
                    template = 'File Load Failed';
                case 'workspace_load_failed'
                    template = 'Workspace Load Failed';
                case 'link_open_failed'
                    template = 'Open Link Failed';
                case 'signal_read_failed'
                    template = 'Signal Read Failed';
                case 'fft_failed'
                    template = 'FFT Analysis Failed';
                case 'time_title'
                    template = 'Signal with FFT Window';
                case 'time_preview'
                    template = 'Signal Preview';
                case 'time_xlabel'
                    template = 'Time (s)';
                case 'mag_ylabel'
                    template = 'Magnitude';
                case 'spectrum_title'
                    template = 'FFT Spectrum';
                case 'freq_xlabel'
                    template = 'Frequency (Hz)';
                case 'percent_ylabel'
                    template = 'Mag (% of Fundamental)';
                case 'legend_signal'
                    template = 'Signal';
                case 'legend_window'
                    template = 'FFT Window';
                case 'spectrum_result_title'
                    template = 'Fundamental %.3g Hz = %.4g, THD = %.3f%%';
                case 'result_fs'
                    template = 'Sampling frequency fs (Hz)';
                case 'result_dt'
                    template = 'Sampling interval dt (s)';
                case 'result_df'
                    template = 'Frequency resolution df (Hz)';
                case 'result_n'
                    template = 'FFT points N';
                case 'result_fund_freq'
                    template = 'Fundamental frequency (Hz)';
                case 'result_fund_mag'
                    template = 'Fundamental magnitude';
                case 'result_thd_method'
                    template = 'THD method';
                case 'result_thd_matlab'
                    template = 'THD MATLAB original (%)';
                case 'result_thd_full_spectrum'
                    template = 'THD full spectrum (%)';
                case 'result_thd'
                    template = 'THD (%)';
                otherwise
                    template = key;
            end
        end

        function [data, candidates] = workspaceSignalCandidates()
            data = struct();
            candidates = struct('label', {}, 'path', {}, 'source', {}, 'column', {});
            names = evalin('base', 'who');

            for k = 1:numel(names)
                name = names{k};
                try
                    value = evalin('base', name);
                catch
                    continue;
                end

                if FourierAnalysisApp.isSupportedSignal(value)
                    newCandidates = struct('label', name, 'path', name, ...
                        'source', 'workspace', 'column', NaN);
                elseif isscalar(value) && (isstruct(value) || FourierAnalysisApp.isSimulationOutputLike(value))
                    newCandidates = FourierAnalysisApp.findSignalCandidates(value, string(name), "workspace");
                else
                    newCandidates = struct('label', {}, 'path', {}, 'source', {}, 'column', {});
                end

                if ~isempty(newCandidates)
                    data.(name) = value;
                    candidates = [candidates, newCandidates]; %#ok<AGROW>
                end
            end
        end

        function candidates = findSignalCandidates(data, prefix, source)
            if nargin < 3
                source = "mat";
            end

            candidates = struct('label', {}, 'path', {}, 'source', {}, 'column', {});
            if ~(isstruct(data) || FourierAnalysisApp.isSimulationOutputLike(data)) || ~isscalar(data)
                return;
            end

            if FourierAnalysisApp.isSimulationOutputLike(data)
                names = who(data);
            else
                names = fieldnames(data);
            end

            for k = 1:numel(names)
                name = names{k};
                try
                    value = FourierAnalysisApp.getMember(data, name);
                catch
                    continue;
                end
                if prefix == ""
                    path = string(name);
                else
                    path = prefix + "." + name;
                end

                if FourierAnalysisApp.isSupportedSignal(value)
                    candidates(end+1).label = char(path); %#ok<AGROW>
                    candidates(end).path = char(path);
                    candidates(end).source = char(source);
                    candidates(end).column = NaN;
                elseif isscalar(value) && (isstruct(value) || FourierAnalysisApp.isSimulationOutputLike(value))
                    nested = FourierAnalysisApp.findSignalCandidates(value, path, source);
                    candidates = [candidates, nested]; %#ok<AGROW>
                end
            end
        end

        function candidates = csvSignalCandidates(csvData)
            candidates = struct('label', {}, 'path', {}, 'source', {}, 'column', {});
            for k = 1:numel(csvData.signalLabels)
                candidates(end+1).label = csvData.signalLabels{k}; %#ok<AGROW>
                candidates(end).path = csvData.signalLabels{k};
                candidates(end).source = 'csv';
                candidates(end).column = k;
            end
        end

        function tf = isSupportedSignal(value)
            try
                [time, waveform] = FourierAnalysisApp.signalValueToTimeWaveform(value);
                tf = ~isempty(time) && ~isempty(waveform);
            catch
                tf = false;
            end
        end

        function [time, waveform] = readSignal(data, path)
            value = FourierAnalysisApp.getByPath(data, path);
            [time, waveform] = FourierAnalysisApp.signalValueToTimeWaveform(value);
        end

        function [time, waveform] = signalValueToTimeWaveform(value)
            if isa(value, 'timeseries')
                time = value.Time;
                waveform = value.Data;
            elseif isstruct(value) && isscalar(value) && isfield(value, 'time') && isfield(value, 'signals')
                signals = value.signals;
                if ~isstruct(signals) || ~isfield(signals, 'values')
                    error('Unsupported signal structure. Expected signals.values.');
                end

                if isscalar(signals)
                    waveform = signals.values;
                else
                    values = arrayfun(@(s) s.values, signals, 'UniformOutput', false);
                    waveform = cat(2, values{:});
                end
                time = value.time;
            else
                error('Unsupported signal type: %s.', class(value));
            end

            time = double(time(:));
            waveform = squeeze(double(waveform));
            if isrow(waveform)
                waveform = waveform(:);
            end
            if size(waveform, 1) ~= numel(time) && size(waveform, 2) == numel(time)
                waveform = waveform.';
            end
            if size(waveform, 1) ~= numel(time)
                error('Selected signal has %d time samples but waveform size is %s.', ...
                    numel(time), mat2str(size(waveform)));
            end
        end

        function [time, waveform] = readCsvSignal(csvData, column)
            time = csvData.time;
            waveform = csvData.waveforms(:, column);
        end

        function matVariables = csvDataToFftAnalyzerMatVariable(csvData, sourceFile, channelIndex, variableName)
            channelCount = size(csvData.waveforms, 2);
            if channelIndex < 1 || channelIndex > channelCount
                error('FourierAnalysisApp:InvalidCsvChannel', ...
                    'Selected CSV channel index must be between 1 and %d.', channelCount);
            end

            signalData = struct();
            signalData.time = csvData.time(:);
            signalData.signals = struct();
            signalData.signals.values = csvData.waveforms(:, channelIndex);
            signalData.signals.dimensions = 1;
            signalData.signals.label = csvData.signalLabels{channelIndex};
            signalData.blockName = sprintf('%s/%s', char(sourceFile), csvData.channelNames{channelIndex});

            variableName = matlab.lang.makeValidName(variableName);
            matVariables = struct();
            matVariables.(variableName) = signalData;
        end

        function channelName = csvChannelExportName(csvData, channelIndex)
            if isfield(csvData, 'channelNames') && numel(csvData.channelNames) >= channelIndex
                channelName = csvData.channelNames{channelIndex};
            else
                channelName = sprintf('CH%d', channelIndex);
            end
            channelName = matlab.lang.makeValidName(channelName);
            if strlength(string(channelName)) == 0
                channelName = sprintf('CH%d', channelIndex);
            end
        end

        function [xOut, yOut] = downsampleForPlot(x, y, maxPoints)
            x = x(:);
            y = y(:);
            if isinf(maxPoints) || numel(x) <= maxPoints
                xOut = x;
                yOut = y;
                return;
            end

            step = ceil(numel(x) / maxPoints);
            indexes = 1:step:numel(x);
            if indexes(end) ~= numel(x)
                indexes = [indexes, numel(x)];
            end
            xOut = x(indexes);
            yOut = y(indexes);
        end

        function [xOut, yOut] = compressSpectrumForPlot(x, y, maxPoints)
            x = x(:);
            y = y(:);
            if numel(x) <= maxPoints
                xOut = x;
                yOut = y;
                return;
            end

            edges = unique(round(linspace(1, numel(x) + 1, maxPoints + 1)));
            indexes = zeros(numel(edges) - 1, 1);
            for k = 1:numel(edges) - 1
                firstIndex = edges(k);
                lastIndex = edges(k + 1) - 1;
                if lastIndex < firstIndex
                    lastIndex = firstIndex;
                end
                [~, localIndex] = max(y(firstIndex:lastIndex));
                indexes(k) = firstIndex + localIndex - 1;
            end
            indexes = unique(indexes);
            xOut = x(indexes);
            yOut = y(indexes);
        end

        function hasText = hasNonAsciiText(textValue)
            hasText = any(double(char(textValue)) > 127);
        end

        function fontName = preferredChineseFont()
            persistent cachedFontName
            if ~isempty(cachedFontName)
                fontName = cachedFontName;
                return;
            end

            preferredFonts = {
                'Microsoft YaHei UI'
                'Microsoft YaHei'
                'SimSun'
                'SimHei'
                'NSimSun'
                'Arial Unicode MS'
                };
            try
                availableFonts = listfonts;
                match = find(ismember(preferredFonts, availableFonts), 1);
            catch
                match = [];
            end

            if isempty(match)
                cachedFontName = 'Helvetica';
            else
                cachedFontName = preferredFonts{match};
            end
            fontName = cachedFontName;
        end

        function value = getByPath(data, path)
            parts = split(string(path), ".");
            value = data;
            for k = 1:numel(parts)
                value = FourierAnalysisApp.getMember(value, char(parts(k)));
            end
        end

        function value = getMember(data, name)
            if isstruct(data)
                value = data.(name);
            elseif FourierAnalysisApp.isSimulationOutputLike(data)
                value = data.get(name);
            elseif isobject(data) && isprop(data, name)
                value = data.(name);
            else
                error('Unsupported container type: %s.', class(data));
            end
        end

        function tf = isSimulationOutputLike(value)
            tf = isa(value, 'Simulink.SimulationOutput') || ...
                (isobject(value) && ismethod(value, 'who') && ismethod(value, 'get'));
        end
    end
end
