# Sprite sources

These `.txt` files contain JSON data from the disassembly https://github.com/ZornsLemma/Imogen. 
`sprdata.txt` supplies common sprites, 
`icodata.txt` supplies icons and level-order metadata, and 
`levelA.txt` through `levelP.txt` supply the sixteen stock levels.

Run `./compile.sh` from the project root to build the game. The build converts the sprite JSON into assembly containing mask/pixel data and sprite lookup records for the SWR renderer. Generated files go under `build/swr_assets/`; only the source JSON needs to be retained in `sprites/`
The aliases and cache families used by the stock build are explicit inputs in `config/sprite-aliases.json` and `config/cache_inventory.json`.

## Source pixel encoding

| JSON pixel | Mask bit | Sprite bit | Effect |
| --- | --- | --- | --- |
| space | 1 | 0 | Preserve screen pixel |
| `#` | 0 | 0 | Clear screen pixel |
| `.` | 0 | 1 | Set screen pixel |

The leftmost pixel occupies bit 7. Byte columns run left to right, with rows
stored top to bottom within each column. Each plane occupies
`((width + 7) DIV 8) * height` bytes. Unused bits preserve the screen.

An eight-byte sprite record contains signed X/Y offsets, width, height, and little-endian mask/pixel pointers. The generated directory retains original IDs, including empty sprites and typed cache entries. Saved-background storage is allocated separately using runtime dimensions and alignment.

For a standalone SWR include:

```sh
python3 tools/convert_sprites.py sprites/levelE.txt --format swr --prefix levelE --output-dir /tmp/imogen-sprites
```

Use `--aliases` for an explicit single-bank ID mapping when needed. The complete game build supplies its stock mappings and validates the assembled records.
