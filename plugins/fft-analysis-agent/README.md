# FFT Analysis Agent plugin

Cross-client Agent plugin for the FFT Analysis Tools repository. The shared `analyze-fft` skill works in Codex and Claude Code; Claude Code also exposes the `fft-analyst` custom agent.

The plugin intentionally does not bundle a machine-specific MCP configuration. Install and configure the official MATLAB Agentic Toolkit first, or ensure `matlab` is available for non-interactive execution.

## Codex local installation

From the repository root:

```powershell
codex plugin marketplace add .
codex plugin add fft-analysis-agent@personal
```

Start a new Codex task, then ask it to use `$analyze-fft`.

For the tagged GitHub release:

```powershell
codex plugin marketplace add ncepuee/FFT_Analysis_Tools --ref v2.1.0
codex plugin add fft-analysis-agent@personal
```

## Claude Code local test

```powershell
claude --plugin-dir ./plugins/fft-analysis-agent
```

Invoke `/fft-analysis-agent:analyze-fft`, or select `fft-analysis-agent:fft-analyst` from the Agent list.

## Claude Code marketplace installation

From the repository root:

```powershell
claude plugin marketplace add .
claude plugin install fft-analysis-agent@fft-analysis-tools
```

To install the tagged GitHub release from another checkout:

```powershell
claude plugin marketplace add ncepuee/FFT_Analysis_Tools@v2.1.0
claude plugin install fft-analysis-agent@fft-analysis-tools
```

Run `/reload-plugins` after updating plugin files.
