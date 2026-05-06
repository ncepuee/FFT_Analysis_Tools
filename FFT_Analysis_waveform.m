%此代码对应大论文图
%Figure(3):图4-22 虚拟阻抗控制前后qZSI系统并网电流i2波形图
%Figure(1):图4-23 虚拟阻抗控制前后qZSI的并网电流傅里叶分析结果
clearvars -except out
close all
uoabc=out.UB1;
i2abc=out.IB1;
time=i2abc.time;
totletime=time(end);
uoa=uoabc.signals.values(:,1);
uob=uoabc.signals.values(:,2);
uoc=uoabc.signals.values(:,3);
i2a=i2abc.signals.values(:,1);
i2b=i2abc.signals.values(:,2);
i2c=i2abc.signals.values(:,3);
% 计算采样频率
dt=time(2)-time(1);%仿真步长
fs=1/dt;%采样频率
f0=50;%用于FFT的基频50Hz;
num_cycles=20; % 希望在FFT中分析的周期数

% FFT窗口的时间长度是周期数除以基频
T=num_cycles/f0;
N=round(T/dt);%采样点数

starttime=2.3;%开始取样时间点

N0=round(starttime/dt);%FFT时间窗的起始点

% 根据窗口长度取信号的一部分用于FFT
uoa_window = uoa(N0+1:N0+N);
i2a_window = i2a(N0+1:N0+N);

uoa_FFT=fft(uoa_window);
i2a_FFT=fft(i2a_window);

% FFT的频率分辨率
df=fs/N;
% 计算频率向量，只需要前半部分
freqs=(0:N/2-1)*df;

% 取FFT的单边频谱的幅值
uoa_FFT = abs(uoa_FFT(1:floor(N/2)))*2/N;
i2a_FFT = abs(i2a_FFT(1:floor(N/2)))*2/N;

% 根据需要显示的频率自动调整显示范围
max_display_freq = 3000;
num= floor(max_display_freq / df) + 1;
freqs_display = freqs(1:num);
uoa_FFT_display = abs(uoa_FFT(1:num));
i2a_FFT_display = abs(i2a_FFT(1:num));

% 计算基波的索引
base_index = round(f0/df)+1; % 基波的索引

% 对于i2a信号的THD计算
base_magnitude_i2a = i2a_FFT(base_index); % 基波幅值
base_rms_i2a =  i2a_FFT(base_index)/sqrt(2);
harmonics_square_sum_i2a = sum(i2a_FFT(2:end).^2) - base_magnitude_i2a^2; % 所有谐波的平方和减去基波的平方
thd_i2a = sqrt(harmonics_square_sum_i2a) / base_magnitude_i2a; % THD计算

% 对于uoa信号的THD计算
base_magnitude_uoa = uoa_FFT(base_index); % 基波幅值
base_rms_uoa =  uoa_FFT(base_index)/sqrt(2);
harmonics_square_sum_uoa = sum(uoa_FFT(2:end).^2) - base_magnitude_uoa^2; % 所有谐波的平方和减去基波的平方
thd_uoa = sqrt(harmonics_square_sum_uoa) / base_magnitude_uoa; % THD计算

% 以uoa信号为例，转换为基波的百分比
uoa_FFT_display_percentage = (uoa_FFT_display/base_magnitude_uoa)*100;
% 以i2a信号为例，转换为基波的百分比
i2a_FFT_display_percentage = (i2a_FFT_display/base_magnitude_i2a)*100;

%%  绘图
%修改伯德图位置
leftMargin = 0.12;
bottomMargin1 = 0.6; % 上方子图的底部边距
bottomMargin2 = 0.12; % 下方子图的底部边距
width = 0.8;%子图的宽
height = 0.32;%子图的高
Fwidth=588; Fheight=441;

%% 电流的FFT计算
figure(1)%i2a

