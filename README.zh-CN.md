# FFT Analysis Tools

<p align="center">
  <strong>中文</strong> · <a href="readme.md">English</a>
</p>

<p align="center">
  <img src="https://raw.githubusercontent.com/ncepuee/FFT_Analysis_Tools/master/resources/FFTAnalysisLogo.png" alt="FFT Analysis Tools logo" width="112">
</p>

<p align="center"><strong>面向 MATLAB 的 FFT、谐波和 THD 图形界面、自动化 API 与 Agent 插件。</strong></p>

<p align="center">
  <a href="https://openai.com/codex/"><img alt="Codex Code Support" src="https://img.shields.io/badge/Codex-Code_Support-orange?logo=data:image/svg%2bxml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCI+PHBhdGggZmlsbD0iI2ZmZiIgZD0iTTguMDg2LjQ1N2E2LjEwNSA2LjEwNSAwIDAxMy4wNDYtLjQxNWMxLjMzMy4xNTMgMi41MjEuNzIgMy41NjQgMS43YS4xMTcuMTE3IDAgMDAuMTA3LjAyOWMxLjQwOC0uMzQ2IDIuNzYyLS4yMjQgNC4wNjEuMzY2bC4wNjMuMDMuMTU0LjA3NmMxLjM1Ny43MDMgMi4zMyAxLjc3IDIuOTE4IDMuMTk4LjI3OC42NzkuNDE4IDEuMzg4LjQyMSAyLjEyNmE1LjY1NSA1LjY1NSAwIDAxLS4xOCAxLjYzMS4xNjcuMTY3IDAgMDAuMDQuMTU1IDUuOTgyIDUuOTgyIDAgMDExLjU3OCAyLjg5MWMuMzg1IDEuOTAxLS4wMSAzLjYxNS0xLjE4MyA1LjE0bC0uMTgyLjIyYTYuMDYzIDYuMDYzIDAgMDEtMi45MzQgMS44NTEuMTYyLjE2MiAwIDAwLS4xMDguMTAyYy0uMjU1LjczNi0uNTExIDEuMzY0LS45ODcgMS45OTItMS4xOTkgMS41ODItMi45NjIgMi40NjItNC45NDggMi40NTEtMS41ODMtLjAwOC0yLjk4Ni0uNTg3LTQuMjEtMS43MzZhLjE0NS4xNDUgMCAwMC0uMTQtLjAzMmMtLjUxOC4xNjctMS4wNC4xOTEtMS42MDQuMTg1YTUuOTI0IDUuOTI0IDAgMDEtMi41OTUtLjYyMiA2LjA1OCA2LjA1OCAwIDAxLTIuMTQ2LTEuNzgxYy0uMjAzLS4yNjktLjQwNC0uNTIyLS41NTEtLjgyMWE3Ljc0IDcuNzQgMCAwMS0uNDk1LTEuMjgzIDYuMTEgNi4xMSAwIDAxLS4wMTctMy4wNjQuMTY2LjE2NiAwIDAwLjAwOC0uMDc0LjExNS4xMTUgMCAwMC0uMDM3LS4wNjQgNS45NTggNS45NTggMCAwMS0xLjM4LTIuMjAyIDUuMTk2IDUuMTk2IDAgMDEtLjMzMy0xLjU4OSA2LjkxNSA2LjkxNSAwIDAxLjE4OC0yLjEzMmMuNDUtMS40ODQgMS4zMDktMi42NDggMi41NzctMy40OTMuMjgyLS4xODguNTUtLjMzNC44MDItLjQzOC4yODYtLjEyLjU3My0uMjIuODYxLS4zMDRhLjEyOS4xMjkgMCAwMC4wODctLjA4N0E2LjAxNiA2LjAxNiAwIDAxNS42MzUgMi4zMUM2LjMxNSAxLjQ2NCA3LjEzMi44NDYgOC4wODYuNDU3em0tLjgwNCA3Ljg1YS44NDguODQ4IDAgMDAtMS40NzMuODQybDEuNjk0IDIuOTY1LTEuNjg4IDIuODQ4YS44NDkuODQ5IDAgMDAxLjQ2Ljg2NGwxLjk0LTMuMjcyYS44NDkuODQ5IDAgMDAuMDA3LS44NTRsLTEuOTQtMy4zOTN6bTUuNDQ2IDYuMjRhLjg0OS44NDkgMCAwMDAgMS42OTVoNC44NDhhLjg0OS44NDkgMCAwMDAtMS42OTZoLTQuODQ4eiIvPjwvc3ZnPg==&logoColor=white"></a>
  <a href="https://openai.com/"><img alt="GPT 5.6 Sol Agent used at v2.1.0" src="https://img.shields.io/badge/GPT--5.6--Sol-Agent_used%40v2.1.0-412991?logo=data:image/svg%2bxml;base64,PHN2ZyByb2xlPSJpbWciIHZpZXdCb3g9IjAgMCAyNCAyNCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48dGl0bGU+T3BlbkFJPC90aXRsZT48cGF0aCBmaWxsPSIjZmZmIiBkPSJNMjIuMjgxOSA5LjgyMTFhNS45ODQ3IDUuOTg0NyAwIDAgMC0uNTE1Ny00LjkxMDggNi4wNDYyIDYuMDQ2MiAwIDAgMC02LjUwOTgtMi45QTYuMDY1MSA2LjA1NTEgMCAwIDAgNC45ODA3IDQuMTgxOGE1Ljk4NDcgNS45ODQ3IDAgMCAwLTMuOTk3NyAyLjkgNi4wNDYyIDYuMDQ2MiAwIDAgMCAuNzQyNyA3LjA5NjYgNS45OCA1Ljk4IDAgMCAwIC41MTEgNC45MTA3IDYuMDUxIDYuMDUxIDAgMCAwIDYuNTE0NiAyLjkwMDFBNS45ODQ3IDUuOTg0NyAwIDAgMCAxMy4yNTk5IDI0YTYuMDU1NyA2LjA1NTcgMCAwIDAgNS43NzE4LTQuMjA1OCA1Ljk4OTQgNS45ODk0IDAgMCAwIDMuOTk3Ny0yLjkwMDEgNi4wNTU3IDYuMDU1NyAwIDAgMC0uNzQ3NS03LjA3Mjl6bS05LjAyMiAxMi42MDgxYTQuNDc1NSA0LjQ3NTUgMCAwIDEtMi44NzY0LTEuMDQwOGwuMTQxOS0uMDgwNCA0Ljc3ODMtMi43NTgyYS43OTQ4Ljc5NDggMCAwIDAgLjM5MjctLjY4MTN2LTYuNzM2OWwyLjAyIDEuMTY4NmEuMDcxLjA3MSAwIDAgMSAuMDM4LjA1MnY1LjU4MjZhNC41MDQgNC41MDQgMCAwIDEtNC40OTQ1IDQuNDk0NHptLTkuNjYwNy00LjEyNTRhNC40NzA4IDQuNDcwOCAwIDAgMS0uNTM0Ni0zLjAxMzdsLjE0Mi4wODUyIDQuNzgzIDIuNzU4MmEuNzcxMiA3NzEyIDAgMCAwIC43ODA2IDBsNS44NDI4LTMuMzY4NXYyLjMzMjRhLjA4MDQuMDgwNCAwIDAgMS0uMDMzMi4wNjE1TDkuNzQgMTkuOTUwMmE0LjQ5OTIgNC40OTkyIDAgMCAxLTYuMTQwOC0xLjY0NjR6TTIuMzQwOCA3Ljg5NTZhNC40ODUgNC40ODUgMCAwIDEgMi4zNjU1LTEuOTcyOFYxMS42YS43NjY0Ljc2NjQgMCAwIDAgLjM4NzkuNjc2NWw1LjgxNDQgMy4zNTQzLTIuMDIwMSAxLjE2ODVhLjA3NTcuMDc1NyAwIDAgMS0uMDcxIDBsLTQuODMwMy0yLjc4NjVBNC41MDQgNC41MDQgMCAwIDEgMi4zNDA4IDcuODcyem0xNi41OTYzIDMuODU1OEwxMy4xMDM4IDguMzY0IDE1LjExOTIgNy4yYS4wNzU3LjA3NTcgMCAwIDEgLjA3MSAwbDQuODMwMyAyLjc5MTNhNC40OTQ0IDQuNDk0NCAwIDAgMS0uNjc2NSA4LjEwNDJ2LTUuNjc3MmEuNzkuNzkgMCAwIDAtLjQwNy0uNjY3em0yLjAxMDctMy4wMjMxbC0uMTQyLS4wODUyLTQuNzczNS0yLjc4MThhLjc3NTkuNzc1OSAwIDAgMC0uNzg1NCAwTDkuNDA5IDkuMjI5N1Y2Ljg5NzRhLjA2NjIuMDY2MiAwIDAgMSAuMDI4NC0uMDYxNWw0LjgzMDMtMi43ODY2YTQuNDk5MiA0LjQ5OTIgMCAwIDEgNi42ODAyIDQuNjZ6TTguMzA2NSAxMi44NjNsLTIuMDItMS4xNjM4YS4wODA0LjA4MDQgMCAwIDEtLjAzOC0uMDU2N1Y2LjA3NDJhNC40OTkyIDQuNDk5MiAwIDAgMSA3LjM3NTctMy40NTM3bC0uMTQyLjA4MDVMOC43MDQgNS40NTlhLjc5NDguNzk0OCAwIDAgMC0uMzkyNy42ODEzem0xLjA5NzYtMi4zNjU0bDIuNjAyLTEuNDk5OCAyLjYwNjkgMS40OTk4djIuOTk5NGwtMi41OTc0IDEuNDk5Ny0yLjYwNjctMS40OTk3WiIvPjwvc3ZnPg==&logoColor=white"></a>
  <a href="https://www.hust.edu.cn/"><img alt="HUST 创建地点" src="https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fncepuee%2FFT_Analysis_Tools%2Fmaster%2Fresources%2FHUSTBadge.json"></a>
