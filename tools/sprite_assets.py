"""Build and validate format-2 SWR assets for the production game."""
from __future__ import annotations

import ast
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import zlib

FORMAT = 2
CRC_OFFSET = 0x34
KIND = {'empty': 0, 'drawable': 1, 'cache': 2}
ROOT = Path(__file__).resolve().parents[1]


class AssetError(Exception):
    pass


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def load_labels(path):
    return ast.literal_eval(re.sub(r'(?<=\d)L\b', '', path.read_text()))[0]


def converter_at(asset_root):
    path = asset_root / 'tools/convert_sprites.py'
    spec = importlib.util.spec_from_file_location('imogen_swr_converter', path)
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    if not hasattr(module, 'swr_assembly'):
        raise AssetError(f'{path} does not support SWR format 2')
    return module


def metadata(source, converter):
    raw = json.loads(source.read_text()).get('level order data')
    if not isinstance(raw, dict):
        raise AssetError('ICODATA needs level order data')
    flags = raw.get('developer_flags')
    if isinstance(flags, str):
        flags = int(flags, 0)
    converter.integer(flags, 'developer_flags', 0, 255)
    first, order = raw.get('first level'), raw.get('level order')
    if not isinstance(first, str) or len(first) != 1 or first not in 'ABCDEFGHIJKLMNOPR':
        raise AssetError('ICODATA first level must be A..P or R')
    if not isinstance(order, str) or sorted(order) != list('ABCDEFGHIJKLMNOP'):
        raise AssetError('ICODATA level order must contain A..P exactly once')
    return bytes([flags, ord(first)]) + order.encode('ascii')


def prepare(asset_root, root=ROOT, bank=4):
    """Validate every input before any game binary is overwritten."""
    asset_root, root = Path(asset_root).resolve(), Path(root).resolve()
    if type(bank) is not int or not 0 <= bank <= 15:
        raise AssetError('Asset bank must be 0..15')
    paths = {name: asset_root / 'sprites' / (stem + '.txt') for name, stem in
             [('common', 'sprdata'), ('icons', 'icodata')] + [(c, 'level' + c) for c in 'ABCDEFGHIJKLMNOP']}
    required = list(paths.values()) + [asset_root / 'tools/convert_sprites.py',
                root / 'config/contract.json', root / 'config/sprite-aliases.json',
                root / 'config/cache_inventory.json']
    missing = [str(p) for p in required if not p.is_file()]
    if missing:
        raise AssetError('Missing SWR asset inputs: ' + ', '.join(missing))
    converter = converter_at(asset_root)
    contract = json.loads(required[-3].read_text())
    aliases = json.loads(required[-2].read_text())
    curated = json.loads(required[-1].read_text())
    entries = {}
    for name, source in paths.items():
        sprites = converter.load_sprites(source)
        first = 0 if name == 'common' else 1 if name == 'icons' else 200
        if sprites[0].number != first:
            raise AssetError(f'{source}: expected first ID {first}')
        mapping = {int(k): v for k, v in aliases.get(name, {}).items()}
        canonical = converter.resolve_aliases(sprites, mapping)
        prefix = name if name in ('common', 'icons') else 'level' + name
        include = converter.swr_assembly(sprites, source.name, prefix=prefix, aliases=mapping,
                                        directory=name not in ('common', 'icons'))
        if name in curated:
            by_id = {s.number: s for s in sprites}
            for cache_id in curated[name]:
                if int(cache_id) not in by_id or by_id[int(cache_id)].kind != 'cache':
                    raise AssetError(f'Level {name}: cache ID {cache_id} is not a cache record')
        entries[name] = {'sprites': sprites, 'canonical': canonical, 'prefix': prefix, 'include': include,
                         'source': source, 'sha256': digest(source)}
    inputs = required + [root / 'src/g.asm', root / 'src/globals.asm'] + [root / f'src/data{c}.asm' for c in 'ABCDEFGHIJKLMNOP']
    inputs += [Path(__file__), root / 'build.py']
    plan = {'entries': entries, 'metadata': metadata(paths['icons'], converter), 'contract': contract,
            'curated': curated, 'bank': bank, 'root': root,
            'inputs': [{'path': str(p), 'sha256': digest(p)} for p in inputs]}
    for name, region in [('common', 'common_assets'), ('icons', 'icon_assets')]:
        start, end = contract['target'][region]
        if asset_bytes(entries[name]) > end-start:
            raise AssetError(f'{name}: sprite data exceeds its sideways bank allocation')
    header(plan)  # Check directory-page capacity during preflight too.
    return plan


