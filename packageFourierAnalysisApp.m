function output = packageFourierAnalysisApp(projectFile)
%PACKAGEFOURIERANALYSISAPP Package the Fourier analysis app.
%
% If a MATLAB app packaging project exists, this function builds the
% .mlappinstall file. Otherwise it directly builds the Windows executable
% software through MATLAB Compiler.
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
    fprintf('Building standalone Windows software with MATLAB Compiler instead.\n');
    output = buildFFTAnalysisSoftware();
end
