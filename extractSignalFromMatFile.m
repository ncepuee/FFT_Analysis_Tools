function [time, waveform] = extractSignalFromMatFile(guiParent)
    % 创建文件选择对话框并加载 MAT 文件
    [file, path] = uigetfile('*.mat', 'Select MAT File');
    if isequal(file, 0)  % 如果未选择文件
        uialert(guiParent, 'No file selected', 'File Selection Error');
        time = [];
        waveform = [];
        return;
    end

    % 加载 MAT 文件
    matData = load(fullfile(path, file));
    if ~isfield(matData, 'out')
        uialert(guiParent, 'Selected file does not contain an ''out'' variable.', 'File Content Error');
        time = [];
        waveform = [];
        return;
    end

    % 获取 `out` 结构体的所有字段名
    variableNames = fieldnames(matData.out);
    if isempty(variableNames)
        uialert(guiParent, 'The ''out'' variable contains no valid fields.', 'Content Error');
        time = [];
        waveform = [];
        return;
    end

    % 创建一个对话框供用户选择变量
    [selectionIndex, ok] = listdlg('PromptString', 'Select a variable for analysis:', ...
                                    'SelectionMode', 'single', ...
                                    'ListString', variableNames, ...
                                    'Name', 'Variable Selection');
    if ~ok  % 用户取消选择
        time = [];
        waveform = [];
        return;
    end

    % 获取用户选择的变量名称
    variableName = variableNames{selectionIndex};

    % 检查并提取时间和波形值
    try
        time = matData.out.(variableName).time; % 提取时间
        waveform = matData.out.(variableName).signals.values; % 提取波形
    catch ME
        uialert(guiParent, sprintf('Error extracting data from variable ''%s'': %s', variableName, ME.message), 'Data Extraction Error');
        time = [];
        waveform = [];
        return;
    end

    % 验证时间和波形是否正确
    if isempty(time) || isempty(waveform)
        uialert(guiParent, sprintf('Extracted data for variable ''%s'' is empty.', variableName), 'Data Error');
        time = [];
        waveform = [];
        return;
    end
end