</p>

<p align="center">
  <a href="https://github.com/ncepuee/FFT_Analysis_Tools/actions/workflows/ci.yml"><img alt="MATLAB CI" src="https://github.com/ncepuee/FFT_Analysis_Tools/actions/workflows/ci.yml/badge.svg"></a>
  <a href="https://github.com/ncepuee/FFT_Analysis_Tools/releases/latest"><img alt="最新版本" src="https://img.shields.io/github/v/release/ncepuee/FFT_Analysis_Tools?display_name=tag&logo=github"></a>
  <a href="https://github.com/ncepuee/FFT_Analysis_Tools/blob/master/LICENSE"><img alt="MIT 许可证" src="https://img.shields.io/github/license/ncepuee/FFT_Analysis_Tools?color=blue"></a>
  <img alt="MATLAB R2020b+" src="https://img.shields.io/badge/MATLAB-R2020b%2B-orange?logo=mathworks&logoColor=white">
  <img alt="Windows macOS Linux" src="https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-0078D4">
  <a href="https://github.com/ncepuee/FFT_Analysis_Tools/releases/tag/v2.1.0"><img alt="Agent 插件" src="https://img.shields.io/badge/Agent_plugin-v2.1.0-FF8A00"></a>
</p>

FFT Analysis Tools 是一个面向电力电子和示波器波形分析的本地 MATLAB 工具包。你可以使用 GUI 完成交互式分析，使用无界面 API 批量处理，也可以通过 Codex 或 Claude Code 中的 Agent 插件进行自然语言分析。

