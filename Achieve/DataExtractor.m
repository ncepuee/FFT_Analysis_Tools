function variables = DataExtractor()
    % 获取当前工作目录下的所有 MAT 文件
    [file, path] = uigetfile('*.mat', '选择一个 MAT 文件', './');
    
    if isequal(file, 0)  % 如果没有选择文件，返回空列表
        variables = {};
        disp('未选择文件');
        return;
    end
    
    % 拼接文件的完整路径
    filePath = fullfile(path, file);
    
    % 加载选中的 MAT 文件
    S = load(filePath);
    variables = fieldnames(S);  % 获取 MAT 文件中的变量名
    
    % 如果存在 out 变量，进一步获取 out 中的字段
    if isfield(S, 'out')
        outVars = fieldnames(S.out);  % 获取 out 变量中的字段名
        variables = [variables; strcat('out.', outVars)];  % 将 out 的字段添加到变量列表中
    end
end
