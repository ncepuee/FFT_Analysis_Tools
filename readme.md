# FFT Analysis Tools

MATLAB GUI for Fourier / THD analysis of MAT and oscilloscope CSV data.

MATLAB 图形界面工具，支持 MAT 文件和示波器 CSV 数据的傅里叶 / THD 分析。

---

## Features / 功能特性

- Load `.mat` (struct / Simulink.SimulationOutput) and oscilloscope `.csv` files
- Load signals directly from MATLAB workspace
- Single-sided amplitude spectrum with fundamental-normalized display
- THD calculation (RMS-based) with selectable method and max frequency
- Spectrum inset zoom view for harmonic detail inspection
- Waveform zoom view with up to 3 independent regions
- CSV single-channel export to Simulink FFT Analyzer compatible MAT format
- Grid / box display toggle, figure export
- Bilingual UI (Chinese / English)
- Standalone Windows installer (MATLAB Runtime R2024b)

---

## Quick Start / 快速开始

### Run in MATLAB

```matlab
% Add project folder to path and launch
runFourierAnalysisApp

% Or directly (if already in project directory)
FourierAnalysisApp
```

### After editing / 修改代码后

```matlab
close all force
clear classes
runFourierAnalysisApp
```

### Standalone Installer / 独立安装包

Download `FFTAnalysisAppInstaller.exe` from [Releases](https://github.com/ncepuee/FFT_Analysis_Tools/releases). First run requires MATLAB Runtime R2024b (~3-4 GB, auto-prompted).

从 [Releases](https://github.com/ncepuee/FFT_Analysis_Tools/releases) 下载 `FFTAnalysisAppInstaller.exe`，首次运行需安装 MATLAB Runtime R2024b（约 3-4 GB，自动提示）。

---

## Supported Data Formats / 支持的数据格式

### MAT Files

Structures with `signal.time` and `signal.signals.values`, including nested `Simulink.SimulationOutput` objects (e.g., `out.Ids`, `out.Iqs`, `out.Uds`).

支持含有 `time` + `signals.values` 的结构体，以及 `Simulink.SimulationOutput` 内的嵌套信号。

### Oscilloscope CSV

Tektronix / MDO style CSV with header metadata and column names (`TIME,CH1,CH4`).

支持示波器导出的 CSV 原始文件，自动识别列名和采样间隔。

---

## FFT Parameters / FFT 参数说明

| Parameter / 参数 | Description / 说明 |
|---|---|
| Fundamental Hz / 基频 | Fundamental frequency, e.g., `50` for power frequency |
| Cycles / 周期数 | Number of fundamental cycles in FFT window |
| Start Time s / 起始时间 | Start time of the FFT window |
| Max Freq Hz / 最大频率 | Maximum frequency displayed in spectrum |
| THD Method / THD 算法 | `matlab` (FFT Analyzer style) or `spectrum` (full spectrum) |
| Max THD Freq / THD 最高频率 | Nyquist or custom upper limit for THD calculation |

THD is computed using RMS definition: `THD = sqrt(sum(Vh_rms.^2)) / V1_rms`

---

## Project Structure / 工程结构

```
FourierAnalysisApp.m       Main GUI application / 主界面
fftAnalyzeSignal.m         FFT computation core / FFT 计算核心
readScopeCsv.m             Oscilloscope CSV parser / 示波器 CSV 解析器
runFourierAnalysisApp.m    Launch wrapper / 启动入口
buildFFTAnalysisSoftware.m MATLAB Compiler build script / 编译脚本
createFFTAnalysisSplash.m  Splash screen generator / 启动画面生成
packageFourierAnalysisApp.m .mlappinstall packaging / 打包工具
UI_README.md               Detailed usage guide (Chinese/English) / 详细使用说明
resources/                 HTML resources and splash image / 资源文件
```

---

## Build from Source / 从源码构建

```matlab
% Build standalone Windows application
buildFFTAnalysisSoftware

% Or package as .mlappinstall for MATLAB Apps panel
packageFourierAnalysisApp
```

---

## License / 许可证

[MIT License](LICENSE) - Copyright (c) 2025-2026 Zhenbin Huang
