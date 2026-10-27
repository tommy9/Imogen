"""Live engine, level-owned cache binding and full-game layout validation."""
import hashlib
import json
from pathlib import Path
import subprocess
from tools import sprite_assets

# Fixed code length is measured by assembly before allocation; all pointer words
# and descriptor capacities have fixed width, so filling final addresses is stable.
RUNTIME='''; Generated level-owned cache binding; called on every room entry.
.swr_level_initialise
    PHA: TXA: PHA: TYA: PHA
    LDA #LO(levelA_sprite_table): STA &0BEF
    LDA #HI(levelA_sprite_table): STA &0BF0
    LDA #0: STA &0BEE
    LDY #0
.swr_level_cache_copy
    LDA swr_level_cache_template,Y
    STA &0B11,Y
    INY
    CPY #220
    BNE swr_level_cache_copy
    ; Relocate the bank tag in sideways cache descriptors after template copy.
    LDY #3
.swr_level_bank_tags
    LDA &0B11,Y
    CMP #255
    BEQ swr_level_next_tag
    LDA swr_live_bank_address: STA &0B11,Y
.swr_level_next_tag
    TYA: CLC: ADC #20: TAY
    CPY #223
    BNE swr_level_bank_tags
    PLA: TAY: PLA: TAX: PLA
    RTS
.swr_level_cache_template
'''


def template(layout,bank):
    data=bytearray(220)
    for owner in range(11):
        d=owner*20;data[d+1]=owner;data[d+3]=255
        if str(owner) not in layout['owners']:continue
        data[d+16:d+18]=layout['owners'][str(owner)]['capacity'].to_bytes(2,'little')
        for plane in layout['planes']:
            if plane['owner']!=owner:continue
            offset=12 if plane['plane']=='background' else 14
            data[d+offset:d+offset+2]=plane['address'].to_bytes(2,'little')
            if plane['region']=='sideways-slack':data[d+3]=bank
    return data


def runtime_source(data,letter='A'):
    return RUNTIME.replace('levelA_sprite_table',f'level{letter}_sprite_table')+'\n'.join('EQUB '+','.join(f'&{v:02X}' for v in data[i:i+16])
                            for i in range(0,len(data),16))+'\n'


def measure_runtime(assembler,root):
    output=root/'build/runtime';output.mkdir(exist_ok=True)
    (output/'levelA_runtime.asm').write_text(runtime_source(bytes(220)))
    probe=output/'runtime_size.asm'
    probe.write_text('ORG &4000\nlevelA_sprite_table = &5000\nswr_live_bank_address = &1400\n.start\n'
                     'INCLUDE "build/runtime/levelA_runtime.asm"\n.end\n')
    result=subprocess.run([assembler,'-i',str(probe),'-labels',str(output/'runtime_size.labels'),'-dd'],
                          cwd=root,capture_output=True,text=True)
    if result.returncode:raise sprite_assets.AssetError(result.stdout+result.stderr)
    labels=sprite_assets.load_labels(output/'runtime_size.labels')
    return labels['.end']-labels['.start']


def prepare_runtime(root,bank):
    layouts=json.loads((root/'build/swr_assets/cache_layout.json').read_text())
    for letter,layout in layouts.items():
        (root/f'build/runtime/level{letter}_runtime.asm').write_text(runtime_source(template(layout,bank),letter))


def label(labels,name):
    found=[v for k,v in labels.items() if k.endswith('.'+name)]
    if len(found)!=1:raise sprite_assets.AssetError(f'Expected one {name} label')
    return found[0]


