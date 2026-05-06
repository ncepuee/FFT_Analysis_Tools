function result = fftAnalyzeSignal(time, waveform, f0, numCycles, startTime, maxDisplayFreq)
%FFTANALYZESIGNAL Compute single-sided FFT and THD information.
%
% result = fftAnalyzeSignal(time, waveform, f0, numCycles, startTime, maxDisplayFreq)
%
% Inputs:
%   time           Time vector in seconds.
%   waveform       Signal vector with the same length as time.
%   f0             Fundamental frequency in Hz.
%   numCycles      Number of fundamental cycles used by the FFT window.
%   startTime      FFT window start time in seconds.
%   maxDisplayFreq Maximum frequency shown in the returned display vectors.
%
% Output fields:
%   fs, dt, df, N, startIndex, endIndex
%   windowTime, windowWaveform
%   freqs, magnitude
%   displayFreqs, displayMagnitude, displayPercent
%   fundamentalFrequency, fundamentalMagnitude, fundamentalRms
%   harmonicFrequencies, harmonicMagnitude, harmonicRms, thd

    arguments
        time (:,1) double
        waveform (:,1) double
        f0 (1,1) double {mustBePositive}
        numCycles (1,1) double {mustBePositive}
        startTime (1,1) double {mustBeFinite}
        maxDisplayFreq (1,1) double {mustBePositive}
    end

    time = time(:);
    waveform = waveform(:);

    if numel(time) ~= numel(waveform)
        error("fftAnalyzeSignal:SizeMismatch", ...
            "time and waveform must have the same number of samples.");
    end

    if numel(time) < 3
        error("fftAnalyzeSignal:NotEnoughSamples", ...
            "At least three samples are required.");
    end

    if any(~isfinite(time)) || any(~isfinite(waveform))
        error("fftAnalyzeSignal:NonFiniteData", ...
            "time and waveform must contain only finite values.");
    end

    dtValues = diff(time);
    if any(dtValues <= 0)
        error("fftAnalyzeSignal:InvalidTime", ...
            "time must be strictly increasing.");
    end

    dt = median(dtValues);
    fs = 1 / dt;
    windowDuration = numCycles / f0;
    N = max(2, round(windowDuration / dt));

    startIndex = find(time >= startTime, 1, "first");
    if isempty(startIndex)
        error("fftAnalyzeSignal:StartTimeOutOfRange", ...
            "startTime is later than the last sample.");
    end

    endIndex = startIndex + N - 1;
    if endIndex > numel(time)
        maxStart = time(max(1, numel(time) - N + 1));
        error("fftAnalyzeSignal:WindowOutOfRange", ...
            "FFT window exceeds signal length. Choose startTime <= %.6g s.", maxStart);
    end

    windowTime = time(startIndex:endIndex);
    windowWaveform = waveform(startIndex:endIndex);

    fftValues = fft(windowWaveform);
    halfCount = floor(N / 2) + 1;
    magnitude = abs(fftValues(1:halfCount)) / N;
    if mod(N, 2) == 0 && halfCount > 2
        magnitude(2:end-1) = 2 * magnitude(2:end-1);
    elseif mod(N, 2) == 1 && halfCount > 1
        magnitude(2:end) = 2 * magnitude(2:end);
    end

    freqs = fs * (0:halfCount-1)' / N;
    df = fs / N;

    [~, baseIndex] = min(abs(freqs - f0));
    fundamentalMagnitude = magnitude(baseIndex);
    if fundamentalMagnitude <= eps
        error("fftAnalyzeSignal:ZeroFundamental", ...
            "The fundamental magnitude is too small for percentage or THD calculation.");
    end

    harmonicFrequencies = (2 * f0:f0:freqs(end)).';
    harmonicMagnitude = zeros(size(harmonicFrequencies));
    harmonicBinIndexes = zeros(size(harmonicFrequencies));
    for k = 1:numel(harmonicFrequencies)
        [~, harmonicIndex] = min(abs(freqs - harmonicFrequencies(k)));
        harmonicBinIndexes(k) = harmonicIndex;
        harmonicMagnitude(k) = magnitude(harmonicIndex);
    end

    fundamentalRms = fundamentalMagnitude / sqrt(2);
    harmonicRms = harmonicMagnitude / sqrt(2);
    thd = sqrt(sum(harmonicRms.^2)) / fundamentalRms;

    maxIndex = find(freqs <= maxDisplayFreq, 1, "last");
    if isempty(maxIndex)
        maxIndex = 1;
    end

    result = struct();
    result.fs = fs;
    result.dt = dt;
    result.df = df;
    result.N = N;
    result.startIndex = startIndex;
    result.endIndex = endIndex;
    result.windowTime = windowTime;
    result.windowWaveform = windowWaveform;
    result.freqs = freqs;
    result.magnitude = magnitude;
    result.displayFreqs = freqs(1:maxIndex);
    result.displayMagnitude = magnitude(1:maxIndex);
    result.displayPercent = result.displayMagnitude / fundamentalMagnitude * 100;
    result.fundamentalFrequency = freqs(baseIndex);
    result.fundamentalMagnitude = fundamentalMagnitude;
    result.fundamentalRms = fundamentalRms;
    result.fundamentalBinIndex = baseIndex;
    result.harmonicFrequencies = harmonicFrequencies;
    result.harmonicBinIndexes = harmonicBinIndexes;
    result.harmonicMagnitude = harmonicMagnitude;
    result.harmonicRms = harmonicRms;
    result.thd = thd;
end
