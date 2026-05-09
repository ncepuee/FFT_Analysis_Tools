# 傅里叶分析 MATLAB UI 使用说明

## 启动方式

在 MATLAB 当前文件夹切换到本工程目录后运行：

```matlab
runFourierAnalysisApp
```

`runFourierAnalysisApp` 会自动把本工程目录加入 MATLAB path，然后启动 `FourierAnalysisApp`。如果已经确认 MATLAB 当前目录就是本工程目录，也可以直接运行：

```matlab
FourierAnalysisApp
```

如果刚修改过 `FourierAnalysisApp.m`，建议先执行：

```matlab
close all force
clear classes
runFourierAnalysisApp
```

如果需要生成 MATLAB Apps 面板可安装的 `.mlappinstall`，运行：

```matlab
packageFourierAnalysisApp
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

如果 `.mat` 文件中保存的是 `Simulink.SimulationOutput` 对象，例如顶层变量为 `out`，界面会自动执行类似下面的扫描逻辑：

```matlab
names = who(out);
signal = out.get(name);
```

因此 `out.mat` 中的 `out.Ids`、`out.Iqs`、`out.Uds`、`out.Uqs`、`out.i2a`、`out.uoa` 等只要包含：

```matlab
signal.time
signal.signals.values
```

都会自动出现在“信号变量 / Signal”下拉框中。

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

### 导出为 Simulink FFT Analyzer 可识别的 MAT

加载 CSV 后，点击“导出 CSV 单路为 FFT MAT / Export One CSV Channel to FFT MAT”。如果 CSV 里有多路通道，例如 `CH1` 到 `CH4`，软件会先弹出列表，要求选择其中一路信号；导出的 MAT 文件只包含这一列信号。

导出的结构参考 `i2abc.mat`：

```matlab
scope_CH1.time
scope_CH1.signals.values
scope_CH1.signals.dimensions
scope_CH1.signals.label
scope_CH1.blockName
```

其中 `signals.values` 是单列向量，`signals.dimensions = 1`，这样更贴近 Simulink/Powergui FFT Analyzer 对单路输入信号的识别习惯。

## 参数含义

- `基频 Hz / Fundamental Hz`：基波频率，例如工频信号常用 `50`。
- `周期数 / Cycles`：FFT 截取窗口包含的基波周期数，例如 `10` 表示截取 10 个 50 Hz 周期。
- `起始时间 s / Start Time s`：从该时间点开始截取 FFT 窗口。
- `最大频率 Hz / Max Freq Hz`：频谱图显示的最高频率。
- `THD 算法 / THD Method`：`MATLAB 原版`按 FFT Analyzer 风格统计基波以上频率成分；`全频谱`统计除直流和基波外的全部显示/采样频谱成分。
- `THD 最高频率 / Max THD Freq`：选择 `奈奎斯特频率` 时 THD 计算到采样允许的最高频率；选择 `同最大频率` 时 THD 只统计到“最大频率 Hz”。

## 输出结果

界面会显示：

- 原始时域波形，并标出 FFT 截取窗口。
- 以基波幅值为 100% 的单边幅频谱。
- 采样频率、采样间隔、频率分辨率、FFT 点数、基波幅值、当前 THD 算法和 THD。

THD 计算采用 RMS 定义：

```matlab
THD = sqrt(sum(Vh_rms.^2)) / V1_rms
```

其中 `V1_rms` 是基波有效值，`Vh_rms` 是参与当前 THD 算法统计的频率成分有效值。界面频谱和结果表显示单边谱幅值；THD 内部按 RMS 定义计算。由于同一正弦分量的 `RMS = amplitude / sqrt(2)`，同一批频率成分用幅值比值和 RMS 比值在数值上等价。

点击“导出结果到工作区 / Export Result to Workspace”后，结果会保存为 MATLAB 工作区变量：

```matlab
FFT_UI_Result
```

## 频谱局部放大

完成 FFT 分析后，可以在“频谱局部放大 / Spectrum Inset”区域填写需要放大的频段，例如：

```text
40-100, 2400-2800
```

多个频段可用英文逗号、中文逗号、分号或换行分隔，一次最多显示 6 个局部放大区域。Y 轴下限和上限可以留空，留空时每个局部放大区域会按该频段内的最大幅值自动缩放；如果手动填写 Y 轴上下限，则所有局部放大区域使用同一套 Y 轴范围。点击“在频谱图中显示局部放大 / Show Spectrum Insets”后，局部放大框会直接叠加在当前频谱图上。

## 波形局部放大

左侧勾选“启用波形局部放大 / Enable Waveform Zoom”后，才会展开详细配置界面。该功能用于对当前信号和当前通道绘制独立放大图。

操作方式：

- 先加载数据，并在“信号变量 / Signal”和“通道 / Channel”中选好要观察的波形。
- 勾选“启用波形局部放大 / Enable Waveform Zoom”。
- 填写“放大区 1”的起点和终点时间。
- Y 下限和 Y 上限可以留空，留空表示自动缩放。
- “放大区 2”和“放大区 3”是可选项；起点和终点都留空时跳过该放大区。
- 点击“绘制放大图 / Draw Zoom Figure”后，会弹出普通 MATLAB `figure`。

弹出的图包含：

- 上方：整体波形，并用竖向虚线标出放大区边界。
- 下方：根据有效放大区数量自适应绘制 1、2 或 3 个局部放大波形。3 个放大区时采用三子图横向布局，参考 `FFT_Analysis_waveform.m` 的三放大子图版本。

该功能直接复用已加载的 `CurrentTime` 和 `CurrentWaveform`，不会重新读取 CSV/MAT 文件。整体图的显示密度受“显示精度 / Plot Detail”控制。

弹出 figure 字体规则：

- 如果文本里同时包含中文和英文/数字/单位，中文段使用宋体，英文/数字/单位段使用 Times New Roman。
- 如果文本全部是英文，则全部使用 Times New Roman。
- 主 UI 控件保持 MATLAB 默认字体样式。

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