def asset_bytes(entry):
    return sum(8 + len(s.mask) + len(s.pixels) for s in entry['sprites']) + 2*len(entry['sprites'])


def effective(entry, number):
    by_id = {s.number: s for s in entry['sprites']}
    return by_id[entry['canonical'].get(number, number)]


def class_bytes(entry):
    kinds = [KIND[effective(entry, s.number).kind] for s in entry['sprites']]
    return bytes(sum(kind << (2 * j) for j, kind in enumerate(kinds[i:i+4]))
                 for i in range(0, len(kinds), 4))


def header(plan):
    """Explicit byte layout; no valid MOS ROM header in the initial 16 bytes."""
    target = plan['contract']['target']
    base, _ = target['bank_window']
    data = bytearray(256)
    data[16:24] = b'IMS2' + bytes([FORMAT, 8, plan['bank'], 1])
    def word(offset, value):
        data[offset:offset+2] = value.to_bytes(2, 'little')
    common, icons = plan['entries']['common'], plan['entries']['icons']
    word(0x18, target['normal_shift_tables'][0]); word(0x1A, target['reflected_shift_tables'][0])
    word(0x1C, target['common_assets'][0] + asset_bytes(common) - 2 * len(common['sprites']))
    word(0x1E, target['icon_assets'][0] + asset_bytes(icons) - 2 * len(icons['sprites']))
    data[0x20:0x24] = bytes([0, len(common['sprites']), 1, len(icons['sprites'])])
    cursor = 0x38
    for name, offset in [('common', 0x24), ('icons', 0x26)]:
        entry = plan['entries'][name]
        values = bytes(entry['canonical'].get(s.number, s.number) for s in entry['sprites'])
        word(offset, base + cursor)
        data[cursor:cursor + len(values)] = values; cursor += len(values)
    for name, offset in [('common', 0x28), ('icons', 0x2A)]:
        values = class_bytes(plan['entries'][name]); word(offset, base + cursor)
        data[cursor:cursor + len(values)] = values; cursor += len(values)
    word(0x2C, base + cursor)
    data[cursor:cursor + 18] = plan['metadata']; cursor += 18
    word(0x2E, target['cache_slack'][0]); word(0x30, target['cache_slack'][1])
    word(0x32, target['developer_snapshots'][0])
    if cursor > 256 or len(data) != 256:
        raise AssetError('SWR directory metadata exceeds the header page')
    return data


def wrapper(plan, data):
    target = plan['contract']['target']
    lines = ['; Generated SWR bank image, format 2. Addresses are final runtime addresses.',
             'ORG &8000', '.swr_bank_start']
    lines += ['    EQUB ' + ', '.join(f'&{v:02X}' for v in data[i:i+16]) for i in range(0, 256, 16)]
    lines += ['.normal_translate_masks',
              'FOR swr_shift, -7, 7', '    FOR swr_byte, 0, 255',
              '        IF swr_shift < 0',
              '            EQUB (((swr_byte EOR 255) << -swr_shift) AND 255) EOR 255',
              '        ELSE', '            EQUB (((swr_byte EOR 255) >> swr_shift) AND 255) EOR 255',
              '        ENDIF', '    NEXT', 'NEXT', '.reflected_translate_masks',
              'FOR swr_shift, -7, 7', '    FOR swr_byte, 0, 255',
              '        swr_reversed = ((swr_byte AND 1) << 7) OR ((swr_byte AND 2) << 5) OR ((swr_byte AND 4) << 3) OR ((swr_byte AND 8) << 1) OR ((swr_byte AND 16) >> 1) OR ((swr_byte AND 32) >> 3) OR ((swr_byte AND 64) >> 5) OR ((swr_byte AND 128) >> 7)',
              '        IF swr_shift < 0',
              '            EQUB (((swr_reversed EOR 255) << -swr_shift) AND 255) EOR 255',
              '        ELSE', '            EQUB (((swr_reversed EOR 255) >> swr_shift) AND 255) EOR 255',
              '        ENDIF', '    NEXT', 'NEXT', 'ASSERT P% = &9F00',
              'INCLUDE "includes/common.asm"',
              f'ASSERT P% <= &{target["common_assets"][1]:04X}', f'SKIP &{target["common_assets"][1]:04X} - P%',
              'INCLUDE "includes/icons.asm"',
              f'ASSERT P% <= &{target["icon_assets"][1]:04X}', f'SKIP &{target["icon_assets"][1]:04X} - P%', '.swr_immutable_end',
              'SKIP &C000 - P%', '.swr_bank_end', 'ASSERT P% = &C000',
              'SAVE "swr_bank.bin", swr_bank_start, swr_bank_end', '']
    return '\n'.join(lines)


