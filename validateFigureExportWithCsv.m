function validateFigureExportWithCsv()
%VALIDATEFIGUREEXPORTWITHCSV Validate exported figure text with real CSV data.

    projectRoot = fileparts(mfilename('fullpath'));
    outDir = fullfile(projectRoot, 'validation_outputs');
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end

    csvFile = fullfile(projectRoot, 'withoutHPF.csv');
    app = FourierAnalysisApp();
    cleanupApp = onCleanup(@() delete(app));

    app.loadDataFileFromPath(csvFile);
    app.runCurrentAnalysis();

    zhInfo = exportAndInspect(app, 'zh', fullfile(outDir, 'fft_export_zh'));
    enInfo = exportAndInspect(app, 'en', fullfile(outDir, 'fft_export_en'));

    report = [
        "CSV=" + string(csvFile)
        formatInfo("ZH", zhInfo)
        formatInfo("EN", enInfo)
        ];
    writelines(report, fullfile(outDir, 'figure_export_validation.txt'));

    assert(~zhInfo.HasFontControlText, 'Chinese exported figure contains raw font control text.');
    assert(~enInfo.HasFontControlText, 'English exported figure contains raw font control text.');
    assert(~zhInfo.HasTexInterpreter, 'Chinese exported figure unexpectedly uses TeX interpreter.');
    assert(~enInfo.HasTexInterpreter, 'English exported figure unexpectedly uses TeX interpreter.');

    fprintf('WITHOUT_HPF_EXPORT_VALIDATION_OK\n');
end

function info = exportAndInspect(app, languageValue, outputBase)
    app.setAppLanguage(languageValue);
    fig = app.exportCurrentAnalysisFigure();
    cleanupFig = onCleanup(@() close(fig));
    drawnow;

    pngFile = char(string(outputBase) + ".png");
    figFile = char(string(outputBase) + ".fig");
    deleteIfExists(pngFile);
    deleteIfExists(figFile);
    try
        exportgraphics(fig, pngFile, 'Resolution', 160);
    catch
        print(fig, pngFile, '-dpng', '-r160');
    end
    savefig(fig, figFile);

    textHandles = findall(fig, 'Type', 'Text');
    legendHandles = findall(fig, 'Type', 'Legend');

    strings = [
        collectProperty(textHandles, 'String')
        collectProperty(legendHandles, 'String')
        ];
    interpreters = [
        collectProperty(textHandles, 'Interpreter')
        collectProperty(legendHandles, 'Interpreter')
        ];
    fonts = [
        collectProperty(textHandles, 'FontName')
        collectProperty(legendHandles, 'FontName')
        ];

    info = struct();
    info.Strings = strings;
    info.Interpreters = interpreters;
    info.Fonts = fonts;
    info.HasFontControlText = any(contains(strings, "\fontname"));
    info.HasTexInterpreter = any(strcmpi(interpreters, "tex"));
end

function deleteIfExists(filePath)
    if isfile(filePath)
        delete(filePath);
    end
end

function values = collectProperty(handles, propertyName)
    if isempty(handles)
        values = strings(0, 1);
        return;
    end

    raw = get(handles, propertyName);
    if ~iscell(raw)
        raw = {raw};
    end

    values = strings(numel(raw), 1);
    for k = 1:numel(raw)
        item = raw{k};
        if iscell(item)
            values(k) = strjoin(string(item), " ");
        else
            values(k) = string(item);
        end
    end
end

function lines = formatInfo(prefix, info)
    lines = [
        prefix + "_HAS_FONT_CONTROL_TEXT=" + string(info.HasFontControlText)
        prefix + "_HAS_TEX_INTERPRETER=" + string(info.HasTexInterpreter)
        prefix + "_INTERPRETERS=" + strjoin(unique(info.Interpreters), ", ")
        prefix + "_FONTS=" + strjoin(unique(info.Fonts), ", ")
        prefix + "_STRINGS=" + strjoin(info.Strings, " | ")
        ];
end