> **当前版本：** [v2.1.0](https://github.com/ncepuee/FFT_Analysis_Tools/releases/tag/v2.1.0)，新增 `fftAnalyzeFile`、跨客户端 `analyze-fft` Skill，以及 Claude Code 的 `fft-analyst` Agent。MATLAB 源码方式支持跨平台运行；编译安装包则按目标操作系统分别构建。

## 核心能力

| 能力 | 说明 |
|---|---|
| MATLAB GUI | 加载文件或扫描 MATLAB 工作区，选择信号和通道，查看时域与频域结果。 |
| FFT 与 THD | 计算单边幅值频谱、基波、谐波以及基于 RMS 的 THD。 |
| 两种 THD 算法 | 支持 `matlab`/Simscape FFT Analyzer 风格和 `spectrum` 全频谱算法。 |
| 波形局部放大 | 支持最多三个可配置的局部时间区间，并弹出独立 MATLAB 图窗。 |
| 频谱 Inset | 插入或删除可配置的频率局部放大图，便于观察谐波细节。 |
| 自动化 API | 不打开 GUI，直接分析 MAT 文件和示波器 CSV 文件。 |
| Agent 工作流 | 让 Codex 或 Claude Code 调用 MATLAB API，并解释谐波与 THD。 |
| 原生安装包 | 从 GitHub Release 下载 Windows、macOS 或 Linux 安装包。 |

## 使用方式选择

| 使用方式 | 适用场景 | 入口 |
|---|---|---|
| GUI | 交互式选择信号和生成图表 | `runFourierAnalysisApp` |
| MATLAB API | 批处理和可复现实验脚本 | `fftAnalyzeFile` / `fftAnalyzeSignal` |
| Agent 插件 | 用自然语言分析并解释结果 | `analyze-fft` |
| 独立应用 | 安装 MATLAB Runtime 后无需 MATLAB 许可证运行 | Release 中对应平台的安装包 |

## 工作流程

~~~mermaid
flowchart LR
    A["MAT / CSV / 工作区信号"] --> B["数据加载\nreadScopeCsv 或 MAT 扫描"]
    B --> C["FFT 与 THD 核心\nfftAnalyzeSignal"]
    C --> D["GUI\nFourierAnalysisApp"]
    C --> E["自动化 API\nfftAnalyzeFile"]
    E --> F["Codex / Claude Code\nanalyze-fft Agent Skill"]
~~~

## 环境要求

### MATLAB 源码方式

- MATLAB R2020b 或更高版本。
- GUI 需要 `uifigure` 和 `uigridlayout` 支持。
- MATLAB 支持的 Windows、macOS 或 Linux 系统。
- Simulink 不是必需项；只有使用 Simulink 特定信号对象和工作流时才需要。

### 编译独立应用

- 编译机器需要 MATLAB Compiler。
- 应在目标操作系统上构建；编译后的应用不是跨平台可执行文件。
- 没有 MATLAB 的电脑需要 MATLAB Runtime R2024b，安装程序会提示下载。

### Agent 工作流

- Codex 或 Claude Code。
- 通过 MATLAB MCP Server 或非交互式 MATLAB 执行 MATLAB。
- 插件不会打包机器专用的 MATLAB MCP 路径或凭据，每台机器需要单独配置 MATLAB 访问方式。

## 安装

### 方式一：在 MATLAB 中运行

~~~powershell
git clone https://github.com/ncepuee/FFT_Analysis_Tools.git
cd FFT_Analysis_Tools
~~~

在 MATLAB 中运行：

~~~matlab
runFourierAnalysisApp
~~~

修改 MATLAB 类文件后，建议重启类定义和应用：

~~~matlab
close all force
clear classes
runFourierAnalysisApp
~~~

### 方式二：安装编译应用

从 [Releases](https://github.com/ncepuee/FFT_Analysis_Tools/releases) 下载对应平台的安装包：

- Windows：`FFTAnalysisAppInstaller.exe`。
- macOS：`FFTAnalysisAppInstaller-macos.zip`。
- Linux：`FFTAnalysisAppInstaller-linux.zip`。

解压后按对应平台的安装程序说明操作。没有 MATLAB 的电脑需要 MATLAB Runtime R2024b。这些是按系统分别构建的安装包，不是一个通用可执行文件。

### 方式三：安装 Agent 插件

#### Codex

从本地仓库安装：

~~~powershell
codex plugin marketplace add .
codex plugin add fft-analysis-agent@personal
~~~

从 GitHub 标签版本安装：

~~~powershell
codex plugin marketplace add ncepuee/FFT_Analysis_Tools --ref v2.1.0
codex plugin add fft-analysis-agent@personal
~~~

启动新的 Codex 任务后，让 Codex 使用 `$analyze-fft`。

#### Claude Code

从本地仓库安装：

~~~powershell
claude plugin marketplace add .
claude plugin install fft-analysis-agent@fft-analysis-tools
~~~

从 GitHub 标签版本安装：

~~~powershell
claude plugin marketplace add ncepuee/FFT_Analysis_Tools@v2.1.0
claude plugin install fft-analysis-agent@fft-analysis-tools
~~~

更多说明见 [`plugins/fft-analysis-agent/README.md`](plugins/fft-analysis-agent/README.md)。

## 快速开始

### GUI 分析

1. 在 MATLAB 中运行 `runFourierAnalysisApp`。
2. 加载 `.mat` 或示波器 `.csv` 文件，或者点击“识别工作区”。
3. 选择信号和通道。
4. 设置基频、周期数、FFT 起始时间和频谱显示上限。
5. 点击“分析”，查看波形、频谱、谐波和 THD。
6. 需要观察局部细节时，使用波形放大或频谱 Inset 功能。

### 文件 API

~~~matlab
addpath("path/to/FFT_Analysis_Tools");

out = fftAnalyzeFile("capture.csv", ...
    Signal="CH1", ...
    FundamentalFrequency=50, ...
    NumCycles=10, ...
    StartTime=0, ...
    MaxDisplayFrequency=3000, ...
    ThdMethod="matlab", ...
    ThdMaxFrequency=Inf);

disp(out.summary)
disp(out.harmonics)
~~~

返回结果包括：

- `out.source`：源文件、信号路径、通道和元数据。
- `out.parameters`：实际使用的分析参数。
- `out.summary`：采样率、FFT 分辨率、基波幅值和 THD 百分比。
- `out.harmonics`：谐波次数、实际频率、幅值及相对基波百分比。
- `out.analysis`：完整单边频谱和 FFT 窗口结果。

### 直接数组 API

~~~matlab
result = fftAnalyzeSignal(time(:), waveform(:), ...
    50, 10, 0, 3000, "matlab", Inf);
~~~

## 支持的数据

### MAT 文件

支持 `timeseries`、包含 `time` 和 `signals.values` 的结构体，以及嵌套的 `Simulink.SimulationOutput` 类容器。如果文件包含多个候选信号或多列通道，API 会要求明确选择，避免静默使用错误信号。

### 示波器 CSV

支持前面带元数据、并包含 `TIME,CH1,CH4` 等表头的 Tektronix/MDO 风格 CSV 文件。解析器会识别通道名称、信号标签、采样信息和波形列。

## FFT 与 THD 约定

FFT 窗口包含指定数量的基波周期。实现使用矩形窗，因此非相干采样会产生频谱泄漏，并影响全频谱 THD。

- `matlab`：遵循本工程兼容 Simscape Electrical FFT Analyzer 的约定，统计预期基波以上、直到 `ThdMaxFrequency` 的成分。
- `spectrum`：统计除基波外的所有非直流频谱成分，对次谐波、间谐波、噪声和泄漏更敏感。

两种算法均采用 RMS 定义：

~~~text
THD = sqrt(sum(harmonic_rms.^2)) / fundamental_rms
~~~

比较不同信号时，请保持基频、周期数、起始时间和 THD 频率上限一致。

## 工程结构

~~~text
FFT_Analysis_Tools/
├── FourierAnalysisApp.m          # MATLAB 主 GUI
├── fftAnalyzeFile.m              # MAT/CSV 无界面自动化 API
├── fftAnalyzeSignal.m            # FFT 与 THD 计算核心
├── readScopeCsv.m                # 示波器 CSV 解析器
├── runFourierAnalysisApp.m       # MATLAB 启动入口
├── buildFFTAnalysisSoftware.m    # MATLAB Compiler 编译脚本
├── packageFourierAnalysisApp.m   # App 打包工具
├── createFFTAnalysisSplash.m     # 启动画面生成器
├── createFigureBestFftInset.m    # FigureBest MagInset 辅助工具
├── validateFigureExportWithCsv.m # 图形导出验证工具
├── .github/workflows/             # MATLAB CI 和多平台发布工作流
├── scripts/archive_installer.py   # Release 安装包归档工具
├── UI_README.md                  # GUI 详细说明
├── RELEASE_NOTES_v2.1.0.md      # 当前版本说明
├── plugins/fft-analysis-agent/   # Codex 和 Claude Code 插件
└── resources/                    # 启动画面和 About HTML 资源
~~~

## 从源码构建

只要安装 MATLAB R2020b 或更高版本，源码可在 Windows、macOS 和 Linux 上运行。将工程目录加入 MATLAB 路径后运行：

~~~matlab
runFourierAnalysisApp
~~~

如果要为当前操作系统生成独立安装包，需要 MATLAB Compiler：

~~~matlab
buildFFTAnalysisSoftware
~~~

如果需要打包到 MATLAB Apps 面板：

~~~matlab
packageFourierAnalysisApp
~~~

构建产物写入 `dist/`，该目录已加入版本控制忽略列表。构建脚本会自动选择当前系统的原生编译入口，并生成带平台名称的安装目录。推送 `v*` 标签后，`.github/workflows/release.yml` 会创建 GitHub Release；该流程需要仓库 Secret `MLM_LICENSE_TOKEN`，因为 MATLAB Compiler 属于转换产品。

## CI 与多平台发布

- `.github/workflows/ci.yml` 会在 Push 和 Pull Request 时，在 Windows、macOS、Linux 上运行 MATLAB 单元测试。
- `.github/workflows/release.yml` 会在推送 `v*` 标签时，在三种 GitHub Runner 上分别生成原生安装包。
- 安装了 MATLAB 后，MATLAB 源码和 API 可在三种系统上运行。
- 编译应用绑定构建时的操作系统，不能交叉编译成一个通用安装包。
- Release 构建使用 MATLAB R2024b，并需要仓库 Secret `MLM_LICENSE_TOKEN`。

## 隐私与本地数据

- 分析过程在本地完成，本项目不会上传 MAT/CSV 实验数据。
- 仓库不包含实验数据、MATLAB 工作区转储、凭据或机器专用 MCP 配置。
- 不要提交示波器采集文件、私有仿真结果、MATLAB Runtime 文件或本地 Agent 设置。
- 如果外部客户端开启请求日志，日志可能包含提示词、波形或工具结果，应按敏感数据处理。

## 许可证与作者

本项目采用 [MIT License](LICENSE)。

Copyright (c) 2025-2026 Zhenbin Huang。

- [ORCID](https://orcid.org/0000-0002-0628-0387)
- [LinkedIn](https://www.linkedin.com/in/zhenbin-huang/)

FFT Analysis Tools 是独立项目，不是 MathWorks、Simulink、Codex 或 Claude Code 的官方产品。

## 发布与文档

- [最新版本](https://github.com/ncepuee/FFT_Analysis_Tools/releases/latest)
- [v2.1.0 发布说明](RELEASE_NOTES_v2.1.0.md)
- [GUI 详细文档](UI_README.md)
- [Agent 插件文档](plugins/fft-analysis-agent/README.md)
