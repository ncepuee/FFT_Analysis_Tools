classdef FourierAnalysisApp < handle
%FOURIERANALYSISAPP MATLAB UI for Simulink-style FFT analysis.
%
% Run from MATLAB with:
%   FourierAnalysisApp

    properties (Access = private)
        Figure
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
        StatusLabel
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
        MaxTimePlotPoints double = 20000
        FineTimePlotPoints double = 200000
        MaxSpectrumBarCount double = 5000
        MaxSpectrumLinePoints double = 20000
    end

    methods
        function app = FourierAnalysisApp()
            app.createComponents();
            app.updateLanguageTexts();
            app.Figure.UserData = app;
        end
    end

    methods (Access = private)
        function createComponents(app)
            app.Figure = uifigure('Name', app.text('app_title'), ...
                'Position', [100 100 1120 700]);

            mainGrid = uigridlayout(app.Figure, [1 2]);
            mainGrid.ColumnWidth = {300, '1x'};
            mainGrid.RowHeight = {'1x'};
            mainGrid.Padding = [12 12 12 12];
            mainGrid.ColumnSpacing = 12;

            app.ControlPanel = uipanel(mainGrid, 'Title', app.text('fft_params'));
            app.ControlPanel.Layout.Row = 1;
            app.ControlPanel.Layout.Column = 1;

            controlGrid = uigridlayout(app.ControlPanel, [17 2]);
            controlGrid.ColumnWidth = {95, '1x'};
            controlGrid.RowHeight = {34, 28, 34, 34, 34, 34, 34, 34, 34, 34, 34, 34, '1x', 34, 34, 24, 24};
            controlGrid.Padding = [12 12 12 12];
            controlGrid.RowSpacing = 8;

            app.LoadButton = uibutton(controlGrid, 'Text', app.text('load_button'), ...
                'ButtonPushedFcn', @(~, ~) app.loadDataFile());
            app.LoadButton.Layout.Row = 1;
            app.LoadButton.Layout.Column = [1 2];

            app.FileLabel = uilabel(controlGrid, 'Text', app.text('loaded_none'), ...
                'WordWrap', 'on');
            app.FileLabel.Layout.Row = 2;
            app.FileLabel.Layout.Column = [1 2];

            app.LanguageLabel = uilabel(controlGrid, 'Text', app.text('language'));
            app.LanguageLabel.Layout.Row = 3;
            app.LanguageLabel.Layout.Column = 1;

            app.LanguageDropDown = uidropdown(controlGrid, ...
                'Items', {'中文', 'English'}, ...
                'Value', '中文', ...
                'ValueChangedFcn', @(~, ~) app.onLanguageChanged());
            app.LanguageDropDown.Layout.Row = 3;
            app.LanguageDropDown.Layout.Column = 2;

            app.SignalLabel = uilabel(controlGrid, 'Text', app.text('signal_var'));
            app.SignalLabel.Layout.Row = 4;
            app.SignalLabel.Layout.Column = 1;

            app.SignalDropDown = uidropdown(controlGrid, ...
                'Items', {app.text('load_file_first')}, ...
                'ValueChangedFcn', @(~, ~) app.onSignalChanged());
            app.SignalDropDown.Layout.Row = 4;
            app.SignalDropDown.Layout.Column = 2;

            app.ChannelLabel = uilabel(controlGrid, 'Text', app.text('channel'));
            app.ChannelLabel.Layout.Row = 5;
            app.ChannelLabel.Layout.Column = 1;

            app.ChannelDropDown = uidropdown(controlGrid, 'Items', {'1'});
            app.ChannelDropDown.Layout.Row = 5;
            app.ChannelDropDown.Layout.Column = 2;

            app.FundamentalLabel = uilabel(controlGrid, 'Text', app.text('fundamental_hz'));
            app.FundamentalLabel.Layout.Row = 6;
            app.FundamentalLabel.Layout.Column = 1;

            app.FundamentalEdit = uieditfield(controlGrid, 'numeric', ...
                'Value', 50, 'Limits', [eps Inf]);
            app.FundamentalEdit.Layout.Row = 6;
            app.FundamentalEdit.Layout.Column = 2;

            app.CyclesLabel = uilabel(controlGrid, 'Text', app.text('cycles'));
            app.CyclesLabel.Layout.Row = 7;
            app.CyclesLabel.Layout.Column = 1;

            app.CyclesEdit = uieditfield(controlGrid, 'numeric', ...
                'Value', 10, 'Limits', [eps Inf]);
            app.CyclesEdit.Layout.Row = 7;
            app.CyclesEdit.Layout.Column = 2;

            app.StartTimeLabel = uilabel(controlGrid, 'Text', app.text('start_time_s'));
            app.StartTimeLabel.Layout.Row = 8;
            app.StartTimeLabel.Layout.Column = 1;

            app.StartTimeEdit = uieditfield(controlGrid, 'numeric', 'Value', 0);
            app.StartTimeEdit.Layout.Row = 8;
            app.StartTimeEdit.Layout.Column = 2;

            app.MaxFreqLabel = uilabel(controlGrid, 'Text', app.text('max_freq_hz'));
            app.MaxFreqLabel.Layout.Row = 9;
            app.MaxFreqLabel.Layout.Column = 1;

            app.MaxFreqEdit = uieditfield(controlGrid, 'numeric', ...
                'Value', 2000, 'Limits', [eps Inf]);
            app.MaxFreqEdit.Layout.Row = 9;
            app.MaxFreqEdit.Layout.Column = 2;

            app.PlotDetailLabel = uilabel(controlGrid, 'Text', app.text('plot_detail'));
            app.PlotDetailLabel.Layout.Row = 10;
            app.PlotDetailLabel.Layout.Column = 1;

            app.PlotDetailDropDown = uidropdown(controlGrid, ...
                'Items', app.plotDetailItems(), ...
                'ValueChangedFcn', @(~, ~) app.onPlotDetailChanged());
            app.PlotDetailDropDown.Layout.Row = 10;
            app.PlotDetailDropDown.Layout.Column = 2;

            app.AnalyzeButton = uibutton(controlGrid, 'Text', app.text('analyze_button'), ...
                'Enable', 'off', ...
                'ButtonPushedFcn', @(~, ~) app.analyzeSignal());
            app.AnalyzeButton.Layout.Row = 11;
            app.AnalyzeButton.Layout.Column = [1 2];

            app.ExportButton = uibutton(controlGrid, 'Text', app.text('export_button'), ...
                'Enable', 'off', ...
                'ButtonPushedFcn', @(~, ~) app.exportResult());
            app.ExportButton.Layout.Row = 12;
            app.ExportButton.Layout.Column = [1 2];

            app.ResultTable = uitable(controlGrid, ...
                'ColumnName', {app.text('table_item'), app.text('table_value')}, ...
                'Data', cell(0, 2));
            app.ResultTable.Layout.Row = [13 15];
            app.ResultTable.Layout.Column = [1 2];

            app.StatusLabel = uilabel(controlGrid, 'Text', app.text('select_file'), ...
                'WordWrap', 'on');
            app.StatusLabel.Layout.Row = [16 17];
            app.StatusLabel.Layout.Column = [1 2];

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

        function updateLanguageTexts(app)
            app.Figure.Name = app.text('app_title');
            app.ControlPanel.Title = app.text('fft_params');
            app.PlotPanel.Title = app.text('analysis_results');
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
            app.ResultTable.ColumnName = {app.text('table_item'), app.text('table_value')};

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
            [plotTime, plotWaveform] = FourierAnalysisApp.downsampleForPlot( ...
                app.CurrentTime, app.CurrentWaveform(:, 1), app.timePlotPointLimit());
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
                result.fundamentalFrequency, result.fundamentalRms, result.thd * 100));
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
                app.text('result_fund_rms'), result.fundamentalRms
                app.text('result_thd'), result.thd * 100
                };
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
            else
                app.AnalyzeButton.Enable = 'on';
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
                case 'plot_detail_fast'
                    template = '快速 2万点';
                case 'plot_detail_fine'
                    template = '精细 20万点';
                case 'plot_detail_full'
                    template = '完整 全部点';
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
                    template = '未找到支持的数据格式。MAT 变量需包含 time 和 signals.values；CSV 需包含 TIME 和至少一个波形列。';
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
                    template = '基波 %.3g Hz RMS = %.4g，THD = %.3f%%';
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
                    template = '基波幅值（峰值）';
                case 'result_fund_rms'
                    template = '基波有效值 RMS';
                case 'result_thd'
                    template = 'THD (%)';
                otherwise
                    template = key;
            end
        end

        function template = englishText(key)
            switch key
                case 'app_title'
                    template = 'Fourier Analysis';
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
                case 'plot_detail_fast'
                    template = 'Fast 20k pts';
                case 'plot_detail_fine'
                    template = 'Fine 200k pts';
                case 'plot_detail_full'
                    template = 'Full all pts';
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
                    template = 'No supported data format was found. MAT variables must contain time and signals.values; CSV files must contain TIME and at least one waveform column.';
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
                    template = 'Fundamental %.3g Hz RMS = %.4g, THD = %.3f%%';
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
                    template = 'Fundamental magnitude (peak)';
                case 'result_fund_rms'
                    template = 'Fundamental RMS';
                case 'result_thd'
                    template = 'THD (%)';
                otherwise
                    template = key;
            end
        end

        function candidates = findSignalCandidates(data, prefix)
            candidates = struct('label', {}, 'path', {}, 'source', {}, 'column', {});
            if ~isstruct(data) || ~isscalar(data)
                return;
            end

            names = fieldnames(data);
            for k = 1:numel(names)
                name = names{k};
                value = data.(name);
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
                elseif isstruct(value) && isscalar(value)
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
            tf = false;
            if isa(value, 'timeseries')
                tf = true;
                return;
            end

            if isstruct(value) && isscalar(value) && isfield(value, 'time') && isfield(value, 'signals')
                signals = value.signals;
                tf = isstruct(signals) && isfield(signals, 'values');
            end
        end

        function [time, waveform] = readSignal(data, path)
            value = FourierAnalysisApp.getByPath(data, path);
            if isa(value, 'timeseries')
                time = value.Time;
                waveform = value.Data;
            else
                time = value.time;
                waveform = value.signals.values;
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

        function value = getByPath(data, path)
            parts = split(string(path), ".");
            value = data;
            for k = 1:numel(parts)
                value = value.(char(parts(k)));
            end
        end
    end
end
