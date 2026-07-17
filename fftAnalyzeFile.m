function output = fftAnalyzeFile(filePath, options)
%FFTANALYZEFILE Load a MAT/CSV signal and run FFT/THD analysis without the GUI.
%
% output = fftAnalyzeFile(filePath)
% output = fftAnalyzeFile(filePath, Name=Value)
%
% Name-value options:
%   Signal                 MAT signal path or CSV channel name/label.
%   Channel                Column within the selected signal (1-based).
%   FundamentalFrequency   Fundamental frequency in Hz (default 50).
%   NumCycles              Fundamental cycles in the FFT window (default 10).
%   StartTime              FFT window start time in seconds (default 0).
%   MaxDisplayFrequency    Maximum returned display frequency (default 3000).
%   ThdMethod              "matlab" or "spectrum" (default "matlab").
%   ThdMaxFrequency        THD upper limit; Inf means Nyquist (default Inf).
%   MaxHarmonics           Harmonic rows returned in output.harmonics (default 25).
%
% The output contains source metadata, a compact summary, a harmonic table,
% and the full result returned by fftAnalyzeSignal in output.analysis.

    arguments
        filePath (1,1) string
        options.Signal (1,1) string = ""
        options.Channel (1,1) double = NaN
        options.FundamentalFrequency (1,1) double {mustBePositive} = 50
        options.NumCycles (1,1) double {mustBePositive} = 10
        options.StartTime (1,1) double {mustBeFinite} = 0
        options.MaxDisplayFrequency (1,1) double {mustBePositive} = 3000
        options.ThdMethod (1,1) string = "matlab"
        options.ThdMaxFrequency (1,1) double {mustBePositive} = Inf
        options.MaxHarmonics (1,1) double {mustBeInteger, mustBePositive} = 25
    end

    filePath = string(filePath);
    if ~isfile(filePath)
        error("fftAnalyzeFile:FileNotFound", "File not found: %s", filePath);
    end
    validateChannel(options.Channel);

    [~, ~, extension] = fileparts(filePath);
    switch lower(string(extension))
        case ".csv"
            [time, waveform, source] = loadCsvSignal(filePath, options.Signal, options.Channel);
        case ".mat"
            [time, waveform, source] = loadMatSignal(filePath, options.Signal, options.Channel);
        otherwise
            error("fftAnalyzeFile:UnsupportedFileType", ...
                "Only .mat and .csv files are supported, not '%s'.", extension);
    end

    analysis = fftAnalyzeSignal(time, waveform, ...
        options.FundamentalFrequency, options.NumCycles, options.StartTime, ...
        options.MaxDisplayFrequency, options.ThdMethod, options.ThdMaxFrequency);

    summary = struct();
    summary.sampleCount = numel(time);
    summary.fsHz = analysis.fs;
    summary.dtSeconds = analysis.dt;
    summary.dfHz = analysis.df;
    summary.fftPoints = analysis.N;
    summary.fundamentalFrequencyHz = analysis.fundamentalFrequency;
    summary.fundamentalMagnitude = analysis.fundamentalMagnitude;
    summary.fundamentalRms = analysis.fundamentalRms;
    summary.thdMethod = analysis.thdMethod;
    summary.thdPercent = 100 * analysis.thd;
    summary.thdMatlabOriginalPercent = 100 * analysis.thdMatlabOriginal;
    summary.thdFullSpectrumPercent = 100 * analysis.thdFullSpectrum;

    output = struct();
    output.source = source;
    output.parameters = struct( ...
        "fundamentalFrequencyHz", options.FundamentalFrequency, ...
        "numCycles", options.NumCycles, ...
        "startTimeSeconds", options.StartTime, ...
        "maxDisplayFrequencyHz", options.MaxDisplayFrequency, ...
        "thdMethod", char(lower(options.ThdMethod)), ...
        "thdMaxFrequencyHz", options.ThdMaxFrequency);
    output.summary = summary;
    output.harmonics = makeHarmonicTable(analysis, options.MaxHarmonics);
    output.analysis = analysis;
