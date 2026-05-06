function packageFourierAnalysisApp(projectFile)
%PACKAGEFOURIERANALYSISAPP Package the Fourier analysis app.
%
% If a packaging project exists, this function builds the .mlappinstall
% file. Otherwise it opens MATLAB's App Packaging Tool so the project can be
% created once through the supported MATLAB UI.
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
        return;
    end

    fprintf('No packaging project was found at:\n  %s\n', projectFile);
    fprintf('Opening MATLAB App Packaging Tool. Save the project as FourierAnalysisApp.prj, then rerun this function.\n');
    matlab.apputil.create;
end
