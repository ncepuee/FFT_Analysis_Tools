# FFT Analysis Tools

<p align="center">
  <a href="README.zh-CN.md">中文</a> · <strong>English</strong>
</p>

<p align="center">
  <img src="https://raw.githubusercontent.com/ncepuee/FFT_Analysis_Tools/master/resources/FFTAnalysisLogo.png" alt="FFT Analysis Tools logo" width="112">
</p>

<p align="center"><strong>MATLAB GUI, automation API, and Agent plugin for FFT, harmonics, and THD analysis.</strong></p>

<p align="center">
  <a href="https://openai.com/codex/"><img alt="Codex Code Support" src="https://img.shields.io/badge/Codex-Code_Support-orange?logo=data:image/svg%2bxml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCI+PHBhdGggZmlsbD0iI2ZmZiIgZD0iTTguMDg2LjQ1N2E2LjEwNSA2LjEwNSAwIDAxMy4wNDYtLjQxNWMxLjMzMy4xNTMgMi41MjEuNzIgMy41NjQgMS43YS4xMTcuMTE3IDAgMDAuMTA3LjAyOWMxLjQwOC0uMzQ2IDIuNzYyLS4yMjQgNC4wNjEuMzY2bC4wNjMuMDMuMTU0LjA3NmMxLjM1Ny43MDMgMi4zMyAxLjc3IDIuOTE4IDMuMTk4LjI3OC42NzkuNDE4IDEuMzg4LjQyMSAyLjEyNmE1LjY1NSA1LjY1NSAwIDAxLS4xOCAxLjYzMS4xNjcuMTY3IDAgMDAuMDQuMTU1IDUuOTgyIDUuOTgyIDAgMDExLjU3OCAyLjg5MWMuMzg1IDEuOTAxLS4wMSAzLjYxNS0xLjE4MyA1LjE0bC0uMTgyLjIyYTYuMDYzIDYuMDYzIDAgMDEtMi45MzQgMS44NTEuMTYyLjE2MiAwIDAwLS4xMDguMTAyYy0uMjU1LjczNi0uNTExIDEuMzY0LS45ODcgMS45OTItMS4xOTkgMS41ODItMi45NjIgMi40NjItNC45NDggMi40NTEtMS41ODMtLjAwOC0yLjk4Ni0uNTg3LTQuMjEtMS43MzZhLjE0NS4xNDUgMCAwMC0uMTQtLjAzMmMtLjUxOC4xNjctMS4wNC4xOTEtMS42MDQuMTg1YTUuOTI0IDUuOTI0IDAgMDEtMi41OTUtLjYyMiA2LjA1OCA2LjA1OCAwIDAxLTIuMTQ2LTEuNzgxYy0uMjAzLS4yNjktLjQwNC0uNTIyLS41NTEtLjgyMWE3Ljc0IDcuNzQgMCAwMS0uNDk1LTEuMjgzIDYuMTEgNi4xMSAwIDAxLS4wMTctMy4wNjQuMTY2LjE2NiAwIDAwLjAwOC0uMDc0LjExNS4xMTUgMCAwMC0uMDM3LS4wNjQgNS45NTggNS45NTggMCAwMS0xLjM4LTIuMjAyIDUuMTk2IDUuMTk2IDAgMDEtLjMzMy0xLjU4OSA2LjkxNSA2LjkxNSAwIDAxLjE4OC0yLjEzMmMuNDUtMS40ODQgMS4zMDktMi42NDggMi41NzctMy40OTMuMjgyLS4xODguNTUtLjMzNC44MDItLjQzOC4yODYtLjEyLjU3My0uMjIuODYxLS4zMDRhLjEyOS4xMjkgMCAwMC4wODctLjA4N0E2LjAxNiA2LjAxNiAwIDAxNS42MzUgMi4zMUM2LjMxNSAxLjQ2NCA3LjEzMi44NDYgOC4wODYuNDU3em0tLjgwNCA3Ljg1YS44NDguODQ4IDAgMDAtMS40NzMuODQybDEuNjk0IDIuOTY1LTEuNjg4IDIuODQ4YS44NDkuODQ5IDAgMDAxLjQ2Ljg2NGwxLjk0LTMuMjcyYS44NDkuODQ5IDAgMDAuMDA3LS44NTRsLTEuOTQtMy4zOTN6bTUuNDQ2IDYuMjRhLjg0OS44NDkgMCAwMDAgMS42OTVoNC44NDhhLjg0OS44NDkgMCAwMDAtMS42OTZoLTQuODQ4eiIvPjwvc3ZnPg==&logoColor=white"></a>
  <a href="https://openai.com/"><img alt="GPT 5.6 Sol Agent used at v2.1.0" src="https://img.shields.io/badge/GPT--5.6--Sol-Agent_used%40v2.1.0-412991?logo=data:image/svg%2bxml;base64,PHN2ZyByb2xlPSJpbWciIHZpZXdCb3g9IjAgMCAyNCAyNCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48dGl0bGU+T3BlbkFJPC90aXRsZT48cGF0aCBmaWxsPSIjZmZmIiBkPSJNMjIuMjgxOSA5LjgyMTFhNS45ODQ3IDUuOTg0NyAwIDAgMC0uNTE1Ny00LjkxMDggNi4wNDYyIDYuMDQ2MiAwIDAgMC02LjUwOTgtMi45QTYuMDY1MSA2LjA1NTEgMCAwIDAgNC45ODA3IDQuMTgxOGE1Ljk4NDcgNS45ODQ3IDAgMCAwLTMuOTk3NyAyLjkgNi4wNDYyIDYuMDQ2MiAwIDAgMCAuNzQyNyA3LjA5NjYgNS45OCA1Ljk4IDAgMCAwIC41MTEgNC45MTA3IDYuMDUxIDYuMDUxIDAgMCAwIDYuNTE0NiAyLjkwMDFBNS45ODQ3IDUuOTg0NyAwIDAgMCAxMy4yNTk5IDI0YTYuMDU1NyA2LjA1NTcgMCAwIDAgNS43NzE4LTQuMjA1OCA1Ljk4OTQgNS45ODk0IDAgMCAwIDMuOTk3Ny0yLjkwMDEgNi4wNTU3IDYuMDU1NyAwIDAgMC0uNzQ3NS03LjA3Mjl6bS05LjAyMiAxMi42MDgxYTQuNDc1NSA0LjQ3NTUgMCAwIDEtMi44NzY0LTEuMDQwOGwuMTQxOS0uMDgwNCA0Ljc3ODMtMi43NTgyYS43OTQ4Ljc5NDggMCAwIDAgLjM5MjctLjY4MTN2LTYuNzM2OWwyLjAyIDEuMTY4NmEuMDcxLjA3MSAwIDAgMSAuMDM4LjA1MnY1LjU4MjZhNC41MDQgNC41MDQgMCAwIDEtNC40OTQ1IDQuNDk0NHptLTkuNjYwNy00LjEyNTRhNC40NzA4IDQuNDcwOCAwIDAgMS0uNTM0Ni0zLjAxMzdsLjE0Mi4wODUyIDQuNzgzIDIuNzU4MmEuNzcxMi43NzEyIDAgMCAwIC43ODA2IDBsNS44NDI4LTMuMzY4NXYyLjMzMjRhLjA4MDQuMDgwNCAwIDAgMS0uMDMzMi4wNjE1TDkuNzQgMTkuOTUwMmE0LjQ5OTIgNC40OTkyIDAgMCAxLTYuMTQwOC0xLjY0NjR6TTIuMzQwOCA3Ljg5NTZhNC40ODUgNC40ODUgMCAwIDEgMi4zNjU1LTEuOTcyOFYxMS42YS43NjY0Ljc2NjQgMCAwIDAgLjM4NzkuNjc2NWw1LjgxNDQgMy4zNTQzLTIuMDIwMSAxLjE2ODVhLjA3NTcuMDc1NyAwIDAgMS0uMDcxIDBsLTQuODMwMy0yLjc4NjVBNC41MDQgNC41MDQgMCAwIDEgMi4zNDA4IDcuODcyem0xNi41OTYzIDMuODU1OEwxMy4xMDM4IDguMzY0IDE1LjExOTIgNy4yYS4wNzU3LjA3NTcgMCAwIDEgLjA3MSAwbDQuODMwMyAyLjc5MTNhNC40OTQ0IDQuNDk0NCAwIDAgMS0uNjc2NSA4LjEwNDJ2LTUuNjc3MmEuNzkuNzkgMCAwIDAtLjQwNy0uNjY3em0yLjAxMDctMy4wMjMxbC0uMTQyLS4wODUyLTQuNzczNS0yLjc4MThhLjc3NTkuNzc1OSAwIDAgMC0uNzg1NCAwTDkuNDA5IDkuMjI5N1Y2Ljg5NzRhLjA2NjIuMDY2MiAwIDAgMSAuMDI4NC0uMDYxNWw0LjgzMDMtMi43ODY2YTQuNDk5MiA0LjQ5OTIgMCAwIDEgNi42ODAyIDQuNjZ6TTguMzA2NSAxMi44NjNsLTIuMDItMS4xNjM4YS4wODA0LjA4MDQgMCAwIDEtLjAzOC0uMDU2N1Y2LjA3NDJhNC40OTkyIDQuNDk5MiAwIDAgMSA3LjM3NTctMy40NTM3bC0uMTQyLjA4MDVMOC43MDQgNS40NTlhLjc5NDguNzk0OCAwIDAgMC0uMzkyNy42ODEzem0xLjA5NzYtMi4zNjU0bDIuNjAyLTEuNDk5OCAyLjYwNjkgMS40OTk4djIuOTk5NGwtMi41OTc0IDEuNDk5Ny0yLjYwNjctMS40OTk3WiIvPjwvc3ZnPg==&logoColor=white"></a>
  <a href="https://www.hust.edu.cn/"><img alt="HUST Created Location" src="https://img.shields.io/endpoint?url=https%3A%2F%2Fgist.githubusercontent.com%2Fncepuee%2Fe394cf76b255550ed1db93e6a0f69ae1%2Fraw%2FHUSTBadge.json"></a>