def validate(root,bank,plan=None):
    engine=sprite_assets.load_labels(root/'build/labels/g.labels')
    contract=json.loads((root/'config/contract.json').read_text())
    layouts=json.loads((root/'build/swr_assets/cache_layout.json').read_text())
    start=engine['.level_data']
    if start>contract['main_ram']['maximum_new_level_start']:
        raise sprite_assets.AssetError(f"Live SWR engine exceeds &{contract['main_ram']['maximum_new_level_start']:04X} resident limit")
    aux=sprite_assets.load_labels(root/'build/labels/auxcode.labels')
    if aux['.pydis_start']!=0x53C0 or aux['.pydis_end']>0x578B:
        raise sprite_assets.AssetError('AUXCODE exceeds its reserved memory range')
    if len((root/'build/auxcode').read_bytes())!=aux['.pydis_end']-aux['.pydis_start']:
        raise sprite_assets.AssetError('AUXCODE binary has the wrong length')
    levels={}
    for letter in 'ABCDEFGHIJKLMNOPQ':
        sy=sprite_assets.load_labels(root/f'build/labels/data{letter}.labels')
        end=label(sy,'levelE_end' if letter=='E' else 'pydis_end')
        if label(sy,'level_data')!=start or end>0x53C0:
            raise sprite_assets.AssetError(f'Converted level {letter} overlaps AUXCODE')
        binary=(root/f'build/data{letter}').read_bytes()
        if len(binary)!=end-start:
            raise sprite_assets.AssetError(f'Level {letter} binary has the wrong length')
        levels[letter]={'start':start,'end':end,'bytes':len(binary)}
        if letter=='Q':continue # Direct bitmap/text epilogue, no sprite directory.
        layout=layouts[letter]
        if int.from_bytes(binary[:2],'little')!=label(sy,f'level{letter}_sprite_table')-start:
            raise sprite_assets.AssetError(f'Level {letter} header does not point to format-2 table')
        offset=label(sy,'swr_level_cache_template')-start
        if binary[offset:offset+220]!=template(layout,bank):
            raise sprite_assets.AssetError(f'Level {letter} cache bindings disagree with allocated storage')
        if plan:
            prefix=f'level{letter}_'
            normalized={'.'+k.split('.')[-1]:v for k,v in sy.items() if k.split('.')[-1].startswith(prefix)}
            origin=label(sy,f'level{letter}_data_start')
            sprite_assets.validate_records(binary[origin-start:],origin,normalized,plan['entries'][letter],True)
        for plane in layout['planes']:
            if plane['region']=='main-before-auxcode' and end>plane['address']:
                raise sprite_assets.AssetError(f'Level {letter} overlaps its saved cache planes')
            if plane['region']=='main-after-auxcode' and plane['address']<0x578B:
                raise sprite_assets.AssetError(f'AUXCODE overlaps a level {letter} saved cache plane')
    names=['src/g.asm','src/swr_sprite_adapter.asm','src/swr_renderer_core.asm','src/swr_frame_alignment.asm',
           'build/swr_boot_config.asm','build/engine_exports.asm','tools/swr_game_build.py','build.py',
           'build/swr_assets/bank_exports.asm','build/g','build/auxcode']
    names += [f'src/data{c}.asm' for c in 'ABCDEFGHIJKLMNOPQ']
    names += [f'build/data{c}' for c in 'ABCDEFGHIJKLMNOPQ']
    names += [f'build/runtime/level{c}_runtime.asm' for c in layouts]
    report={'live_renderer':True,'converted_levels':list(levels),'levels':levels,'level_start':start,
            'frame_alignment':sprite_assets.symbols((root/'build/swr_boot_config.asm').read_text()).get('swr_frame_alignment_enabled',0),
            'frame_alignment_phase':sprite_assets.symbols((root/'build/swr_boot_config.asm').read_text()).get('swr_frame_alignment_phase',192),
            'resident_growth_bytes':start-contract['main_ram']['legacy_level_start'],
            'resident_budget_remaining':contract['main_ram']['maximum_new_level_start']-start,
            'AUXCODE_reserved':[0x53C0,0x578B],'cache_layout':layouts,'bank':bank,
            'inputs':{name:hashlib.sha256((root/name).read_bytes()).hexdigest() for name in names}}
    (root/'build/runtime/report.json').write_text(json.dumps(report,indent=2)+'\n')
    return report
