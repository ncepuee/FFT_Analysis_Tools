# FFT Analysis Tools

<p align="center">
  <a href="README.zh-CN.md">中文</a> · <strong>English</strong>
</p>

<p align="center">
  <img src="https://raw.githubusercontent.com/ncepuee/FFT_Analysis_Tools/master/resources/FFTAnalysisSplash.png" alt="FFT Analysis Tools" width="520">
</p>

<p align="center"><strong>MATLAB GUI, automation API, and Agent plugin for FFT, harmonics, and THD analysis.</strong></p>

<p align="center">
  <a href="https://openai.com/codex/"><img alt="Codex Code Support" src="https://img.shields.io/badge/Codex-Code%20Support-FF6B35?logo=openai&logoColor=white"></a>
  <a href="https://openai.com/"><img alt="GPT 5.6 Sol Agent used at v2.1.0" src="https://img.shields.io/badge/GPT--5.6--Sol-Agent%20used%40v2.1.0-412991?logo=openai&logoColor=white"></a>
</p>

<p align="center">
  <a href="https://github.com/ncepuee/FFT_Analysis_Tools/actions/workflows/ci.yml"><img alt="MATLAB CI" src="https://github.com/ncepuee/FFT_Analysis_Tools/actions/workflows/ci.yml/badge.svg"></a>
  <a href="https://github.com/ncepuee/FFT_Analysis_Tools/releases/latest"><img alt="Latest release" src="https://img.shields.io/github/v/release/ncepuee/FFT_Analysis_Tools?display_name=tag&logo=github"></a>
  <a href="https://github.com/ncepuee/FFT_Analysis_Tools/blob/master/LICENSE"><img alt="MIT license" src="https://img.shields.io/github/license/ncepuee/FFT_Analysis_Tools?color=blue"></a>
  <img alt="MATLAB R2020b+" src="https://img.shields.io/badge/MATLAB-R2020b%2B-orange?logo=mathworks">
  <img alt="Windows macOS Linux" src="https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-0078D4">
  <a href="https://github.com/ncepuee/FFT_Analysis_Tools/releases/tag/v2.1.0"><img alt="Agent plugin" src="https://img.shields.io/badge/Agent_plugin-v2.1.0-FF8A00"></a>
</p>

FFT Analysis Tools is a local-first MATLAB toolkit for power-electronics and oscilloscope waveform analysis. Use the graphical application for interactive work, the non-GUI API for reproducible automation, or the bundled Agent plugin from Codex and Claude Code.