def assemble(assembler, directory, source, log_name, verbose):
    labels = directory / 'labels' / (log_name + '.labels')
    result = subprocess.run([assembler, '-i', source, '-labels', str(labels), '-dd'],
                            cwd=directory, capture_output=True, text=True)
    output = result.stdout + result.stderr
    (directory / 'logs' / (log_name + '.log')).write_text(output)
    if verbose or result.returncode:
        print(output, end='', file=sys.stderr if result.returncode else sys.stdout)
    if result.returncode:
        raise AssetError(f'SWR {source} assembly failed:\n{output}')
    return load_labels(labels)


def validate_records(binary, origin, labels, entry, directory):
    """Check actual assembled headers, absolute pointers, indices and planes."""
    prefix = entry['prefix']; start = labels['.' + prefix + '_data_start']
    end = labels['.' + prefix + '_data_end']; table = labels['.' + prefix + '_sprite_table']
    if start != origin or end - origin != len(binary):
        raise AssetError(f'{prefix}: assembled range does not match binary')
    def block(address, size):
        if not origin <= address <= end or address + size > end:
            raise AssetError(f'{prefix}: pointer outside asset bank')
        return binary[address-origin:address-origin+size]
    for index, sprite in enumerate(entry['sprites']):
        s = effective(entry, sprite.number)
        pointer = int.from_bytes(block(table + 2 * index, 2), 'little')
        expected = labels[f'.{prefix}_sprite_{s.number:02x}']
        # Alias labels are equates, so only the canonical emitted label is needed.
        if pointer != expected:
            raise AssetError(f'{prefix}: ID {sprite.number} has wrong record pointer')
        record = block(pointer, 8)
        if record[:4] != bytes([s.offset_x & 255, s.offset_y & 255, s.width, s.height]):
            raise AssetError(f'{prefix}: header mismatch for ID {sprite.number}')
        mask, pixels = int.from_bytes(record[4:6], 'little'), int.from_bytes(record[6:8], 'little')
        if s.width:
            if block(mask, len(s.mask)) != s.mask or block(pixels, len(s.pixels)) != s.pixels:
                raise AssetError(f'{prefix}: plane mismatch for ID {sprite.number}')
        elif mask or pixels:
            raise AssetError(f'{prefix}: empty/cache record contains source pointers')
    if directory:
        if block(table - 4, 4) != bytes([FORMAT, entry['sprites'][0].number, len(entry['sprites']), 8]):
            raise AssetError(f'{prefix}: invalid directory')
        kinds = bytes(KIND[effective(entry, s.number).kind] for s in entry['sprites'])
        ids = bytes(entry['canonical'].get(s.number, s.number) for s in entry['sprites'])
        if block(table + 2 * len(kinds), len(kinds)) != kinds or block(table + 3 * len(kinds), len(kinds)) != ids:
            raise AssetError(f'{prefix}: invalid class/canonical ID tables')
    return {'origin': origin, 'end_exclusive': end, 'table': table,
            'first_id': entry['sprites'][0].number, 'count': len(entry['sprites']),
            'bytes': len(binary), 'aliases': entry['canonical'],
            'classes': {s.number: KIND[effective(entry, s.number).kind] for s in entry['sprites']}}


