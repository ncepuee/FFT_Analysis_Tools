## v2.1.0 — Agent Plugin and Automation API / Agent 插件与自动化接口

This release adds a cross-client Agent plugin for Codex and Claude Code, plus a non-GUI MATLAB API for automated FFT and THD analysis.

本版本新增适用于 Codex 与 Claude Code 的跨客户端 Agent 插件，并提供无 GUI 的 MATLAB 自动化 FFT/THD 分析接口。

### Added / 新增

- `fftAnalyzeFile` non-GUI API for MAT files and oscilloscope CSV files.
- Strict signal and channel selection for multi-signal inputs.
- Compact analysis summary and harmonic table for Agent responses.
- Shared `analyze-fft` Skill for Codex and Claude Code.
- Claude Code `fft-analyst` custom Agent.
- Codex and Claude Code plugin manifests and marketplace metadata.
- MATLAB unit tests covering MAT, CSV, multi-signal selection, harmonics, and THD.

### Fixed / 修复

- Fixed MATLAB-style THD calculation when floating-point rounding placed the fundamental bin infinitesimally above the requested fundamental frequency. The algorithm now excludes DC through the detected fundamental bin by index.

### Verification / 验证

- MATLAB tests: 3 passed, 0 failed.
- Codex plugin validation: passed.
- Agent Skill validation: passed.

### Agent Plugin Installation / Agent 插件安装

Codex:

```powershell
codex plugin marketplace add ncepuee/FFT_Analysis_Tools --ref v2.1.0
codex plugin add fft-analysis-agent@personal
```

Claude Code:

```powershell
claude plugin marketplace add ncepuee/FFT_Analysis_Tools@v2.1.0
claude plugin install fft-analysis-agent@fft-analysis-tools
```

The plugin does not publish machine-specific MATLAB MCP paths. Configure the official MATLAB MCP Server separately on each machine.

### Windows Application / Windows 应用

Download `FFTAnalysisAppInstaller.exe`. MATLAB Runtime R2024b is required on systems without MATLAB; the web installer prompts for it automatically.