end

function validateChannel(channel)
    if ~isnan(channel) && (~isfinite(channel) || channel < 1 || fix(channel) ~= channel)
        error("fftAnalyzeFile:InvalidChannel", "Channel must be a positive integer.");
    end
end

function [time, waveform, source] = loadCsvSignal(filePath, signalName, channel)
    data = readScopeCsv(filePath);
    channelCount = size(data.waveforms, 2);

    if signalName ~= ""
        names = string(data.channelNames);
        labels = string(data.signalLabels);
        indexes = find(strcmpi(signalName, names) | strcmpi(signalName, labels));
        if isempty(indexes)
            error("fftAnalyzeFile:SignalNotFound", ...
                "CSV signal '%s' was not found. Available channels: %s", ...
                signalName, strjoin(names, ", "));
        end
        if numel(indexes) > 1
            error("fftAnalyzeFile:AmbiguousSignal", ...
                "CSV signal '%s' matches more than one channel.", signalName);
        end
        selectedChannel = indexes;
        if ~isnan(channel) && channel ~= selectedChannel
            error("fftAnalyzeFile:ConflictingSelection", ...
                "Signal and Channel select different CSV channels.");
        end
    else
        selectedChannel = chooseChannel(channel, channelCount, string(data.channelNames), "CSV");
    end

    time = data.time;
    waveform = data.waveforms(:, selectedChannel);
    source = struct( ...
        "file", char(filePath), ...
        "type", "csv", ...
        "signal", data.signalLabels{selectedChannel}, ...
        "channelName", data.channelNames{selectedChannel}, ...
        "channel", selectedChannel, ...
        "timeOffsetSeconds", data.timeOffset);
end

function [time, waveform, source] = loadMatSignal(filePath, signalPath, channel)
    data = load(filePath);
    candidates = findSignalCandidates(data, "");
    if isempty(candidates)
        error("fftAnalyzeFile:NoSignals", ...
            "No supported MAT signal was found. Expected timeseries or time/signals.values data.");
    end

    candidatePaths = string({candidates.path});
    if signalPath == ""
        if numel(candidates) ~= 1
            error("fftAnalyzeFile:SignalSelectionRequired", ...
                "The MAT file contains multiple signals. Set Signal to one of: %s", ...
                strjoin(candidatePaths, ", "));
        end
        candidateIndex = 1;
    else
        matches = find(strcmpi(signalPath, candidatePaths));
        if isempty(matches)
            error("fftAnalyzeFile:SignalNotFound", ...
                "MAT signal '%s' was not found. Available signals: %s", ...
                signalPath, strjoin(candidatePaths, ", "));
        end
        if numel(matches) > 1
            error("fftAnalyzeFile:AmbiguousSignal", ...
                "MAT signal '%s' matches more than one candidate.", signalPath);
        end
        candidateIndex = matches;
    end

    selectedPath = candidatePaths(candidateIndex);
    value = getByPath(data, selectedPath);
    [time, allWaveforms] = signalValueToTimeWaveform(value);
    channelCount = size(allWaveforms, 2);
    selectedChannel = chooseChannel(channel, channelCount, ...
        "channel " + string(1:channelCount), "MAT signal " + selectedPath);
    waveform = allWaveforms(:, selectedChannel);

    source = struct( ...
        "file", char(filePath), ...
        "type", "mat", ...
        "signal", char(selectedPath), ...
        "channelName", sprintf("channel %d", selectedChannel), ...
        "channel", selectedChannel, ...
        "timeOffsetSeconds", time(1));
end

function channel = chooseChannel(requested, count, names, sourceLabel)
    if isnan(requested)
        if count ~= 1
            error("fftAnalyzeFile:ChannelSelectionRequired", ...
                "%s contains multiple channels. Set Channel to one of 1..%d (%s).", ...
                sourceLabel, count, strjoin(string(names), ", "));
        end
        channel = 1;
        return;
    end
    if requested > count
        error("fftAnalyzeFile:ChannelOutOfRange", ...
            "Channel %d is outside the available range 1..%d.", requested, count);
    end
    channel = requested;
