# FFT Analysis API

## File entry point

```matlab
out = fftAnalyzeFile(filePath, Name=Value)
```

Supported files:

- `.csv`: oscilloscope CSV parsed by `readScopeCsv`; headers such as `TIME,CH1,CH4` are supported.
- `.mat`: `timeseries`, `time` + `signals.values` structs, and nested `Simulink.SimulationOutput`-like containers.

Options:

| Option | Default | Meaning |
|---|---:|---|
| `Signal` | `""` | MAT signal path or CSV channel name/label |
| `Channel` | automatic | One-based column within a selected multi-column signal |
| `FundamentalFrequency` | `50` | Expected fundamental in Hz |
| `NumCycles` | `10` | Fundamental cycles in the FFT window |
| `StartTime` | `0` | Window start in seconds |
| `MaxDisplayFrequency` | `3000` | Highest frequency returned in display vectors/harmonics |
| `ThdMethod` | `"matlab"` | `"matlab"` or `"spectrum"` |
| `ThdMaxFrequency` | `Inf` | Upper frequency for MATLAB-style THD |
| `MaxHarmonics` | `25` | Maximum rows in the harmonic table |

Selection is intentionally strict: a file with multiple candidate signals or channels raises an error listing the available choices instead of silently choosing one.

## Output

- `out.source`: file, type, signal path/label, channel name/index, original time offset.
- `out.parameters`: effective request parameters.
- `out.summary`: compact scalar results suitable for an Agent response.
- `out.harmonics`: table with harmonic order, target and actual bin frequencies, magnitude, and percent of fundamental.
- `out.analysis`: full `fftAnalyzeSignal` result, including time window and complete single-sided spectrum vectors.

Important summary fields:

- `fsHz`, `dtSeconds`, `dfHz`, `fftPoints`
- `fundamentalFrequencyHz`, `fundamentalMagnitude`, `fundamentalRms`
- `thdPercent`, `thdMatlabOriginalPercent`, `thdFullSpectrumPercent`

## THD methods

`"matlab"` zeros DC and all bins at or below the expected fundamental, then sums remaining components up to `ThdMaxFrequency`. It follows this project's Simscape Electrical FFT Analyzer-compatible convention.

`"spectrum"` sums every non-DC sampled spectrum component except the fundamental. It is more sensitive to subharmonics, interharmonics, noise, and leakage.

Both methods normalize the root-sum-square magnitude by the fundamental magnitude. Returned `analysis.thd` values are ratios; `summary.thdPercent` is already multiplied by 100.

## Direct array entry point

```matlab
result = fftAnalyzeSignal(time, waveform, f0, numCycles, startTime, ...
    maxDisplayFreq, thdMethod, thdMaxFrequency)
```

The function requires finite column vectors of equal length and strictly increasing time. Its FFT window length is `round((numCycles/f0)/median(diff(time)))`.
