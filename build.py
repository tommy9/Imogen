#!/usr/bin/env python3
"""Build the SWR edition of Imogen and package imogen.ssd."""

import argparse
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

from tools import sprite_assets


ROOT = Path(__file__).resolve().parent
SRC_DIR = ROOT / "src"
BUILD_DIR = ROOT / "build"
LOG_DIR = BUILD_DIR / "logs"
EXPORTS = BUILD_DIR / "engine_exports.asm"
SOURCES = ("g.asm", "imogen.asm", "auxcode.asm") + tuple(
    f"data{letter}.asm" for letter in "ABCDEFGHIJKLMNOPQ"
)
EXPORT_BEGIN = "ENGINE_EXPORTS_BEGIN"
EXPORT_END = "ENGINE_EXPORTS_END"
EXPORT_DECLARATION = re.compile(
    r'^\s*PRINT\s+"([A-Za-z_]\w*)\s*=\s*",\s*~[A-Za-z_]\w*\s*$',
    re.MULTILINE,
)
EXPORT_ASSIGNMENT = re.compile(r"([A-Za-z_]\w*)\s*=\s*[&$]([0-9a-fA-F]+)")


class BuildError(Exception):
    pass


def preflight():
    """Check production sources before overwriting build outputs."""
    required = {f"src/{name}" for name in SOURCES} | {
        "src/globals.asm", "src/ssd_maker.asm", "src/swr_sprite_adapter.asm",
        "src/swr_renderer_core.asm", "src/swr_frame_alignment.asm",
        "src/swr_bootstrap.asm", "tools/swr_bootstrap_build.py",
        "tools/swr_game_build.py",
    }
    missing = sorted(name for name in required if not (ROOT / name).is_file())
    if missing:
        raise BuildError("Missing build inputs: " + ", ".join(missing))
    assembler = shutil.which("beebasm")
    if assembler is None:
        raise BuildError("beebasm was not found on PATH.")
    return assembler


def assemble(assembler, source, verbose, *options):
    print(f"Assembling {source}...", flush=True)
    result = subprocess.run(
        [assembler, "-i", str(source) if Path(source).is_absolute() else f"src/{source}", *options], cwd=ROOT,
        stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True,
    )
    log = LOG_DIR / f"{Path(source).stem}.log"
    log.write_text(result.stdout)
    if verbose or result.returncode:
        print(result.stdout, end="", file=sys.stderr if result.returncode else sys.stdout)
    if result.returncode:
        raise BuildError(
            f"{source} failed (exit {result.returncode}); see {log.relative_to(ROOT)}."
        )
    return result.stdout


def parse_exports(output):
    lines = [line.strip() for line in output.splitlines()]
    if lines.count(EXPORT_BEGIN) != 1 or lines.count(EXPORT_END) != 1:
        raise BuildError("Expected one complete engine export block; see build/logs/g.log.")
    start, end = lines.index(EXPORT_BEGIN), lines.index(EXPORT_END)
    if end <= start:
        raise BuildError("Engine export markers are out of order; see build/logs/g.log.")

    expected = EXPORT_DECLARATION.findall((SRC_DIR / "g.asm").read_text())
    if not expected or len(expected) != len(set(expected)):
        raise BuildError("g.asm must declare a unique list of engine exports.")
    values = {}
    for line in lines[start + 1:end]:
        match = EXPORT_ASSIGNMENT.fullmatch(line)
        if match is None:
            raise BuildError(f"Malformed engine export: {line!r}; see build/logs/g.log.")
        name, value = match.group(1), int(match.group(2), 16)
        if name in values or value > 0xFFFF:
            raise BuildError(f"Duplicate or invalid engine export: {name}.")
        values[name] = value
    missing, unexpected = set(expected) - values.keys(), values.keys() - set(expected)
    if missing or unexpected:
        raise BuildError(
            f"Engine exports do not match g.asm: missing {sorted(missing)}, "
            f"unexpected {sorted(unexpected)}; see build/logs/g.log."
        )
    for name in (
        "g_load_address", "g_execution_address", "sprite_op_flags", "level_data_load_address",
    ):
        if name not in values:
            raise BuildError(f"Required engine export is missing: {name}.")
    load, execution = values["g_load_address"], values["g_execution_address"]
    if not load <= execution < load + (BUILD_DIR / "g").stat().st_size:
        raise BuildError("The execution address lies outside the assembled g binary.")
    return values


def write_exports(values):
    text = "; Generated from g.asm by compile.sh. Do not edit by hand.\n\n"
    text += "".join(f"{name:<54} = &{value:04X}\n" for name, value in values.items())
    with tempfile.TemporaryDirectory(dir=ROOT, prefix=".engine-exports-") as directory:
        temporary = Path(directory) / EXPORTS.name
        temporary.write_text(text)
        temporary.replace(EXPORTS)


