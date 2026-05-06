function performFFT_GUI(time, waveform)
    % 弹出输入框让用户输入参数
    prompt = {'请输入基频 (Hz):', '请输入周期数:', '请输入开始时间 (s):', '请输入最大频率范围 (Hz):'};
    dlg_title = '输入FFT分析参数';
    num_lines = 1;
    defaultans = {'50', '5', '0', '500'};
    answer = inputdlg(prompt, dlg_title, num_lines, defaultans);

    % 获取输入的参数
    f0 = str2double(answer{1});  % 基频 (Hz)
    num_cycles = str2double(answer{2});  % 周期数
    starttime = str2double(answer{3});  % 开始时间 (s)
    max_display_freq = str2double(answer{4});  % 最大频率范围 (Hz)

    % 计算采样频率和步长
    dt = time(2) - time(1);
    fs = 1 / dt;
    T = num_cycles / f0; 
    N = round(T / dt); 
    N0 = round(starttime / dt); 

    % 选择用于FFT的信号窗口
    waveform_window = waveform(N0+1:N0+N);

    % FFT变换
    waveform_FFT = fft(waveform_window);

    % 频率分辨率和频率向量
    df = fs / N;
    freqs = (0:N/2 - 1) * df;

    % 单边频谱幅值计算
    waveform_FFT = abs(waveform_FFT(1:floor(N/2))) * 2 / N;

    % 显示范围的限制
    num = floor(max_display_freq / df) + 1;
    freqs_display = freqs(1:num);
    waveform_FFT_display = waveform_FFT(1:num);

    % 基波幅值和THD计算
    base_index = round(f0 / df) + 1;
    base_magnitude_waveform = waveform_FFT(base_index);
    harmonics_square_sum_waveform = sum(waveform_FFT(2:end).^2) - base_magnitude_waveform^2; 
    thd_waveform = sqrt(harmonics_square_sum_waveform) / base_magnitude_waveform;

    % 幅值转换为基波百分比
    waveform_FFT_display_percentage = (waveform_FFT_display / base_magnitude_waveform) * 100;

    %% 绘图
    leftMargin = 0.12;
    bottomMargin1 = 0.6;
    bottomMargin2 = 0.12;
    width = 0.8;
    height = 0.32;
    Fwidth = 588; Fheight = 441;

    % 图像窗口设置
    figure;
    set(gcf, 'Position', [100, 350, Fwidth, Fheight]);
    subplotPosition1 = [leftMargin, bottomMargin1, width, height];
    subplotPosition2 = [leftMargin, bottomMargin2, width, height];

    % 时间波形图
    subplot('Position', subplotPosition1);
    plot(time, waveform, 'b');
    hold on;
    plot(time(N0+1:N0+N), waveform_window, 'r');
    title('Signal with FFT Window');
    xlabel('\fontname{宋体}时间 \fontname{Times new roman}(s)');
    ylabel('\fontname{宋体}电流 \fontname{Times new roman}(A)');
    ylim([-10, 10]);
    setFigureFormat();

    % FFT结果图
    subplot('Position', subplotPosition2);
    bar(freqs_display, waveform_FFT_display_percentage);
    title(sprintf('Fundamental (%.2f Hz) = %.2f, THD = %.2f%%', f0, base_magnitude_waveform, thd_waveform * 100));
    xlabel('\fontname{宋体}频率 \fontname{Times new roman}(Hz)');
    ylabel('\fontname{宋体}幅值(占基波的百分比)');
    xticks(0:200:max_display_freq);
    grid on;
    set(gca, 'GridLineStyle', ':', 'GridAlpha', 0.4, 'GridColor', [0.1, 0.1, 0.1]);

    % 调用格式函数
    setFigureFormat();

    %% 内部格式设置函数
    function setFigureFormat()
        set(gca, 'LineWidth', 0.75);
        set(gca, 'FontName', 'Times New Roman', 'FontSize', 12.5);
        set(gcf, 'Color', 'white');
    end
end