end

function candidates = findSignalCandidates(value, prefix)
    candidates = struct("path", {});
    if isSupportedSignal(value)
        if prefix == ""
            candidates = struct("path", "<root>");
        else
            candidates = struct("path", char(prefix));
        end
        return;
    end
    if ~isscalar(value) || ~(isstruct(value) || isSimulationOutputLike(value))
        return;
    end

    if isSimulationOutputLike(value)
        names = who(value);
    else
        names = fieldnames(value);
    end
    for index = 1:numel(names)
        name = names{index};
        try
            member = getMember(value, name);
        catch
            continue;
        end
        if prefix == ""
            path = string(name);
        else
            path = prefix + "." + string(name);
        end
        nested = findSignalCandidates(member, path);
        candidates = [candidates, nested]; %#ok<AGROW>
    end
end

function tf = isSupportedSignal(value)
    try
        [time, waveform] = signalValueToTimeWaveform(value);
        tf = ~isempty(time) && ~isempty(waveform);
    catch
        tf = false;
    end
end

function [time, waveform] = signalValueToTimeWaveform(value)
    if isa(value, "timeseries")
        time = value.Time;
        waveform = value.Data;
    elseif isstruct(value) && isscalar(value) && isfield(value, "time") && isfield(value, "signals")
        signals = value.signals;
        if ~isstruct(signals) || ~isfield(signals, "values")
            error("fftAnalyzeFile:InvalidSignal", "Expected signals.values.");
        end
        if isscalar(signals)
            waveform = signals.values;
        else
            values = arrayfun(@(item) item.values, signals, "UniformOutput", false);
            waveform = cat(2, values{:});
        end
        time = value.time;
    else
        error("fftAnalyzeFile:UnsupportedSignal", "Unsupported signal type: %s.", class(value));
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
        error("fftAnalyzeFile:SignalSizeMismatch", ...
            "Signal has %d time samples but waveform size is %s.", ...
            numel(time), mat2str(size(waveform)));
    end
end

function value = getByPath(data, path)
    if string(path) == "<root>"
        value = data;
        return;
    end
    parts = split(string(path), ".");
    value = data;
    for index = 1:numel(parts)
        value = getMember(value, char(parts(index)));
    end
end

function value = getMember(data, name)
    if isstruct(data)
        value = data.(name);
    elseif isSimulationOutputLike(data)
        value = data.get(name);
    elseif isobject(data) && isprop(data, name)
        value = data.(name);
    else
        error("fftAnalyzeFile:UnsupportedContainer", ...
            "Unsupported container type: %s.", class(data));
    end
end

function tf = isSimulationOutputLike(value)
    tf = isa(value, "Simulink.SimulationOutput") || ...
        (isobject(value) && ismethod(value, "who") && ismethod(value, "get"));
end

function harmonics = makeHarmonicTable(analysis, maxHarmonics)
    nyquist = analysis.freqs(end);
    maxFrequency = min(analysis.displayFreqs(end), nyquist);
    availableCount = floor(maxFrequency / analysis.fundamentalFrequency);
    harmonicCount = min(maxHarmonics, availableCount);
    order = (1:harmonicCount)';
    targetFrequencyHz = order * analysis.fundamentalFrequency;
    binIndex = round(targetFrequencyHz / analysis.df) + 1;
    binIndex = min(max(binIndex, 1), numel(analysis.freqs));
    frequencyHz = analysis.freqs(binIndex);
    magnitude = analysis.magnitude(binIndex);
    percentOfFundamental = 100 * magnitude / analysis.fundamentalMagnitude;
    harmonics = table(order, targetFrequencyHz, frequencyHz, magnitude, ...
        percentOfFundamental);
end