def write_config(bank, bank_auto, *, measurement):
    (BUILD_DIR / "swr_boot_config.asm").write_text(
        "; Generated SWR build configuration; do not edit.\n"
        "swr_boot_enabled = 1\n"
        f"swr_renderer_enabled = {int(not measurement)}\n"
        f"swr_measurement = {int(measurement)}\n"
        f"swr_frame_alignment_enabled = {int(not measurement)}\n"
        "swr_frame_alignment_phase = 192\n"
        f"swr_bank_auto = {int(bank_auto)}\n"
        f"swr_configured_bank = {bank}\n")


def main():
    from tools import swr_bootstrap_build, swr_game_build

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--verbose", action="store_true", help="also show full assembler output")
    parser.add_argument("--asset-root", type=Path, default=ROOT,
                        help="asset directory containing sprites/ and tools/convert_sprites.py (default: this project)")
    parser.add_argument("--swr-bank", default="auto",
                        help="auto discovers spare 16K RAM (prefers 4); 0..15 forces a slot")
    args = parser.parse_args()
    bank_auto = args.swr_bank == "auto"
    try:
        bank = 4 if bank_auto else int(args.swr_bank)
    except ValueError:
        parser.error("--swr-bank must be auto or an integer from 0 to 15")
    if not 0 <= bank <= 15:
        parser.error("--swr-bank must be auto or an integer from 0 to 15")

    assembler = preflight()
    asset_plan = sprite_assets.prepare(args.asset_root, ROOT, bank)
    LOG_DIR.mkdir(parents=True, exist_ok=True)
    labels_dir = BUILD_DIR / "labels"
    labels_dir.mkdir(exist_ok=True)

    def options(source):
        return ("-labels", str(labels_dir / (Path(source).stem + ".labels")), "-dd")

    # Measure code without sprites before allocating the final assets and caches.
    write_config(bank, bank_auto, measurement=True)
    values = parse_exports(assemble(assembler, "g.asm", args.verbose, *options("g.asm")))
    write_exports(values)
    for source in SOURCES[1:]:
        assemble(assembler, source, args.verbose, *options(source))
    if values['level_data_load_address'] > asset_plan['contract']['main_ram']['maximum_new_level_start']:
        raise BuildError("The resident engine exceeds the SWR memory contract.")
    code_sizes = {}
    for letter in "ABCDEFGHIJKLMNOP":
        labels = sprite_assets.load_labels(labels_dir / f"data{letter}.labels")

        def address(name):
            matches = [v for k, v in labels.items() if k.endswith('.' + name)]
            if len(matches) != 1:
                raise BuildError(f"Level {letter} has no unique {name} label.")
            return matches[0]

        if address('level_data') != values['level_data_load_address']:
            raise BuildError(f"Level {letter} has the wrong load address.")
        code_sizes[letter] = address('sprite_data') - address('level_data')
    runtime_bytes = 3 + swr_game_build.measure_runtime(assembler, ROOT)
    code_sizes = {letter: size + runtime_bytes for letter, size in code_sizes.items()}
    report = sprite_assets.generate(asset_plan, assembler, code_sizes, BUILD_DIR / "swr_assets", args.verbose)
    print(f"Prepared SWR format {report['format']}: {report['bank_bytes']} byte bank; "
          f"minimum planned memory headroom {report['minimum_remaining_bytes']} bytes.", flush=True)

    swr_game_build.prepare_runtime(ROOT, bank)
    write_config(bank, bank_auto, measurement=False)
    values = parse_exports(assemble(assembler, "g.asm", args.verbose, *options("g.asm")))
    write_exports(values)
    for source in SOURCES[1:]:
        assemble(assembler, source, args.verbose, *options(source))
    game_report = swr_game_build.validate(ROOT, bank, asset_plan)
    print(f"SWR game: engine ends &{game_report['level_start']:04X}; "
          f"{game_report['resident_budget_remaining']} resident bytes remain.", flush=True)
    disk_source = swr_bootstrap_build.build(assembler, ROOT, args.verbose)
    # Stage beside the destination so a failed build preserves the previous disk.
    with tempfile.TemporaryDirectory(dir=ROOT, prefix=".imogen-build-") as directory:
        disk = Path(directory) / "imogen.ssd"
        assemble(assembler, disk_source, args.verbose, "-do", str(disk), "-boot", "IMOGEN")
        if not disk.is_file() or disk.stat().st_size == 0:
            raise BuildError("The assembler did not produce a disk image; see build/logs/ssd_maker.log.")
        disk.replace(ROOT / "imogen.ssd")
    print("Built imogen.ssd. Full assembler logs: build/logs/")


if __name__ == "__main__":
    try:
        main()
    except (BuildError, sprite_assets.AssetError, OSError, ValueError) as error:
        print(f"Build failed: {error}", file=sys.stderr)
        sys.exit(1)
    except KeyboardInterrupt:
        print("Build interrupted.", file=sys.stderr)
        sys.exit(130)
