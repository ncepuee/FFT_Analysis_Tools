function results = buildFFTAnalysisSoftware()
%BUILDFFTANALYSISSOFTWARE Build the FFT analysis app for the current OS.
%
% This build uses MATLAB Compiler. The generated application requires
% MATLAB Runtime R2024b on machines that do not have MATLAB installed.

    projectRoot = fileparts(mfilename('fullpath'));
    platformTag = currentPlatformTag();
    outputRoot = fullfile(projectRoot, 'dist', ...
        sprintf('FFTAnalysisApp-%s', platformTag));
    installerRoot = fullfile(projectRoot, 'dist', ...
        sprintf('FFTAnalysisAppInstaller-%s', platformTag));
    splashFile = createFFTAnalysisSplash(fullfile(projectRoot, 'resources'));

    outputRoot = resetBuildFolder(projectRoot, outputRoot);
    installerRoot = resetBuildFolder(projectRoot, installerRoot);

    additionalFiles = {
        fullfile(projectRoot, 'FourierAnalysisApp.m')
        fullfile(projectRoot, 'fftAnalyzeFile.m')
        fullfile(projectRoot, 'fftAnalyzeSignal.m')
        fullfile(projectRoot, 'readScopeCsv.m')
        splashFile
        fullfile(projectRoot, 'resources', 'FFTAnalysisLogo.png')
        fullfile(projectRoot, 'resources', 'authorLinks.html')
        fullfile(projectRoot, 'resources', 'aboutAuthor.html')
        fullfile(projectRoot, 'UI_README.md')
        fullfile(projectRoot, 'README.md')
        fullfile(projectRoot, 'README.zh-CN.md')
        };

    buildOptions = {
        fullfile(projectRoot, 'runFourierAnalysisApp.m'), ...
        'ExecutableName', 'FFTAnalysisApp', ...
        'ExecutableVersion', '2.1.0.0', ...
        'ExecutableSplashScreen', splashFile, ...
        'AdditionalFiles', additionalFiles, ...
        'AutoDetectDataFiles', 'off', ...
        'SupportPackages', 'none', ...
        'EmbedArchive', 'on', ...
        'OutputDir', outputRoot, ...
        'Verbose', 'on'};

    if ispc
        results = compiler.build.standaloneWindowsApplication(buildOptions{:});
    else
        results = compiler.build.standaloneApplication(buildOptions{:});
    end

    compiler.package.installer(results, ...
        'InstallerName', 'FFTAnalysisAppInstaller', ...
        'ApplicationName', 'FFT Analysis App', ...
        'AuthorName', 'Zhenbin Huang', ...
        'Summary', 'MATLAB FFT and THD analysis app for MAT and oscilloscope CSV data.', ...
        'Description', ['Load MAT or oscilloscope CSV data, select signals, compute FFT and THD, ' ...
            'preview waveforms, plot spectra, and export results. Copyright (c) 2026 Zhenbin Huang. ' ...
            'ORCID: https://orcid.org/0000-0002-0628-0387. ' ...
            'LinkedIn: https://www.linkedin.com/in/zhenbin-huang/'], ...
        'Version', '2.1.0', ...
        'InstallerSplash', splashFile, ...
        'RuntimeDelivery', 'web', ...
        'OutputDir', installerRoot, ...
        'Verbose', 'on');
end

function platformTag = currentPlatformTag()
    if ispc
        platformTag = 'windows';
    elseif ismac
        platformTag = 'macos';
    elseif isunix
        platformTag = 'linux';
    else
        error('buildFFTAnalysisSoftware:UnsupportedPlatform', ...
            'Unsupported MATLAB platform: %s.', computer('arch'));
    end
end

function targetFolder = resetBuildFolder(projectRoot, targetFolder)
    projectRoot = char(projectRoot);
    targetFolder = char(targetFolder);
    distRoot = fullfile(projectRoot, 'dist');

    assertFolderInsideDist(distRoot, targetFolder);

    if isfolder(targetFolder)
        try
            rmdir(targetFolder, 's');
        catch ME
            timestamp = char(datetime('now', 'Format', 'yyyyMMdd_HHmmss'));
            fallbackFolder = sprintf('%s_%s', targetFolder, timestamp);
            warning('buildFFTAnalysisSoftware:OutputFolderLocked', ...
                'Could not remove %s (%s). Building into %s instead.', ...
                targetFolder, ME.message, fallbackFolder);
            targetFolder = fallbackFolder;
            assertFolderInsideDist(distRoot, targetFolder);
        end
    end
    mkdir(targetFolder);
end

function assertFolderInsideDist(distRoot, targetFolder)
    normalizedTarget = lower(char(java.io.File(targetFolder).getCanonicalPath()));
    normalizedDistRoot = lower(char(java.io.File(distRoot).getCanonicalPath()));
    if ~startsWith(normalizedTarget, [normalizedDistRoot lower(filesep)])
        error('Refusing to clean output folder outside dist: %s', targetFolder);
    end
end
