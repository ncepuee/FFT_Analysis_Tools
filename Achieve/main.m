% 运行 DataExtractor_GUI 函数并获取返回的变量名称
variables = DataExtractor();  % 调用函数，返回文件中的变量名称
disp(variables);  % 打印所有变量名称

% 如果获取到变量，可以继续操作
if ~isempty(variables)
    selectedVar = variables{1};  % 获取第一个选中的变量名（可以根据需要调整）

    % 动态加载该变量的数据
    time = eval([selectedVar '.time']);
    waveform = eval([selectedVar '.signals.values']);

    % 调用 FFT 函数进行分析
    performFFT(time, waveform,50,10,2,1200);
end