def validate_shift_tables(image):
    """Check assembler output per destination bit, including one-filled padding."""
    for reflected, base in [(False, 0x8100), (True, 0x9000)]:
        for shift in range(-7, 8):
            for value in range(256):
                expected = 0
                for x in range(8):
                    source_x = x - shift
                    bit = 1 if not 0 <= source_x < 8 else (value >> (source_x if reflected else 7-source_x)) & 1
                    expected |= bit << (7-x)
                offset = base - 0x8000 + (shift + 7) * 256 + value
                if image[offset] != expected:
                    raise AssetError(f'Invalid shift table byte at &{offset + 0x8000:04X}')


def symbols(text):
    return {name: int(value[1:], 16) if value.startswith('&') else int(value)
            for name, value in re.findall(r'^(\w+)\s*=\s*(&[0-9a-fA-F]+|\d+)\s*(?:;.*)?$', text, re.M)}


def allocate_cache_planes(owners,level_end,contract):
    """Allocate both planes for each owner while protecting the overlay/screen."""
    aux_start,aux_end=contract['main_ram']['auxcode']
    if level_end>aux_start:raise AssetError('Converted level code/assets overlap AUXCODE')
    regions = [[level_end, aux_start, 'main-before-auxcode'],
               [aux_end, contract['main_ram']['screen_start'], 'main-after-auxcode'],
               [*contract['target']['cache_slack'], 'sideways-slack']]
    allocations = []
    planes = sorted([(o['capacity'], owner, plane) for owner,o in owners.items()
                     for plane in ['background', 'preserve_mask']], reverse=True)
    for size, owner, plane in planes:
        if not 0 <= owner < contract['cache']['registry_entries']:
            raise AssetError('Invalid cache owner')
        fitting = [(end-start, i) for i,(start,end,_) in enumerate(regions) if end-start >= size]
        if not fitting:
            raise AssetError('Cache planes exceed available memory')
        _, i = min(fitting); start, _, name = regions[i]
        allocations.append({'owner': owner, 'plane': plane, 'address': start, 'bytes': size, 'region': name})
        regions[i][0] += size
    return {'owners':owners,'planes':allocations,
            'cache_bytes':sum(2*o['capacity'] for o in owners.values()),
            'remaining_bytes':sum(end-start for start,end,_ in regions)}


