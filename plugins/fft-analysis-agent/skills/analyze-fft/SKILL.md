---
name: analyze-fft
description: Analyze MATLAB MAT files, oscilloscope CSV files, workspace signals, or numeric time/waveform arrays with this repository's FFT and THD implementation. Use when the user asks to inspect harmonics, calculate THD, compare channels, explain a spectrum, validate a fundamental frequency, or automate the FFT Analysis Tools GUI workflow from Codex or Claude Code.
---

# Analyze FFT and THD

Use the repository's public, non-GUI functions. Do not reimplement the FFT or THD formulas in another language unless the user explicitly asks for an independent cross-check.

## Prepare

1. Locate the workspace containing `fftAnalyzeFile.m`, `fftAnalyzeSignal.m`, and `readScopeCsv.m`.
2. Prefer the MATLAB MCP tools `evaluate_matlab_code` and `run_matlab_file` when available. Otherwise run MATLAB non-interactively with `matlab -batch`.
3. Add the workspace root to the MATLAB path before calling the API.
4. Never open `FourierAnalysisApp` unless the user explicitly requests the GUI.

Read [references/analysis-api.md](references/analysis-api.md) before constructing a call or interpreting result fields.

## Analyze a file

Call `fftAnalyzeFile` with explicit engineering assumptions:

```matlab
addpath(projectRoot);
out = fftAnalyzeFile(inputFile, ...
    Signal="CH1", ...
    FundamentalFrequency=50, ...
    NumCycles=10, ...
    StartTime=0, ...
    MaxDisplayFrequency=3000, ...
    ThdMethod="matlab", ...
    ThdMaxFrequency=Inf);

disp(out.summary)
disp(out.harmonics)
```

If a MAT file contains multiple signal objects or a selected waveform contains multiple columns, use the selection error's candidate list and ask the user only when the intended signal cannot be inferred safely. For CSV input, accept either a channel name such as `CH1` or its full signal label.

## Analyze arrays or workspace data

When time and waveform arrays are already available, call the core directly:

```matlab
result = fftAnalyzeSignal(time(:), waveform(:), 50, 10, 0, 3000, "matlab", Inf);
```

For a struct with `time` and `signals.values`, save it to a temporary MAT file and use `fftAnalyzeFile`, or extract the arrays explicitly. Preserve the original data and units.

## Validate before interpreting

- Confirm time is strictly increasing and approximately uniformly sampled.
- Confirm the chosen FFT window fits fully inside the signal.
- State the assumed fundamental frequency, cycle count, window start, THD method, and THD upper limit.
- Check that the requested cycle window produces adequate frequency resolution and contains the expected fundamental bin.
- Treat spectral leakage as a measurement limitation. This implementation applies a rectangular window; non-coherent windows can spread energy into neighboring bins and inflate full-spectrum THD.
- Do not compare `matlab` and `spectrum` THD values without explaining their different included-frequency rules.

## Report

Lead with the selected source/channel, fundamental magnitude, THD percentage, sampling rate, FFT points, and frequency resolution. Then list the relevant harmonics and explain anomalies or limitations. Use percentages for THD and `percentOfFundamental`; the underlying `analysis.thd` value is a ratio.

When comparing signals, keep all FFT parameters identical unless the user requests different windows. Clearly label any parameter differences.
