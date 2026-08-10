"""Archive one platform-specific MATLAB Compiler installer directory."""

from __future__ import annotations

import argparse
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile


def select_installer_directory(project_root: Path, platform_name: str) -> Path:
    dist_root = project_root / "dist"
    expected = dist_root / f"FFTAnalysisAppInstaller-{platform_name}"
    if expected.is_dir():
        return expected

    candidates = [
        path
        for path in dist_root.glob(f"FFTAnalysisAppInstaller-{platform_name}_*")
        if path.is_dir()
    ]
    if not candidates:
        raise FileNotFoundError(
            f"No installer directory found for platform {platform_name!r} in {dist_root}"
        )
    return max(candidates, key=lambda path: path.stat().st_mtime)


def archive_installer(project_root: Path, platform_name: str) -> Path:
    source_directory = select_installer_directory(project_root, platform_name)
    output_path = project_root / "dist" / f"FFTAnalysisAppInstaller-{platform_name}.zip"
    if output_path.exists():
        output_path.unlink()

    with ZipFile(output_path, "w", ZIP_DEFLATED) as archive:
        for file_path in sorted(source_directory.rglob("*")):
            if file_path.is_file():
                archive.write(file_path, file_path.relative_to(source_directory.parent))

    return output_path


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--platform", choices=("windows", "macos", "linux"), required=True)
    arguments = parser.parse_args()
    project_root = Path(__file__).resolve().parents[1]
    output_path = archive_installer(project_root, arguments.platform)
    print(f"Created {output_path}")


if __name__ == "__main__":
    main()
