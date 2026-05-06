% clear all
% 数据变量一定是带时间的结构体格式!
wave=Station_Pepu;
close all
time =wave.time; %输入时间列向量
waveform =wave.signals.values; % 输入波形的数组列向量
% 计算采样频率
dt = time(2) - time(1); % 仿真步长
fs = 1/dt; % 采样频率
f0 = 50; % 用于FFT的基频50Hz
num_cycles =10; % 希望在FFT中分析的周期数

% FFT窗口的时间长度是周期数除以基频
T = num_cycles / f0;
N = round(T/dt); % 采样点数

starttime = 1; % 开始取样时间点
totletime = time(end);
N0 = round(starttime / dt); % FFT时间窗的起始点

% 根据窗口长度取信号的一部分用于FFT
waveform_window = waveform(N0+1:N0+N);

% 进行FFT变换
waveform_FFT = fft(waveform_window);

% FFT的频率分辨率
df = fs / N;

% 计算频率向量，只需要前半部分
freqs = (0:N/2 - 1) * df;

% 取FFT的单边频谱的幅值
waveform_FFT = abs(waveform_FFT(1:floor(N/2))) * 2 / N;

% 根据需要显示的频率自动调整显示范围
max_display_freq = 2000;
num = floor(max_display_freq / df) + 1;
freqs_display = freqs(1:num);
waveform_FFT_display = waveform_FFT(1:num);

% 计算基波的索引
base_index = round(f0 / df) + 1; % 基波的索引

% 基波幅值计算
base_magnitude_waveform = waveform_FFT(base_index);

% 计算谐波总和，用于THD计算
harmonics_square_sum_waveform = sum(waveform_FFT(2:end).^2) - base_magnitude_waveform^2; 
thd_waveform = sqrt(harmonics_square_sum_waveform) / base_magnitude_waveform; % THD计算

% 将幅值转换为基波的百分比
waveform_FFT_display_percentage = (waveform_FFT_display / base_magnitude_waveform) * 100;

%% 绘图部分
leftMargin = 0.12;
bottomMargin1 = 0.6;
bottomMargin2 = 0.12;
width = 0.8;
height = 0.32;
Fwidth = 588; Fheight = 441;

% 波形图
figure(1)
set(gcf, 'Position', [100, 350, Fwidth, Fheight]); % 设置图像窗口
subplotPosition1 = [leftMargin, bottomMargin1, width, height];
subplotPosition2 = [leftMargin, bottomMargin2, width, height];

% 时间波形图
subplot('Position',subplotPosition1);
plot(time, waveform, 'b'); % 原始信号
hold on;
plot(time(N0+1:N0+N), waveform_window, 'r'); % FFT窗口内的信号
title('Signal with FFT Window');
xlabel('Time (s)');
ylabel('Magnitude');
% xlabel('\fontname{宋体}时间 \fontname{Times new roman}(s)');
% ylabel('\fontname{宋体}电流 \fontname{Times new roman}(A)');
% ylim([-10, 10]);
setFigureFormat();
xlim([0,time(end)])

% FFT 结果图
subplot('Position', subplotPosition2);
bar(freqs_display, waveform_FFT_display_percentage);
title(sprintf('Fundamental (50Hz) = %.2f, THD = %.2f%%', base_magnitude_waveform, thd_waveform * 100));
xlabel('Frequency(Hz)');
ylabel('Mag (% of Fundamental)');
% xlabel('\fontname{宋体}频率 \fontname{Times new roman}(Hz)');
% ylabel('\fontname{宋体}幅值(占基波的百分比)');
% ylim([0, 20]);
xticks(0:400:max_display_freq);
% yticks(0:4:20);
grid on;
ylim([0,thd_waveform*100])
set(gca, 'GridLineStyle', ':', 'GridAlpha', 0.4, 'GridColor', [0.1, 0.1, 0.1]);

% 调用函数统一格式
setFigureFormat();

%% 绘制放大图部分
% 略...

% 设置图形格式的函数
function setFigureFormat()
    % 设置当前坐标轴的格式
    set(gca, 'LineWidth', 0.75);
    set(gca, 'FontName', 'Times New Roman', 'FontSize', 12.5);
    % 设置当前图形窗口的格式
    set(gcf, 'Color', 'white');
end