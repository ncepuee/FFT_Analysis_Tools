function scopeData = readScopeCsv(filePath)
%READSCOPECSV Read oscilloscope CSV files with metadata before numeric data.
%
% scopeData = readScopeCsv(filePath)
%
% The parser expects a data header like:
%   TIME,CH1,CH4
%
% Returned fields:
%   time           Time vector shifted so the first sample is 0.
%   waveforms      Numeric waveform matrix. Each column is one channel.
%   channelNames   Channel names from the CSV header.
%   signalLabels   User-facing labels, e.g. Voltage (CH1), Current (CH4).
%   timeOffset     Original first timestamp. time = rawTime - timeOffset.
%   sampleInterval Sample interval from metadata or median(diff(time)).
%   metadata       Parsed header metadata.

    filePath = char(filePath);

    [headerLine, channelNames, metadata] = inspectHeader(filePath);

    raw = readmatrix(filePath, 'FileType', 'text', 'NumHeaderLines', headerLine);
    if isempty(raw) || size(raw, 2) < 2
        error('readScopeCsv:InvalidData', ...
            'CSV data section must contain at least TIME and one waveform column.');
    end

    validRows = isfinite(raw(:, 1));
    raw = raw(validRows, :);
    if size(raw, 1) < 3
        error('readScopeCsv:NotEnoughSamples', ...
            'CSV data section does not contain enough valid numeric rows.');
    end

    timeRaw = raw(:, 1);
    waveforms = raw(:, 2:end);
    channelNames = normalizeChannelNames(channelNames, size(waveforms, 2));

    validColumns = any(isfinite(waveforms), 1);
    waveforms = waveforms(:, validColumns);
    channelNames = channelNames(validColumns);
    if isempty(waveforms)
        error('readScopeCsv:NoWaveformColumns', ...
            'CSV data section does not contain valid waveform columns.');
    end

    timeOffset = timeRaw(1);
    time = timeRaw - timeOffset;
    if isfield(metadata, 'sampleInterval') && isfinite(metadata.sampleInterval)
        sampleInterval = metadata.sampleInterval;
    else
        sampleInterval = median(diff(time));
    end

    units = {};
    if isfield(metadata, 'verticalUnits')
        units = metadata.verticalUnits;
        units = normalizeUnits(units, numel(validColumns));
        units = units(validColumns);
    end

    scopeData = struct();
    scopeData.filePath = filePath;
    scopeData.time = time;
    scopeData.waveforms = waveforms;
    scopeData.channelNames = channelNames;
    scopeData.signalLabels = makeSignalLabels(channelNames, units);
    scopeData.timeOffset = timeOffset;
    scopeData.sampleInterval = sampleInterval;
    scopeData.metadata = metadata;
end

function [headerLine, channelNames, metadata] = inspectHeader(filePath)
    fid = fopen(filePath, 'r');
    if fid < 0
        error('readScopeCsv:FileOpenFailed', 'Unable to open CSV file: %s', filePath);
    end
    cleanup = onCleanup(@() fclose(fid));

    headerLine = 0;
    channelNames = {};
    metadata = struct();
    lineNumber = 0;

    while true
        lineText = fgetl(fid);
        if ~ischar(lineText)
            break;
        end
        lineNumber = lineNumber + 1;
        fields = strtrim(strsplit(lineText, ','));
        if isempty(fields) || isempty(fields{1})
            continue;
        end

        key = fields{1};
        if strcmpi(key, 'TIME')
            headerLine = lineNumber;
            channelNames = fields(2:end);
            channelNames = channelNames(~cellfun('isempty', channelNames));
            break;
        end

        switch lower(key)
            case 'sample interval'
                metadata.sampleInterval = firstNumericField(fields);
            case 'record length'
                metadata.recordLength = firstNumericField(fields);
            case 'horizontal units'
                metadata.horizontalUnits = firstTextField(fields);
            case 'horizontal scale'
                metadata.horizontalScale = firstNumericField(fields);
            case 'horizontal delay'
                metadata.horizontalDelay = firstNumericField(fields);
            case 'vertical units'
                metadata.verticalUnits = fields(2:end);
            case 'model'
                metadata.model = firstTextField(fields);
            case 'firmware version'
                metadata.firmwareVersion = firstTextField(fields);
        end
    end

    if headerLine == 0 || isempty(channelNames)
        error('readScopeCsv:HeaderNotFound', ...
            'Could not find CSV data header. Expected a line like: TIME,CH1,CH4');
    end
end

function channelNames = normalizeChannelNames(channelNames, columnCount)
    if numel(channelNames) < columnCount
        for k = numel(channelNames)+1:columnCount
            channelNames{k} = sprintf('CH%d', k);
        end
    elseif numel(channelNames) > columnCount
        channelNames = channelNames(1:columnCount);
    end
end

function units = normalizeUnits(units, columnCount)
    if numel(units) < columnCount
        for k = numel(units)+1:columnCount
            units{k} = '';
        end
    elseif numel(units) > columnCount
        units = units(1:columnCount);
    end
end

function labels = makeSignalLabels(channelNames, units)
    labels = cell(1, numel(channelNames));
    for k = 1:numel(channelNames)
        channelName = strtrim(channelNames{k});
        if isempty(channelName)
            channelName = sprintf('CH%d', k);
        end

        if numel(channelNames) == 2 && k == 1
            signalName = 'Voltage';
        elseif numel(channelNames) == 2 && k == 2
            signalName = 'Current';
        else
            signalName = channelName;
        end

        unitText = '';
        if nargin >= 2 && numel(units) >= k && ~isempty(strtrim(units{k}))
            unitText = sprintf(' [%s]', strtrim(units{k}));
        end
        labels{k} = sprintf('%s (%s)%s', signalName, channelName, unitText);
    end
end

function value = firstNumericField(fields)
    value = NaN;
    for k = 2:numel(fields)
        candidate = str2double(fields{k});
        if isfinite(candidate)
            value = candidate;
            return;
        end
    end
end

function value = firstTextField(fields)
    value = '';
    for k = 2:numel(fields)
        candidate = strtrim(fields{k});
        if ~isempty(candidate)
            value = candidate;
            return;
        end
    end
end
