#!/usr/bin/env python3
"""Convert Imogen sprite JSON to separate BeebAsm mask and pixel planes.

With no arguments, convert sprites/levelA.txt through levelP.txt alongside
their sources. Paths on the command line select individual input files;
--output-dir places the generated includes in another directory.
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass
import json
from pathlib import Path
import re
import sys


SPRITES_DIR = Path(__file__).resolve().parents[1] / "sprites"


@dataclass(frozen=True)
class Sprite:
    number: int
    offset_x: int = 0
    offset_y: int = 0
    width: int = 0
    height: int = 0
    mask: bytes = b""
    pixels: bytes = b""
    reserved_bytes: int = 0
    kind: str = "empty"

    @property
    def label(self) -> str:
        return f"sprite_{self.number:02x}"


def integer(value: object, name: str, minimum: int, maximum: int) -> int:
    if type(value) is not int or not minimum <= value <= maximum:
        raise ValueError(f"{name}: expected an integer in {minimum}..{maximum}")
    return value


def encode_sprite(entry: dict) -> Sprite:
    """Pack eight horizontal pixels per byte, columns left-to-right.

    Rows within a byte column are stored top-to-bottom.
    Its renderer starts at height-1 and decrements to draw bottom-to-top.
    Mask 1 preserves the screen. Pixel 1 sets it; '#' has pixel 0, '.' has 1.
    The unused low bits of the last column are transparent (mask 1, pixel 0).
    """
    number = entry.get("sprite number")
    if isinstance(number, str):
        try:
            number = int(number, 0)
        except ValueError:
            raise ValueError(f"invalid sprite number: {number!r}") from None
    number = integer(number, "sprite number", 0, 255)
    if "sprite width" not in entry:
        if set(entry) != {"sprite number"}:
            raise ValueError(f"sprite &{number:02X}: missing sprite width")
        return Sprite(number)

    width = integer(entry["sprite width"], "sprite width", 0, 255)
    height = integer(entry.get("sprite height"), "sprite height", 0, 255)
    offset_x = integer(entry.get("offset x"), "offset x", -128, 127)
    offset_y = integer(entry.get("offset y"), "offset y", -128, 127)
    rows = entry.get("pixels")
    if width == 0 and height == 0:
        # Legacy erase caches are '#' strings: four symbols reserve one byte.
        # Their dimensions are set at runtime, so they have no drawable planes.
        if not isinstance(rows, str) or set(rows) - {"#"}:
            raise ValueError(f"sprite &{number:02X}: expected a reserved '#' string")
        return Sprite(number, offset_x, offset_y, reserved_bytes=(len(rows) + 3) // 4,
                      kind="cache")
    if width == 0 or height == 0:
        raise ValueError(f"sprite &{number:02X}: width and height must both be nonzero")
    if not isinstance(rows, list) or len(rows) != height:
        raise ValueError(f"sprite &{number:02X}: expected {height} pixel rows")
    for y, row in enumerate(rows):
        if not isinstance(row, str) or len(row) != width:
            raise ValueError(f"sprite &{number:02X}, row {y}: expected {width} pixels")
        if set(row) - {" ", "#", "."}:
            raise ValueError(f"sprite &{number:02X}, row {y}: only space, '#' and '.' allowed")

    mask = bytearray()
    pixels = bytearray()
    for x in range(0, width, 8):
        for row in rows:
            mask_byte = pixel_byte = 0
            for pixel in row[x:x + 8].ljust(8):
                mask_byte = (mask_byte << 1) | (pixel == " ")
                pixel_byte = (pixel_byte << 1) | (pixel == ".")
            mask.append(mask_byte)
            pixels.append(pixel_byte)
    return Sprite(number, offset_x, offset_y, width, height, bytes(mask), bytes(pixels),
                  kind="drawable")


def load_sprites(source: Path) -> list[Sprite]:
    data = json.loads(source.read_text(encoding="utf-8"))
    if not isinstance(data, dict) or not isinstance(data.get("sprites"), list):
        raise ValueError("expected a JSON object containing a sprites list")
    sprites = []
    for index, entry in enumerate(data["sprites"]):
        if not isinstance(entry, dict):
            raise ValueError(f"sprites[{index}]: expected an object")
        sprites.append(encode_sprite(entry))
    if not sprites:
        raise ValueError("sprites list is empty")
    if any(b.number != a.number + 1 for a, b in zip(sprites, sprites[1:])):
        raise ValueError("sprite numbers must be consecutive and in source order")
    return sprites


def plane_lines(label: str, data: bytes, height: int, alias: str | None) -> list[str]:
    lines = []
    if alias:
        lines.append(f".{alias} ; first drawable sprite, for the existing renderer test")
    lines.extend([f".{label}", "{"])
    for i, byte in enumerate(data):
        if i % height == 0:
            lines.append(f"    ; Byte column {i // height}, rows top-to-bottom")
        lines.append(f"    EQUB %{byte:08b}")
    lines.extend(["}", ""])
    return lines


def assembly(sprites: list[Sprite], source_name: str) -> str:
    lines = [
        f"; Generated from {source_name} by tools/convert_sprites.py. Do not edit.",
        "; Eight pixels per byte (leftmost pixel = bit 7). Byte columns left-to-right.",
        "; Rows within each byte column are TOP-TO-BOTTOM.",
        "; Draw bottom-to-top by reading each column from height-1 down to zero.",
        "; space: mask=1 pixel=0; '#': mask=0 pixel=0; '.': mask=0 pixel=1.",
        "; Composite: screen = (screen AND mask) OR pixels.",
        "; Last byte column is padded with transparent pixels to a multiple of eight.",
        "; Include ONE level file at the caller's chosen ORG; no animation data is inferred.",
        "",
        f"sprite_first_id = &{sprites[0].number:02X}",
        f"sprite_count = {len(sprites)}",
        "sprite_record_size = 8 ; signed X, signed Y, width, height, mask pointer, pixel pointer",
        "",
        ".level_sprite_data_start",
    ]
    first = True
    for sprite in sprites:
        label = sprite.label
        lines.extend([
            f"; Sprite &{sprite.number:02X}: {sprite.width} x {sprite.height}, "
            f"offset ({sprite.offset_x}, {sprite.offset_y})",
            f"{label}_width = {sprite.width}",
            f"{label}_height = {sprite.height}",
            f"{label}_plane_size = {len(sprite.mask)}",
            f"{label}_reserved_size = {sprite.reserved_bytes}",
        ])
        if sprite.width:
            lines.extend(plane_lines(f"{label}_mask_data", sprite.mask, sprite.height,
                                     "mask_data" if first else None))
            lines.extend(plane_lines(f"{label}_sprite_data", sprite.pixels, sprite.height,
                                     "sprite_data" if first else None))
            first = False
        lines.extend([
            f".{label}",
            "{",
            f"    EQUB &{sprite.offset_x & 255:02X}, &{sprite.offset_y & 255:02X}, "
            f"{sprite.width}, {sprite.height}",
            f"    EQUW {label}_mask_data, {label}_sprite_data" if sprite.width else
            "    EQUW 0, 0 ; no drawable planes",
            "}",
        ])
        if sprite.reserved_bytes:
            lines.extend([
                "; Legacy scratch capacity only; new screen backups need runtime dimensions.",
                f".{label}_reserved_data SKIP {sprite.reserved_bytes}",
            ])
        lines.append("")
    lines.extend([
        "; Index by (sprite ID - sprite_first_id) * 2. Empty/reserved IDs keep their slots.",
        ".sprite_table",
        "{",
    ])
    lines.extend(f"    EQUW {sprite.label} ; &{sprite.number:02X}" for sprite in sprites)
    lines.extend(["}", ".level_sprite_data_end", ""])
    return "\n".join(lines)


def resolve_aliases(sprites: list[Sprite], aliases: dict[int, int] | None = None) -> dict[int, int]:
    """Resolve explicit aliases without guessing that an empty ID is an alias."""
    by_id = {sprite.number: sprite for sprite in sprites}
    aliases = aliases or {}
    for source, target in aliases.items():
        integer(source, 'alias source', 0, 255)
        integer(target, 'alias target', 0, 255)
    resolved = {}
    for source in aliases:
        if source not in by_id or by_id[source].kind != "empty":
            raise ValueError(f"alias source &{source:02X} must be an existing empty ID")
        seen, target = {source}, aliases[source]
        while target in aliases:
            if target in seen:
                raise ValueError(f"cyclic sprite alias at &{source:02X}")
            seen.add(target)
            target = aliases[target]
        if target not in by_id or by_id[target].kind == "empty":
            raise ValueError(f"alias &{source:02X} has no drawable/cache target")
        resolved[source] = target
    return resolved


def swr_assembly(sprites: list[Sprite], source_name: str, *, prefix: str,
                 aliases: dict[int, int] | None = None, directory: bool = True) -> str:
    """Emit format 2: eight-byte records, absolute index and explicit classes.

    Legacy scratch is metadata only. Alias IDs index the canonical record and
    expose an equal-address label. Retained unused records keep the Phase 1
    bank-size bounds conservative. Directory metadata is emitted for levels;
    common/icon directories are stored in the sideways bank header instead.
    """
    if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", prefix):
        raise ValueError("SWR prefix must be an assembly identifier")
    if not sprites or len(sprites) > 255:
        raise ValueError("SWR bank must contain 1..255 sprites")
    if any(b.number != a.number + 1 for a, b in zip(sprites, sprites[1:])):
        raise ValueError("sprite numbers must be consecutive and in source order")
    for sprite in sprites:
        integer(sprite.width, 'SWR width', 0, 255)
        integer(sprite.height, 'SWR height', 0, 127)
        plane_size = ((sprite.width + 7) // 8) * sprite.height
        if len(sprite.mask) != plane_size or len(sprite.pixels) != plane_size:
            raise ValueError(f"sprite &{sprite.number:02X}: plane length does not match dimensions")
        if bool(sprite.width) != bool(sprite.height):
            raise ValueError(f"sprite &{sprite.number:02X}: inconsistent zero dimensions")
        if any(m & p for m, p in zip(sprite.mask, sprite.pixels)):
            raise ValueError(f"sprite &{sprite.number:02X}: pixels beneath transparent mask")
    canonical = resolve_aliases(sprites, aliases)
    by_id = {sprite.number: sprite for sprite in sprites}
    label = lambda number: f"{prefix}_sprite_{number:02x}"
    lines = [f"; Generated from {source_name}; SWR sprite format 2. Do not edit.",
             "; Mask 1 preserves; pixels beneath transparent mask are 0.",
             "; Byte columns left-to-right, rows top-to-bottom; absolute pointers.",
             f"{prefix}_format = 2", f"{prefix}_first_id = {sprites[0].number}",
             f"{prefix}_count = {len(sprites)}", f"{prefix}_record_size = 8",
             f".{prefix}_data_start", ""]
    for sprite in sprites:
        name = label(sprite.number)
        lines.extend([f"{name}_legacy_reserved_size = {sprite.reserved_bytes}",
                      f"{name}_kind = { {'empty': 0, 'drawable': 1, 'cache': 2}[by_id[canonical.get(sprite.number, sprite.number)].kind] }"])
        if sprite.width:
            lines += plane_lines(name + "_mask", sprite.mask, sprite.height, None)
            lines += plane_lines(name + "_pixels", sprite.pixels, sprite.height, None)
        record = name + "_unused_record" if sprite.number in canonical else name
        lines += [f".{record}",
                  f"    EQUB &{sprite.offset_x & 255:02X}, &{sprite.offset_y & 255:02X}, {sprite.width}, {sprite.height}",
                  f"    EQUW {name}_mask, {name}_pixels" if sprite.width else
                  "    EQUW 0, 0 ; empty/cache records have no source planes",
                  ""]
    for source, target in sorted(canonical.items()):
        lines += [f"{label(source)} = {label(target)} ; preserve legacy table alias"]
    if directory:
        lines += [f".{prefix}_directory", f"    EQUB 2, {sprites[0].number}, {len(sprites)}, 8"]
    lines += [f".{prefix}_sprite_table"]
    lines += [f"    EQUW {label(sprite.number)}" for sprite in sprites]
    if directory:
        lines += [f".{prefix}_kinds", "    EQUB " + ", ".join(str(
            {'empty': 0, 'drawable': 1, 'cache': 2}[by_id[canonical.get(s.number, s.number)].kind]) for s in sprites),
                  f".{prefix}_canonical_ids", "    EQUB " + ", ".join(str(canonical.get(s.number, s.number)) for s in sprites)]
    lines += [f".{prefix}_data_end", ""]
    return "\n".join(lines)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("inputs", nargs="*", type=Path, help="sprite JSON files")
    parser.add_argument("-o", "--output-dir", type=Path, help="default: alongside each input")
    parser.add_argument("--format", choices=("legacy", "swr"), default="legacy",
                        help="legacy: existing renderer includes; swr: namespaced format 2")
    parser.add_argument("--prefix", help="SWR namespace (one input only); default: input stem")
    parser.add_argument("--aliases", type=Path, help="SWR alias JSON mapping sprite IDs to target IDs (one input)")
    args = parser.parse_args(argv)
    sources = args.inputs or sorted(SPRITES_DIR.glob("level*.txt"))
    try:
        if not sources:
            raise ValueError("no input files found")
        if (args.prefix or args.aliases) and (args.format != "swr" or len(sources) != 1):
            raise ValueError("--prefix/--aliases require SWR format and exactly one input")
        aliases = None
        if args.aliases:
            raw = json.loads(args.aliases.read_text())
            aliases = {int(k, 0): int(v, 0) if isinstance(v, str) else v for k, v in raw.items()}
        # Validate every source before writing any output.
        converted = []
        for source in sources:
            sprites = load_sprites(source)
            output = (swr_assembly(sprites, source.name, prefix=args.prefix or source.stem, aliases=aliases)
                      if args.format == "swr" else assembly(sprites, source.name))
            converted.append((source, sprites, output))
        for source, sprites, output in converted:
            destination = (args.output_dir or source.parent) / (source.stem + ".asm")
            if destination.resolve() == source.resolve():
                raise ValueError(f"refusing to overwrite input: {source}")
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_text(output, encoding="utf-8")
            drawable = sum(bool(sprite.width) for sprite in sprites)
            print(f"{destination}: {len(sprites)} IDs, {drawable} drawable sprites")
    except (OSError, ValueError) as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