</p>

<p align="center">
  <a href="https://github.com/ncepuee/FFT_Analysis_Tools/actions/workflows/ci.yml"><img alt="MATLAB CI" src="https://github.com/ncepuee/FFT_Analysis_Tools/actions/workflows/ci.yml/badge.svg"></a>
  <a href="https://github.com/ncepuee/FFT_Analysis_Tools/releases/latest"><img alt="Latest release" src="https://img.shields.io/github/v/release/ncepuee/FFT_Analysis_Tools?display_name=tag&logo=github"></a>
  <a href="https://github.com/ncepuee/FFT_Analysis_Tools/blob/master/LICENSE"><img alt="MIT license" src="https://img.shields.io/github/license/ncepuee/FFT_Analysis_Tools?color=blue"></a>
  <img alt="MATLAB R2020b+" src="https://img.shields.io/badge/MATLAB-R2020b%2B-orange?logo=mathworks">
  <img alt="Windows macOS Linux" src="https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-0078D4">
  <a href="https://github.com/ncepuee/FFT_Analysis_Tools/releases/tag/v2.2.2"><img alt="Agent plugin" src="https://img.shields.io/badge/Agent_plugin-v2.2.2-FF8A00"></a>
</p>

FFT Analysis Tools is a local-first MATLAB toolkit for power-electronics and oscilloscope waveform analysis. Use the graphical application for interactive work, the non-GUI API for reproducible automation, or the bundled Agent plugin from Codex and Claude Code.

