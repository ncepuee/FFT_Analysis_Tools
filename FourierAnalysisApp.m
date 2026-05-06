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
        LanguageLabel
        LanguageDropDown
        PlotDetailLabel
        PlotDetailDropDown
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
        AnalyzeButton
        ExportButton
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
        StatusLabel
        FooterHtml
        AboutButton
        TimeAxes
        SpectrumAxes
        ResultTable

        Language char = 'zh'
        CurrentFileName char = ''
        MatData struct = struct()
        CsvData struct = struct()
        SignalCandidates struct = struct('label', {}, 'path', {}, 'source', {}, 'column', {})
        CurrentTime double = []
        CurrentWaveform double = []
        Result struct = struct()
        HasResult logical = false
        LastStatusKey char = 'select_file'
        LastStatusArgs cell = {}
        PlotDetailMode char = 'fast'
        ZoomEnabled logical = false
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

            app.ControlGrid = uigridlayout(app.ControlPanel, [17 2]);
            app.ControlGrid.ColumnWidth = {95, '1x'};
            app.ControlGrid.RowHeight = {34, 28, 34, 34, 34, 34, 34, 34, 34, 34, 34, 34, 120, 34, 0, 0, 52};
            app.ControlGrid.Padding = [12 12 12 12];
            app.ControlGrid.RowSpacing = 8;

            app.LoadButton = uibutton(app.ControlGrid, 'Text', app.text('load_button'), ...
                'ButtonPushedFcn', @(~, ~) app.loadDataFile());
            app.LoadButton.Layout.Row = 1;
            app.LoadButton.Layout.Column = [1 2];

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
                'Value', 2000, 'Limits', [eps Inf]);
            app.MaxFreqEdit.Layout.Row = 9;
            app.MaxFreqEdit.Layout.Column = 2;

            app.PlotDetailLabel = uilabel(app.ControlGrid, 'Text', app.text('plot_detail'));
            app.PlotDetailLabel.Layout.Row = 10;
            app.PlotDetailLabel.Layout.Column = 1;

            app.PlotDetailDropDown = uidropdown(app.ControlGrid, ...
                'Items', app.plotDetailItems(), ...
                'ValueChangedFcn', @(~, ~) app.onPlotDetailChanged());
            app.PlotDetailDropDown.Layout.Row = 10;
            app.PlotDetailDropDown.Layout.Column = 2;

            app.AnalyzeButton = uibutton(app.ControlGrid, 'Text', app.text('analyze_button'), ...
                'Enable', 'off', ...
                'ButtonPushedFcn', @(~, ~) app.analyzeSignal());
            app.AnalyzeButton.Layout.Row = 11;
            app.AnalyzeButton.Layout.Column = [1 2];

            app.ExportButton = uibutton(app.ControlGrid, 'Text', app.text('export_button'), ...
                'Enable', 'off', ...
                'ButtonPushedFcn', @(~, ~) app.exportResult());
            app.ExportButton.Layout.Row = 12;
            app.ExportButton.Layout.Column = [1 2];

            app.ResultTable = uitable(app.ControlGrid, ...
                'ColumnName', {app.text('table_item'), app.text('table_value')}, ...
                'Data', cell(0, 2));
            app.ResultTable.Layout.Row = 13;
            app.ResultTable.Layout.Column = [1 2];

            app.ZoomEnableCheckBox = uicheckbox(app.ControlGrid, ...
                'Text', app.text('enable_zoom_checkbox'), ...
                'Value', false, ...
                'ValueChangedFcn', @(~, ~) app.onZoomEnableChanged());
            app.ZoomEnableCheckBox.Layout.Row = 14;
            app.ZoomEnableCheckBox.Layout.Column = [1 2];

            app.ZoomPanel = uipanel(app.ControlGrid, 'Title', app.text('zoom_panel_title'));
            app.ZoomPanel.Layout.Row = 15;
            app.ZoomPanel.Layout.Column = [1 2];
            app.createZoomControls(app.ZoomPanel);

            app.DrawZoomButton = uibutton(app.ControlGrid, 'Text', app.text('draw_zoom_button'), ...
                'Enable', 'off', ...
                'ButtonPushedFcn', @(~, ~) app.plotZoomView());
            app.DrawZoomButton.Layout.Row = 16;
            app.DrawZoomButton.Layout.Column = [1 2];

            app.StatusLabel = uilabel(app.ControlGrid, 'Text', app.text('select_file'), ...
                'WordWrap', 'on');
            app.StatusLabel.Layout.Row = 17;
            app.StatusLabel.Layout.Column = [1 2];
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
            grid(app.TimeAxes, 'on');

            app.SpectrumAxes = uiaxes(plotGrid);
            app.SpectrumAxes.Layout.Row = 2;
            grid(app.SpectrumAxes, 'on');
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

        function updateZoomVisibility(app)
            if isempty(app.ControlGrid) || ~isvalid(app.ControlGrid)
                return;
            end

            rowHeights = app.ControlGrid.RowHeight;
            if app.ZoomEnabled
                rowHeights{15} = 380;
                rowHeights{16} = 34;
                app.ZoomPanel.Visible = 'on';
                app.DrawZoomButton.Visible = 'on';
            else
                rowHeights{15} = 0;
                rowHeights{16} = 0;
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
            [~, ~, extension] = fileparts(file);
            app.LoadButton.Enable = 'off';
            app.AnalyzeButton.Enable = 'off';
            app.ExportButton.Enable = 'off';
            app.setStatus('loading_file');
            drawnow('limitrate');
            cleanup = onCleanup(@() app.restoreActionButtons());
            try
                app.MatData = struct();
                app.CsvData = struct();
                if strcmpi(extension, '.csv')
                    app.CsvData = readScopeCsv(fullPath);
                    app.SignalCandidates = FourierAnalysisApp.csvSignalCandidates(app.CsvData);
                else
                    app.MatData = load(fullPath);
                    app.SignalCandidates = app.findSignalCandidates(app.MatData, "");
                end
            catch ME
                app.showError('file_load_failed', ME.message);
                return;
            end

            app.CurrentFileName = file;
            app.FileLabel.Text = file;
            app.HasResult = false;
            app.Result = struct();
            app.ResultTable.Data = cell(0, 2);
            app.ExportButton.Enable = 'off';

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
                app.setStatus('csv_loaded', numel(labels), app.CsvData.sampleInterval, app.CsvData.timeOffset);
            else
                app.setStatus('signals_found', numel(labels));
            end
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
            app.setStatus('analysis_running');
            drawnow('limitrate');
            cleanup = onCleanup(@() app.restoreActionButtons());

            channelIndex = str2double(app.ChannelDropDown.Value);
            waveform = app.CurrentWaveform(:, channelIndex);

            try
                app.Result = fftAnalyzeSignal(app.CurrentTime, waveform, ...
                    app.FundamentalEdit.Value, app.CyclesEdit.Value, ...
                    app.StartTimeEdit.Value, app.MaxFreqEdit.Value);
            catch ME
                app.showError('fft_failed', ME.message);
                return;
            end

            app.HasResult = true;
            app.plotResult(waveform);
            app.updateResultTable();
            app.ExportButton.Enable = 'on';
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

        function onZoomEnableChanged(app)
            app.ZoomEnabled = logical(app.ZoomEnableCheckBox.Value);
            app.updateZoomVisibility();
        end

        function updateLanguageTexts(app)
            app.Figure.Name = app.text('app_title');
            app.ControlPanel.Title = app.text('fft_params');
            app.PlotPanel.Title = app.text('analysis_results');
            app.ZoomPanel.Title = app.text('zoom_panel_title');
            app.ZoomEnableCheckBox.Text = app.text('enable_zoom_checkbox');
            app.LoadButton.Text = app.text('load_button');
            app.LanguageLabel.Text = app.text('language');
            app.PlotDetailLabel.Text = app.text('plot_detail');
            app.PlotDetailDropDown.Items = app.plotDetailItems();
            app.PlotDetailDropDown.Value = app.plotDetailValue();
            app.SignalLabel.Text = app.text('signal_var');
            app.ChannelLabel.Text = app.text('channel');
            app.FundamentalLabel.Text = app.text('fundamental_hz');
            app.CyclesLabel.Text = app.text('cycles');
            app.StartTimeLabel.Text = app.text('start_time_s');
            app.MaxFreqLabel.Text = app.text('max_freq_hz');
            app.AnalyzeButton.Text = app.text('analyze_button');
            app.ExportButton.Text = app.text('export_button');
            app.DrawZoomButton.Text = app.text('draw_zoom_button');
            app.AboutButton.Text = app.text('about_button');
            app.ResultTable.ColumnName = {app.text('table_item'), app.text('table_value')};
            app.refreshZoomControls();
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
            grid(app.TimeAxes, 'on');
        end

        function plotResult(app, waveform)
            result = app.Result;

            cla(app.TimeAxes);
            [plotTime, plotWaveform] = FourierAnalysisApp.downsampleForPlot( ...
                app.CurrentTime, waveform, app.timePlotPointLimit());
            [windowTime, windowWaveform] = FourierAnalysisApp.downsampleForPlot( ...
                result.windowTime, result.windowWaveform, app.timePlotPointLimit());
            plot(app.TimeAxes, plotTime, plotWaveform, 'Color', [0.1 0.35 0.8]);
            hold(app.TimeAxes, 'on');
            plot(app.TimeAxes, windowTime, windowWaveform, ...
                'Color', [0.85 0.15 0.1], 'LineWidth', 1.2);
            hold(app.TimeAxes, 'off');
            title(app.TimeAxes, app.text('time_title'));
            xlabel(app.TimeAxes, app.text('time_xlabel'));
            ylabel(app.TimeAxes, app.text('mag_ylabel'));
            legend(app.TimeAxes, {app.text('legend_signal'), app.text('legend_window')}, ...
                'Location', 'best');
            grid(app.TimeAxes, 'on');

            cla(app.SpectrumAxes);
            if numel(result.displayFreqs) <= app.MaxSpectrumBarCount
                bar(app.SpectrumAxes, result.displayFreqs, result.displayPercent, ...
                    'FaceColor', [0.2 0.45 0.75], 'EdgeColor', 'none');
            else
                [plotFreqs, plotPercent] = FourierAnalysisApp.compressSpectrumForPlot( ...
                    result.displayFreqs, result.displayPercent, app.MaxSpectrumLinePoints);
                plot(app.SpectrumAxes, plotFreqs, plotPercent, ...
                    'Color', [0.2 0.45 0.75], 'LineWidth', 1);
            end
            title(app.SpectrumAxes, app.text('spectrum_result_title', ...
                result.fundamentalFrequency, result.fundamentalMagnitude, result.thd * 100));
            xlabel(app.SpectrumAxes, app.text('freq_xlabel'));
            ylabel(app.SpectrumAxes, app.text('percent_ylabel'));
            xlim(app.SpectrumAxes, [0 max(result.displayFreqs)]);
            grid(app.SpectrumAxes, 'on');
        end

        function formatSpectrumAxes(app, mode)
            if strcmp(mode, 'empty')
                title(app.SpectrumAxes, app.text('spectrum_title'));
            end
            xlabel(app.SpectrumAxes, app.text('freq_xlabel'));
            ylabel(app.SpectrumAxes, app.text('percent_ylabel'));
            grid(app.SpectrumAxes, 'on');
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
                'Position', [560 180 820 600]);

            overviewPos = [0.08 0.56 0.86 0.36];
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
            title(overviewAxes, app.mixedFontText(sprintf('%s - %s', app.text('zoom_overview_title'), signalName)), ...
                'Interpreter', 'tex');
            xlabel(overviewAxes, app.mixedFontText(app.text('time_xlabel')), 'Interpreter', 'tex');
            ylabel(overviewAxes, app.mixedFontText(app.text('mag_ylabel')), 'Interpreter', 'tex');
            xlim(overviewAxes, [time(1), time(end)]);
            app.setStandaloneAxesFormat(overviewAxes);

            for k = 1:zoomCount
                zoomAxes = subplot('Position', zoomPositions(k, :));
                idx = time >= zoomRanges(k, 1) & time <= zoomRanges(k, 2);
                [zoomTime, zoomWaveform] = FourierAnalysisApp.downsampleForPlot( ...
                    time(idx), waveform(idx), app.timePlotPointLimit());
                plot(zoomAxes, zoomTime, zoomWaveform, 'Color', [0.1 0.35 0.8]);
                title(zoomAxes, app.mixedFontText(app.text('zoom_subplot_title', k, zoomRanges(k, 1), zoomRanges(k, 2))), ...
                    'Interpreter', 'tex');
                xlabel(zoomAxes, app.mixedFontText(app.text('time_xlabel')), 'Interpreter', 'tex');
                ylabel(zoomAxes, app.mixedFontText(app.text('mag_ylabel')), 'Interpreter', 'tex');
                xlim(zoomAxes, zoomRanges(k, :));
                if ~isempty(yLimits{k})
                    ylim(zoomAxes, yLimits{k});
                end
                app.setStandaloneAxesFormat(zoomAxes);
            end
        end

        function resetPlots(app)
            cla(app.TimeAxes);
            title(app.TimeAxes, app.text('time_title'));
            xlabel(app.TimeAxes, app.text('time_xlabel'));
            ylabel(app.TimeAxes, app.text('mag_ylabel'));
            grid(app.TimeAxes, 'on');

            cla(app.SpectrumAxes);
            app.formatSpectrumAxes('empty');
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
                app.text('result_thd'), result.thd * 100
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

        function drawZoomBoundary(~, axesHandle, xValue)
            yLimits = ylim(axesHandle);
            line(axesHandle, [xValue xValue], yLimits, ...
                'Color', 'k', 'LineStyle', '--', 'LineWidth', 0.9);
        end

        function setStandaloneAxesFormat(~, axesHandle)
            grid(axesHandle, 'on');
            box(axesHandle, 'on');
            set(axesHandle, 'LineWidth', 0.75, ...
                'FontName', 'Times New Roman', ...
                'FontSize', 12.5, ...
                'GridLineStyle', ':', ...
                'GridAlpha', 0.4, ...
                'GridColor', [0.1, 0.1, 0.1]);
            set(ancestor(axesHandle, 'figure'), 'Color', 'white');
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

        function formatted = mixedFontText(~, textValue)
            textValue = char(textValue);
            if isempty(textValue)
                formatted = '';
                return;
            end

            formatted = '';
            currentIsChinese = [];
            segment = '';
            for k = 1:numel(textValue)
                ch = textValue(k);
                isChinese = double(ch) > 127;
                if isempty(currentIsChinese)
                    currentIsChinese = isChinese;
                    segment = ch;
                elseif isChinese == currentIsChinese
                    segment = [segment ch]; %#ok<AGROW>
                else
                    formatted = [formatted FourierAnalysisApp.fontSegment(segment, currentIsChinese)]; %#ok<AGROW>
                    currentIsChinese = isChinese;
                    segment = ch;
                end
            end
            formatted = [formatted FourierAnalysisApp.fontSegment(segment, currentIsChinese)];
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

        function setStatus(app, key, varargin)
            app.LastStatusKey = key;
            app.LastStatusArgs = varargin;
            app.StatusLabel.Text = app.text(key, varargin{:});
        end

        function restoreActionButtons(app)
            app.LoadButton.Enable = 'on';
            if isempty(app.CurrentTime) || isempty(app.CurrentWaveform)
                app.AnalyzeButton.Enable = 'off';
                app.DrawZoomButton.Enable = 'off';
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
            else
                app.ExportButton.Enable = 'off';
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
                    template = '加载 MAT/CSV 文件';
                case 'loaded_none'
                    template = '未加载文件';
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
                case 'analyze_button'
                    template = '开始分析';
                case 'export_button'
                    template = '导出结果到工作区';
                case 'table_item'
                    template = '项目';
                case 'table_value'
                    template = '数值';
                case 'select_file'
                    template = '请选择 MAT 文件，或示波器导出的 CSV 原始文件。';
                case 'loading_file'
                    template = '正在加载文件，请稍候...';
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
                case 'no_supported_format'
                    template = '未找到支持的数据格式。MAT 中的 struct 或 Simulink.SimulationOutput 内部变量需包含 time 和 signals.values；CSV 需包含 TIME 和至少一个波形列。';
                case 'signals_found'
                    template = '已找到 %d 个可分析信号。';
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
                case 'file_load_failed'
                    template = '文件加载失败';
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
                    template = 'Load MAT/CSV File';
                case 'loaded_none'
                    template = 'No file loaded';
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
                case 'analyze_button'
                    template = 'Analyze';
                case 'export_button'
                    template = 'Export Result to Workspace';
                case 'table_item'
                    template = 'Item';
                case 'table_value'
                    template = 'Value';
                case 'select_file'
                    template = 'Select a MAT file or an oscilloscope CSV source file.';
                case 'loading_file'
                    template = 'Loading file, please wait...';
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
                case 'no_supported_format'
                    template = 'No supported data format was found. MAT struct variables or Simulink.SimulationOutput entries must contain time and signals.values; CSV files must contain TIME and at least one waveform column.';
                case 'signals_found'
                    template = 'Found %d analyzable signal(s).';
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
                case 'file_load_failed'
                    template = 'File Load Failed';
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
                case 'result_thd'
                    template = 'THD (%)';
                otherwise
                    template = key;
            end
        end

        function candidates = findSignalCandidates(data, prefix)
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
                    candidates(end).source = 'mat';
                    candidates(end).column = NaN;
                elseif isscalar(value) && (isstruct(value) || FourierAnalysisApp.isSimulationOutputLike(value))
                    nested = FourierAnalysisApp.findSignalCandidates(value, path);
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

        function formatted = fontSegment(segment, isChinese)
            if isChinese
                fontName = '宋体';
            else
                fontName = 'Times New Roman';
            end
            escaped = FourierAnalysisApp.escapeTexLiteral(segment);
            formatted = sprintf('\\fontname{%s}%s', fontName, escaped);
        end

        function escaped = escapeTexLiteral(textValue)
            escaped = char(textValue);
            replacements = {
                '{', '\{'
                '}', '\}'
                '_', '\_'
                '^', '\^{}'
                '%', '\%'
                };
            for k = 1:size(replacements, 1)
                escaped = strrep(escaped, replacements{k, 1}, replacements{k, 2});
            end
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