> **Current release:** [v2.1.0](https://github.com/ncepuee/FFT_Analysis_Tools/releases/tag/v2.1.0) adds `fftAnalyzeFile`, a shared `analyze-fft` Skill, and the `fft-analyst` Claude Code agent. The MATLAB source workflow is cross-platform; compiled packages are built natively for each operating system.

## Core Capabilities

| Capability | Description |
|---|---|
| MATLAB GUI | Load files or scan the MATLAB workspace, select signals and channels, and inspect time-domain and spectral results. |
| FFT and THD | Calculate single-sided amplitude spectra, fundamental values, harmonics, and RMS-based THD. |
| THD methods | Compare `matlab`/Simscape FFT Analyzer-style THD with `spectrum` full-spectrum THD. |
| Waveform zoom | Plot up to three configurable local time regions in a standalone MATLAB figure. |
| Spectrum inset | Insert and delete configurable frequency insets for harmonic inspection. |
| Automation API | Analyze MAT and oscilloscope CSV files without opening the GUI. |
| Agent workflow | Ask Codex or Claude Code to run the MATLAB API and explain harmonics and THD. |
| Native packages | Download a Windows, macOS, or Linux package from a GitHub Release. |

## Choose a Workflow

| Workflow | Best for | Entry point |
|---|---|---|
| GUI | Interactive signal selection and publication-quality plots | `runFourierAnalysisApp` |
| MATLAB API | Batch analysis and reproducible scripts | `fftAnalyzeFile` / `fftAnalyzeSignal` |
| Agent plugin | Natural-language analysis and engineering interpretation | `analyze-fft` |
| Standalone app | Running without a MATLAB license after installing MATLAB Runtime | Platform package in a release |

## Architecture

~~~mermaid
flowchart LR
    A["MAT / CSV / workspace signal"] --> B["Loader\nreadScopeCsv or MAT scanner"]
    B --> C["FFT and THD core\nfftAnalyzeSignal"]
    C --> D["GUI\nFourierAnalysisApp"]
    C --> E["Automation API\nfftAnalyzeFile"]
    E --> F["Codex / Claude Code\nanalyze-fft Agent Skill"]
~~~

## Requirements

### MATLAB source workflow

- MATLAB R2020b or later.
- `uifigure` and `uigridlayout` support for the GUI.
- Windows, macOS, or Linux supported by the installed MATLAB release.
- Simulink is optional; it is only needed for Simulink-specific signal objects and workflows.

### Standalone compiled application

- MATLAB Compiler on the build machine.
- Build on the target operating system; the compiled application is not cross-platform.
- MATLAB Runtime R2024b on machines without MATLAB. The installer prompts for the Runtime download.

### Agent workflow

- Codex or Claude Code.
- MATLAB available through MATLAB MCP Server or non-interactive MATLAB execution.
- The plugin does not bundle machine-specific MCP paths or credentials; configure MATLAB access separately on each machine.

## Installation

### Option 1: Run from MATLAB

Clone the repository and open MATLAB in the project folder:

~~~powershell
git clone https://github.com/ncepuee/FFT_Analysis_Tools.git
cd FFT_Analysis_Tools
~~~

~~~matlab
runFourierAnalysisApp
~~~

After editing MATLAB class code, restart the class and app:

~~~matlab
close all force
clear classes
runFourierAnalysisApp
~~~

### Option 2: Install a compiled application

Download the matching package from [Releases](https://github.com/ncepuee/FFT_Analysis_Tools/releases):

- `FFTAnalysisAppInstaller.exe` for Windows.
- `FFTAnalysisAppInstaller-macos.zip` for macOS.
- `FFTAnalysisAppInstaller-linux.zip` for Linux.

Extract the package and follow the platform installer instructions. Machines without MATLAB need MATLAB Runtime R2024b. These are native packages, not a single universal executable.

### Option 3: Install the Agent plugin

#### Codex

From a local checkout:

~~~powershell
codex plugin marketplace add .
codex plugin add fft-analysis-agent@personal
~~~

From the tagged release:

~~~powershell
codex plugin marketplace add ncepuee/FFT_Analysis_Tools --ref v2.1.0
codex plugin add fft-analysis-agent@personal
~~~

Start a new task and ask Codex to use `$analyze-fft`.

#### Claude Code

For a local checkout:

~~~powershell
claude plugin marketplace add .
claude plugin install fft-analysis-agent@fft-analysis-tools
~~~

For a tagged release:

~~~powershell
claude plugin marketplace add ncepuee/FFT_Analysis_Tools@v2.1.0
claude plugin install fft-analysis-agent@fft-analysis-tools
~~~

The plugin files and additional instructions are in [`plugins/fft-analysis-agent/README.md`](plugins/fft-analysis-agent/README.md).

## Quick Start

### GUI analysis

1. Run `runFourierAnalysisApp` in MATLAB.
2. Load a `.mat` or oscilloscope `.csv` file, or click **Scan Workspace**.
3. Select the signal and channel.
4. Set the fundamental frequency, cycle count, FFT start time, and display frequency.
5. Click **Analyze** to display the waveform, spectrum, harmonics, and THD.
6. Use waveform zoom or spectrum inset controls when local details are needed.

### File API

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

The output contains:

- `out.source`: source file, signal path, channel, and metadata.
- `out.parameters`: effective analysis parameters.
- `out.summary`: sampling rate, FFT resolution, fundamental magnitude, and THD percentages.
- `out.harmonics`: harmonic order, actual frequency, magnitude, and percentage of the fundamental.
- `out.analysis`: complete single-sided spectrum and FFT-window result.

### Direct array API

~~~matlab
result = fftAnalyzeSignal(time(:), waveform(:), ...
    50, 10, 0, 3000, "matlab", Inf);
~~~

## Supported Inputs

### MAT files

The loader recognizes `timeseries`, structures containing `time` and `signals.values`, and nested `Simulink.SimulationOutput`-like containers. Multi-signal and multi-column files require explicit selection when the API cannot infer the intended signal safely.

### Oscilloscope CSV files

Tektronix/MDO-style files with metadata before a header such as `TIME,CH1,CH4` are supported. The parser identifies channel names, labels, sampling information, and waveform columns.

## FFT and THD Conventions

The FFT window contains the requested number of fundamental cycles. The implementation uses a rectangular window, so non-coherent sampling can produce leakage and affect full-spectrum THD.

- `matlab`: follows this project's Simscape Electrical FFT Analyzer-compatible convention and sums components above the expected fundamental up to `ThdMaxFrequency`.
- `spectrum`: sums non-DC spectrum components other than the fundamental, making it more sensitive to subharmonics, interharmonics, noise, and leakage.

Both methods use the RMS definition:

~~~text
THD = sqrt(sum(harmonic_rms.^2)) / fundamental_rms
~~~

When comparing signals, keep the fundamental frequency, cycle count, start time, and THD limits identical.

## Project Structure

~~~text
FFT_Analysis_Tools/
├── FourierAnalysisApp.m          # Main MATLAB GUI
├── fftAnalyzeFile.m              # Non-GUI MAT/CSV automation API
├── fftAnalyzeSignal.m            # FFT and THD computation core
├── readScopeCsv.m                # Oscilloscope CSV parser
├── runFourierAnalysisApp.m       # MATLAB launch wrapper
├── buildFFTAnalysisSoftware.m    # MATLAB Compiler build script
├── packageFourierAnalysisApp.m   # App packaging helper
├── createFFTAnalysisSplash.m     # Splash image generator
├── createFigureBestFftInset.m    # FigureBest MagInset helper
├── validateFigureExportWithCsv.m # Figure export validation helper
├── .github/workflows/             # MATLAB CI and multi-platform release workflows
├── scripts/archive_installer.py   # Release package archiver
├── UI_README.md                  # Detailed GUI usage notes
├── RELEASE_NOTES_v2.1.0.md      # Current release notes
├── plugins/fft-analysis-agent/   # Codex and Claude Code plugin
└── resources/                    # Splash image and About HTML resources
~~~

## Build from Source

The source code runs on Windows, macOS, and Linux as long as MATLAB R2020b or later is installed. Add the project folder to the MATLAB path and run:

~~~matlab
runFourierAnalysisApp
~~~

To build a standalone package for the current operating system, MATLAB Compiler is required:

~~~matlab
buildFFTAnalysisSoftware
~~~

To package the app for MATLAB's Apps panel:

~~~matlab
packageFourierAnalysisApp
~~~

Build outputs are written to `dist/` and excluded from version control. The build script selects the native compiler entry point and writes a platform-specific installer directory. GitHub Release packages are created by `.github/workflows/release.yml` when a `v*` tag is pushed. That workflow requires the repository secret `MLM_LICENSE_TOKEN` because MATLAB Compiler is a transformation product.

## CI and Multi-platform Releases

- `.github/workflows/ci.yml` runs the MATLAB unit tests on Windows, macOS, and Linux for pushes and pull requests.
- `.github/workflows/release.yml` builds native packages on all three GitHub-hosted operating systems when a `v*` tag is pushed.
- MATLAB source and API code are portable across the three operating systems when MATLAB is installed.
- A compiled application is tied to the operating system used for the build; it cannot be cross-compiled into one universal package.
- Release builds use MATLAB R2024b and require the repository secret `MLM_LICENSE_TOKEN`.

## Privacy and Local State

- Analysis is local; input MAT/CSV files are not uploaded by this project.
- The repository does not contain experiment data, MATLAB workspace dumps, credentials, or machine-specific MCP configuration.
- Do not commit oscilloscope captures, private simulation results, MATLAB Runtime files, or local Agent settings.
- When enabling request logging in an external client, treat logs as potentially sensitive because prompts, waveforms, or tool results may be recorded.

## License and Author

Released under the [MIT License](LICENSE).

Copyright (c) 2025-2026 Zhenbin Huang.

- [ORCID](https://orcid.org/0000-0002-0628-0387)
- [LinkedIn](https://www.linkedin.com/in/zhenbin-huang/)

FFT Analysis Tools is an independent project and is not an official MathWorks, Simulink, Codex, or Claude Code product.

## Releases and Documentation

- [Latest Release](https://github.com/ncepuee/FFT_Analysis_Tools/releases/latest)
- [v2.1.0 Release Notes](RELEASE_NOTES_v2.1.0.md)
- [Detailed GUI Documentation](UI_README.md)
- [Agent Plugin Documentation](plugins/fft-analysis-agent/README.md)
