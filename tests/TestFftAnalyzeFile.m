classdef TestFftAnalyzeFile < matlab.unittest.TestCase
    methods (Test)
        function analyzesMatSignal(testCase)
            [time, waveform] = TestFftAnalyzeFile.syntheticSignal();
            signal = struct("time", time, "signals", struct("values", waveform));
            filePath = string(tempname) + ".mat";
            cleanup = onCleanup(@() TestFftAnalyzeFile.deleteIfPresent(filePath));
            save(filePath, "signal");

            output = fftAnalyzeFile(filePath, FundamentalFrequency=50, ...
                NumCycles=10, MaxDisplayFrequency=500);

            testCase.verifyEqual(output.source.signal, 'signal');
            testCase.verifyEqual(output.summary.fundamentalMagnitude, 1, "AbsTol", 1e-10);
            testCase.verifyEqual(output.summary.thdPercent, 10, "AbsTol", 1e-8);
            testCase.verifyEqual(output.harmonics.percentOfFundamental(3), 10, "AbsTol", 1e-8);
            clear cleanup;
        end

        function requiresMatSignalSelection(testCase)
            [time, waveform] = TestFftAnalyzeFile.syntheticSignal();
            first = struct("time", time, "signals", struct("values", waveform));
            second = first;
            filePath = string(tempname) + ".mat";
            cleanup = onCleanup(@() TestFftAnalyzeFile.deleteIfPresent(filePath));
            save(filePath, "first", "second");

            testCase.verifyError(@() fftAnalyzeFile(filePath), ...
                "fftAnalyzeFile:SignalSelectionRequired");
            output = fftAnalyzeFile(filePath, Signal="second", ...
                FundamentalFrequency=50, MaxDisplayFrequency=500);
            testCase.verifyEqual(output.source.signal, 'second');
            clear cleanup;
        end

        function analyzesScopeCsv(testCase)
            [time, waveform] = TestFftAnalyzeFile.syntheticSignal();
            filePath = string(tempname) + ".csv";
            cleanup = onCleanup(@() TestFftAnalyzeFile.deleteIfPresent(filePath));
            fileId = fopen(filePath, "w");
            fileCleanup = onCleanup(@() fclose(fileId));
            fprintf(fileId, "Sample Interval,%.12g\n", time(2) - time(1));
            fprintf(fileId, "TIME,CH1\n");
            fprintf(fileId, "%.12g,%.12g\n", [time, waveform].');
            clear fileCleanup;

            output = fftAnalyzeFile(filePath, Signal="CH1", ...
                FundamentalFrequency=50, NumCycles=10, MaxDisplayFrequency=500);

            testCase.verifyEqual(output.source.channelName, 'CH1');
            testCase.verifyEqual(output.summary.thdPercent, 10, "AbsTol", 1e-6);
            clear cleanup;
        end
    end

    methods (Static, Access = private)
        function [time, waveform] = syntheticSignal()
            sampleRate = 10000;
            time = (0:1/sampleRate:0.4).';
            waveform = sin(2*pi*50*time) + 0.1*sin(2*pi*150*time);
        end

        function deleteIfPresent(filePath)
            if isfile(filePath)
                delete(filePath);
            end
        end
    end
end