set(gcf, 'Position', [100, 350, Fwidth, Fheight]);% [left, bottom, width, height]
%设置两个子图的大小和位置
subplotPosition1 = [leftMargin, bottomMargin1, width, height]; %[左边距,上方子图的底部位置,子图的宽度,上方子图的高度]
subplotPosition2 = [leftMargin, bottomMargin2, width, height];  %[左边距,下方子图的底部位置,子图的宽度,下方子图的高度]
subplot('Position',subplotPosition1); % 上面的幅度子图
% subplot(2,1,1)
plot(time, i2a, 'Color','#4BACC6'); % 原始信号为蓝色
hold on;
plot(time(N0+1:N0+N), i2a_window, 'Color','#F79646'); % FFT窗口内的信号为红色
title('i2a Signal with FFT Window');
xlabel('Time (s)');
ylabel('Current (p.u.)');
xlim([0,totletime]);
ylim([-10, 10]);
% subplot(2,1,2)
subplot('Position', subplotPosition2);
bar(freqs_display, i2a_FFT_display_percentage);
title(sprintf('Fundamental (50Hz) = %.2f, THD = %.2f%%', base_magnitude_i2a, thd_i2a * 100));
xlabel('Frequency (Hz)');
ylabel('Mag (% of Fundamental)');
% 调整x轴刻度标记的密度
% xticks(0:200:max_display_freq); % 以100Hz为步长设置x轴刻度，调整此步长以改变密度
% yticks(0:4:20); % 以100Hz为步长设置x轴刻度，调整此步长以改变密度
grid on; % 打开网格
set(gca, 'GridLineStyle', ':'); % 设置网格线的样式为点线
set(gca, 'GridAlpha', 0.4); % 设置网格线的透明度
set(gca, 'GridColor', [0.1, 0.1, 0.1]); % 设置网格线的颜色为深灰色

%% 电压的FFT计算
figure(2)%uoa
set(gcf, 'Position', [600, 350, Fwidth, Fheight]);% [left, bottom, width, height]
%设置两个子图的大小和位置
subplotPosition1 = [leftMargin, bottomMargin1, width, height]; %[左边距,上方子图的底部位置,子图的宽度,上方子图的高度]
subplotPosition2 = [leftMargin, bottomMargin2, width, height];  %[左边距,下方子图的底部位置,子图的宽度,下方子图的高度]
subplot('Position',subplotPosition1); % 上面的幅度子图
% subplot(2,1,1)
plot(time, uoa, 'Color','#4BACC6'); % 原始信号为蓝色
hold on;
plot(time(N0+1:N0+N), uoa_window, 'Color','#F79646'); % FFT窗口内的信号为红色
title('uoa Signal with FFT Window');
xlabel('Time (s)');
ylabel('Voltage (p.u.)');
ylim([-2, 2]);
% subplot(2,1,2)
xlim([0,totletime]);
subplot('Position', subplotPosition2);
bar(freqs_display, uoa_FFT_display_percentage);
title(sprintf('Fundamental (50Hz) = %.2f, THD = %.2f%%', base_magnitude_uoa, thd_uoa * 100));
xlabel('Frequency (Hz)');
ylabel('Mag (% of Fundamental)');
% 调整x轴刻度标记的密度
% xticks(0:200:max_display_freq); % 以100Hz为步长设置x轴刻度，调整此步长以改变密度
% yticks(0:4:100); % 以100Hz为步长设置x轴刻度，调整此步长以改变密度
grid on; % 打开网格
set(gca, 'GridLineStyle', ':'); % 设置网格线的样式为点线
set(gca, 'GridAlpha', 0.4); % 设置网格线的透明度
set(gca, 'GridColor', [0.1, 0.1, 0.1]); % 设置网格线的颜色为深灰色
xlim([0, max_display_freq]);


