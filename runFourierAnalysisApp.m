function app = runFourierAnalysisApp()
%RUNFOURIERANALYSISAPP Launch the Fourier analysis MATLAB app.
%
% Use this launcher when MATLAB's current folder is not the project folder,
% or when the app is packaged and launched from the Apps tab.

    appFolder = fileparts(mfilename('fullpath'));
    pathParts = strsplit(path, pathsep);
    if ~any(strcmpi(pathParts, appFolder))
        addpath(appFolder);
    end

    app = FourierAnalysisApp();

    if nargout == 0
        clear app
    end
end
