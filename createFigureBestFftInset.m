function [zoomFig, zoomAxes] = createFigureBestFftInset(sourceFigure, zoomArea, insetPosition, lines, figureBestRoot)
%CREATEFIGUREBESTFFTINSET Apply FigureBest MagInset to an exported FFT figure.
%
% FigureBest's MagInset expects the target axes to be a direct child of the
% figure. FFT figures exported by FourierAnalysisApp use tiledlayout, so this
% helper copies the spectrum axes into a plain figure before calling MagInset.
%
% Example:
%   [zoomFig, zoomAxes] = createFigureBestFftInset( ...
%       FFT_UI_Figure, [250 400 0 10], [900 1500 35 90]);

    if nargin < 1 || isempty(sourceFigure)
        sourceFigure = defaultSourceFigure();
    end
    if nargin < 2 || isempty(zoomArea)
        error('createFigureBestFftInset:MissingZoomArea', ...
            'zoomArea is required: [xMin xMax yMin yMax].');
    end
    if nargin < 3 || isempty(insetPosition)
        error('createFigureBestFftInset:MissingInsetPosition', ...
            'insetPosition is required: [xMin xMax yMin yMax].');
    end
    if nargin < 4
        lines = {'NW', 'SW'; 'NE', 'SE'};
    end
    if nargin < 5
        figureBestRoot = '';
    end

    ensureFigureBestOnPath(figureBestRoot);
    sourceFigure = normalizeFigure(sourceFigure);
    sourceAxes = findSpectrumAxes(sourceFigure);

    zoomFig = figure('Name', appendFigureName(sourceFigure.Name), ...
        'Color', 'white', ...
        'Position', [560 200 820 460]);
    zoomAxes = copyobj(sourceAxes, zoomFig);
    zoomAxes.Units = 'normalized';
    zoomAxes.OuterPosition = [0 0 1 1];
    zoomAxes.Position = [0.12 0.16 0.78 0.74];

    MagInset(zoomFig, zoomAxes, zoomArea, insetPosition, lines);
end

function fig = defaultSourceFigure()
    if evalin('base', 'exist(''FFT_UI_Figure'', ''var'')')
        fig = evalin('base', 'FFT_UI_Figure');
    else
        fig = gcf;
    end
end

function ensureFigureBestOnPath(figureBestRoot)
    if exist('MagInset', 'file') == 2 || exist('MagInset', 'file') == 6
        return;
    end

    if strlength(string(figureBestRoot)) == 0
        defaultRoot = 'G:\EMTProgram\simulinkprogram\FigureBest_4.7.1';
        if isfolder(defaultRoot)
            figureBestRoot = defaultRoot;
        end
    end

    if strlength(string(figureBestRoot)) > 0 && isfolder(figureBestRoot)
        addpath(genpath(figureBestRoot));
    end

    if ~(exist('MagInset', 'file') == 2 || exist('MagInset', 'file') == 6)
        error('createFigureBestFftInset:MissingFigureBest', ...
            'MagInset was not found. Add FigureBest_4.7.1 to the MATLAB path first.');
    end
end

function fig = normalizeFigure(sourceFigure)
    if isstring(sourceFigure) || ischar(sourceFigure)
        fig = openfig(char(sourceFigure), 'visible');
        return;
    end

    if ishghandle(sourceFigure, 'figure')
        fig = sourceFigure;
        return;
    end

    error('createFigureBestFftInset:InvalidFigure', ...
        'sourceFigure must be a figure handle, a .fig path, or empty.');
end

function ax = findSpectrumAxes(fig)
    axesList = findall(fig, 'Type', 'axes');
    if isempty(axesList)
        error('createFigureBestFftInset:NoAxes', ...
            'No axes were found in the source figure.');
    end

    scores = zeros(size(axesList));
    for k = 1:numel(axesList)
        xLabel = lower(join(string(axesList(k).XLabel.String), " "));
        yLabel = lower(join(string(axesList(k).YLabel.String), " "));
        titleText = lower(join(string(axesList(k).Title.String), " "));
        scores(k) = scores(k) ...
            + 3 * contains(xLabel, "hz") ...
            + 2 * contains(xLabel, "freq") ...
            + 2 * contains(xLabel, "frequency") ...
            + contains(yLabel, "percent") ...
            + contains(titleText, "fft") ...
            + contains(titleText, "thd");
    end

    [bestScore, bestIndex] = max(scores);
    if bestScore == 0
        error('createFigureBestFftInset:NoSpectrumAxes', ...
            'Could not identify the spectrum axes. Pass a figure whose spectrum x-label includes Hz/freq/frequency.');
    end

    ax = axesList(bestIndex);
end

function name = appendFigureName(sourceName)
    if strlength(string(sourceName)) == 0
        sourceName = 'FFT spectrum';
    end
    name = sprintf('%s - FigureBest inset', char(sourceName));
end