figure(1)%i2a
subplot('Position',subplotPosition1); % 上面的幅度子图
setFigureFormat();
subplot('Position',subplotPosition2); % 上面的幅度子图
setFigureFormat();
figure(2)%uoa
subplot('Position',subplotPosition1); % 上面的幅度子图
setFigureFormat();
subplot('Position',subplotPosition2); % 上面的幅度子图
setFigureFormat();

%% 绘制放大图
figure(3)
Fwidth=600; Fheight=400;
set(gcf, 'Position', [600, 350, Fwidth, Fheight]);% [left, bottom, width, height]
%设置两个子图的大小和位置
%修改伯德图位置
siga=i2a;
sigb=i2b;
sigc=i2c;
leftMargin = 0.1;
bottomMargin1 = 0.58; % 上方子图的底部边距
bottomMargin2 = 0.1; % 下方子图的底部边距
bottomMargin3 = 0.1; % 下方子图的底部边距
widthtop = 0.84;%子图的宽
widthdown = 0.39;%子图的宽
height = 0.35;%子图的高
subplotPosition1 = [leftMargin, bottomMargin1, widthtop, height]; %[左边距,上方子图的底部位置,子图的宽度,上方子图的高度]
subplotPosition2 = [leftMargin, bottomMargin2, widthdown, height];  %[左边距,下方子图的底部位置,子图的宽度,下方子图的高度]
subplotPosition3 = [leftMargin+(widthtop-widthdown), bottomMargin3,widthdown, height];  %[左边距,下方子图的底部位置,子图的宽度,下方子图的高度]
subplot('Position',subplotPosition1); % 上面的幅度子图
% subplot(2,1,1)
plot(time, siga, 'Color', '#0072BD');hold on;
plot(time, sigb, 'Color', '#D95319');hold on;
plot(time, sigc, 'Color', '#EDB120');
% ylim([-60, 60]);
xlabel('Time (s)');
ylabel('Current (p.u.)');
xlim([0.2,totletime]);
ylim([-50, 50]);

line([1 1], ylim(), 'Color', 'k', 'LineStyle', '--'); % 添加虚线
line([1.4 1.4], ylim(), 'Color', 'k', 'LineStyle', '--'); % 添加虚线
line([3 3], ylim(), 'Color', 'k', 'LineStyle', '--'); % 添加虚线
line([3.4 3.4], ylim(), 'Color', 'k', 'LineStyle', '--'); % 添加虚线

legend('i2a', 'i2b', 'i2c', 'Orientation', 'horizontal', 'Location', 'best'); % 图例水平排列，自动最佳位置
setFigureFormat();

subplot('Position',subplotPosition2); % 上面的幅度子图
% subplot(2,1,2)
idx = time >= 1 & time <= 1.4;
plot(time(idx), siga(idx), 'Color', '#0072BD'); hold on;
plot(time(idx), sigb(idx), 'Color', '#D95319'); hold on;
plot(time(idx), sigc(idx), 'Color', '#EDB120'); hold on;
ylabel('Current (p.u.)');
legend('i2a', 'i2b', 'i2c', 'Orientation', 'horizontal', 'Location', 'best'); % 图例水平排列，自动最佳位置
setFigureFormat();
xlim([1,1.4]); 
ylim([-50, 50]);
subplot('Position',subplotPosition3); % 上面的幅度子图
idx = time >= 3 & time <= 3.4;
plot(time(idx), siga(idx), 'Color', '#0072BD'); hold on;
plot(time(idx), sigb(idx), 'Color', '#D95319'); hold on;
plot(time(idx), sigc(idx), 'Color', '#EDB120'); hold on;
xlim([3, 3.4]);
ylim([-3, 3]);

legend('i2a', 'i2b', 'i2c', 'Orientation', 'horizontal', 'Location', 'best'); % 图例水平排列，自动最佳位置
% ylim([-60, 60]);
setFigureFormat();
% %% Figure美化
% 设置当前坐标轴的格式
% figure(1)
% subplot(2,1,1)
% setFigureFormat();
% subplot(2,1,2)
% setFigureFormat();
% figure(2)
% subplot(2,1,1)
% setFigureFormat();
% subplot(2,1,2)
% setFigureFormat();
% figure(4)
% setFigureFormat();
% xlim([0, max_display_freq]);