def cache_layout(plan, code_sizes, sizes):
    common = plan['entries']['common']; contract = plan['contract']; result = {}
    def cap(entry, number):
        s = effective(entry, number)
        return ((s.width + 14) // 8) * s.height if s.width else 0
    common_max = max(cap(common, s.number) for s in common['sprites'])
    for letter in 'ABCDEFGHIJKLMNOP':
        entry = plan['entries'][letter]
        source = (plan['root'] / f'src/data{letter}.asm').read_text()
        names = symbols((plan['root'] / 'src/globals.asm').read_text()) | symbols(source)
        observed = set()
        source_lines = source.splitlines()
        for i, line in enumerate(source_lines):
            if re.search(r'\bsta\s+object_erase_type', line, re.I):
                previous = next((v.strip() for v in reversed(source_lines[max(0, i-7):i])
                                 if v.strip() and not v.lstrip().startswith(';')), '')
                match = re.match(r'lda\s+#(\w+|&[0-9a-f]+)', previous, re.I)
                if not match:
                    raise AssetError(f'Level {letter}: unresolved cache assignment at line {i+1}')
                value = match[1]
                cache_id = names[value] if value in names else int(value[1:], 16) if value.startswith('&') else int(value)
                if cache_id not in (0, 255):
                    observed.add(cache_id)
        if observed != {int(k) for k in plan['curated'][letter]}:
            raise AssetError(f'Level {letter}: cache assignments differ from the audited inventory')
        owners = {0: {'cache_ids': [199], 'capacity': max([common_max] + [cap(entry, i) for i in range(200, 206)] if letter == 'E' else [common_max])},
                  1: {'cache_ids': [198], 'capacity': max([common_max] + [cap(entry, s.number) for s in entry['sprites']])}}
        lines = source.splitlines()
        for i, line in enumerate(lines):
            if re.search(r'\b(jsr|jmp)\s+update_level_completion', line):
                for previous in reversed(lines[max(0, i-6):i]):
                    m = re.search(r'\blda\s+#(objectid_\w+|\d+|&[0-9a-f]+)', previous, re.I)
                    if m:
                        value = m[1]; owner = names[value] if value in names else int(value[1:], 16) if value.startswith('&') else int(value)
                        owners.setdefault(owner, {'cache_ids': [], 'capacity': 0})
                        owners[owner]['cache_ids'].append(197)
                        owners[owner]['capacity'] = max(owners[owner]['capacity'], max(cap(common, k) for k in [0,34,35,36,37,38]))
                        break
                else:
                    raise AssetError(f'Level {letter}: completion cache owner unresolved')
        for cache_id, family in plan['curated'][letter].items():
            size = max(cap(common if i < 200 else entry, i) for i in family['frames'])
            for owner in set(names['objectid_' + alias] for alias in family['owners']):
                o = owners.setdefault(owner, {'cache_ids': [], 'capacity': 0})
                o['cache_ids'] = sorted(set(o['cache_ids'] + [int(cache_id)]))
                o['capacity'] = max(o['capacity'], size)
        level_start = contract['main_ram']['maximum_new_level_start']
        level_end = level_start + code_sizes[letter] + sizes[letter]['bytes']
        aux_start, aux_end = contract['main_ram']['auxcode']
        if level_end > aux_start:
            raise AssetError(f'Level {letter}: converted code/assets overlap AUXCODE')
        allocation = allocate_cache_planes(owners,level_end,contract)
        result[letter] = {'level_start_budget': level_start, 'level_end_budget': level_end,
                          'legacy_code_bytes': code_sizes[letter], **allocation}
    return result


def generate(plan, assembler, code_sizes, output_dir, verbose=False):
    """Stage, assemble and verify the entire bundle before replacing its predecessor."""
    output_dir = Path(output_dir)
    output_dir.parent.mkdir(parents=True, exist_ok=True)
    for item in plan['inputs']:
        if digest(Path(item['path'])) != item['sha256']:
            raise AssetError(f'Asset input changed during build: {item["path"]}')
    with tempfile.TemporaryDirectory(dir=output_dir.parent, prefix='.swr-assets-') as temp:
        bundle = Path(temp) / 'bundle'; bundle.mkdir()
        for directory in ['includes', 'levels', 'labels', 'logs']:
            (bundle / directory).mkdir()
        for name, entry in plan['entries'].items():
            (bundle / 'includes' / (entry['prefix'] + '.asm')).write_text(entry['include'])
        data = header(plan); source = bundle / 'swr_bank.asm'; source.write_text(wrapper(plan, data))
        labels = assemble(assembler, bundle, 'swr_bank.asm', 'swr_bank', verbose)
        image = bytearray((bundle / 'swr_bank.bin').read_bytes())
        if len(image) != 16384 or image[:256] != data:
            raise AssetError('Assembler did not produce a valid 16 KiB SWR image/header')
        sizes = {}
        for name, region in [('common', 'common_assets'), ('icons', 'icon_assets')]:
            start, end = plan['contract']['target'][region]
            actual_end = labels['.' + plan['entries'][name]['prefix'] + '_data_end']
            if actual_end > end or any(image[actual_end-0x8000:end-0x8000]):
                raise AssetError(f'{name}: invalid padding/allocation boundary')
            sizes[name] = validate_records(bytes(image[start-0x8000:actual_end-0x8000]), start, labels, plan['entries'][name], False)
        for name, region in [('normal_translate_masks', 'normal_shift_tables'), ('reflected_translate_masks', 'reflected_shift_tables')]:
            if labels['.' + name] != plan['contract']['target'][region][0]:
                raise AssetError('Shift tables are not at the contracted page boundaries')
        validate_shift_tables(image)
        immutable = plan['contract']['target']['cache_slack'][0] - 0x8000
        if any(image[immutable:]):
            raise AssetError('Cache/snapshot regions must be zero in the initial bank image')
        checksum = zlib.crc32(image[:immutable])
        image[CRC_OFFSET:CRC_OFFSET+4] = checksum.to_bytes(4, 'little')
        data[CRC_OFFSET:CRC_OFFSET+4] = checksum.to_bytes(4, 'little')
        source.write_text(wrapper(plan, data))
        (bundle / 'swr_bank.bin').write_bytes(image)
        for letter in 'ABCDEFGHIJKLMNOP':
            entry = plan['entries'][letter]; prefix = entry['prefix']
            origin = plan['contract']['main_ram']['maximum_new_level_start'] + code_sizes[letter]
            wrapper_path = 'levels/' + prefix + '.asm'
            (bundle / wrapper_path).write_text(f'ORG &{origin:04X}\nINCLUDE "includes/{prefix}.asm"\n'
                f'ASSERT {prefix}_data_end <= &{plan["contract"]["main_ram"]["auxcode"][0]:04X}\n'
                f'SAVE "levels/{prefix}.bin", {prefix}_data_start, {prefix}_data_end\n')
            sy = assemble(assembler, bundle, wrapper_path, prefix, verbose)
            binary = (bundle / 'levels' / (prefix + '.bin')).read_bytes()
            sizes[letter] = validate_records(binary, origin, sy, entry, True)
        caches = cache_layout(plan, code_sizes, sizes)
        exports = {'swr_format_version': FORMAT, 'swr_asset_bank': plan['bank'],
                   'swr_bank_start': 0x8000, 'swr_bank_bytes': len(image), 'swr_header_crc32': 0x8000 + CRC_OFFSET,
                   'swr_immutable_end': 0x8000 + immutable, 'swr_kind_empty': 0, 'swr_kind_drawable': 1, 'swr_kind_cache': 2,
                   'swr_normal_translate_masks': 0x8100, 'swr_reflected_translate_masks': 0x9000,
                   'swr_common_table': sizes['common']['table'], 'swr_icon_table': sizes['icons']['table'],
                   'swr_common_first_id': 0, 'swr_common_count': sizes['common']['count'],
                   'swr_icon_first_id': 1, 'swr_icon_count': sizes['icons']['count'],
                   'swr_common_canonical_ids': int.from_bytes(data[0x24:0x26], 'little'),
                   'swr_icon_canonical_ids': int.from_bytes(data[0x26:0x28], 'little'),
                   'swr_common_kinds': int.from_bytes(data[0x28:0x2A], 'little'),
                   'swr_icon_kinds': int.from_bytes(data[0x2A:0x2C], 'little'),
                   'swr_metadata': int.from_bytes(data[0x2C:0x2E], 'little'),
                   'swr_cache_start': plan['contract']['target']['cache_slack'][0],
                   'swr_cache_end': plan['contract']['target']['cache_slack'][1]}
        exports.update({'swr_cache_field_' + field['name']: field['offset']
                        for field in plan['contract']['cache']['descriptor_fields']})
        exports.update({'swr_zp_' + name: value for name,value in plan['contract']['renderer_zero_page'].items()})
        exports.update({'swr_cache_registry': plan['contract']['main_ram']['cache_registry'][0],
                        'swr_cache_descriptor_bytes': plan['contract']['cache']['descriptor_bytes'],
                        'swr_cache_registry_entries': plan['contract']['cache']['registry_entries'],
                        'swr_maximum_height': plan['contract']['assets']['maximum_height']})
        (bundle / 'bank_exports.asm').write_text('; Generated SWR bank layout; do not edit.\n' + ''.join(f'{k} = &{v:04X}\n' for k,v in exports.items()))
        (bundle / 'cache_layout.json').write_text(json.dumps(caches, sort_keys=True, indent=2) + '\n')
        files = {str(p.relative_to(bundle)): {'bytes': p.stat().st_size, 'sha256': digest(p)}
                 for p in sorted(bundle.rglob('*')) if p.is_file()}
        report = {'format': FORMAT, 'bank_bytes': len(image), 'bank_crc32': checksum,
                  'immutable_bytes': immutable, 'inputs': plan['inputs'], 'assets': sizes,
                  'exports': exports, 'minimum_remaining_bytes': min(l['remaining_bytes'] for l in caches.values()),
                  'files': files}
        (bundle / 'manifest.json').write_text(json.dumps(report, sort_keys=True, indent=2) + '\n')
        for item in plan['inputs']:
            if digest(Path(item['path'])) != item['sha256']:
                raise AssetError(f'Asset input changed during assembly: {item["path"]}')
        previous = Path(temp) / 'previous'
        if output_dir.exists():
            if not output_dir.is_dir() or not (output_dir / 'manifest.json').is_file():
                raise AssetError(f'Refusing to replace an unrecognised output directory: {output_dir}')
            output_dir.rename(previous)
        try:
            bundle.rename(output_dir)
        except OSError:
            if previous.exists():
                previous.rename(output_dir)
            raise
    return report
