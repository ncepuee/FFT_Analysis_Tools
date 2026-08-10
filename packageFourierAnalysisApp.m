function output = packageFourierAnalysisApp(projectFile)
%PACKAGEFOURIERANALYSISAPP Package the Fourier analysis app.
%
% If a MATLAB app packaging project exists, this function builds the
% .mlappinstall file. Otherwise it builds a standalone application for the
% current operating system through MATLAB Compiler.
%
% In the App Packaging Tool, use:
%   Main file: runFourierAnalysisApp.m
%   Files:     FourierAnalysisApp.m, fftAnalyzeSignal.m, readScopeCsv.m
%   Optional:  UI_README.md, readme.md

    appFolder = fileparts(mfilename('fullpath'));
    currentFolder = pwd;
    cleanup = onCleanup(@() cd(currentFolder));
    cd(appFolder);

    if nargin < 1 || strlength(string(projectFile)) == 0
        projectFile = fullfile(appFolder, 'FourierAnalysisApp.prj');
    end

    if isfile(projectFile)
        matlab.apputil.package(projectFile);
        output = projectFile;
        return;
    end

    fprintf('No MATLAB app packaging project was found at:\n  %s\n', projectFile);
    fprintf('Building standalone %s software with MATLAB Compiler instead.\n', ...
        currentPlatformLabel());
    output = buildFFTAnalysisSoftware();
end

function platformLabel = currentPlatformLabel()
    if ispc
        platformLabel = 'Windows';
    elseif ismac
        platformLabel = 'macOS';
    elseif isunix
        platformLabel = 'Linux';
    else
        platformLabel = computer('arch');
    end
end