> **Current release:** [v2.2.2](https://github.com/ncepuee/FFT_Analysis_Tools/releases/tag/v2.2.2) provides source-code archives and native Windows, macOS, and Linux installers. The MATLAB source workflow is cross-platform; compiled packages are built natively for each operating system.

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

Download the matching package from the [v2.2.2 Release](https://github.com/ncepuee/FFT_Analysis_Tools/releases/tag/v2.2.2):

- [`FFTAnalysisAppInstaller-windows-x64.exe`](https://github.com/ncepuee/FFT_Analysis_Tools/releases/download/v2.2.2/FFTAnalysisAppInstaller-windows-x64.exe) for Windows x64.
- [`FFTAnalysisAppInstaller-macos.dmg`](https://github.com/ncepuee/FFT_Analysis_Tools/releases/download/v2.2.2/FFTAnalysisAppInstaller-macos.dmg) for macOS.
- [`FFTAnalysisAppInstaller-linux.install`](https://github.com/ncepuee/FFT_Analysis_Tools/releases/download/v2.2.2/FFTAnalysisAppInstaller-linux.install) for Linux.

Machines without MATLAB need MATLAB Runtime R2024b. These are native packages, not a single universal executable. The release page also provides the source code as ZIP and TAR.GZ archives for the corresponding tag.

### Option 3: Install the Agent plugin

#### Codex

From a local checkout:

~~~powershell
codex plugin marketplace add .
codex plugin add fft-analysis-agent@personal
~~~

From the tagged release:

~~~powershell
codex plugin marketplace add ncepuee/FFT_Analysis_Tools --ref v2.2.2
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
claude plugin marketplace add ncepuee/FFT_Analysis_Tools@v2.2.2
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

Build outputs are written to `dist/` and excluded from version control. The build script selects the native compiler entry point and writes a platform-specific installer directory. The release workflow converts those outputs into a Windows `.exe`, a macOS `.dmg`, and a Linux `.install` file. GitHub Release packages are created by `.github/workflows/release.yml` when a `v*` tag is pushed. That workflow requires the repository secret `MLM_LICENSE_TOKEN` because MATLAB Compiler is a transformation product.

## CI and Multi-platform Releases

- `.github/workflows/ci.yml` runs the MATLAB unit tests on Windows, macOS, and Linux for pushes and pull requests.
- `.github/workflows/release.yml` builds native packages on all three GitHub-hosted operating systems when a `v*` tag is pushed.
- Each release provides `FFTAnalysisAppInstaller-windows-x64.exe`, `FFTAnalysisAppInstaller-macos.dmg`, and `FFTAnalysisAppInstaller-linux.install`.
- GitHub also provides source-code ZIP and TAR.GZ archives generated from the release tag.
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
- [v2.2.2 Release](https://github.com/ncepuee/FFT_Analysis_Tools/releases/tag/v2.2.2)
- [v2.1.0 Release Notes](RELEASE_NOTES_v2.1.0.md)
- [Detailed GUI Documentation](UI_README.md)
- [Agent Plugin Documentation](plugins/fft-analysis-agent/README.md)
