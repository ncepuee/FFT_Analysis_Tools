# 傅里叶分析 MATLAB UI 使用说明

## 启动方式

在 MATLAB 当前文件夹切换到本工程目录后运行：

```matlab
FourierAnalysisApp
```

如果刚修改过 `FourierAnalysisApp.m`，建议先执行：

```matlab
close all force
clear classes
FourierAnalysisApp
```

## 中英文切换

界面左侧提供“语言 / Language”下拉框：

- 选择 `中文`：显示中文界面。
- 选择 `English`：显示英文界面。

切换语言时，按钮、参数标签、图标题、坐标轴、图例、状态提示和结果表格会同步更新，已经加载的数据和 FFT 结果不会丢失。

## 支持的数据格式

界面支持 `.mat` 和示波器导出的 `.csv` 文件。

### MAT 文件

界面会自动识别 `.mat` 文件中符合以下格式的信号：

```matlab
signal.time
signal.signals.values
```

也支持放在 `out` 结构体下面的 Simulink 输出，例如：

```matlab
out.Station_Pepu.time
out.Station_Pepu.signals.values
```

如果 `signals.values` 是多列矩阵，界面会把每一列识别为一个通道，可以在“通道 / Channel”下拉框中选择。

### 示波器 CSV 文件

支持 Tektronix/MDO 类示波器导出的 CSV 原始文件，文件前面可以包含采样间隔、记录长度、单位等信息，只要数值数据前存在类似下面的列名行：

```text
TIME,CH1,CH4
```

例如 `withoutHPF.csv` 和 `withHPF.csv` 会被识别为：

- `Voltage (CH1) [V]`
- `Current (CH4) [V]`

CSV 第一列时间会自动平移到从 `0` 开始。例如原始时间从 `-5` 开始时，界面内部使用：

```matlab
time = rawTime - rawTime(1);
```

也可以在命令行单独读取 CSV：

```matlab
data = readScopeCsv('withoutHPF.csv');
time = data.time;
voltage = data.waveforms(:, 1);
current = data.waveforms(:, 2);
```

## 参数含义

- `基频 Hz / Fundamental Hz`：基波频率，例如工频信号常用 `50`。
- `周期数 / Cycles`：FFT 截取窗口包含的基波周期数，例如 `10` 表示截取 10 个 50 Hz 周期。
- `起始时间 s / Start Time s`：从该时间点开始截取 FFT 窗口。
- `最大频率 Hz / Max Freq Hz`：频谱图显示的最高频率。

## 输出结果

界面会显示：

- 原始时域波形，并标出 FFT 截取窗口。
- 以基波幅值为 100% 的单边幅频谱。
- 采样频率、采样间隔、频率分辨率、FFT 点数、基波幅值和 THD。

THD 计算采用 RMS 定义：

```matlab
THD = sqrt(sum(Vh_rms.^2)) / V1_rms
```

其中 `V1_rms` 是基波有效值，`Vh_rms` 是 2 次及以上整数谐波的有效值。界面频谱使用单边谱峰值显示，但 THD 内部会转换为 RMS；由于同一正弦分量的 `RMS = peak / sqrt(2)`，用同一套峰值比值和 RMS 比值在数值上等价。

点击“导出结果到工作区 / Export Result to Workspace”后，结果会保存为 MATLAB 工作区变量：

```matlab
FFT_UI_Result
```

## 性能说明

为了避免大 `.mat` 文件反复绘图时卡顿，界面的时域图会对显示数据做降采样；FFT、基波幅值和 THD 计算仍然使用原始完整数据。频谱点数很少时显示柱状图，频谱点数很多时自动切换为轻量曲线显示。

左侧“显示精度 / Plot Detail”控制时域图的显示点数：

- `快速 2万点 / Fast 20k pts`：默认模式，交互最快。
- `精细 20万点 / Fine 200k pts`：波形更密，速度适中。
- `完整 全部点 / Full all pts`：显示全部采样点，用于核对原始波形密度；对 1000 万点 CSV 可能明显卡顿。

注意：该选项只影响界面绘图密度，不影响 CSV 读取、FFT 计算或 THD 计算。

## 工程代码结构

- `fftAnalyzeSignal.m`：只负责 FFT 计算，不创建窗口，便于脚本和 UI 共用。
- `FourierAnalysisApp.m`：负责 UI、语言切换、文件加载、变量选择、绘图和结果导出。
- 原来的 `FFT_Analysis.m`、`performFFT.m` 可以继续作为命令行或论文绘图脚本使用。