figure(3)
subplot('Position',subplotPosition1); % 上面的幅度子图
setFigureFormat();
subplot('Position',subplotPosition2); % 上面的幅度子图
setFigureFormat();
subplot('Position',subplotPosition3); % 上面的幅度子图
setFigureFormat();

function setFigureFormat()
    % 设置当前坐标轴的格式
    set(gca, 'LineWidth', 0.75); % 设置边框的线宽为0.75
    set(gca, 'FontName', 'Times New Roman', 'FontSize', 12.5);
    % 设置当前图形窗口的格式
    set(gcf, 'Color', 'white');
end

%% ======== Figure(3): 三放大子图版本 ========
figure(4)
clf
Fwidth = 600; 
Fheight =500;
set(gcf,'Position',[600,350,Fwidth,Fheight],'Color','white');

% siga = uoa;
% sigb = uob;
% sigc = uoc;
siga=i2a;
sigb=i2b;
sigc=i2c;


% --- 子图位置布局 ---
topPos    = [0.08 0.54 0.86 0.38];   % 上方总图
zoomWidth = 0.26;                    % 三子图宽度
zoomHeight= 0.26;                   
gap       = 0.04;

z1Pos = [0.08   0.12 zoomWidth zoomHeight];
z2Pos = [0.38   0.12 zoomWidth zoomHeight];
z3Pos = [0.68   0.12 zoomWidth zoomHeight];

% ===== (1) 总体波形 =====
subplot('Position',topPos)
plot(time, siga,'Color','#0072BD'); hold on;
plot(time, sigb,'Color','#D95319');
plot(time, sigc,'Color','#EDB120');
xlabel('Time (s)');
ylabel('Voltage (p.u.)');

xlim([0 totletime]);
ylim([-25 25]);

% 虚线标注区域
xline(0.4,'--k');xline(0.6,'--k');
xline(1.4,'--k'); xline(1.6,'--k');
xline(2.4,'--k'); xline(2.6,'--k');

legend('i2a','i2b','i2c','Orientation','horizontal','Location','best');
setFigureFormat();

% ===== (2) 放大区域 1（1–1.4s） =====
subplot('Position',z1Pos)
idx = time>=0.4 & time<=0.6;
plot(time(idx), siga(idx),'Color','#0072BD'); hold on;
plot(time(idx), sigb(idx),'Color','#D95319');
plot(time(idx), sigc(idx),'Color','#EDB120');
xlabel('Time (s)');
ylabel('Voltage (p.u.)');
title('Zoom 1: 0.4–0.6 s');
xlim([0.4 0.6]); ylim([-25 25]);
setFigureFormat();

% ===== (3) 放大区域 2（你可调整 2–2.4s） =====
subplot('Position',z2Pos)
idx = time>=1.4 & time<=1.6;
plot(time(idx), siga(idx),'Color','#0072BD'); hold on;
plot(time(idx), sigb(idx),'Color','#D95319');
plot(time(idx), sigc(idx),'Color','#EDB120');
xlabel('Time (s)');
title('Zoom 2: 1.4–1.6 s');
xlim([1.4 1.6]); ylim([-25 25]);
setFigureFormat();

% ===== (4) 放大区域 3（3–3.4s） =====
subplot('Position',z3Pos)
idx = time>=2.4 & time<=2.6;
plot(time(idx), siga(idx),'Color','#0072BD'); hold on;
plot(time(idx), sigb(idx),'Color','#D95319');
plot(time(idx), sigc(idx),'Color','#EDB120');
xlabel('Time (s)');
title('Zoom 3: 2.4–2.6 s');
xlim([2.4 2.6]); ylim([-2 2]);
setFigureFormat();

